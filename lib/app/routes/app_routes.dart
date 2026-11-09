// ignore_for_file: constant_identifier_names

abstract final class Routes {
  static const String initial = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String otp = '/auth/otp';
  static const String pinVerification = '/auth/pin-verification';
  static const String deviceCompromised = '/security/device-compromised';

  static const String productList = '/products';
  static const String productDetail = '/products/detail';

  static const String checkout = '/checkout';
  static const String paymentSelection = '/checkout/payment-selection';
  static const String orderSuccess = '/checkout/order-success';

  // Uppercase aliases for strict conformity with rules
  static const String INITIAL = initial;
  static const String LOGIN = login;
  static const String REGISTER = register;
  static const String OTP = otp;
  static const String PIN_VERIFICATION = pinVerification;
  static const String DEVICE_COMPROMISED = deviceCompromised;
  static const String PRODUCT_LIST = productList;
  static const String PRODUCT_DETAIL = productDetail;
  static const String CHECKOUT = checkout;
  static const String PAYMENT_SELECTION = paymentSelection;
  static const String ORDER_SUCCESS = orderSuccess;
}
