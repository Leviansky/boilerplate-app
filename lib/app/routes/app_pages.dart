import 'package:get/get.dart';
import "package:testing_boilerplate/app/middleware/auth_middleware.dart";
import "package:testing_boilerplate/app/middleware/security_middleware.dart";
import "package:testing_boilerplate/app/middleware/session_middleware.dart";
import "package:testing_boilerplate/app/modules/auth/bindings/auth_binding.dart";
import "package:testing_boilerplate/app/modules/auth/views/device_compromised_view.dart";
import "package:testing_boilerplate/app/modules/auth/views/login_view.dart";
import "package:testing_boilerplate/app/modules/auth/views/otp_view.dart";
import "package:testing_boilerplate/app/modules/auth/views/pin_verification_view.dart";
import "package:testing_boilerplate/app/modules/auth/views/register_view.dart";
import "package:testing_boilerplate/app/modules/checkout/bindings/checkout_binding.dart";
import "package:testing_boilerplate/app/modules/checkout/views/checkout_view.dart";
import "package:testing_boilerplate/app/modules/checkout/views/order_success_view.dart";
import "package:testing_boilerplate/app/modules/checkout/views/payment_selection_view.dart";
import "package:testing_boilerplate/app/modules/product/bindings/product_binding.dart";
import "package:testing_boilerplate/app/modules/product/views/product_detail_view.dart";
import "package:testing_boilerplate/app/modules/product/views/product_list_view.dart";
import 'app_routes.dart';

abstract final class AppPages {
  static const String initial = Routes.LOGIN;

  static final routes = <GetPage>[
    // Security Compromised Isolation Page
    GetPage(
      name: Routes.DEVICE_COMPROMISED,
      page: () => const DeviceCompromisedView(),
      transition: Transition.fade,
    ),

    // Auth Pages
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
      middlewares: [
        SecurityMiddleware(),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      middlewares: [
        SecurityMiddleware(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.OTP,
      page: () => const OtpView(),
      binding: AuthBinding(),
      middlewares: [
        SecurityMiddleware(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PIN_VERIFICATION,
      page: () => const PinVerificationView(),
      binding: AuthBinding(),
      middlewares: [
        SecurityMiddleware(),
      ],
      transition: Transition.downToUp,
    ),

    // Product Catalog Pages
    GetPage(
      name: Routes.PRODUCT_LIST,
      page: () => const ProductListView(),
      binding: ProductBinding(),
      middlewares: [
        SecurityMiddleware(),
        AuthMiddleware(),
        SessionMiddleware(),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PRODUCT_DETAIL,
      page: () => const ProductDetailView(),
      binding: ProductBinding(),
      middlewares: [
        SecurityMiddleware(),
        AuthMiddleware(),
        SessionMiddleware(),
      ],
      transition: Transition.rightToLeft,
    ),

    // Checkout & Sensitive Financial Pages
    GetPage(
      name: Routes.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: [
        SecurityMiddleware(),
        AuthMiddleware(),
        SessionMiddleware(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PAYMENT_SELECTION,
      page: () => const PaymentSelectionView(),
      binding: CheckoutBinding(),
      middlewares: [
        SecurityMiddleware(),
        AuthMiddleware(),
        SessionMiddleware(),
      ],
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.ORDER_SUCCESS,
      page: () => const OrderSuccessView(),
      binding: CheckoutBinding(),
      middlewares: [
        SecurityMiddleware(),
      ],
      transition: Transition.zoom,
    ),
  ];
}
