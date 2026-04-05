import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Manages Firebase ID token lifecycle with automatic refresh
/// 
/// This class ensures that API requests always use valid, non-expired tokens
/// and handles automatic token refresh before expiration.
class AuthTokenManager {
  final FirebaseAuth _firebaseAuth;
  final Logger _logger = Logger();

  String? _cachedToken;
  DateTime? _tokenExpiry;

  // Token refresh threshold: refresh 5 minutes before expiry
  static const _refreshThreshold = Duration(minutes: 5);
  
  // Firebase ID tokens expire after 1 hour
  static const _tokenLifetime = Duration(hours: 1);

  AuthTokenManager(this._firebaseAuth);

  /// Get a valid ID token, refreshing if necessary
  /// 
  /// Returns null if user is not authenticated.
  /// Automatically refreshes token if it's about to expire.
  Future<String?> getValidToken({bool forceRefresh = false}) async {
    final user = _firebaseAuth.currentUser;
    
    if (user == null) {
      _logger.w('🔒 [AuthTokenManager] No authenticated user');
      clearToken();
      return null;
    }

    // Check if cached token is still valid
    if (!forceRefresh && _cachedToken != null && _tokenExpiry != null) {
      final now = DateTime.now();
      final timeUntilExpiry = _tokenExpiry!.difference(now);
      
      if (timeUntilExpiry > _refreshThreshold) {
        _logger.d('🔑 [AuthTokenManager] Using cached token (expires in ${timeUntilExpiry.inMinutes}m)');
        return _cachedToken;
      }
      
      _logger.i('🔄 [AuthTokenManager] Token expires soon (${timeUntilExpiry.inMinutes}m), refreshing...');
    }

    // Fetch new token from Firebase
    try {
      final idToken = await user.getIdToken(forceRefresh);
      
      if (idToken != null) {
        _cachedToken = idToken;
        _tokenExpiry = DateTime.now().add(_tokenLifetime);
        
        _logger.i('✅ [AuthTokenManager] Token refreshed successfully');
        return idToken;
      }
      
      _logger.e('❌ [AuthTokenManager] Failed to get token: idToken is null');
      return null;
      
    } catch (e) {
      _logger.e('❌ [AuthTokenManager] Token refresh failed', error: e);
      clearToken();
      return null;
    }
  }

  /// Clear cached token (call on logout)
  void clearToken() {
    _cachedToken = null;
    _tokenExpiry = null;
    _logger.i('🗑️  [AuthTokenManager] Token cache cleared');
  }

  /// Get time remaining until token expiry
  Duration? getTimeUntilExpiry() {
    if (_tokenExpiry == null) return null;
    return _tokenExpiry!.difference(DateTime.now());
  }

  /// Check if token exists and is valid
  bool get hasValidToken {
    if (_cachedToken == null || _tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  /// Force token refresh (use sparingly)
  Future<String?> forceRefresh() async {
    _logger.i('🔄 [AuthTokenManager] Forcing token refresh');
    return getValidToken(forceRefresh: true);
  }
}
