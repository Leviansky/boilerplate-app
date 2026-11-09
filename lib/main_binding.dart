import 'package:get/get.dart';
import 'app/shared/controllers/connectivity_controller.dart';
import 'app/shared/controllers/global_session_watcher_controller.dart';
import 'core/config/remote_config_service.dart';
import 'core/network/api_client.dart';
import 'core/security/anti_tamper/freerasp_service.dart';
import 'core/security/anti_tamper/safe_device_service.dart';
import 'core/security/biometrics/biometric_service.dart';
import 'core/security/session/session_tracker.dart';
import 'core/service/device_service.dart';
import 'core/service/secure_storage_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (Pre-initialized singletons in GetX registry)
    Get.lazyPut<SecureStorageService>(() => SecureStorageService(), fenix: true);
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<DeviceService>(() => DeviceService(), fenix: true);
    Get.lazyPut<BiometricService>(() => BiometricService(), fenix: true);
    Get.lazyPut<RemoteConfigService>(() => RemoteConfigService(), fenix: true);
    Get.lazyPut<FreeRaspService>(() => FreeRaspService(), fenix: true);
    Get.lazyPut<SafeDeviceService>(() => SafeDeviceService(), fenix: true);
    Get.lazyPut<SessionTracker>(() => SessionTracker(), fenix: true);

    // Global App-wide Controllers
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
    Get.put<GlobalSessionWatcherController>(GlobalSessionWatcherController(), permanent: true);
  }
}
