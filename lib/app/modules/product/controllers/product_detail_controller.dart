import 'package:get/get.dart';
import "package:testing_boilerplate/core/network/error_handler.dart";
import "package:testing_boilerplate/app/shared/widgets/screen_state_view.dart";
import "package:testing_boilerplate/app/modules/product/data/models/product_model.dart";
import "package:testing_boilerplate/app/modules/product/data/models/variant_model.dart";
import "package:testing_boilerplate/app/modules/product/data/repo/product_repository.dart";

class ProductDetailController extends GetxController {
  final ProductRepository _repository;

  ProductDetailController(this._repository);

  final viewStatus = ViewStatus.initial.obs;
  final product = Rxn<ProductModel>();
  final selectedVariant = Rxn<VariantModel>();
  final currentImageIndex = 0.obs;
  final quantity = 1.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final productId = Get.arguments?['product_id']?.toString() ?? '';
    if (productId.isNotEmpty) {
      loadProductDetail(productId);
    } else {
      viewStatus.value = ViewStatus.error;
      errorMessage.value = 'ID produk tidak ditemukan.';
    }
  }

  Future<void> loadProductDetail(String productId) async {
    try {
      viewStatus.value = ViewStatus.loading;
      errorMessage.value = '';

      final detail = await _repository.fetchProductDetail(productId);
      product.value = detail;

      if (detail.variants.isNotEmpty) {
        selectedVariant.value = detail.variants.first;
      }

      viewStatus.value = ViewStatus.success;
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      if (failure is NetworkFailure) {
        viewStatus.value = ViewStatus.noConnection;
      } else {
        errorMessage.value = failure.message;
        viewStatus.value = ViewStatus.error;
      }
    }
  }

  void selectVariant(VariantModel variant) {
    selectedVariant.value = variant;
  }

  void setImageIndex(int index) {
    currentImageIndex.value = index;
  }

  void incrementQuantity() {
    final maxStock = selectedVariant.value?.stock ?? product.value?.stock ?? 99;
    if (quantity.value < maxStock) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
}
