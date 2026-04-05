import '../entities/coupon.dart';
import '../repositories/coupon_repository.dart';

class ApplyCouponUseCase {
  final CouponRepository repository;

  ApplyCouponUseCase(this.repository);

  Future<Coupon> call({
    required String code,
    required double orderTotal,
    required String userId,
  }) async {
    return await repository.validateAndApplyCoupon(
      code: code,
      orderTotal: orderTotal,
      userId: userId,
    );
  }
}
