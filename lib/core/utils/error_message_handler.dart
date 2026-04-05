/// Error message handler for user-friendly error messages
/// 
/// Prevents exposing system details and provides helpful messages
class ErrorMessageHandler {
  ErrorMessageHandler._();

  /// Convert Firebase auth errors to user-friendly messages
  static String getUserFriendlyAuthMessage(String errorCode) {
    switch (errorCode) {
      // Login errors
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      
      // Registration errors
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      
      case 'invalid-email':
        return 'Please enter a valid email address.';
      
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with letters and numbers.';
      
      case 'operation-not-allowed':
        return 'This sign-in method is not available. Please contact support.';
      
      // Password reset errors
      case 'expired-action-code':
        return 'This reset link has expired. Please request a new one.';
      
      case 'invalid-action-code':
        return 'This reset link is invalid. Please request a new one.';
      
      // Network errors
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      
      // Default
      default:
        if (errorCode.contains('network') || errorCode.contains('timeout')) {
          return 'Connection error. Please check your internet and try again.';
        }
        return 'An error occurred. Please try again.';
    }
  }

  /// Convert general exceptions to user-friendly messages
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Connection error. Please check your internet.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('permission')) {
      return 'Permission denied. Please check your account permissions.';
    }
    
    if (errorString.contains('not found')) {
      return 'The requested resource was not found.';
    }
    
    // Generic fallback - don't expose technical details
    return 'Something went wrong. Please try again.';
  }

  /// Extract Firebase error code from exception message
  static String? extractFirebaseErrorCode(String message) {
    // Firebase auth errors often come in format: "[firebase_auth/error-code] message"
    final regex = RegExp(r'\[firebase_auth/([^\]]+)\]');
    final match = regex.firstMatch(message);
    return match?.group(1);
  }
}
