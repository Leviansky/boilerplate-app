import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/network/error_handler.dart";
import "package:testing_boilerplate/core/values/app_constants.dart";
import "package:testing_boilerplate/app/shared/controllers/connectivity_controller.dart";
import "package:testing_boilerplate/app/shared/widgets/screen_state_view.dart";
import "package:testing_boilerplate/app/modules/product/data/models/category_model.dart";
import "package:testing_boilerplate/app/modules/product/data/models/product_model.dart";
import "package:testing_boilerplate/app/modules/product/data/repo/product_repository.dart";

class ProductController extends GetxController {
  final ProductRepository _repository;

  ProductController(this._repository);

  late final ScrollController scrollController;
  late final TextEditingController searchController;
  Timer? _debounceTimer;

  // Granular Observables
  final viewStatus = ViewStatus.initial.obs;
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final selectedCategoryId = ''.obs;
  final errorMessage = ''.obs;

  // Pagination variables
  int _currentPage = 1;
  final int _pageSize = AppConstants.defaultPageSize;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    searchController = TextEditingController();

    scrollController.addListener(_onScroll);
    loadInitialData();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (maxScroll - currentScroll <= AppConstants.scrollThresholdPx) {
      if (hasMoreData.value && !isLoadingMore.value && viewStatus.value == ViewStatus.success) {
        loadNextPage();
      }
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounce, () {
      loadInitialData();
    });
  }

  void selectCategory(String categoryId) {
    if (selectedCategoryId.value == categoryId) {
      selectedCategoryId.value = '';
    } else {
      selectedCategoryId.value = categoryId;
    }
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    // Check network connectivity first
    if (Get.isRegistered<ConnectivityController>() && !ConnectivityController.to.isOnline.value) {
      viewStatus.value = ViewStatus.noConnection;
      return;
    }

    try {
      viewStatus.value = ViewStatus.loading;
      _currentPage = 1;
      hasMoreData.value = true;
      errorMessage.value = '';

      final categoriesFuture = _repository.fetchCategories();
      final productsFuture = _repository.fetchProducts(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: searchController.text.trim(),
        categoryId: selectedCategoryId.value.isNotEmpty ? selectedCategoryId.value : null,
      );

      final results = await Future.wait([categoriesFuture, productsFuture]);

      final fetchedCategories = results[0] as List<CategoryModel>;
      final productsResponse = results[1] as dynamic;

      categories.assignAll(fetchedCategories);

      final fetchedProducts = productsResponse.data as List<ProductModel>? ?? [];
      products.assignAll(fetchedProducts);

      if (products.isEmpty) {
        viewStatus.value = ViewStatus.empty;
      } else {
        viewStatus.value = ViewStatus.success;
      }

      final pagination = productsResponse.pagination;
      if (pagination != null) {
        hasMoreData.value = pagination.hasNextPage;
      } else {
        hasMoreData.value = fetchedProducts.length >= _pageSize;
      }
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

  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      final nextPage = _currentPage + 1;

      final response = await _repository.fetchProducts(
        page: nextPage,
        pageSize: _pageSize,
        searchQuery: searchController.text.trim(),
        categoryId: selectedCategoryId.value.isNotEmpty ? selectedCategoryId.value : null,
      );

      final nextProducts = response.data ?? [];
      if (nextProducts.isNotEmpty) {
        _currentPage = nextPage;
        products.addAll(nextProducts);
      }

      final pagination = response.pagination;
      if (pagination != null) {
        hasMoreData.value = pagination.hasNextPage;
      } else {
        hasMoreData.value = nextProducts.length >= _pageSize;
      }
    } catch (_) {
      // Keep existing data visible on pagination fail
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshCatalog() async {
    await loadInitialData();
  }
}
