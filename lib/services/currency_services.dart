import 'dart:convert';
import 'package:currencyconv/model/currency_model.dart';
import 'package:http/http.dart' as http;

class CurrencyServices {
  final String apiKey = "ff57af7bf3161ce7f2c8f81f";

  Future<List<CurrencyModel>> fetchAllCurrencies() async {
    final url = "https://v6.exchangerate-api.com/v6/$apiKey/codes";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<CurrencyModel> currencies = [];

      if (data['result'] == 'success') {
        final List<dynamic> supportedCodes = data['supported_codes'];
        for (var codeData in supportedCodes) {
          currencies.add(CurrencyModel(code: codeData[0], name: codeData[1]));
        }
      }
      return currencies;
    } else {
      throw Exception('Failed to fetch currency codes ${response.statusCode}');
    }
  }

  Future<Map<String, double>> fetchRates(String baseCurrency) async {
    final url = "https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['result'] == 'success') {
        final rawRates = data['conversion_rates'] as Map<String, dynamic>;
        final Map<String, double> rates = {};
        rawRates.forEach((key, value) {
          rates[key] = value is int ? value.toDouble() : value;
        });
        return rates;
      } else {
        throw Exception('Api returned error ${data['error']}');
      }
    } else {
      throw Exception('Failed to fetch exchange rates ${response.statusCode}');
    }
  }
}
