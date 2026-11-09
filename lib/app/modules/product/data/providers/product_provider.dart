import "package:testing_boilerplate/core/network/api_client.dart";
import "package:testing_boilerplate/core/network/api_endpoints.dart";
import "package:testing_boilerplate/app/shared/models/base_api_response_model.dart";
import "package:testing_boilerplate/app/modules/product/data/models/category_model.dart";
import "package:testing_boilerplate/app/modules/product/data/models/product_model.dart";

class ProductProvider {
  final ApiClient _apiClient;

  ProductProvider(this._apiClient);

  Future<BaseApiResponseModel<List<ProductModel>>> getProducts({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? categoryId,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParameters['search'] = searchQuery.trim();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParameters['category_id'] = categoryId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: queryParameters,
    );

    return BaseApiResponseModel<List<ProductModel>>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) {
        if (data is List) {
          return data
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>?))
              .toList();
        }
        return <ProductModel>[];
      },
    );
  }

  Future<BaseApiResponseModel<ProductModel>> getProductDetail(String id) async {
    final path = ApiEndpoints.productDetail.replaceAll('{id}', id);
    final response = await _apiClient.get(path);

    return BaseApiResponseModel<ProductModel>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => ProductModel.fromJson(data as Map<String, dynamic>?),
    );
  }

  Future<BaseApiResponseModel<List<CategoryModel>>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);

    return BaseApiResponseModel<List<CategoryModel>>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) {
        if (data is List) {
          return data
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>?))
              .toList();
        }
        return <CategoryModel>[];
      },
    );
  }
}
