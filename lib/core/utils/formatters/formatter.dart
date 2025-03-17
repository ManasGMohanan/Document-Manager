import 'package:intl/intl.dart';

class DMFormatter {
  static String formatDate(DateTime? date) {
    if (date == null) {
      return ''; // Return empty string if date is null // issue solved
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  static bool isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate);
  }

  static bool isExpiringSoon(DateTime? date) {
    if (date == null) return false;
    final daysUntilExpiry = date.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry < 30;
  }

  static int daysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return -1;
    return expiryDate.difference(DateTime.now()).inDays;
  }
}
