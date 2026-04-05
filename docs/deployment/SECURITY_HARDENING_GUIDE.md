# 🔒 Security Hardening Guide - EcoShop E-Commerce Application

**Version:** 1.0  
**Last Updated:** February 24, 2026  
**Severity Level:** CRITICAL - Immediate Implementation Required

---

## 📋 Executive Summary

This guide provides **actionable security hardening steps** for the EcoShop Flutter e-commerce application. All recommendations are prioritized by severity and aligned with OWASP Mobile Security standards.

### ⚠️ Critical Vulnerabilities Identified

| ID | Vulnerability | Severity | Status |
|----|---------------|----------|--------|
| SEC-001 | Mock token system instead of real Firebase ID tokens | **CRITICAL** | 🔴 Open |
| SEC-002 | Sensitive Firebase API keys in source control | **HIGH** | 🔴 Open |
| SEC-003 | No input validation on authentication flows | **HIGH** | 🔴 Open |
| SEC-004 | Missing token refresh mechanism | **MEDIUM** | 🔴 Open |
| SEC-005 | No rate limiting on API calls | **MEDIUM** | 🔴 Open |
| SEC-006 | Insufficient error message sanitization | **LOW** | 🔴 Open |

---

## 🎯 Phase 1: Critical Security Fixes (P0 - Immediate)

### 1.1 Replace Mock Token System with Real Firebase ID Tokens

**Current Issue:**  
```dart
// ❌ CRITICAL VULNERABILITY - lib/features/authentication/data/repositories/auth_repository_impl.dart:26
await localDataSource.cacheToken('mock_token_${user.id}');
```

**Fix Implementation:**

#### Step 1: Update `AuthRepositoryImpl` to use real Firebase tokens

```dart
// ✅ SECURE IMPLEMENTATION
// lib/features/authentication/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.login(
      email: email,
      password: password,
    );
    
    // ✅ Get real Firebase ID token
    final idToken = await _firebaseAuth.currentUser?.getIdToken();
    if (idToken != null) {
      await localDataSource.cacheToken(idToken);
    }
    
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );
    
    // ✅ Get real Firebase ID token
    final idToken = await _firebaseAuth.currentUser?.getIdToken();
    if (idToken != null) {
      await localDataSource.cacheToken(idToken);
    }
    
    await localDataSource.cacheUser(user);
    return user;
  }
}
```

#### Step 2: Update Dependency Injection

```dart
// lib/injection_container.dart

sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    remoteDataSource: sl<AuthRemoteDataSource>(),
    localDataSource: sl<AuthLocalDataSource>(),
    firebaseAuth: sl<FirebaseAuth>(), // ✅ Add this
  ),
);
```

#### Step 3: Implement Token Refresh Mechanism

```dart
// lib/core/network/auth_token_manager.dart (NEW FILE)

import 'package:firebase_auth/firebase_auth.dart';

class AuthTokenManager {
  final FirebaseAuth _firebaseAuth;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  AuthTokenManager(this._firebaseAuth);

  /// Get valid ID token, refreshing if necessary
  Future<String?> getValidToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    // Check if cached token is still valid (refresh 5 min before expiry)
    if (_cachedToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
        return _cachedToken;
      }
    }

    // Force refresh token
    final idToken = await user.getIdToken(true);
    _cachedToken = idToken;
    
    // Firebase ID tokens expire after 1 hour
    _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
    
    return idToken;
  }

  void clearToken() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}
```

#### Step 4: Update API Client with Token Interceptor

```dart
// lib/core/network/api_client.dart

class _AuthInterceptor extends Interceptor {
  final AuthTokenManager _tokenManager;

  _AuthInterceptor(this._tokenManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ✅ Automatically attach fresh token to all requests
    final token = await _tokenManager.getValidToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ✅ Handle 401 - Token expired, refresh and retry
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _tokenManager.getValidToken();
        if (newToken != null) {
          // Retry the request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          
          final response = await Dio().request(
            opts.path,
            options: Options(
              method: opts.method,
              headers: opts.headers,
            ),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          
          return handler.resolve(response);
        }
      } catch (e) {
        // Token refresh failed - logout user
        return handler.reject(err);
      }
    }
    handler.next(err);
  }
}
```

