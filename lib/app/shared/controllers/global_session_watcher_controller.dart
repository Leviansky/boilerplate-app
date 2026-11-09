import 'package:get/get.dart';
import "package:testing_boilerplate/core/security/session/session_tracker.dart";
import "package:testing_boilerplate/core/service/secure_storage_service.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";

class GlobalSessionWatcherController extends GetxController {
  static GlobalSessionWatcherController get to => Get.find<GlobalSessionWatcherController>();

  final isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind reactivity to session tracker
    if (Get.isRegistered<SessionTracker>()) {
      ever(SessionTracker.to.isSessionLocked, (bool locked) {
        if (locked && isAuthenticated.value) {
          Get.toNamed(
            Routes.PIN_VERIFICATION,
            arguments: {'unlock_reason': 'IDLE_TIMEOUT'},
          );
        }
      });
    }
  }

  Future<void> endSession() async {
    isAuthenticated.value = false;
    if (Get.isRegistered<SecureStorageService>()) {
      await SecureStorageService.to.clearAll();
    }
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.LOGIN);
  }
}
