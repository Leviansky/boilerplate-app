import 'package:get/get.dart';
import "package:testing_boilerplate/core/network/api_client.dart";
import "package:testing_boilerplate/app/modules/product/controllers/product_controller.dart";
import "package:testing_boilerplate/app/modules/product/controllers/product_detail_controller.dart";
import "package:testing_boilerplate/app/modules/product/data/providers/product_provider.dart";
import "package:testing_boilerplate/app/modules/product/data/repo/product_repository.dart";

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductProvider>(
      () => ProductProvider(Get.find<ApiClient>()),
    );

    Get.lazyPut<ProductRepository>(
      () => ProductRepository(Get.find<ProductProvider>()),
    );

    Get.lazyPut<ProductController>(
      () => ProductController(Get.find<ProductRepository>()),
    );

    Get.lazyPut<ProductDetailController>(
      () => ProductDetailController(Get.find<ProductRepository>()),
    );
  }
}
