# Phase 2: Bug Catalog - Authentication Module

**Module:** Authentication  
**Review Date:** February 24, 2026  
**Severity Levels:** CRITICAL | HIGH | MEDIUM | LOW

---

## 🔴 CRITICAL BUGS

### BUG-AUTH-001: Forgot Password Not Implemented
**File:** `lib/features/authentication/presentation/bloc/auth_bloc.dart:94-108`  
**Severity:** CRITICAL  
**Category:** Missing Implementation  
**Impact:** Users cannot reset forgotten passwords

**Current Code:**
```dart
Future<void> _onForgotPassword(
  AuthForgotPasswordRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  try {
    // ❌ Placeholder: in a real app, call forgotPassword use case
    await Future.delayed(const Duration(seconds: 1));
    emit(const AuthForgotPasswordSuccess(
      'Password reset link sent to your email',
    ));
  } catch (e) {
    emit(AuthError(e.toString()));
  }
}
```

**Issue:**
- Fake delay instead of actual Firebase password reset
- Users see success message but no email is sent
- Complete authentication recovery flow is broken

**Fix Priority:** P0 (Immediate)  
**Estimated Effort:** 2 hours

**Recommended Fix:**
```dart
Future<void> _onForgotPassword(
  AuthForgotPasswordRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  try {
    // ✅ Call actual repository method
    await forgotPasswordUseCase(event.email);
    emit(const AuthForgotPasswordSuccess(
      'Password reset link sent to your email',
    ));
  } catch (e) {
    emit(AuthError(e.toString()));
  }
}
```

**Required Changes:**
1. Create `ForgotPasswordUseCase` in domain layer
2. Implement in `AuthRepositoryImpl` (already exists in remote datasource)
3. Wire up dependency injection
4. Update BLoC to call use case

---

### BUG-AUTH-002: No Rate Limiting on Authentication
**Files:** 
- `lib/features/authentication/presentation/bloc/auth_bloc.dart`
- `lib/features/authentication/data/datasources/auth_remote_datasource.dart`

**Severity:** CRITICAL  
**Category:** Security Vulnerability  
**Impact:** Application vulnerable to brute force attacks

**Issue:**
- No client-side rate limiting implemented
- Users can attempt unlimited login/register attempts
- Enables credential stuffing attacks
- DoS vulnerability via excessive Firebase calls

**Fix Priority:** P0 (From Phase 1, partially addressed)  
**Estimated Effort:** 4 hours

**Recommended Fix:**
Already covered in `SECURITY_HARDENING_GUIDE.md` Section 2.2 - needs implementation

---

## 🟠 HIGH SEVERITY BUGS

### BUG-AUTH-003: Navigation Stack Not Cleared After Authentication
**File:** `lib/features/authentication/presentation/screens/register_screen.dart:64`  
**Severity:** HIGH  
**Category:** Navigation Logic Error  
**Impact:** Poor UX, users can navigate back to auth screens when logged in

**Current Code:**
```dart
} else if (state is AuthAuthenticated) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}
```

**Issue:**
- `popUntil((route) => route.isFirst)` doesn't work correctly with go_router
- Auth screens remain in navigation stack
- User can press back button and see login screen while authenticated
- Inconsistent with app router redirect logic

**Fix Priority:** P1 (High)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
} else if (state is AuthAuthenticated) {
  // ✅ Let go_router handle navigation via redirect
  // Router will automatically redirect to home based on auth state
  // No manual navigation needed
}
```

**Explanation:**
The `AppRouter` already has redirect logic that handles authenticated users. Manual navigation creates conflicts.

---

### BUG-AUTH-004: Error Messages Expose System Details
**File:** `lib/features/authentication/data/datasources/auth_remote_datasource.dart:59, 91, 112, 150`  
**Severity:** HIGH  
**Category:** Security - Information Disclosure  
**Impact:** Error messages reveal Firebase implementation details

**Current Code:**
```dart
} on firebase_auth.FirebaseAuthException catch (e) {
  throw Exception(e.message ?? 'Authentication failed');
}
```

**Issue:**
- Firebase error messages exposed directly to user
- Reveals backend implementation (Firebase)
- Aids attackers in reconnaissance
- Examples: "user-not-found", "wrong-password", "email-already-in-use"

**Fix Priority:** P1 (Covered in Phase 1 - needs implementation)  
**Estimated Effort:** 2 hours

**Recommended Fix:**
Use `ErrorHandler.getUserFriendlyMessage()` from Phase 1 security guide.

---

### BUG-AUTH-005: No Email Verification Flow
**Files:** 
- `lib/features/authentication/presentation/screens/register_screen.dart`
- `lib/features/authentication/data/datasources/auth_remote_datasource.dart`

**Severity:** HIGH  
**Category:** Missing Feature  
**Impact:** Users can register with fake emails, no email ownership verification

**Issue:**
- Registration completes without email verification
- Users gain full access immediately
- No `sendEmailVerification()` called
- Security and data quality concern

**Fix Priority:** P1 (High)  
**Estimated Effort:** 4 hours

**Recommended Fix:**
```dart
// In auth_remote_datasource.dart after registration
await user.sendEmailVerification();