**Estimated Effort:** 4 hours  
**Risk Level:** LOW (Firebase SDK handles this natively)

---

### 1.2 Secure Firebase API Keys

**Current Issue:**  
API keys are hardcoded in `lib/firebase_options.dart` which is committed to source control.

**Fix Implementation:**

#### Step 1: Move sensitive config to environment variables

```dart
// lib/core/config/environment_config.dart (UPDATE)

import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  // ✅ Load from environment or build-time config
  static String get firebaseApiKey {
    const key = String.fromEnvironment('FIREBASE_API_KEY');
    if (key.isEmpty && kDebugMode) {
      // Development fallback
      return 'AIzaSyCaUFf1zyv-shYswlhj2cNHphkoZhWu-nY';
    }
    return key;
  }

  static String get firebaseProjectId {
    const id = String.fromEnvironment('FIREBASE_PROJECT_ID');
    return id.isEmpty ? 'ecoshop-store-2026' : id;
  }
  
  // Add other sensitive configs...
}
```

#### Step 2: Update `.gitignore`

```gitignore
# Firebase config (regenerate for each environment)
lib/firebase_options.dart
google-services.json
GoogleService-Info.plist
firebase-debug.log

# Environment files
.env
.env.local
.env.production
```

#### Step 3: Use build-time injection

```bash
# Build with environment variables
flutter build apk --dart-define=FIREBASE_API_KEY=your_key_here --dart-define=FIREBASE_PROJECT_ID=your_project_id
```

#### Step 4: Add API Key Restrictions in Firebase Console

**Critical Actions:**
1. Go to Google Cloud Console → Credentials
2. For each API key, set restrictions:
   - **Android Key:** Restrict to package name `com.example.ecoshop` + SHA-1 fingerprint
   - **iOS Key:** Restrict to bundle ID `com.example.ecoshop`
   - **Web Key:** Restrict to authorized domains only
3. Enable only required APIs (Auth, Firestore, Storage, FCM)

**Estimated Effort:** 2 hours  
**Risk Level:** LOW

---

### 1.3 Implement Input Validation & Sanitization

**Current Issue:**  
No validation on user inputs before sending to Firebase.

**Fix Implementation:**

#### Step 1: Create Comprehensive Validators

```dart
// lib/core/utils/validators.dart (UPDATE)

class Validators {
  // ✅ Enhanced email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Regex for RFC 5322 compliant email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    // ✅ Block disposable email domains
    final disposableDomains = [
      'tempmail.com', 'guerrillamail.com', '10minutemail.com',
      'throwaway.email', 'mailinator.com'
    ];
    
    final domain = value.split('@').last.toLowerCase();
    if (disposableDomains.contains(domain)) {
      return 'Disposable email addresses are not allowed';
    }
    
    return null;
  }

  // ✅ Strong password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for complexity
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!hasUppercase || !hasLowercase || !hasDigit) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    
    // ✅ Check against common passwords
    final commonPasswords = [
      'password', '12345678', 'qwerty', 'abc123', 'password123'
    ];
    
    if (commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a stronger one';
    }
    
    return null;
  }

  // ✅ Name validation (prevent XSS)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2 || value.length > 100) {
      return 'Name must be between 2 and 100 characters';
    }
    
    // Block HTML/Script tags
    final dangerousPattern = RegExp(r'<script|<iframe|javascript:|onerror=|onclick=', caseSensitive: false);
    if (dangerousPattern.hasMatch(value)) {
      return 'Invalid characters detected';
    }
    
    // Only allow letters, spaces, hyphens, apostrophes
    final validNamePattern = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!validNamePattern.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // ✅ Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove common formatting characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Must be 10-15 digits
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Please enter a valid phone number';
    }
    
    // Only digits allowed
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Phone number can only contain digits';
    }
    
    return null;
  }

  // ✅ Sanitize user input (remove dangerous characters)
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<.*?>'), '') // Remove all HTML tags
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .trim();
  }
}
```

