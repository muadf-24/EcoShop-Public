import '../entities/coupon.dart';

abstract class CouponRepository {
  Future<Coupon> validateAndApplyCoupon({
    required String code,
    required double orderTotal,
    required String userId,
  });
  
  Future<List<Coupon>> getAvailableCoupons(String userId);
  
  Future<void> markCouponAsUsed({
    required String code,
    required String userId,
    required String orderId,
  });
}
