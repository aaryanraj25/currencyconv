# Currency Converter App

A feature-rich Flutter currency converter application with offline support, dark/light mode, and conversion history tracking.

## Features

- 🔄 Real-time currency conversion
- 💾 Offline mode with cached rates
- 🌓 Dark/Light theme toggle
- 📊 Conversion history tracking
- 🔍 Searchable currency selection
- 📱 Responsive UI with animations

## Setup Instructions

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/aaryanraj25/currencyconv.git
   cd currencyconv
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```


## Used Packages

- `get` - State management
- `connectivity_plus` - Network connectivity detection
- `shared_preferences` - Local data storage
- `intl` - Internationalization and formatting
- `flutter_animate` - UI animations

## API Used

The application uses the [ExchangeRate-API](https://www.exchangerate-api.com/) for currency conversion data:

```dart
// API endpoints used
final String _baseUrl = 'https://v6.exchangerate-api.com/v6/';
final String _apiKey = 'YOUR_API_KEY'; // Replace with your API key

// To fetch all currencies
Future<List<CurrencyModel>> fetchAllCurrencies() async {
  final url = '$_baseUrl$_apiKey/codes';
  final response = await http.get(Uri.parse(url));
  
  // Process response...
  // Returns List<CurrencyModel>
}

// To fetch rates for specific base currency
Future<Map<String, double>> fetchRates(String baseCurrency) async {
  final url = '$_baseUrl$_apiKey/latest/$baseCurrency';
  final response = await http.get(Uri.parse(url));
  
  // Process response...
  // Returns Map<String, double> with currency codes and rates
}
```

The free plan includes:
- 1,500 API calls per month
- Hourly rate updates
- 161 currencies supported
- HTTPS encryption
- JSON format response

## Challenges & Solutions

```
// 1. Rate Limiting
CHALLENGE: API free tier limits (1,500 calls/month)
SOLUTION:
```
```dart
// Cache data with shared_preferences
Future<void> saveCacheData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('cached_rates', jsonEncode(rates));
  prefs.setString('last_updated', DateTime.now().toIso8601String());
}
```

```
// 2. Offline Support
CHALLENGE: App must function without internet
SOLUTION:
```
```dart
// Check connectivity before API calls
final connectivityResult = await Connectivity().checkConnectivity();
final bool isConnected = connectivityResult != ConnectivityResult.none;

if (!isConnected) {
  // Use cached data instead
  if (rates.isNotEmpty) {
    convert();
    isLoading.value = false;
    return;
  } 
}
```

```
// 3. Currency Search UX
CHALLENGE: 161 currencies hard to browse in dropdown
SOLUTION:
```
```dart
// Custom search delegate
showSearch<String?>(
  context: context,
  delegate: CurrencySearchDelegate(
    currencies: controller.currencies,
    selectedValue: value,
    isDarkMode: Theme.of(context).brightness == Brightness.dark,
  ),
);
```

```
// 4. Theme Consistency
CHALLENGE: Maintaining UI in both dark/light modes
SOLUTION:
```
```dart
// Reactive theme toggle
void toggleThemeMode() {
  isDarkMode.value = !isDarkMode.value;
  saveThemePreference();
  Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
}
```

## Acknowledgments

- Currency data provided by [ExchangeRate-API](https://www.exchangerate-api.com/)
