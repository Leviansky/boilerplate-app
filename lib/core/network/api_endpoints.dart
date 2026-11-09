abstract final class ApiEndpoints {
  // Auth Endpoints
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String verifyPin = '/api/v1/auth/verify-pin';
  static const String verifyOtp = '/api/v1/auth/verify-otp';

  // Product & Catalog Endpoints
  static const String products = '/api/v1/products';
  static const String productDetail = '/api/v1/products/{id}';
  static const String categories = '/api/v1/categories';

  // Checkout & Sensitive Financial Endpoints
  static const String checkoutValidate = '/api/v1/checkout/validate';
  static const String createOrder = '/api/v1/checkout/order';
  static const String processPayment = '/api/v1/payments/process';
  static const String paymentChannels = '/api/v1/payments/channels';
}
