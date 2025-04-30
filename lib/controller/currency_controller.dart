import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currencyconv/model/conversion_history_model.dart';
import 'package:currencyconv/model/currency_model.dart';
import 'package:currencyconv/services/currency_services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


class CurrencyController extends GetxController {
  final CurrencyServices _service = CurrencyServices();

  var currencies = <CurrencyModel>[].obs;
  var rates = <String, double>{}.obs;

  var fromCurrency = 'INR'.obs;
  var toCurrency = 'EUR'.obs;
  var amount = 1.0.obs;
  var result = 0.0.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var conversionHistory = <ConversionHistoryModel>[].obs;
  var showHistory = false.obs;
  var lastUpdated = DateTime.now().obs;
  
  // Theme mode state
  var isDarkMode = false.obs;
  var isButtonLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedData();
    fetchCurrencies();
    loadConversionHistory();
    loadThemePreference();
  }
  
  Future<void> loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCurrencies = prefs.getString('cached_currencies');
    if (cachedCurrencies != null) {
      final List<dynamic> decoded = jsonDecode(cachedCurrencies);
      currencies.value = decoded
          .map((item) => CurrencyModel(code: item['code'], name: item['name']))
          .toList();
    }
    
    final cachedRates = prefs.getString('cached_rates');
    if (cachedRates != null) {
      final Map<String, dynamic> decoded = jsonDecode(cachedRates);
      final Map<String, double> parsedRates = {};
      decoded.forEach((key, value) {
        parsedRates[key] = value is int ? value.toDouble() : value;
      });
      rates.value = parsedRates;
    }
    
    fromCurrency.value = prefs.getString('from_currency') ?? 'INR';
    toCurrency.value = prefs.getString('to_currency') ?? 'EUR';
    
    // Load last updated timestamp
    final lastUpdatedStr = prefs.getString('last_updated');
    if (lastUpdatedStr != null) {
      lastUpdated.value = DateTime.parse(lastUpdatedStr);
    }
  }
  
  // Load theme preference
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
    _applyTheme();
  }
  
  // Save theme preference
  Future<void> saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_dark_mode', isDarkMode.value);
  }
  
  // Toggle theme mode
  void toggleThemeMode() {
    isDarkMode.value = !isDarkMode.value;
    saveThemePreference();
    _applyTheme();
  }
  
  // Apply theme to GetX
  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  Future<void> saveCacheData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> currenciesJson = 
        currencies.map((currency) => {'code': currency.code, 'name': currency.name}).toList();
    prefs.setString('cached_currencies', jsonEncode(currenciesJson));
    prefs.setString('cached_rates', jsonEncode(rates));
    prefs.setString('from_currency', fromCurrency.value);
    prefs.setString('to_currency', toCurrency.value);

    lastUpdated.value = DateTime.now();
    prefs.setString('last_updated', lastUpdated.value.toIso8601String());
  }

  Future<void> fetchCurrencies() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isConnected = connectivityResult != ConnectivityResult.none;
    
    if (!isConnected) {
      if (currencies.isNotEmpty) {
        isLoading.value = false;
        return;
      } else {
        hasError.value = true;
        errorMessage.value = 'No internet connection. Please check your connection and try again.';
        isLoading.value = false;
        return;
      }
    }
    
    try {
      final data = await _service.fetchAllCurrencies();
      if (data.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'No currencies found';
      } else {
        currencies.value = data;
        if (!currencies.any((c) => c.code == fromCurrency.value)) {
          fromCurrency.value = currencies.first.code;
        }
        if (!currencies.any((c) => c.code == toCurrency.value)) {
          toCurrency.value = currencies.length > 1 ? currencies[1].code : currencies.first.code;
        }
        await fetchRates(fromCurrency.value);
        saveCacheData();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to fetch currencies: $e';
      print('Error fetching currencies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRates(String baseCurrency) async {
    isLoading.value = true;
    hasError.value = false;
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isConnected = connectivityResult != ConnectivityResult.none;
    
    if (!isConnected) {
      if (rates.isNotEmpty) {
        convert();
        isLoading.value = false;
        return;
      } else {
        hasError.value = true;
        errorMessage.value = 'No internet connection. Please check your connection and try again.';
        isLoading.value = false;
        return;
      }
    }
    
    try {
      final data = await _service.fetchRates(baseCurrency);
      if (data.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'No rates found for $baseCurrency';
      } else {
        rates.value = data;
        convert();
        saveCacheData();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to fetch rates: $e';
      print('Error fetching rates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void convert() {
    if (rates.isEmpty) {
      result.value = 0.0;
      return;
    }
    double fromRate = (rates[fromCurrency.value] ?? 1.0).toDouble();
    double toRate = (rates[toCurrency.value] ?? 1.0).toDouble();
    result.value = (amount.value * toRate) / fromRate;
  }
  
  // Convert with loading state for button animation
  Future<void> convertWithLoadingState() async {
    isButtonLoading.value = true;
    convert();
    await Future.delayed(Duration(milliseconds: 500)); // Small delay for better UX
    saveToHistory();
    isButtonLoading.value = false;
  }

  void saveToHistory() {
    final historyItem = ConversionHistoryModel(
      amount: amount.value,
      result: result.value,
      fromCurrency: fromCurrency.value,
      toCurrency: toCurrency.value,
      timestamp: DateTime.now(),
    );
    
    conversionHistory.insert(0, historyItem);
    if (conversionHistory.length > 5) {
      conversionHistory.removeRange(5, conversionHistory.length);
    }
    saveConversionHistory();
  }
  
  Future<void> saveConversionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> historyJson = 
        conversionHistory.map((item) => item.toJson()).toList();
    prefs.setString('conversion_history', jsonEncode(historyJson));
  }
  
  Future<void> loadConversionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('conversion_history');
    
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      conversionHistory.value = decoded
          .map((item) => ConversionHistoryModel.fromJson(item))
          .toList();
    }
  }
  
  // Clear conversion history
  void clearHistory() {
    conversionHistory.clear();
    saveConversionHistory();
  }

  void swapCurrencies() {
    var temp = fromCurrency.value;
    fromCurrency.value = toCurrency.value;
    toCurrency.value = temp;

    fetchRates(fromCurrency.value); 
  }

  void setAmount(String value) {
    final parsedValue = double.tryParse(value);
    if (parsedValue != null) {
      amount.value = parsedValue;
      convert();
    }
  }
  
  void toggleHistory() {
    showHistory.value = !showHistory.value;
  }
  
  void loadPastConversion(ConversionHistoryModel history) {
    fromCurrency.value = history.fromCurrency;
    toCurrency.value = history.toCurrency;
    amount.value = history.amount;
    result.value = history.result;
  }
}