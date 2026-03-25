import 'package:intl/intl.dart';

class AppHelpers {
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  static String formatDateShort(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    if (amount == amount.truncateToDouble()) {
      return '₹${amount.toInt()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  static DateTime getNextDeliveryDate(String schedule) {
    final now = DateTime.now();
    int targetDay;
    if (schedule.toUpperCase() == 'SATURDAY') {
      targetDay = DateTime.saturday;
    } else {
      targetDay = DateTime.sunday;
    }
    int daysUntil = targetDay - now.weekday;
    if (daysUntil <= 0) daysUntil += 7;
    return now.add(Duration(days: daysUntil));
  }

  static String getDeliveryScheduleText(String? schedule) {
    if (schedule == null || schedule.isEmpty) return '';
    return '${schedule[0]}${schedule.substring(1).toLowerCase()} Delivery';
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length != 10) return 'Phone number must be 10 digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Invalid phone number';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName, {int minLength = 1}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
}
