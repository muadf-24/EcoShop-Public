# Phase 2: Bug Catalog - Checkout Module

**Module:** Checkout  
**Review Date:** February 24, 2026  
**Severity Levels:** CRITICAL | HIGH | MEDIUM | LOW

---

## 🔴 CRITICAL BUGS

### BUG-CHECKOUT-001: CheckoutBloc Stores State in Private Variables
**File:** `lib/features/checkout/presentation/bloc/checkout_bloc.dart:17-18`  
**Severity:** CRITICAL  
**Category:** Architecture Violation / State Management Error  
**Impact:** State not managed by BLoC, loses on hot reload, breaks time-travel debugging

**Current Code:**
```dart
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  // ...
  Address? _address; // ❌ State stored in private variables
  String? _paymentMethod; // ❌ Not part of emitted state
```

**Issue:**
- **Violates BLoC pattern:** State should only be in emitted states, not instance variables
- **Hot reload loses data:** User's address and payment info disappear
- **No state history:** Cannot use time-travel debugging
- **Race conditions:** Private variables not synchronized with state stream
- **Testing nightmare:** Cannot properly test state transitions

**Examples of Problems:**
```dart
void _onAddressSubmitted(...) {
  _address = Address(...); // ❌ Stored in variable
  emit(CheckoutPaymentStage(address: _address!)); // State has it
}

void _onOrderPlaced(...) {
  // ❌ Uses private variables instead of reading from state
  shippingAddress: _address!, 
  paymentMethod: _paymentMethod!,
}
```

**Fix Priority:** P0 (Critical Architecture Issue)  
**Estimated Effort:** 4 hours

**Recommended Fix:**
```dart
// ✅ Store everything in state
class CheckoutPaymentStage extends CheckoutState {
  final Address address;
  final String? selectedPayment; // Add optional payment
  
  const CheckoutPaymentStage({
    required this.address,
    this.selectedPayment,
  });
}

class CheckoutReviewStage extends CheckoutState {
  final Address address;
  final String paymentMethod;
  // Already correct
}

// In BLoC - read from state, not variables
void _onOrderPlaced(...) {
  final currentState = state;
  if (currentState is! CheckoutReviewStage) {
    emit(CheckoutError('Invalid checkout state'));
    return;
  }
  
  // ✅ Use state values
  shippingAddress: currentState.address,
  paymentMethod: currentState.paymentMethod,
}
```

---

### BUG-CHECKOUT-002: Checkout Doesn't Validate Cart Before Order
**File:** `lib/features/checkout/presentation/bloc/checkout_bloc.dart:67-77`  
**Severity:** CRITICAL  
**Category:** Business Logic Error  
**Impact:** Can place order with empty/modified cart

**Current Code:**
```dart
Future<void> _onOrderPlaced(...) async {
  emit(CheckoutLoading());
  try {
    final cartState = cartBloc.state;
    if (cartState is! CartLoaded || cartState.isEmpty) {
      emit(const CheckoutError('Cart is empty'));
      return; // ✅ Good - checks empty cart
    }
    
    final items = cartState.items.map(...).toList();
    // ❌ No validation that items still exist, prices unchanged, etc.
```

**Issue:**
- User starts checkout with $100 cart
- During checkout, removes items or prices change
- Order placed with stale/incorrect data
- Financial and inventory discrepancies

**Fix Priority:** P0 (Critical)  
**Estimated Effort:** 3 hours

**Recommended Fix:**
```dart
Future<void> _onOrderPlaced(...) async {
  emit(CheckoutLoading());
  try {
    final cartState = cartBloc.state;
    if (cartState is! CartLoaded || cartState.isEmpty) {
      emit(const CheckoutError('Cart is empty'));
      return;
    }
    
    // ✅ Re-validate cart items and prices
    final validationResult = await _validateCartItems(cartState.items);
    if (!validationResult.isValid) {
      emit(CheckoutError(
        'Cart has changed: ${validationResult.message}\n'
        'Please review your cart and try again.'
      ));
      return;
    }
    
    // Continue with order creation...
  }
}

Future<ValidationResult> _validateCartItems(List<CartItem> items) async {
  for (final item in items) {
    // Fetch current product data
    final product = await productRepository.getProductById(item.productId);
    
    if (product == null) {
      return ValidationResult.error('Product ${item.productName} no longer available');
    }
    
    if (product.price != item.price) {
      return ValidationResult.error(
        'Price changed for ${item.productName}: '
        '${Formatters.currency(item.price)} → ${Formatters.currency(product.price)}'
      );
    }
    
    // Check stock if applicable
    if (product.stock != null && product.stock < item.quantity) {
      return ValidationResult.error(
        'Only ${product.stock} units available for ${item.productName}'
      );
    }
  }
  
  return ValidationResult.success();
}
```