#### Step 2: Apply Validation in Auth Screens

```dart
// lib/features/authentication/presentation/screens/register_screen.dart

TextFormField(
  controller: _emailController,
  validator: Validators.validateEmail, // ✅ Add validation
  autovalidateMode: AutovalidateMode.onUserInteraction,
  keyboardType: TextInputType.emailAddress,
  // ... other properties
),

TextFormField(
  controller: _passwordController,
  validator: Validators.validatePassword, // ✅ Add validation
  autovalidateMode: AutovalidateMode.onUserInteraction,
  obscureText: true,
  // ... other properties
),

TextFormField(
  controller: _nameController,
  validator: Validators.validateName, // ✅ Add validation
  autovalidateMode: AutovalidateMode.onUserInteraction,
  // ... other properties
),
```

#### Step 3: Server-side validation in Firestore Rules

Already implemented in `firestore.rules` - see validation functions.

**Estimated Effort:** 3 hours  
**Risk Level:** LOW

---

## 🛡️ Phase 2: Additional Security Enhancements (P1 - High Priority)

### 2.1 Implement Secure Storage for Sensitive Data

**Current Issue:**  
User tokens stored in SharedPreferences (unencrypted).

**Fix Implementation:**

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
// lib/features/authentication/data/datasources/auth_local_datasource.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  static const _userKey = 'cached_user';
  static const _tokenKey = 'auth_token';
  
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage; // ✅ Add secure storage

  AuthLocalDataSource(this._prefs, this._secureStorage);

  // ✅ Store token in secure storage
  Future<void> cacheToken(String token) async {
    await _secureStorage.write(
      key: _tokenKey,
      value: token,
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // ✅ Retrieve token from secure storage
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearCache() async {
    await _prefs.remove(_userKey);
    await _secureStorage.delete(key: _tokenKey); // ✅ Clear secure storage
  }
}
```

**Estimated Effort:** 2 hours  
**Risk Level:** LOW

---

### 2.2 Add Rate Limiting & Brute Force Protection

**Implementation:**

```dart
// lib/core/security/rate_limiter.dart (NEW FILE)

class RateLimiter {
  final Map<String, List<DateTime>> _attempts = {};
  final int maxAttempts;
  final Duration timeWindow;

  RateLimiter({
    this.maxAttempts = 5,
    this.timeWindow = const Duration(minutes: 15),
  });

  bool isAllowed(String identifier) {
    final now = DateTime.now();
    final attempts = _attempts[identifier] ?? [];
    
    // Remove old attempts outside time window
    attempts.removeWhere((time) => now.difference(time) > timeWindow);
    
    if (attempts.length >= maxAttempts) {
      return false; // Rate limit exceeded
    }
    
    attempts.add(now);
    _attempts[identifier] = attempts;
    return true;
  }

  void reset(String identifier) {
    _attempts.remove(identifier);
  }

  Duration getRetryAfter(String identifier) {
    final attempts = _attempts[identifier] ?? [];
    if (attempts.isEmpty) return Duration.zero;
    
    final oldestAttempt = attempts.first;
    final resetTime = oldestAttempt.add(timeWindow);
    return resetTime.difference(DateTime.now());
  }
}
```

**Usage in AuthBloc:**

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RateLimiter _rateLimiter = RateLimiter(maxAttempts: 5);

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // ✅ Check rate limit
    if (!_rateLimiter.isAllowed(event.email)) {
      final retryAfter = _rateLimiter.getRetryAfter(event.email);
      return emit(AuthError(
        message: 'Too many login attempts. Please try again in ${retryAfter.inMinutes} minutes.',
      ));
    }

    emit(AuthLoading());
    try {
      final user = await _loginUseCase(LoginParams(
        email: event.email,
        password: event.password,
      ));
      
      _rateLimiter.reset(event.email); // ✅ Reset on success
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

**Estimated Effort:** 3 hours  
**Risk Level:** LOW

---

### 2.3 Sanitize Error Messages

**Current Issue:**  
Error messages expose internal system details.

**Fix:**

```dart
// lib/core/error/error_handler.dart (NEW FILE)

class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // ✅ Map internal errors to safe user messages
    if (errorString.contains('user-not-found')) {
      return 'Invalid email or password';
    }
    if (errorString.contains('wrong-password')) {
      return 'Invalid email or password'; // Same message for security
    }
    if (errorString.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    }
    if (errorString.contains('weak-password')) {
      return 'Please choose a stronger password';
    }
    if (errorString.contains('network')) {
      return 'Network error. Please check your connection';
    }
    if (errorString.contains('permission-denied')) {
      return 'You do not have permission to perform this action';
    }
    
    // ✅ Generic fallback (don't expose details)
    return 'An error occurred. Please try again later';
  }
}
```

**Estimated Effort:** 1 hour  
**Risk Level:** VERY LOW

---

## 📊 Security Checklist

### Authentication & Authorization
- [ ] Replace mock tokens with real Firebase ID tokens
- [ ] Implement token refresh mechanism
- [ ] Add rate limiting on login/register
- [ ] Use secure storage for sensitive data
- [ ] Implement biometric authentication (optional)
- [ ] Add 2FA support (future enhancement)

### Data Protection
- [ ] Deploy Firestore security rules
- [ ] Deploy Storage security rules
- [ ] Encrypt sensitive data at rest
- [ ] Use HTTPS for all API calls
- [ ] Implement certificate pinning (optional)

### Input Validation
- [ ] Validate all user inputs client-side
- [ ] Sanitize inputs to prevent XSS
- [ ] Enforce strong password policy
- [ ] Block disposable email addresses
- [ ] Validate file uploads (size, type, content)

### Firebase Security
- [ ] Restrict API keys by platform
- [ ] Enable Firebase App Check
- [ ] Review and test Firestore rules
- [ ] Set up Firebase Security Rules Unit Tests
- [ ] Enable audit logging

### Code Security
- [ ] Remove hardcoded secrets from source
- [ ] Use environment variables for config
- [ ] Implement proper error handling
- [ ] Add security headers in web build
- [ ] Run static code analysis (flutter analyze)

---

## 🚀 Deployment Steps

### 1. Deploy Firebase Rules

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules
```

