# Template & Blueprint Modul Baru (Enterprise Marketplace)

Dokumen ini menjelaskan struktur standar, kontrak arsitektur, dan cara membuat fitur/modul baru sesuai dengan direktif **Enterprise Flutter Marketplace Engineering, Security & Architecture Rules**.

---

## 🛠️ Cara Pembuatan Otomatis (CLI Scaffolder)

Untuk men-generate modul baru secara otomatis lengkap dengan seluruh berkas arsitektur yang valid:

```bash
dart run tool/create_module.dart <nama_modul>
```

**Contoh:**
```bash
dart run tool/create_module.dart order_history
```

Perintah di atas akan secara otomatis membuat struktur folder:
```text
lib/app/modules/order_history/
├── bindings/
│   └── order_history_binding.dart
├── controllers/
│   └── order_history_controller.dart
├── views/
│   └── order_history_view.dart
├── widgets/
│   └── order_history_item_card.dart
└── data/
    ├── models/
    │   └── order_history_model.dart
    ├── providers/
    │   └── order_history_provider.dart
    └── repo/
        └── order_history_repository.dart
```

---

## 📋 Cetak Biru (Blueprint) Berkas Modul Baru

### 1. Model: `data/models/<feature>_model.dart`
- **Zero-Float**: Simpan nominal mata uang sebagai `int` satuan minor (Rupiah bulat).
- **Defensive Parsing**: Wajib gunakan `tryParse` dan fallback default aman (hindari `as int` atau `as String`).

```dart
class FeatureModel {
  final String id;
  final String title;
  final int price; // Zero-Float
  final String createdAt;

  const FeatureModel({
    required this.id,
    required this.title,
    required this.price,
    required this.createdAt,
  });

  factory FeatureModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FeatureModel(id: '', title: '', price: 0, createdAt: '');
    }
    return FeatureModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'created_at': createdAt,
  };
}
```

---

### 2. Provider: `data/providers/<feature>_provider.dart`
- Menggunakan singleton `ApiClient` (terpasang SSL pinning & 5-interceptor pipeline).

```dart
import 'package:testing_boilerplate/core/network/api_client.dart';
import 'package:testing_boilerplate/app/shared/models/base_api_response_model.dart';
import '../models/feature_model.dart';

class FeatureProvider {
  final ApiClient _apiClient;
  FeatureProvider(this._apiClient);

  Future<BaseApiResponseModel<List<FeatureModel>>> getFeatureList({
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/features',
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    return BaseApiResponseModel<List<FeatureModel>>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => (data as List)
          .map((item) => FeatureModel.fromJson(item as Map<String, dynamic>?))
          .toList(),
    );
  }
}
```

---

### 3. Repository: `data/repo/<feature>_repository.dart`
- Single source of truth.
- Menerjemahkan exception ke domain `Failure` via `ErrorHandler.handle(e)`.

```dart
import 'package:testing_boilerplate/core/network/error_handler.dart';
import 'package:testing_boilerplate/app/shared/models/base_api_response_model.dart';
import '../models/feature_model.dart';
import '../providers/feature_provider.dart';

class FeatureRepository {
  final FeatureProvider _provider;
  FeatureRepository(this._provider);

  Future<BaseApiResponseModel<List<FeatureModel>>> fetchFeatureList({
    required int page,
    required int pageSize,
  }) async {
    try {
      return await _provider.getFeatureList(page: page, pageSize: pageSize);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
```

---

### 4. Controller: `controllers/<feature>_controller.dart`
- **5-State Contract**: `ViewStatus.initial`, `loading`, `success`, `empty`, `error`, `noConnection`.
- **Lifecycle Disposal**: `ScrollController`, `TextEditingController`, `Timer`, `StreamSubscription` dibersihkan pada `onClose()`.
- **Granular Reactivity**: Nama observable bersih (`isLoading.obs`, `items = <FeatureModel>[].obs`).

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testing_boilerplate/core/network/error_handler.dart';
import 'package:testing_boilerplate/core/values/app_constants.dart';
import 'package:testing_boilerplate/app/shared/controllers/connectivity_controller.dart';
import 'package:testing_boilerplate/app/shared/widgets/screen_state_view.dart';
import '../data/models/feature_model.dart';
import '../data/repo/feature_repository.dart';

class FeatureController extends GetxController {
  final FeatureRepository _repository;
  FeatureController(this._repository);

