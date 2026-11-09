import "package:testing_boilerplate/core/network/error_handler.dart";
import "package:testing_boilerplate/app/shared/models/base_api_response_model.dart";
import "package:testing_boilerplate/app/modules/product/data/models/category_model.dart";
import "package:testing_boilerplate/app/modules/product/data/models/product_model.dart";
import "package:testing_boilerplate/app/modules/product/data/providers/product_provider.dart";

class ProductRepository {
  final ProductProvider _provider;

  ProductRepository(this._provider);

  Future<BaseApiResponseModel<List<ProductModel>>> fetchProducts({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? categoryId,
  }) async {
    try {
      final response = await _provider.getProducts(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        categoryId: categoryId,
      );
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<ProductModel> fetchProductDetail(String id) async {
    try {
      final response = await _provider.getProductDetail(id);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerFailure(response.message, response.statusCode);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _provider.getCategories();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return <CategoryModel>[];
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
