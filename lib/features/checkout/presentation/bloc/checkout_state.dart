import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../../profile/domain/entities/address.dart';
import '../../../../core/services/pricing_service.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutAddressStage extends CheckoutState {}

class CheckoutPaymentStage extends CheckoutState {
  final Address address;
  const CheckoutPaymentStage({required this.address});
  @override
  List<Object?> get props => [address];
}

class CheckoutReviewStage extends CheckoutState {
  final Address address;
  final String paymentMethod;
  final String? appliedPromoCode;
  final OrderPricing pricing;
  const CheckoutReviewStage({
    required this.address,
    required this.paymentMethod,
    required this.pricing,
    this.appliedPromoCode,
  });
  @override
  List<Object?> get props => [address, paymentMethod, appliedPromoCode, pricing];
}

class CheckoutSuccess extends CheckoutState {
  final Order order;
  const CheckoutSuccess(this.order);
  @override
  List<Object?> get props => [order];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrdersLoaded extends CheckoutState {
  final List<Order> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}