// Add verification check in checkAuth()
if (!user.emailVerified) {
  throw Exception('Please verify your email address');
}
```

---

## 🟡 MEDIUM SEVERITY BUGS

### BUG-AUTH-006: Password Validation Inconsistency
**Files:**
- `lib/features/authentication/presentation/screens/login_screen.dart:134-139`
- `lib/features/authentication/presentation/screens/register_screen.dart:121`

**Severity:** MEDIUM  
**Category:** Validation Inconsistency  
**Impact:** Different validation rules between screens

**Login Screen (Weak):**
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  return null; // ❌ No strength validation
},
```

**Register Screen (Strong):**
```dart
validator: Validators.password, // ✅ Strong validation
```

**Issue:**
- Login accepts any password (only checks if not empty)
- Register enforces strong password rules
- Inconsistent user experience
- Confusing for users

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 30 minutes

**Recommended Fix:**
```dart
// Login screen should use same validator
validator: Validators.password,
```

**Note:** For login, we actually should NOT validate password strength (existing users may have weak passwords), but we should maintain minimum length check.

---

### BUG-AUTH-007: Social Login Buttons Non-Functional
**File:** `lib/features/authentication/presentation/screens/login_screen.dart:208`  
**Severity:** MEDIUM  
**Category:** Missing Implementation  
**Impact:** Feature shown but not working

**Issue:**
- Social login buttons displayed to users
- No implementation behind them
- Clicking does nothing (silently fails)
- False advertising of features

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 8 hours (full OAuth implementation)

**Options:**
1. **Implement:** Add Google/Apple/Facebook OAuth (8 hours)
2. **Remove:** Hide buttons until implemented (5 minutes)
3. **Disable with message:** Show "Coming Soon" (30 minutes)

**Recommended:** Option 3 (Disable with message) for MVP

---

### BUG-AUTH-008: Auto-filled Demo Credentials in Production
**File:** `lib/features/checkout/presentation/screens/checkout_screen.dart:24-30`  
**Severity:** MEDIUM  
**Category:** Development Code in Production  
**Impact:** Pre-filled form fields in production

**Current Code:**
```dart
final _nameController = TextEditingController(text: 'Alex Green');
final _address1Controller = TextEditingController(text: '123 Eco Way');
final _cityController = TextEditingController(text: 'Portland');
final _stateController = TextEditingController(text: 'OR');
final _zipController = TextEditingController(text: '97204');
final _phoneController = TextEditingController(text: '555-0123');
```

**Issue:**
- Hard-coded test data in production build
- Poor user experience
- Appears unprofessional
- User might not notice and submit wrong address

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 15 minutes

**Recommended Fix:**
```dart
final _nameController = TextEditingController();
final _address1Controller = TextEditingController();
// ... etc (remove all default values)
```

---

## 🟢 LOW SEVERITY BUGS

### BUG-AUTH-009: Missing Loading State on Social Buttons
**File:** `lib/features/authentication/presentation/widgets/social_login_buttons.dart`  
**Severity:** LOW  
**Category:** UX Issue  
**Impact:** No visual feedback when social login is triggered

**Issue:**
- No loading indicator on social auth buttons
- User doesn't know if click registered
- Can lead to multiple taps

**Fix Priority:** P3 (Low)  
**Estimated Effort:** 1 hour

---

### BUG-AUTH-010: Terms & Privacy Links Not Clickable
**File:** `lib/features/authentication/presentation/screens/register_screen.dart:166-168`  
**Severity:** LOW  
**Category:** Missing Functionality  
**Impact:** Legal links shown but not clickable

**Current Code:**
```dart
TextSpan(
  text: 'Terms of Service', 
  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)
),
```

**Issue:**
- Links styled to look clickable but aren't
- No GestureRecognizer attached
- Legal requirement may not be met

**Fix Priority:** P3 (Low)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
Use `flutter_linkify` or add `GestureRecognizer` to TextSpan.

---

## Summary Statistics

| Severity | Count | Total Effort |
|----------|-------|--------------|
| CRITICAL | 2 | 6 hours |
| HIGH | 4 | 11 hours |
| MEDIUM | 4 | 18 hours |
| LOW | 2 | 2 hours |
| **TOTAL** | **12** | **37 hours** |

**Next:** Product Module Bugs
