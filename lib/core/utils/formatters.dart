import 'package:intl/intl.dart';

/// Formatting utilities for currency, dates, etc.
class Formatters {
  Formatters._();

  /// Format as currency (e.g., $29.99)
  static String currency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format as compact currency (e.g., $1.2K)
  static String compactCurrency(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount, symbol: symbol);
  }

  /// Format date (e.g., Feb 21, 2026)
  static String date(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Format date with time (e.g., Feb 21, 2026 at 3:30 PM)
  static String dateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);
  }

  /// Format relative time (e.g., 2 hours ago)
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return date(dateTime);
    }
  }

  /// Format number with commas (e.g., 1,234,567)
  static String number(num value) {
    return NumberFormat('#,##0').format(value);
  }

  /// Format star rating (e.g., 4.5)
  static String rating(double value) {
    return value.toStringAsFixed(1);
  }

  /// Format percent (e.g., 25%)
  static String percent(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  /// Format discount (e.g., -20%)
  static String discount(double percentage) {
    return '-${percentage.toStringAsFixed(0)}%';
  }

  /// Format phone number (e.g., (555) 123-4567)
  static String phoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  /// Format card number with masking (e.g., •••• •••• •••• 4242)
  static String maskedCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 4) {
      return '•••• •••• •••• ${cleaned.substring(cleaned.length - 4)}';
    }
    return cardNumber;
  }

  /// Format order ID (e.g., #ECO-00001234)
  static String orderId(String id) {
    return '#ECO-${id.padLeft(8, '0')}';
  }
}
