# 🧪 SPRINT 1 - QA Testing Checklist

**Sprint:** Sprint 1 - Critical Bug Fixes  
**Date:** February 24, 2026  
**Status:** Ready for QA Testing  
**Bugs Fixed:** 10/10 CRITICAL  

---

## 📋 Pre-Testing Setup

- [ ] Firebase Security Rules deployed (firestore.rules, storage.rules)
- [ ] Flutter dependencies updated (`flutter pub get`)
- [ ] Build successful (`flutter build apk` or `flutter build ios`)
- [ ] Test environment configured
- [ ] Test user accounts created

---

## 🔐 Authentication Module Testing

### AUTH-C01: Forgot Password
- [ ] **TC-AUTH-001:** User clicks "Forgot Password" on login screen
  - Expected: Navigates to forgot password screen
- [ ] **TC-AUTH-002:** User enters valid email and submits
  - Expected: Shows success message "Password reset link sent to your email"
- [ ] **TC-AUTH-003:** User enters invalid email
  - Expected: Shows error "Invalid email format"
- [ ] **TC-AUTH-004:** User checks email and receives reset link
  - Expected: Email received within 2 minutes
- [ ] **TC-AUTH-005:** User clicks reset link and changes password
  - Expected: Password updated successfully

### AUTH-C02: Email Verification
- [ ] **TC-AUTH-006:** New user registers account
  - Expected: Account created, verification email sent
- [ ] **TC-AUTH-007:** User checks for verification email
  - Expected: Email received within 2 minutes
- [ ] **TC-AUTH-008:** User clicks verification link
  - Expected: Email verified, status updates in app
- [ ] **TC-AUTH-009:** Verified user accesses protected features
  - Expected: Full access granted
- [ ] **TC-AUTH-010:** Unverified user attempts protected action
  - Expected: Prompted to verify email

---

## 🛍️ Product Module Testing

### PROD-C01: Product BLoC State Management
- [ ] **TC-PROD-001:** User loads home screen
  - Expected: Products display with loading indicator
- [ ] **TC-PROD-002:** User navigates to product detail, then back
  - Expected: Product list state preserved (scroll position, filters)
- [ ] **TC-PROD-003:** User applies category filter
  - Expected: Filtered products shown, can clear filter
- [ ] **TC-PROD-004:** User sorts products (price/rating)
  - Expected: Products re-sorted, sort indicator visible
- [ ] **TC-PROD-005:** User navigates to cart and back to products
  - Expected: Previous product state intact

### PROD-C02: Product Loading States
- [ ] **TC-PROD-006:** Initial app load
  - Expected: Skeleton loader or loading indicator shown
- [ ] **TC-PROD-007:** Navigate to product detail
  - Expected: Detail loads smoothly, no unnecessary loading flash
- [ ] **TC-PROD-008:** Pull to refresh products
  - Expected: Refresh indicator shown, products reload
- [ ] **TC-PROD-009:** Load more products (pagination)
  - Expected: "Loading more..." shown at bottom
- [ ] **TC-PROD-010:** Network error during load
  - Expected: Error message shown with retry option

### PROD-C03: Search Debouncing
- [ ] **TC-PROD-011:** User types "eco" rapidly in search
  - Expected: No search triggered until typing stops (500ms)
- [ ] **TC-PROD-012:** User types "eco" → waits → "bag"
  - Expected: Two searches: one for "eco", one for "ecobag"
- [ ] **TC-PROD-013:** User types and immediately clears search
  - Expected: Returns to product list, no search executed
- [ ] **TC-PROD-014:** User types, then navigates away quickly
  - Expected: No memory leaks, debounce timer cancelled
- [ ] **TC-PROD-015:** Search returns no results
  - Expected: "No products found" message shown

---

## 🛒 Cart Module Testing

### CART-C01: Cart BLoC State Persistence
- [ ] **TC-CART-001:** User adds item to cart
  - Expected: Item appears in cart immediately
- [ ] **TC-CART-002:** User closes and reopens app
  - Expected: Cart items persist
- [ ] **TC-CART-003:** User adds same product twice
  - Expected: Quantity increments (no duplicate entry)
- [ ] **TC-CART-004:** User navigates between screens
  - Expected: Cart count badge updates correctly
- [ ] **TC-CART-005:** Network failure during cart update
  - Expected: Cart rolls back to previous state, error shown

### CART-C02: Quantity Update Logic
- [ ] **TC-CART-006:** User increments quantity from 1 to 2
  - Expected: Quantity updates, total price recalculates
- [ ] **TC-CART-007:** User decrements quantity from 2 to 1
  - Expected: Quantity updates, total price recalculates
- [ ] **TC-CART-008:** User sets quantity to 0
  - Expected: Item removed from cart
- [ ] **TC-CART-009:** User tries to set quantity > 99
  - Expected: Error "Maximum quantity is 99"
- [ ] **TC-CART-010:** User manually enters negative quantity
  - Expected: Item removed or error shown
- [ ] **TC-CART-011:** Rapid quantity changes (spam click +/-)
  - Expected: UI responsive, no race conditions

---

## 💳 Checkout Module Testing

### CHECK-C01: Checkout BLoC Architecture
- [ ] **TC-CHECK-001:** User clicks "Checkout" from cart
  - Expected: Navigates to address entry (Stage 1)
- [ ] **TC-CHECK-002:** User completes address, clicks next
  - Expected: Navigates to payment selection (Stage 2)
- [ ] **TC-CHECK-003:** User selects payment, clicks next
  - Expected: Navigates to order review (Stage 3)
- [ ] **TC-CHECK-004:** User clicks "Back" on payment stage
  - Expected: Returns to address (address preserved)
