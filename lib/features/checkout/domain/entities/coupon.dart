import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final String code;
  final double discountPercentage;
  final bool isValid;
  final DateTime expiryDate;

  const Coupon({
    required this.code,
    required this.discountPercentage,
    required this.isValid,
    required this.expiryDate,
  });

  @override
  List<Object?> get props => [code, discountPercentage, isValid, expiryDate];
}