import 'package:intl/intl.dart';

class Formatters {
  static String currency(num amount) {
    if (amount <= 0) return 'FREE';
    final formatter = NumberFormat('#,##0', 'en_US');
    return 'LKR ${formatter.format(amount)}';
  }

  static String compactCurrency(num amount) {
    if (amount <= 0) return 'FREE';
    if (amount >= 1000) {
      double val = amount / 1000.0;
      String formatted = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
      return '${formatted}K';
    }
    return amount.toInt().toString();
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
