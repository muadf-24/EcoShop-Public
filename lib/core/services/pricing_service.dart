import '../../features/cart/domain/entities/cart_item.dart';
import '../../features/profile/domain/entities/address.dart';

/// Service for calculating order pricing
/// 
/// ✅ FIX CHECK-H01: Centralized, configurable pricing logic
class PricingService {
  PricingService._();

  // ═══════ Configuration (can be fetched from backend) ═══════
  
  /// Tax rates by state (can be moved to Firebase Remote Config)
  static const Map<String, double> _taxRatesByState = {
    'CA': 0.0875, // California: 8.75%
    'NY': 0.08875, // New York: 8.875%
    'TX': 0.0825, // Texas: 8.25%
    'FL': 0.06, // Florida: 6%
    'OR': 0.00, // Oregon: 0% (no sales tax)
    // Add more states as needed
    // Default fallback rate
  };
  
  static const double _defaultTaxRate = 0.08; // 8% default
  
  /// Free shipping threshold
  static const double freeShippingThreshold = 50.0;
  
  /// Standard shipping cost
  static const double standardShippingCost = 5.99;
  
  /// Eco-friendly discount percentage (can be promotional)
  static const double ecoDiscountRate = 0.05; // 5%
  
  /// Minimum order for eco discount
  static const double minOrderForEcoDiscount = 20.0;

  // ═══════ Public Methods ═══════

  /// Calculate complete order pricing
  static OrderPricing calculateOrderPricing({
    required double subtotal,
    required List<CartItem> items,
    required Address shippingAddress,
    String? promoCode,
    double couponDiscountPercentage = 0.0,
  }) {
    // Calculate tax based on shipping address
    final taxRate = _getTaxRate(shippingAddress.state);
    final tax = subtotal * taxRate;
    
    // Calculate shipping
    final shipping = _calculateShipping(subtotal, shippingAddress);
    
    // Calculate discounts
    final discount = _calculateDiscount(subtotal, items, promoCode, couponDiscountPercentage);
    
    // Calculate total
    final total = (subtotal + tax + shipping - discount).clamp(0.0, double.infinity);
    
    return OrderPricing(
      subtotal: subtotal,
      tax: tax,
      taxRate: taxRate,
      shipping: shipping,
      discount: discount,
      total: total,
      appliedPromoCode: promoCode,
    );
  }

  // ═══════ Private Helper Methods ═══════

  /// Get tax rate for a specific state
  static double _getTaxRate(String state) {
    return _taxRatesByState[state.toUpperCase()] ?? _defaultTaxRate;
  }

  /// Calculate shipping cost
  static double _calculateShipping(double subtotal, Address address) {
    // Free shipping for orders over threshold
    if (subtotal >= freeShippingThreshold) {
      return 0.0;
    }
    
    return standardShippingCost;
  }

  /// Calculate applicable discounts
  static double _calculateDiscount(
    double subtotal,
    List<CartItem> items,
    String? promoCode,
    double couponDiscountPercentage,
  ) {
    double totalDiscount = 0.0;
    
    // 1. Eco-friendly discount (automatic for qualifying orders)
    if (subtotal >= minOrderForEcoDiscount) {
      totalDiscount += subtotal * ecoDiscountRate;
    }
    
    // 2. Dynamic Coupon Discount
    if (couponDiscountPercentage > 0) {
      totalDiscount += subtotal * (couponDiscountPercentage / 100);
    }
    
    return totalDiscount;
  }


  /// Get human-readable tax description
  static String getTaxDescription(String state) {
    final rate = _getTaxRate(state);
    return '${state.toUpperCase()} Sales Tax (${(rate * 100).toStringAsFixed(2)}%)';
  }

  /// Get shipping description
  static String getShippingDescription(double subtotal) {
    if (subtotal >= freeShippingThreshold) {
      return 'FREE Shipping (orders over \$${freeShippingThreshold.toStringAsFixed(2)})';
    }
    return 'Standard Shipping';
  }

  /// Get discount description
  static String getDiscountDescription() {
    return 'Eco-Friendly Discount (${(ecoDiscountRate * 100).toStringAsFixed(0)}%)';
  }
}

/// Order pricing result
class OrderPricing {
  final double subtotal;
  final double tax;
  final double taxRate;
  final double shipping;
  final double discount;
  final double total;
  final String? appliedPromoCode;

  const OrderPricing({
    required this.subtotal,
    required this.tax,
    required this.taxRate,
    required this.shipping,
    required this.discount,
    required this.total,
    this.appliedPromoCode,
  });

  /// Create from JSON (for backend sync)
  factory OrderPricing.fromJson(Map<String, dynamic> json) {
    return OrderPricing(
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      appliedPromoCode: json['promo_code'] as String?,
    );
  }

  /// Convert to JSON (for backend sync)
  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'tax': tax,
      'tax_rate': taxRate,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'promo_code': appliedPromoCode,
    };
  }
}
