import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/security/anti_tamper/freerasp_service.dart";
import "package:testing_boilerplate/core/security/anti_tamper/safe_device_service.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";

class SecurityMiddleware extends GetMiddleware {
  @override
  int? get priority => 0; // Highest priority - security first

  @override
  RouteSettings? redirect(String? route) {
    if (route == Routes.DEVICE_COMPROMISED) {
      return null;
    }

    // Check FreeRASP and SafeDevice state
    final isFreeRaspTampered = Get.isRegistered<FreeRaspService>() &&
        FreeRaspService.to.isDeviceTampered.value;

    final isDeviceInsecure = Get.isRegistered<SafeDeviceService>() &&
        !SafeDeviceService.to.isDeviceSecure;

    if (isFreeRaspTampered || isDeviceInsecure) {
      return const RouteSettings(
        name: Routes.DEVICE_COMPROMISED,
        arguments: {'reason': 'DEVICE_INTEGRITY_VIOLATION'},
      );
    }

    return null;
  }
}
