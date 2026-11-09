abstract final class AppConstants {
  // Network & Session Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration sessionIdleTimeout = Duration(minutes: 5);
  static const Duration backgroundLockTimeout = Duration(minutes: 2);

  // Pagination
  static const int defaultPageSize = 20;
  static const double scrollThresholdPx = 200.0;

  // Throttling & Debounce
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const Duration actionThrottle = Duration(milliseconds: 1000);

  // Security thresholds
  static const int maxPinAttempts = 3;
  static const int maxTimeSkewSeconds = 300; // 5 minutes max clock drift for HMAC
}
