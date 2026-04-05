import 'package:flutter_test/flutter_test.dart';
import 'package:ecoshop/core/services/pricing_service.dart';
import 'package:ecoshop/features/cart/domain/entities/cart_item.dart';
import 'package:ecoshop/features/cart/data/models/cart_item_model.dart';
import 'package:ecoshop/features/profile/domain/entities/address.dart';

void main() {
  group('PricingService Tests', () {
    final mockAddress = Address(
      id: '1',
      label: 'Home',
      fullName: 'Test User',
      street: '123 Main St',
      city: 'Seattle',
      state: 'WA', // Not in map, uses 8% default
      zipCode: '98101',
      country: 'USA',
      phone: '1234567890',
    );

    final List<CartItem> mockItems = [
      CartItemModel(
        id: 'c1',
        productId: 'p1',
        productName: 'Eco Bag',
        productImage: 'img1',
        price: 20.0,
        quantity: 2,
      ),
    ];

    test('calculateOrderPricing returns correct subtotal and tax', () {
      final pricing = PricingService.calculateOrderPricing(
        subtotal: 40.0,
        items: mockItems,
        shippingAddress: mockAddress,
      );

      expect(pricing.subtotal, 40.0);
      expect(pricing.taxRate, 0.08); // WA default
      expect(pricing.tax, 3.2); // 40 * 0.08
    });

    test('calculateOrderPricing applies automatic eco-discount and coupon correctly', () {
      final pricing = PricingService.calculateOrderPricing(
        subtotal: 100.0,
        items: mockItems,
        shippingAddress: mockAddress,
        promoCode: 'SAVE10',
        couponDiscountPercentage: 10.0,
      );

      // Eco discount (5% of 100 = 5) + Coupon (10% of 100 = 10)
      expect(pricing.discount, 15.0);
      expect(pricing.shipping, 0.0); // 100 > 50 threshold
      expect(pricing.total, 100 + 8.0 + 0.0 - 15.0); // total = 93.0
    });

    test('calculateOrderPricing handles shipping for small orders', () {
      final pricing = PricingService.calculateOrderPricing(
        subtotal: 10.0,
        items: [],
        shippingAddress: mockAddress,
      );

      expect(pricing.shipping, 5.99); // < 50 threshold
      expect(pricing.discount, 0.0); // < 20 for eco discount
      expect(pricing.total, 10.0 + 0.8 + 5.99 - 0.0);
    });
    
    test('calculateOrderPricing handles Oregon zero tax', () {
      final oregonAddress = mockAddress.copyWith(state: 'OR');
      final pricing = PricingService.calculateOrderPricing(
        subtotal: 100.0,
        items: [],
        shippingAddress: oregonAddress,
      );

      expect(pricing.taxRate, 0.0);
      expect(pricing.tax, 0.0);
    });
  });
}
