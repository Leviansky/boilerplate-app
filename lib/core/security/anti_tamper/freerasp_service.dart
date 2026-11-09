import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freerasp/freerasp.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/core/service/secure_storage_service.dart";

class FreeRaspService extends GetxService {
  static FreeRaspService get to => Get.find<FreeRaspService>();

  final isDeviceTampered = false.obs;

  Future<FreeRaspService> init() async {
    // FreeRASP is natively supported on mobile (Android & iOS)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final config = TalsecConfig(
          androidConfig: AndroidConfig(
            packageName: 'com.enterprise.marketplace.testing_boilerplate',
            signingCertHashes: ['w/mItsNd4etnmK+xmAYsFcYbkTLPXeiYSBWCGGW1304='],
            supportedStores: ['com.sec.android.app.samsungapps'],
          ),
          iosConfig: IOSConfig(
            bundleIds: ['com.enterprise.marketplace.testingBoilerplate'],
            teamId: 'TEAMID12345',
          ),
          watcherMail: 'security-alerts@marketplace.enterprise.com',
          isProd: kReleaseMode,
        );

        final callback = ThreatCallback(
          onHooks: () => _handleThreat('HOOKING_FRAMEWORK_DETECTED'),
          onDebug: () => _handleThreat('DEBUGGER_ATTACHED'),
          onPasscode: () => _handleThreat('NO_DEVICE_PASSCODE'),
          onSimulator: () => _handleThreat('UNTRUSTED_SIMULATOR'),
          onAppIntegrity: () => _handleThreat('TAMPERED_APP_INTEGRITY'),
          onPrivilegedAccess: () => _handleThreat('PRIVILEGED_ACCESS_ROOT_OR_JAILBREAK'),
          onDevMode: () => _handleThreat('DEVELOPER_MODE_ACTIVE'),
          onADBEnabled: () => _handleThreat('ADB_DEBUGGING_ACTIVE'),
        );

        Talsec.instance.attachListener(callback);
        await Talsec.instance.start(config);
      } catch (e) {
        // If config fails or runs in non-mobile emulator, fail-safe log without throwing unhandled crash
      }
    }
    return this;
  }

  /// Zero-Trust Anti-Tamper Mitigation Protocol:
  /// Wipe all sensitive data, terminate in-memory controllers, and lock the app
  Future<void> _handleThreat(String threatReason) async {
    isDeviceTampered.value = true;
    try {
      if (Get.isRegistered<SecureStorageService>()) {
        await SecureStorageService.to.clearAll();
      }
      Get.deleteAll(force: true);

      // Force navigate to isolated compromised screen
      Get.offAllNamed(
        Routes.DEVICE_COMPROMISED,
        arguments: {'threat_reason': threatReason},
      );
    } catch (_) {
      // In worst-case fallback, terminate process immediately
      SystemNavigator.pop();
    }
  }
}