---

## 🟠 HIGH SEVERITY BUGS

### BUG-CHECKOUT-003: Hardcoded Tax and Discount Rates
**File:** `lib/features/checkout/presentation/bloc/checkout_bloc.dart:90-92`  
**Severity:** HIGH  
**Category:** Business Logic Hardcoded  
**Impact:** Cannot change tax rates without code deployment

**Current Code:**
```dart
final subtotal = cartState.subtotal;
final tax = subtotal * 0.08; // ❌ Hardcoded 8% tax
final ecoDiscount = subtotal * 0.05; // ❌ Hardcoded 5% discount
final shipping = subtotal >= 50 ? 0.0 : 5.99; // ❌ Hardcoded shipping
```

**Issue:**
- Tax rate hardcoded (varies by location)
- Discount rate hardcoded (should be configurable)
- Cannot run promotions without code changes
- Doesn't account for different states/countries
- Business logic in presentation layer

**Fix Priority:** P1 (High)  
**Estimated Effort:** 4 hours

**Recommended Fix:**
```dart
// Create service for calculations
class OrderCalculationService {
  final TaxRepository taxRepository;
  final PromotionRepository promotionRepository;
  
  Future<OrderPricing> calculatePricing({
    required double subtotal,
    required List<CartItem> items,
    required Address shippingAddress,
  }) async {
    // ✅ Fetch tax rate based on address
    final taxRate = await taxRepository.getTaxRate(
      state: shippingAddress.state,
      zipCode: shippingAddress.zipCode,
    );
    
    final tax = subtotal * taxRate;
    
    // ✅ Check for active promotions
    final activePromotions = await promotionRepository.getActivePromotions(items);
    final discount = _calculateDiscount(subtotal, items, activePromotions);
    
    // ✅ Calculate shipping
    final shipping = await _calculateShipping(subtotal, shippingAddress);
    
    return OrderPricing(
      subtotal: subtotal,
      tax: tax,
      taxRate: taxRate,
      discount: discount,
      shipping: shipping,
      total: subtotal + tax + shipping - discount,
    );
  }
}

// In BLoC
final pricing = await orderCalculationService.calculatePricing(
  subtotal: cartState.subtotal,
  items: cartState.items,
  shippingAddress: currentState.address,
);

final params = CreateOrderParams(
  subtotal: pricing.subtotal,
  tax: pricing.tax,
  shipping: pricing.shipping,
  discount: pricing.discount,
  // ...
);
```

---

### BUG-CHECKOUT-004: No Cart Synchronization After Order Success
**File:** `lib/features/checkout/presentation/bloc/checkout_bloc.dart:105`  
**Severity:** HIGH  
**Category:** State Synchronization Error  
**Impact:** Cart cleared but user sees old cart briefly

**Current Code:**
```dart
final order = await createOrderUseCase(params);
cartBloc.add(CartCleared()); // ❌ Event fired but not awaited
emit(CheckoutSuccess(order)); // ❌ Emitted immediately
```

**Issue:**
- `CartCleared` event is async but not awaited
- `CheckoutSuccess` emitted before cart actually clears
- Navigation happens before cart updates
- User might see old cart items briefly after order

**Fix Priority:** P1 (High)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
final order = await createOrderUseCase(params);

// ✅ Wait for cart to clear
cartBloc.add(CartCleared());
await Future.delayed(const Duration(milliseconds: 100)); // Allow event to process

// Or better: use stream subscription
final cartClearedFuture = cartBloc.stream
  .firstWhere((state) => state is CartLoaded && state.isEmpty);
  
cartBloc.add(CartCleared());
await cartClearedFuture.timeout(const Duration(seconds: 2));

