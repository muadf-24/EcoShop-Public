import 'package:equatable/equatable.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutStarted extends CheckoutEvent {}

class CheckoutAddressSubmitted extends CheckoutEvent {
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String phone;

  const CheckoutAddressSubmitted({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phone,
  });

  @override
  List<Object?> get props => [fullName, addressLine1, city, state, zipCode];
}

class CheckoutPaymentSubmitted extends CheckoutEvent {
  final String paymentMethod;
  const CheckoutPaymentSubmitted({required this.paymentMethod});
  @override
  List<Object?> get props => [paymentMethod];
}

class CheckoutOrderPlaced extends CheckoutEvent {}

class CheckoutOrdersLoadRequested extends CheckoutEvent {}

class CheckoutResetRequested extends CheckoutEvent {}

class CheckoutCouponApplied extends CheckoutEvent {
  final String code;
  const CheckoutCouponApplied(this.code);
  @override
  List<Object?> get props => [code];
}