### 2. Test Security Rules

```bash
# Install emulator suite
firebase init emulators

# Start emulators
firebase emulators:start

# Run security tests
firebase emulators:exec "npm test"
```

### 3. Enable Firebase App Check

```bash
# In Firebase Console:
# 1. Go to Project Settings → App Check
# 2. Enable for each platform
# 3. Add SafetyNet (Android), DeviceCheck (iOS), reCAPTCHA (Web)
```

---

## 📈 Success Metrics

- **Zero** hardcoded secrets in source code
- **100%** of API calls using real Firebase tokens
- **95%+** reduction in successful brute-force attempts
- **Zero** XSS/injection vulnerabilities
- **A+** rating on OWASP Mobile Security Testing Guide

---

## 🆘 Emergency Response

If a security breach is detected:

1. **Immediately revoke** all Firebase API keys
2. **Force logout** all users (revoke refresh tokens via Admin SDK)
3. **Deploy emergency** Firestore rules (deny all writes)
4. **Notify users** via email/push notification
5. **Audit logs** in Firebase Console → Analytics → DebugView
6. **Patch vulnerability** and redeploy

---

## 📚 Additional Resources

- [OWASP Mobile Security Testing Guide](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [CWE Top 25 Software Weaknesses](https://cwe.mitre.org/top25/)

---

**Document Owner:** Development Team Lead  
**Review Cycle:** Quarterly  
**Next Review:** May 24, 2026
