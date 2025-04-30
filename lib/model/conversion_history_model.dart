class ConversionHistoryModel {
  final double amount;
  final double result;
  final String fromCurrency;
  final String toCurrency;
  final DateTime timestamp;

  ConversionHistoryModel({
    required this.amount,
    required this.result,
    required this.fromCurrency, 
    required this.toCurrency,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'result': result,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  factory ConversionHistoryModel.fromJson(Map<String, dynamic> json) {
    return ConversionHistoryModel(
      amount: json['amount'],
      result: json['result'],
      fromCurrency: json['fromCurrency'],
      toCurrency: json['toCurrency'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}