emit(CheckoutSuccess(order));
```

---

### BUG-CHECKOUT-005: Checkout Doesn't Handle Cart BLoC Errors
**File:** `lib/features/checkout/presentation/bloc/checkout_bloc.dart:73`  
**Severity:** HIGH  
**Category:** Error Handling Missing  
**Impact:** Checkout breaks if cart BLoC is in error state

**Current Code:**
```dart
final cartState = cartBloc.state;
if (cartState is! CartLoaded || cartState.isEmpty) {
  // ❌ Only checks CartLoaded and empty
  // What if cartState is CartError? CartInitial?
}
```

**Issue:**
- Doesn't handle `CartError` state
- Doesn't handle `CartInitial` state
- Doesn't handle `CartLoading` state
- Type cast will fail silently

**Fix Priority:** P1 (High)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
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
  emit(const CheckoutError('Cart is empty'));
  return;
}
```

---

### BUG-CHECKOUT-006: Payment Method Not Validated
**File:** `lib/features/checkout/presentation/screens/checkout_screen.dart:398`  
**Severity:** HIGH  
**Category:** Business Logic Missing  
**Impact:** Can proceed without selecting payment

**Current Code:**
```dart
CustomButton(
  text: 'Review Order',
  useGradient: true,
  onPressed: () {
    context.read<CheckoutBloc>().add(
      CheckoutPaymentSubmitted(paymentMethod: _selectedPayment)
    ); // ❌ No validation if _selectedPayment is valid
  },
),
```

**Issue:**
- `_selectedPayment` initialized to 'Credit Card' by default
- User could theoretically set it to null/empty
- No validation before submission
- No check if payment method is actually available

**Fix Priority:** P1 (High)  
**Estimated Effort:** 30 minutes

**Recommended Fix:**
```dart
onPressed: () {
  if (_selectedPayment.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a payment method')),
    );
    return;
  }
  
  context.read<CheckoutBloc>().add(
    CheckoutPaymentSubmitted(paymentMethod: _selectedPayment)
  );
},
```

---

## 🟡 MEDIUM SEVERITY BUGS

### BUG-CHECKOUT-007: No Order Confirmation Email/Notification
**File:** `lib/features/checkout/presentation/bloc/checkout_bloc.dart:104`  
**Severity:** MEDIUM  
**Category:** Missing Feature  
**Impact:** Users don't receive order confirmation

**Issue:**
- Order created successfully
- No email notification sent
- No push notification
- User has no record except in-app

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 6 hours

**Recommended Fix:**
```dart
final order = await createOrderUseCase(params);

// ✅ Send confirmation email
await emailService.sendOrderConfirmation(
  email: user.email,
  order: order,
  address: currentState.address,
);

// ✅ Send push notification
await notificationService.showLocalNotification(
  title: 'Order Confirmed!',
  body: 'Order #${order.id} has been placed successfully.',
);

cartBloc.add(CartCleared());
emit(CheckoutSuccess(order));
```

---

### BUG-CHECKOUT-008: No Loading State During Address Submission
**File:** `lib/features/checkout/presentation/bloc/checkout_bloc.dart:38-54`  
**Severity:** MEDIUM  
**Category:** UX Issue  
**Impact:** No visual feedback when processing address

**Current Code:**
```dart
void _onAddressSubmitted(...) {
  _address = Address(...); // ❌ Synchronous, no loading
  emit(CheckoutPaymentStage(address: _address!));
}
```

**Issue:**
- Address creation is instant (synchronous)
- In real app, might validate address via API
- No loading state if validation is async
- Button can be tapped multiple times

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
Future<void> _onAddressSubmitted(...) async {
  emit(CheckoutLoading());
  
  try {
    // ✅ Validate address (if needed)
    final validated = await addressValidationService.validate(
      fullName: event.fullName,
      street: event.addressLine1,
      city: event.city,
      // ...
    );
    
    final address = Address.fromValidated(validated);
    emit(CheckoutPaymentStage(address: address));
  } catch (e) {
    emit(CheckoutError('Invalid address: ${e.toString()}'));
  }
}
```

---

### BUG-CHECKOUT-009: Deprecated Member Used
**File:** `lib/features/checkout/presentation/screens/checkout_screen.dart:0`  
**Severity:** MEDIUM  
**Category:** Code Quality  
**Impact:** Uses deprecated API, may break in future

**Current Code:**
```dart
// ignore_for_file: deprecated_member_use
```

**Issue:**
- File-wide ignore of deprecation warnings
- Hides important migration warnings
- Will break when deprecated API is removed
- No comment explaining what's deprecated or why

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 30 minutes

**Recommended Fix:**
```dart
// Find and fix deprecated API usage
// Common issues:
color.withOpacity(0.5) // ❌ Deprecated
color.withValues(alpha: 0.5) // ✅ New API (already used elsewhere)

