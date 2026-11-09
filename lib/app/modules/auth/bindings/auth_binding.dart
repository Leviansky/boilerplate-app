import 'package:get/get.dart';
import "package:testing_boilerplate/core/network/api_client.dart";
import "package:testing_boilerplate/core/service/secure_storage_service.dart";
import "package:testing_boilerplate/app/modules/auth/controllers/auth_controller.dart";
import "package:testing_boilerplate/app/modules/auth/data/providers/auth_provider.dart";
import "package:testing_boilerplate/app/modules/auth/data/repo/auth_repository.dart";

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(Get.find<ApiClient>()),
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        Get.find<AuthProvider>(),
        Get.find<SecureStorageService>(),
      ),
    );

    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthRepository>()),
    );
  }
}