  late final ScrollController scrollController;
  final viewStatus = ViewStatus.initial.obs;
  final items = <FeatureModel>[].obs;
  final errorMessage = ''.obs;

  int _currentPage = 1;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    loadInitialData();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.maxScrollExtent - scrollController.position.pixels <= AppConstants.scrollThresholdPx) {
      if (hasMoreData.value && !isLoadingMore.value && viewStatus.value == ViewStatus.success) {
        loadNextPage();
      }
    }
  }

  Future<void> loadInitialData() async {
    if (Get.isRegistered<ConnectivityController>() && !ConnectivityController.to.isOnline.value) {
      viewStatus.value = ViewStatus.noConnection;
      return;
    }

    try {
      viewStatus.value = ViewStatus.loading;
      _currentPage = 1;
      errorMessage.value = '';

      final response = await _repository.fetchFeatureList(page: _currentPage, pageSize: AppConstants.defaultPageSize);
      final fetched = response.data ?? [];
      items.assignAll(fetched);
      viewStatus.value = items.isEmpty ? ViewStatus.empty : ViewStatus.success;
      hasMoreData.value = response.pagination?.hasNextPage ?? (fetched.length >= AppConstants.defaultPageSize);
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
      final response = await _repository.fetchFeatureList(page: nextPage, pageSize: AppConstants.defaultPageSize);
      final nextItems = response.data ?? [];
      if (nextItems.isNotEmpty) {
        _currentPage = nextPage;
        items.addAll(nextItems);
      }
      hasMoreData.value = response.pagination?.hasNextPage ?? (nextItems.length >= AppConstants.defaultPageSize);
    } finally {
      isLoadingMore.value = false;
    }
  }
}
```

---

### 5. Binding: `bindings/<feature>_binding.dart`
- Gunakan `Get.lazyPut<T>()` untuk semua dependensi.

```dart
import 'package:get/get.dart';
import 'package:testing_boilerplate/core/network/api_client.dart';
import '../controllers/feature_controller.dart';
import '../data/providers/feature_provider.dart';
import '../data/repo/feature_repository.dart';

class FeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeatureProvider>(() => FeatureProvider(Get.find<ApiClient>()));
    Get.lazyPut<FeatureRepository>(() => FeatureRepository(Get.find<FeatureProvider>()));
    Get.lazyPut<FeatureController>(() => FeatureController(Get.find<FeatureRepository>()));
  }
}
```

---

### 6. View: `views/<feature>_view.dart`
- **SafeScreenWrapper**: Pasang di luar Scaffold.
- **ScreenStateView**: Menangani kelima status otomatis.
- **Zero-Hardcoding**: Gunakan `AppColors`, `AppSpacing`, `AppGaps`, `AppRadius`, `AppTypography`.
- **Virtualisasi List**: Gunakan `CustomScrollView` + `SliverList` / `SliverGrid`.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testing_boilerplate/core/theme/app_colors.dart';
import 'package:testing_boilerplate/core/theme/spacing.dart';
import 'package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart';
import 'package:testing_boilerplate/app/shared/widgets/screen_state_view.dart';
import '../controllers/feature_controller.dart';
import '../widgets/feature_item_card.dart';

class FeatureView extends GetView<FeatureController> {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      enableScreenShield: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Nama Fitur')),
        body: Obx(() {
          return ScreenStateView(
            status: controller.viewStatus.value,
            onRefresh: controller.loadInitialData,
            onRetry: controller.loadInitialData,
            errorMessage: controller.errorMessage.value,
            successView: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverPadding(
                  padding: AppSpacing.p16,
                  sliver: Obx(() {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FeatureItemCard(item: controller.items[index]),
                        childCount: controller.items.length,
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
```

---

## 🔗 Pendaftaran Rute Navigasi

Setelah modul dibuat, daftarkan rutenya:

1. Di [`lib/app/routes/app_routes.dart`](file:///Users/cino/Documents/Work/testing_boilerplate/lib/app/routes/app_routes.dart):
   ```dart
   static const String feature = '/feature';
   static const String FEATURE = feature;
   ```

2. Di [`lib/app/routes/app_pages.dart`](file:///Users/cino/Documents/Work/testing_boilerplate/lib/app/routes/app_pages.dart):
   ```dart
   GetPage(
     name: Routes.feature,
     page: () => const FeatureView(),
     binding: FeatureBinding(),
     middlewares: [
       SecurityMiddleware(),
       AuthMiddleware(),
       SessionMiddleware(),
     ],
     transition: Transition.rightToLeft,
   ),
   ```
