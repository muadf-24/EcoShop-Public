/// Order validation utilities for security and business logic
class OrderValidator {
  // Business constraints
  static const double maxOrderTotal = 50000.0; // $50,000 max order
  static const double minOrderTotal = 0.01; // $0.01 minimum
  static const int maxItemsPerOrder = 100;
  static const int minItemsPerOrder = 1;
  static const double maxDiscountPercentage = 0.9; // 90% max discount

  /// Validate order total calculation
  /// 
  /// Ensures client-calculated total matches server calculation
  /// to prevent price manipulation attacks.
  static ValidationResult validateOrderTotal({
    required double subtotal,
    required double tax,
    required double shipping,
    required double discount,
    required double providedTotal,
  }) {
    // Calculate expected total
    final expectedTotal = subtotal + tax + shipping - discount;
    
    // Check for floating-point precision errors (1 cent tolerance)
    final difference = (providedTotal - expectedTotal).abs();
    
    if (difference > 0.01) {
      return ValidationResult.error(
        'Total mismatch: Expected \$${expectedTotal.toStringAsFixed(2)}, '
        'got \$${providedTotal.toStringAsFixed(2)}',
      );
    }
    
    return ValidationResult.success();
  }

  /// Validate individual order components
  static ValidationResult validateOrderComponents({
    required double subtotal,
    required double tax,
    required double shipping,
    required double discount,
  }) {
    // Check for negative values
    if (subtotal < 0) {
      return ValidationResult.error('Subtotal cannot be negative');
    }
    
    if (tax < 0) {
      return ValidationResult.error('Tax cannot be negative');
    }
    
    if (shipping < 0) {
      return ValidationResult.error('Shipping cost cannot be negative');
    }
    
    if (discount < 0) {
      return ValidationResult.error('Discount cannot be negative');
    }
    
    // Check maximum values
    if (subtotal > maxOrderTotal) {
      return ValidationResult.error(
        'Subtotal exceeds maximum allowed (\$${maxOrderTotal.toStringAsFixed(2)})',
      );
    }
    
    // Discount validation: cannot exceed subtotal
    if (discount > subtotal) {
      return ValidationResult.error('Discount cannot exceed subtotal');
    }
    
    // Discount percentage check (prevent unrealistic discounts)
    final discountPercentage = subtotal > 0 ? discount / subtotal : 0;
    if (discountPercentage > maxDiscountPercentage) {
      return ValidationResult.error(
        'Discount percentage (${(discountPercentage * 100).toStringAsFixed(0)}%) '
        'exceeds maximum allowed (${(maxDiscountPercentage * 100).toStringAsFixed(0)}%)',
      );
    }
    
    // Tax validation: reasonable range (0-30% of subtotal)
    if (tax > subtotal * 0.3) {
      return ValidationResult.error('Tax amount seems incorrect');
    }
    
    return ValidationResult.success();
  }

  /// Validate order items
  static ValidationResult validateOrderItems(List<dynamic> items) {
    if (items.isEmpty) {
      return ValidationResult.error('Order must contain at least one item');
    }
    
    if (items.length > maxItemsPerOrder) {
      return ValidationResult.error(
        'Order cannot contain more than $maxItemsPerOrder items',
      );
    }
    
    // Validate each item has required fields
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      
      if (item is! Map) {
        return ValidationResult.error('Invalid item format at position $i');
      }
      
      // Check required fields
      if (!item.containsKey('productId') || 
          !item.containsKey('quantity') || 
          !item.containsKey('price')) {
        return ValidationResult.error(
          'Item at position $i is missing required fields',
        );
      }
      
      // Validate quantity
      final quantity = item['quantity'];
      if (quantity is! int || quantity < 1 || quantity > 99) {
        return ValidationResult.error(
          'Invalid quantity for item at position $i',
        );
      }
      
      // Validate price
      final price = item['price'];
      if (price is! num || price < 0) {
        return ValidationResult.error(
          'Invalid price for item at position $i',
        );
      }
    }
    
    return ValidationResult.success();
  }

  /// Validate shipping address
  static ValidationResult validateShippingAddress(Map<String, dynamic> address) {
    final requiredFields = [
      'full_name',
      'phone',
      'address_line1',
      'city',
      'state',
      'postal_code',
      'country',
    ];
    
    for (final field in requiredFields) {
      if (!address.containsKey(field) || 
          address[field] == null || 
          address[field].toString().trim().isEmpty) {
        return ValidationResult.error(
          'Shipping address is missing required field: $field',
        );
      }
    }
    
    // Validate field lengths
    if (address['full_name'].toString().length < 2) {
      return ValidationResult.error('Full name must be at least 2 characters');
    }
    
    if (address['phone'].toString().length < 10) {
      return ValidationResult.error('Invalid phone number');
    }
    
    if (address['postal_code'].toString().length < 4) {
      return ValidationResult.error('Invalid postal code');
    }
    
    return ValidationResult.success();
  }

  /// Comprehensive order validation (use before creating order)
  static ValidationResult validateCompleteOrder({
    required double subtotal,
    required double tax,
    required double shipping,
    required double discount,
    required double total,
    required List<dynamic> items,
    required Map<String, dynamic> shippingAddress,
  }) {
    // Validate components
    var result = validateOrderComponents(
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      discount: discount,
    );
    if (!result.isValid) return result;
    
    // Validate total calculation
    result = validateOrderTotal(
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      discount: discount,
      providedTotal: total,
    );
    if (!result.isValid) return result;
    
    // Validate items
    result = validateOrderItems(items);
    if (!result.isValid) return result;
    
    // Validate shipping address
    result = validateShippingAddress(shippingAddress);
    if (!result.isValid) return result;
    
    // Final total check
    if (total < minOrderTotal) {
      return ValidationResult.error(
        'Order total must be at least \$${minOrderTotal.toStringAsFixed(2)}',
      );
    }
    
    if (total > maxOrderTotal) {
      return ValidationResult.error(
        'Order total exceeds maximum allowed (\$${maxOrderTotal.toStringAsFixed(2)})',
      );
    }
    
    return ValidationResult.success();
  }
}

/// Validation result wrapper
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult._({required this.isValid, this.errorMessage});

  factory ValidationResult.success() {
    return ValidationResult._(isValid: true);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(isValid: false, errorMessage: message);
  }

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: $errorMessage';
  }
}
