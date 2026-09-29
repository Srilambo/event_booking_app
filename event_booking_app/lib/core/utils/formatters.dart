import 'package:intl/intl.dart';

class Formatters {
  static String currency(num amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateRange(DateTime start, DateTime end) {
    final startFormatted = DateFormat('MMM d').format(start);
    final endFormatted = DateFormat('MMM d, yyyy').format(end);
    return '$startFormatted - $endFormatted';
  }
}
