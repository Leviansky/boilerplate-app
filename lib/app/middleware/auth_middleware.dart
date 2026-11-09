import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/service/secure_storage_service.dart";
import "package:testing_boilerplate/core/values/storage_keys.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1; 
  
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<SecureStorageService>()) {
      return null;
    }

    // Auth endpoints that do not require login
    final isAuthRoute = route == Routes.LOGIN ||
        route == Routes.REGISTER ||
        route == Routes.OTP ||
        route == Routes.DEVICE_COMPROMISED;

    if (isAuthRoute) {
      return null;
    }

    // Check token presence synchronously via existing memory / storage check
    // If not authenticated, redirect to login
    return null;
  }

  /// Async validation before page is built
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    if (!Get.isRegistered<SecureStorageService>()) {
      return null;
    }

    final path = route.currentPage?.name;
    final isAuthRoute = path == Routes.LOGIN ||
        path == Routes.REGISTER ||
        path == Routes.OTP ||
        path == Routes.DEVICE_COMPROMISED;

    if (isAuthRoute) {
      return null;
    }

    final token = await SecureStorageService.to.read(key: StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }

    return null;
  }
}
