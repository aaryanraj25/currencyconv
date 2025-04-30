import 'package:currencyconv/controller/currency_controller.dart';
import 'package:currencyconv/model/currency_model.dart';
import 'package:currencyconv/widgets/currency_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CurrencyView extends StatelessWidget {
  final CurrencyController controller = Get.find();
  final TextEditingController amountController =
      TextEditingController(text: "1.0");
  final TextEditingController searchController = TextEditingController();
  final _dropdownAnimationDuration = 300.ms;

  CurrencyView() {
    amountController.text = controller.amount.value.toString();
    ever(controller.amount, (value) {
      if (amountController.text != value.toString()) {
        amountController.text = value.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        forceMaterialTransparency: true,
        title: Text(
          'Currency Converter',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: () => controller.fetchCurrencies(),
          ),
          Obx(() => IconButton(
                icon: Icon(
                    controller.isDarkMode.value
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => controller.toggleThemeMode(),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading currency data...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                )
              ],
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchCurrencies(),
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              ],
            ),
          );
        }

        if (controller.currencies.isEmpty) {
          return Center(
            child: Text(
              'No currencies available',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          );
        }

        return _buildMainContent(context);
      }),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultCard(context),
            SizedBox(height: 24),
            _buildInputCard(context),
            SizedBox(height: 16),
            _buildExchangeRateInfo(context),
            if (controller.lastUpdated.value
                    .difference(DateTime.now())
                    .inHours
                    .abs() >
                1)
              _buildOfflineIndicator(context),
            SizedBox(height: 24),
            _buildHistorySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    List<Color> gradientColors = Theme.of(context).brightness == Brightness.dark
        ? [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ]
        : [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Converted Amount',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                formatter.format(controller.result.value),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                controller.toCurrency.value,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${formatter.format(controller.amount.value)} ${controller.fromCurrency.value}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${formatter.format(controller.result.value)} ${controller.toCurrency.value}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.money,
                  color: Theme.of(context).colorScheme.primary,
                ),
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter amount',
                hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                ),
                suffixText: controller.fromCurrency.value,
                suffixStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              onChanged: (value) {
                controller.setAmount(value);
              },
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildSearchableCurrencyDropdown(
                        context,
                        value: controller.fromCurrency.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.fromCurrency.value = value;
                            controller.fetchRates(value);
                          }
                        },
                      )
                          .animate()
                          .fadeIn(duration: _dropdownAnimationDuration)
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: _dropdownAnimationDuration),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.swap_horiz,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: controller.swapCurrencies,
                      tooltip: 'Swap currencies',
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildSearchableCurrencyDropdown(
                        context,
                        value: controller.toCurrency.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.toCurrency.value = value;
                            controller.convert();
                          }
                        },
                      )
                          .animate()
                          .fadeIn(duration: _dropdownAnimationDuration)
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: _dropdownAnimationDuration),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isButtonLoading.value
                        ? null
                        : () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            controller.convertWithLoadingState();
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: controller.isButtonLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withOpacity(0.7),
                                ),
                              ),
                            )
                          : Text(
                              'Convert',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableCurrencyDropdown(
    BuildContext context, {
    required String value,
    required void Function(String?)? onChanged,
  }) {
    final selectedCurrency = controller.currencies.firstWhere(
      (c) => c.code == value,
      orElse: () => controller.currencies.isNotEmpty
          ? controller.currencies.first
          : CurrencyModel(code: value, name: value),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () async {
          final selectedValue = await showSearch<String?>(
            context: Get.context!,
            delegate: CurrencySearchDelegate(
              currencies: controller.currencies,
              selectedValue: value,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
          );
          if (selectedValue != null && onChanged != null) {
            onChanged(selectedValue);
          }
        },
        child: Container(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${selectedCurrency.code} - ${selectedCurrency.name}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    delay: NumDurationExtensions(3).seconds,
                    duration: NumDurationExtensions(1).seconds,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeRateInfo(BuildContext context) {
    if (controller.rates.isEmpty) {
      return SizedBox.shrink();
    }

    double exchangeRate = controller.rates[controller.toCurrency.value] ?? 1.0;
    final formatter = NumberFormat("#,##0.00000", "en_US");

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exchange Rate',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    '1 ${controller.fromCurrency.value} = ${formatter.format(exchangeRate)} ${controller.toCurrency.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _getLastUpdatedText(),
              style: TextStyle(
                fontSize: 12,
                color: _getLastUpdatedColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    final Color backgroundColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.amber[900]!.withOpacity(0.3)
            : Colors.amber[50]!;
    final Color borderColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.amber[700]!
        : Colors.amber[300]!;
    final Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.amber[100]!
        : Colors.amber[900]!;

    return Card(
      margin: EdgeInsets.only(top: 12),
      color: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.signal_wifi_off, color: textColor, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'You\'re using cached rates from ${DateFormat('MMM d, y HH:mm').format(controller.lastUpdated.value)}',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Conversions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            if (controller.conversionHistory.isNotEmpty)
              TextButton.icon(
                onPressed: controller.clearHistory,
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                ),
                label: Text(
                  'Clear',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        controller.conversionHistory.isEmpty
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Theme.of(context).disabledColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No conversion history yet',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.conversionHistory.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(
                    context,
                    controller.conversionHistory[index],
                    index,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildHistoryItem(context, history, index) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    final dateFormatter = DateFormat('MMM d, y HH:mm');

    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          controller.loadPastConversion(history);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${formatter.format(history.amount)} ${history.fromCurrency} → ${formatter.format(history.result)} ${history.toCurrency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                dateFormatter.format(history.timestamp),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  String _getLastUpdatedText() {
    final now = DateTime.now();
    final difference = now.difference(controller.lastUpdated.value);

    if (difference.inMinutes < 5) {
      return 'Updated Just Now';
    } else if (difference.inHours < 1) {
      return 'Updated ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Updated ${difference.inHours} hr ago';
    } else {
      return 'Updated ${DateFormat('MMM d').format(controller.lastUpdated.value)}';
    }
  }
  Color _getLastUpdatedColor() {
    final difference = DateTime.now().difference(controller.lastUpdated.value);

    if (difference.inHours < 1) {
      return Colors.green[700]!;
    } else if (difference.inHours < 24) {
      return Colors.amber[700]!;
    } else {
      return Colors.red[700]!;
    }
  }
}

