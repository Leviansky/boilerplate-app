import 'package:get/get.dart';
import "package:testing_boilerplate/core/network/api_client.dart";
import "package:testing_boilerplate/app/modules/checkout/controllers/checkout_controller.dart";
import "package:testing_boilerplate/app/modules/checkout/data/providers/checkout_provider.dart";
import "package:testing_boilerplate/app/modules/checkout/data/repo/checkout_repository.dart";

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutProvider>(
      () => CheckoutProvider(Get.find<ApiClient>()),
    );

    Get.lazyPut<CheckoutRepository>(
      () => CheckoutRepository(Get.find<CheckoutProvider>()),
    );

    Get.lazyPut<CheckoutController>(
      () => CheckoutController(Get.find<CheckoutRepository>()),
    );
  }
}