// Remove file-level ignore once fixed
```

---

### BUG-CHECKOUT-010: Step Indicator Not Tappable
**File:** `lib/features/checkout/presentation/screens/checkout_screen.dart:106`  
**Severity:** MEDIUM  
**Category:** UX Issue  
**Impact:** Users expect to tap steps to navigate but can't

**Current Code:**
```dart
_buildStep(0, 'Address', currentStep >= 0, currentStep == 0),
// ❌ No GestureDetector or onTap
```

**Issue:**
- Step indicators look interactive but aren't
- Standard UX pattern: tap to jump to that step
- Users frustrated when taps don't work
- Must use "Back" button instead

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 2 hours

**Recommended Fix:**
```dart
Widget _buildStep(int index, String label, bool isCompleted, bool isActive) {
  return GestureDetector(
    onTap: () {
      if (index < currentStep) {
        // ✅ Allow going back to previous steps
        if (index == 0) {
          context.read<CheckoutBloc>().add(CheckoutStarted());
        } else if (index == 1 && state is CheckoutReviewStage) {
          final reviewState = state as CheckoutReviewStage;
          context.read<CheckoutBloc>().add(
            CheckoutAddressSubmitted(/* restore address */),
          );
        }
      }
    },
    child: Column(
      children: [
        Container(
          // ... existing step UI
        ),
      ],
    ),
  );
}
```

---

## 🟢 LOW SEVERITY BUGS

### BUG-CHECKOUT-011: Payment Icons Hardcoded
**File:** `lib/features/checkout/presentation/screens/checkout_screen.dart:302-307`  
**Severity:** LOW  
**Category:** Code Quality  
**Impact:** Payment methods hardcoded in UI

**Issue:**
- Payment methods defined in UI, not fetched from backend
- Cannot add/remove methods without code change
- Different methods for different regions not supported

**Fix Priority:** P3 (Low)  
**Estimated Effort:** 3 hours

---

### BUG-CHECKOUT-012: No Estimated Delivery Date Shown in Review
**File:** `lib/features/checkout/presentation/screens/checkout_screen.dart:409-474`  
**Severity:** LOW  
**Category:** Missing Feature  
**Impact:** Users don't see delivery estimate before confirming

**Issue:**
- Order creates with estimated delivery date
- Not shown in review stage
- User doesn't know when to expect delivery

**Fix Priority:** P3 (Low)  
**Estimated Effort:** 1 hour

---

### BUG-CHECKOUT-013: Address Form Doesn't Support International
**File:** `lib/features/checkout/presentation/screens/checkout_screen.dart:221-262`  
**Severity:** LOW  
**Category:** Limited Functionality  
**Impact:** Only supports US addresses

**Issue:**
- Hardcoded "United States" as country
- State field assumes US states
- Zip code instead of postal code
- International customers cannot checkout

**Fix Priority:** P3 (Low for MVP, P1 for international launch)  
**Estimated Effort:** 8 hours

---

## Summary Statistics - Checkout Module

| Severity | Count | Effort (hours) |
|----------|-------|----------------|
| CRITICAL | 2 | 7 |
| HIGH | 5 | 11.5 |
| MEDIUM | 5 | 12.5 |
| LOW | 3 | 12 |
| **TOTAL** | **15** | **43 hours** |

---

## Critical Path Issues

These bugs **MUST** be fixed before production:

1. **BUG-CHECKOUT-001** - State management violation
2. **BUG-CHECKOUT-002** - Cart validation missing
3. **BUG-CHECKOUT-003** - Hardcoded business rules
4. **BUG-AUTH-001** - Forgot password not implemented (from Part 1)
5. **BUG-PROD-001** - Loading state UX disaster (from Part 2)

**Total Critical Path Effort:** ~20 hours across all modules

**Next:** Phase 2 Summary & Implementation Plan
