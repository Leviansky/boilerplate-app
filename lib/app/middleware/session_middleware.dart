import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/security/session/session_tracker.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";

class SessionMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (route == Routes.PIN_VERIFICATION ||
        route == Routes.LOGIN ||
        route == Routes.DEVICE_COMPROMISED) {
      return null;
    }

    if (Get.isRegistered<SessionTracker>() && SessionTracker.to.isSessionLocked.value) {
      return const RouteSettings(
        name: Routes.PIN_VERIFICATION,
        arguments: {'unlock_reason': 'SESSION_LOCKED_IDLE'},
      );
    }

    return null;
  }
}
