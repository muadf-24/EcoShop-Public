import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/domain/entities/address.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/models/order_model.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/utils/order_validator.dart';
import '../../../../core/services/pricing_service.dart';
import '../../../../core/services/payment_service.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final ApplyCouponUseCase applyCouponUseCase;
  final CartBloc cartBloc;
  final PaymentService paymentService;

  Address? _address;
  String? _paymentMethod;
  String? _appliedPromoCode;
  double _couponDiscountPercentage = 0.0;

  CheckoutBloc({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.applyCouponUseCase,
    required this.cartBloc,
    required this.paymentService,
  }) : super(CheckoutInitial()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutAddressSubmitted>(_onAddressSubmitted);
    on<CheckoutPaymentSubmitted>(_onPaymentSubmitted);
    on<CheckoutCouponApplied>(_onCouponApplied);
    on<CheckoutOrderPlaced>(_onOrderPlaced);
    on<CheckoutOrdersLoadRequested>(_onLoadOrders);
    on<CheckoutResetRequested>(_onReset);
  }

  void _onStarted(CheckoutStarted event, Emitter<CheckoutState> emit) {
    // ✅ FIX: Validate cart before starting checkout
    final cartState = cartBloc.state;
    
    if (cartState is! CartLoaded || cartState.isEmpty) {
      emit(const CheckoutError('Your cart is empty. Add items before checkout.'));
      return;
    }

    // ✅ FIX: Validate minimum order amount
    if (cartState.subtotal < 1.0) {
      emit(const CheckoutError('Minimum order amount is \$1.00'));
      return;
    }

    _address = null;
    _paymentMethod = null;
    emit(CheckoutAddressStage());
  }

  Future<void> _onAddressSubmitted(
    CheckoutAddressSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    // ✅ FIX CHECK-H05: Add loading state during address validation
    emit(CheckoutLoading());
    
    // Small delay to show loading (simulates address validation)
    await Future.delayed(const Duration(milliseconds: 300));
    
    // ✅ FIX: Validate address fields
    if (event.fullName.trim().isEmpty) {
      emit(const CheckoutError('Full name is required'));
      emit(CheckoutAddressStage());
      return;
    }

    if (event.addressLine1.trim().isEmpty) {
      emit(const CheckoutError('Address line 1 is required'));
      emit(CheckoutAddressStage());
      return;
    }

    if (event.city.trim().isEmpty) {
      emit(const CheckoutError('City is required'));
      emit(CheckoutAddressStage());
      return;
    }

    if (event.state.trim().isEmpty) {
      emit(const CheckoutError('State is required'));
      emit(CheckoutAddressStage());
      return;
    }

    if (event.zipCode.trim().isEmpty || !_isValidZipCode(event.zipCode)) {
      emit(const CheckoutError('Valid ZIP code is required'));
      emit(CheckoutAddressStage());
      return;
    }

    if (event.phone.trim().isEmpty || !_isValidPhone(event.phone)) {
      emit(const CheckoutError('Valid phone number is required'));
      emit(CheckoutAddressStage());
      return;
    }

    _address = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Shipping',
      fullName: event.fullName.trim(),
      street: event.addressLine1.trim(),
      city: event.city.trim(),
      state: event.state.trim(),
      zipCode: event.zipCode.trim(),
      country: 'United States',
      phone: event.phone.trim(),
    );
    
    emit(CheckoutPaymentStage(address: _address!));
  }

  void _onPaymentSubmitted(
    CheckoutPaymentSubmitted event,
    Emitter<CheckoutState> emit,
  ) {
    // ✅ FIX: Validate payment method
    if (event.paymentMethod.trim().isEmpty) {
      emit(const CheckoutError('Please select a payment method'));
      if (_address != null) {
        emit(CheckoutPaymentStage(address: _address!));
      }
      return;
    }

    if (_address == null) {
      emit(const CheckoutError('Address not found. Please go back and re-enter.'));
      emit(CheckoutAddressStage());
      return;
    }

    _paymentMethod = event.paymentMethod;
    
    final cartState = cartBloc.state as CartLoaded;
    final pricing = PricingService.calculateOrderPricing(
      subtotal: cartState.subtotal,
      items: cartState.items,
      shippingAddress: _address!,
      promoCode: _appliedPromoCode,
      couponDiscountPercentage: _couponDiscountPercentage,
    );

    emit(CheckoutReviewStage(
      address: _address!,
      paymentMethod: _paymentMethod!,
      pricing: pricing,
    ));
  }

  Future<void> _onOrderPlaced(
    CheckoutOrderPlaced event,
    Emitter<CheckoutState> emit,
  ) async {
    // ✅ FIX: Comprehensive validation before placing order
    if (_address == null || _paymentMethod == null) {
      emit(const CheckoutError('Missing checkout information. Please start over.'));
      emit(CheckoutInitial());
      return;
    }

    // ✅ FIX CHECK-H03: Handle all cart BLoC states properly
    final cartState = cartBloc.state;
    
    if (cartState is CartError) {
      emit(CheckoutError('Cart error: ${cartState.message}'));
      return;
    }
    
    if (cartState is CartInitial || cartState is CartLoading) {
      emit(const CheckoutError('Cart is not ready. Please wait...'));
      return;
    }
    
    if (cartState is! CartLoaded) {
      emit(const CheckoutError('Invalid cart state'));
      return;
    }
    
    if (cartState.isEmpty) {
      emit(const CheckoutError('Cart is empty. Cannot place order.'));
      return;
    }

    emit(CheckoutLoading());
    
    try {
      final items = cartState.items
          .map((item) => OrderItemModel(
                productId: item.productId,
                productName: item.productName,
                productImage: item.productImage,
                price: item.price,
                quantity: item.quantity,
              ))
          .toList();

      // ✅ FIX CHECK-H01: Use centralized PricingService instead of hardcoded values
      final pricing = PricingService.calculateOrderPricing(
        subtotal: cartState.subtotal,
        items: cartState.items,
        shippingAddress: _address!,
        promoCode: _appliedPromoCode,
        couponDiscountPercentage: _couponDiscountPercentage,
      );
      
      final subtotal = pricing.subtotal;
      final tax = pricing.tax;
      final ecoDiscount = pricing.discount;
      final shipping = pricing.shipping;
      final total = pricing.total;

      // ✅ FIX: Validate order totals using OrderValidator
      final validationResult = OrderValidator.validateCompleteOrder(
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        discount: ecoDiscount,
        total: total,
        items: items.map((item) => {
          'productId': item.productId,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        shippingAddress: {
          'full_name': _address!.fullName,
          'phone': _address!.phone,
          'address_line1': _address!.street,
          'city': _address!.city,
          'state': _address!.state,
          'postal_code': _address!.zipCode,
          'country': _address!.country,
        },
      );

      if (!validationResult.isValid) {
        emit(CheckoutError('Order validation failed: ${validationResult.errorMessage}'));
        return;
      }

      final params = CreateOrderParams(
        items: items,
        shippingAddress: _address!,
        paymentMethod: _paymentMethod!,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        discount: ecoDiscount,
        promoCode: _appliedPromoCode,
      );

      // ✅ NEW: Unified Payment & Order Placement Flow
      try {
        final paymentSuccess = await paymentService.processPayment(
          amount: total,
          currency: 'USD',
          email: 'user@example.com', // Future: Get from AuthBloc
        );

        if (!paymentSuccess) {
          emit(const CheckoutError('Payment was declined. Please check your card or selection.'));
          emit(CheckoutReviewStage(
            address: _address!,
            paymentMethod: _paymentMethod!,
            pricing: pricing,
          ));
          return;
        }

        final order = await createOrderUseCase(params);
        
        // Finalize
        cartBloc.add(CartCleared());
        
        // Wait for cart to actually clear (with timeout)
        try {
          await cartBloc.stream
            .firstWhere((state) => state is CartLoaded && state.isEmpty)
            .timeout(const Duration(seconds: 2));
        } catch (e) {
          // Continue even if timeout - cart will eventually clear
        }
        
        // Reset checkout state
        _address = null;
        _paymentMethod = null;
        
        emit(CheckoutSuccess(order));
      } on PaymentException catch (e) {
        // ✅ FIX: Specific payment error handling
        emit(CheckoutError('Payment failed: ${e.message}. Please try again.'));
        // Return to payment stage
        emit(CheckoutPaymentStage(address: _address!));
      } on NetworkException catch (e) {
        emit(CheckoutError('Network error: ${e.message}. Please check your connection.'));
      } on ServerException catch (e) {
        emit(CheckoutError('Server error: ${e.message}. Please try again later.'));
      }
    } catch (e) {
      // ✅ FIX: Generic error handling with user-friendly message
      emit(CheckoutError('Failed to place order: ${e.toString()}'));
    }
  }

  Future<void> _onCouponApplied(
    CheckoutCouponApplied event,
    Emitter<CheckoutState> emit,
  ) async {
    final cartState = cartBloc.state;
    if (cartState is! CartLoaded) return;

    emit(CheckoutLoading());
    try {
      // Validate coupon with backend
      final coupon = await applyCouponUseCase(
        code: event.code,
        orderTotal: cartState.subtotal,
        userId: 'current-user-id', // Future: Get from AuthBloc
      );

      _appliedPromoCode = coupon.code;
      _couponDiscountPercentage = coupon.discountPercentage;

      final pricing = PricingService.calculateOrderPricing(
        subtotal: cartState.subtotal,
        items: cartState.items,
        shippingAddress: _address!,
        promoCode: _appliedPromoCode,
        couponDiscountPercentage: _couponDiscountPercentage,
      );

      emit(CheckoutReviewStage(
        address: _address!,
        paymentMethod: _paymentMethod!,
        appliedPromoCode: _appliedPromoCode,
        pricing: pricing,
      ));
    } catch (e) {
      emit(CheckoutError('Promo code error: ${e.toString()}'));
      
      final pricing = PricingService.calculateOrderPricing(
        subtotal: cartState.subtotal,
        items: cartState.items,
        shippingAddress: _address!,
        promoCode: _appliedPromoCode,
        couponDiscountPercentage: _couponDiscountPercentage,
      );

      emit(CheckoutReviewStage(
        address: _address!,
        paymentMethod: _paymentMethod!,
        appliedPromoCode: _appliedPromoCode,
        pricing: pricing,
      ));
    }
  }

  Future<void> _onLoadOrders(
    CheckoutOrdersLoadRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    try {
      final orders = await getOrdersUseCase();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(CheckoutError('Failed to load orders: ${e.toString()}'));
    }
  }

  void _onReset(CheckoutResetRequested event, Emitter<CheckoutState> emit) {
    _address = null;
    _paymentMethod = null;
    emit(CheckoutInitial());
  }

  // ✅ Helper validation methods
  bool _isValidZipCode(String zipCode) {
    // US ZIP code format: 12345 or 12345-6789
    final regex = RegExp(r'^\d{5}(-\d{4})?$');
    return regex.hasMatch(zipCode);
  }

  bool _isValidPhone(String phone) {
    // Remove common separators
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Must be 10 or 11 digits (with country code)
    return cleaned.length >= 10 && cleaned.length <= 11 && int.tryParse(cleaned) != null;
  }
}

// ✅ Custom exceptions for better error handling
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
