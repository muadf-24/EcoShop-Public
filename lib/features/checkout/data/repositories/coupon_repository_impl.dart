import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final FirebaseFirestore _firestore;

  CouponRepositoryImpl({required FirebaseFirestore firestore}) 
      : _firestore = firestore;

  @override
  Future<Coupon> validateAndApplyCoupon({
    required String code,
    required double orderTotal,
    required String userId,
  }) async {
    try {
      final query = await _firestore
          .collection('coupons')
          .where('code', isEqualTo: code.toUpperCase())
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Invalid coupon code');
      }

      final data = query.docs.first.data();
      final coupon = Coupon(
        code: data['code'] as String,
        discountPercentage: (data['discountPercentage'] as num).toDouble(),
        isValid: data['isValid'] as bool,
        expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      );

      // Validation logic
      if (coupon.expiryDate.isBefore(DateTime.now())) {
        throw Exception('Coupon has expired');
      }

      if (!coupon.isValid) {
        throw Exception('Coupon is no longer valid');
      }

      // Check if user has already used this coupon
      final usageQuery = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('promoCode', isEqualTo: code.toUpperCase())
          .get();

      if (usageQuery.docs.isNotEmpty) {
        throw Exception('You have already used this coupon');
      }

      return coupon;
    } on FirebaseException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  @override
  Future<List<Coupon>> getAvailableCoupons(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('coupons')
          .where('isValid', isEqualTo: true)
          .where('expiryDate', isGreaterThan: Timestamp.fromDate(now))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Coupon(
          code: data['code'] as String,
          discountPercentage: (data['discountPercentage'] as num).toDouble(),
          isValid: data['isValid'] as bool,
          expiryDate: (data['expiryDate'] as Timestamp).toDate(),
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch coupons: ${e.message}');
    }
  }

  @override
  Future<void> markCouponAsUsed({
    required String code,
    required String userId,
    required String orderId,
  }) async {
    await _firestore.collection('coupon_usage').add({
      'code': code.toUpperCase(),
      'userId': userId,
      'orderId': orderId,
      'usedAt': FieldValue.serverTimestamp(),
    });
  }
}