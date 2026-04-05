import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// General helper functions used throughout the app
class Helpers {
  Helpers._();

  /// Generate a unique ID
  static String generateId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(999999);
    return '$timestamp$randomPart';
  }

  /// Dismiss keyboard
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Haptic feedback
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  /// Calculate discount percentage
  static double calculateDiscount(double originalPrice, double salePrice) {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - salePrice) / originalPrice) * 100;
  }

  /// Calculate tax
  static double calculateTax(double amount, double taxRate) {
    return amount * taxRate;
  }

  /// Calculate total with tax and shipping
  static double calculateOrderTotal({
    required double subtotal,
    required double tax,
    required double shipping,
    double discount = 0,
  }) {
    return subtotal + tax + shipping - discount;
  }

  /// Delay for animations
  static Future<void> wait(int milliseconds) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Generate star rating text
  static String starRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    return 'Poor';
  }

  /// Get order status color
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFB703);
      case 'processing':
        return const Color(0xFF4895EF);
      case 'shipped':
        return const Color(0xFF52B788);
      case 'delivered':
        return const Color(0xFF2D6A4F);
      case 'cancelled':
        return const Color(0xFFD62828);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
