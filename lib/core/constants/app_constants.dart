/// Application-wide constants
class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────────────────
  static const String appName = 'EcoShop';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Shop Sustainably, Live Consciously';

  // ─── API ──────────────────────────────────────────────────────
  static const int apiTimeout = 30000;
  static const int maxRetries = 3;

  // ─── Pagination ───────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // ─── Cache ────────────────────────────────────────────────────
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // ─── Validation ───────────────────────────────────────────────
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int phoneLength = 10;
  static const int otpLength = 6;

  // ─── Image ────────────────────────────────────────────────────
  static const double productImageAspectRatio = 1.0;
  static const double bannerAspectRatio = 16 / 9;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // ─── Cart ─────────────────────────────────────────────────────
  static const int maxCartItems = 99;
  static const int maxQuantityPerItem = 10;
  static const double freeShippingThreshold = 50.0;
  static const double shippingCost = 5.99;
  static const double taxRate = 0.08;

  // ─── Currency ─────────────────────────────────────────────────
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';

  // ─── Animation Keys ──────────────────────────────────────────
  static const String heroTagProduct = 'product_hero_';
  static const String heroTagCart = 'cart_hero';
}