- [ ] **TC-CHECK-005:** User completes order successfully
  - Expected: Checkout state resets, cart cleared

### CHECK-C02: Cart Validation
- [ ] **TC-CHECK-006:** User tries checkout with empty cart
  - Expected: Error "Your cart is empty. Add items before checkout."
- [ ] **TC-CHECK-007:** User leaves address name blank
  - Expected: Error "Full name is required"
- [ ] **TC-CHECK-008:** User enters invalid ZIP code (e.g., "abcde")
  - Expected: Error "Valid ZIP code is required"
- [ ] **TC-CHECK-009:** User enters invalid phone (e.g., "123")
  - Expected: Error "Valid phone number is required"
- [ ] **TC-CHECK-010:** User enters valid 5-digit ZIP (e.g., "12345")
  - Expected: Accepted, proceeds to next stage
- [ ] **TC-CHECK-011:** User enters ZIP+4 format (e.g., "12345-6789")
  - Expected: Accepted, proceeds to next stage
- [ ] **TC-CHECK-012:** User enters 10-digit phone (e.g., "5551234567")
  - Expected: Accepted, proceeds to next stage
- [ ] **TC-CHECK-013:** Order total mismatch (price manipulation attempt)
  - Expected: Server rejects, error shown

### CHECK-C03: Payment Error Handling
- [ ] **TC-CHECK-014:** Payment processing fails (simulated)
  - Expected: Error "Payment failed: [reason]. Please try again."
- [ ] **TC-CHECK-015:** After payment failure, user is returned to payment stage
  - Expected: Can retry payment, address preserved
- [ ] **TC-CHECK-016:** Network timeout during payment
  - Expected: Error "Network error: Please check your connection."
- [ ] **TC-CHECK-017:** Server error during order creation
  - Expected: Error "Server error: Please try again later."
- [ ] **TC-CHECK-018:** Successful payment
  - Expected: Cart cleared, success screen shown
- [ ] **TC-CHECK-019:** User tries to place order twice (double click)
  - Expected: Only one order created (idempotency)

---

## 🔄 Integration Testing

### Cross-Module Workflows
- [ ] **TC-INT-001:** End-to-end purchase flow
  - Browse → Add to Cart → Checkout → Payment → Success
- [ ] **TC-INT-002:** Authentication + Shopping
  - Register → Verify Email → Browse → Add to Cart → Checkout
- [ ] **TC-INT-003:** Search + Filter + Cart
  - Search "eco" → Filter by price → Add items → Checkout
- [ ] **TC-INT-004:** Cart persistence across login/logout
  - Add items → Logout → Login → Cart restored
- [ ] **TC-INT-005:** Multiple tabs/windows (web)
  - Cart updates sync across tabs

---

## 📱 Device/Platform Testing

### Android
- [ ] Android 10 (API 29)
- [ ] Android 11 (API 30)
- [ ] Android 12+ (API 31+)
- [ ] Various screen sizes (phone, tablet)

### iOS
- [ ] iOS 13
- [ ] iOS 14
- [ ] iOS 15+
- [ ] iPhone SE (small screen)
- [ ] iPhone Pro Max (large screen)
- [ ] iPad

### Web
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)

---

## ⚡ Performance Testing

- [ ] **PERF-001:** App cold start time < 3 seconds
- [ ] **PERF-002:** Search results appear < 1 second after typing stops
- [ ] **PERF-003:** Cart updates feel instant (optimistic updates)
- [ ] **PERF-004:** Product list scroll smooth (60 FPS)
- [ ] **PERF-005:** No memory leaks after 30 minutes of use

---

## 🔒 Security Testing

- [ ] **SEC-001:** Firestore rules prevent unauthorized data access
- [ ] **SEC-002:** Storage rules prevent unauthorized file uploads
- [ ] **SEC-003:** Order total validation prevents price manipulation
- [ ] **SEC-004:** Password reset tokens expire properly
- [ ] **SEC-005:** Email verification required for sensitive actions

---

## 🐛 Regression Testing

### Areas to Watch
- [ ] Login/Logout still works correctly
- [ ] Product images load properly
- [ ] Wishlist functionality (if implemented) unaffected
- [ ] Profile update still works
- [ ] Order history displays correctly

---

## 📊 Test Results Template

```
Test ID: TC-XXXX-XXX
Test Name: [Name]
Tester: [Name]
Date: [Date]
Status: [PASS/FAIL/BLOCKED]
Environment: [Dev/Staging/Production]

Steps:
1. [Step 1]
2. [Step 2]

Expected Result: [Expected]
Actual Result: [Actual]

Notes: [Any observations]
Screenshots: [Attach if needed]
```

---

## ✅ Sign-Off Criteria

### Must Pass Before Production
- [ ] Zero CRITICAL bugs remaining
- [ ] Zero HIGH priority bugs in core flows
- [ ] All authentication tests pass
- [ ] All checkout tests pass
- [ ] Cart persistence verified
- [ ] Performance benchmarks met
- [ ] Security audit passed

### Nice to Have
- [ ] All MEDIUM bugs resolved
- [ ] All LOW bugs documented
- [ ] Analytics tracking verified
- [ ] Error logging functional

---

## 🚀 Deployment Approval

**QA Lead:** _________________ Date: _______  
**Dev Lead:** _________________ Date: _______  
**Product Manager:** _________________ Date: _______  

---

**Notes:**
- All test cases should be executed on at least 2 different devices
- Document all failures with screenshots and logs
- Retest all failed cases after fixes
- Verify fixes don't introduce new regressions

---

*Sprint 1 QA Checklist - Version 1.0*  
*Last Updated: February 24, 2026*
