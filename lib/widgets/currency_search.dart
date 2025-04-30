import 'package:currencyconv/model/currency_model.dart';
import 'package:flutter/material.dart';

class CurrencySearchDelegate extends SearchDelegate<String?> {
  final List<CurrencyModel> currencies;
  final String selectedValue;
  final bool isDarkMode;

  CurrencySearchDelegate({
    required this.currencies,
    required this.selectedValue,
    required this.isDarkMode,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 18,
        ),
      ),
      scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Return null when back button is pressed
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredCurrencies = currencies.where((currency) {
      final lowerQuery = query.toLowerCase();
      return currency.code.toLowerCase().contains(lowerQuery) ||
          currency.name.toLowerCase().contains(lowerQuery);
    }).toList();

    return ListView.builder(
      itemCount: filteredCurrencies.length,
      itemBuilder: (context, index) {
        final currency = filteredCurrencies[index];
        final isSelected = currency.code == selectedValue;

        return ListTile(
          title: Text(
            "${currency.code} - ${currency.name}",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          tileColor: isSelected
              ? (isDarkMode
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1))
              : null,
          onTap: () {
            close(context, currency.code);
          },
        );
      },
    );
  }
}
