import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'core/config/env_config.dart';
import 'core/config/remote_config_service.dart';
import 'core/network/api_client.dart';
import 'core/security/anti_tamper/freerasp_service.dart';
import 'core/security/anti_tamper/safe_device_service.dart';
import 'core/security/biometrics/biometric_service.dart';
import 'core/security/session/session_tracker.dart';
import 'core/service/device_service.dart';
import 'core/service/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'main_binding.dart';

/// Common bootstrap logic shared by all flavor entry points
Future<void> bootstrapApp(Environment environment) async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize active environment flavor configuration
    EnvConfig.initialize(environment);

    // 2. Sanitized Global Error Handlers (Zero-Leakage in Production)
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!kReleaseMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kReleaseMode) {
        debugPrint('[Unhandled Exception]: $error\n$stack');
      }
      return true; // Mark as handled
    };

    // 3. Mandatory Zero-Trust Anti-Tamper & Security Services Initialization
    // Executed strictly before runApp()
    await Get.putAsync(() => SecureStorageService().init(), permanent: true);
    await Get.putAsync(() => DeviceService().init(), permanent: true);
    await Get.putAsync(() => FreeRaspService().init(), permanent: true);
    await Get.putAsync(() => SafeDeviceService().init(), permanent: true);
    await Get.putAsync(() => BiometricService().init(), permanent: true);
    await Get.putAsync(() => RemoteConfigService().init(), permanent: true);
    await Get.putAsync(() => ApiClient().init(), permanent: true);
    Get.put(SessionTracker(), permanent: true);

    // 4. Launch Enterprise Application
    runApp(const MarketplaceEnterpriseApp());
  }, (error, stack) {
    if (!kReleaseMode) {
      debugPrint('[Root Zone Error]: $error\n$stack');
    }
  });
}

class MarketplaceEnterpriseApp extends StatelessWidget {
  const MarketplaceEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: EnvConfig.appName,
      debugShowCheckedModeBanner: !EnvConfig.isProduction,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: MainBinding(),
      defaultTransition: Transition.cupertino,
    );
  }
}
