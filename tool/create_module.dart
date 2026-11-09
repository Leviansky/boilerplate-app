import 'dart:io';

/// Automated Module Scaffolder CLI for Enterprise Flutter Marketplace
/// Usage: `dart run tool/create_module.dart <module_name>`
/// Example: `dart run tool/create_module.dart order_history`
void main(List<String> args) {
  if (args.isEmpty) {
    stdout.writeln('❌ Error: Nama modul belum dicantumkan.');
    stdout.writeln('Penggunaan: dart run tool/create_module.dart <module_name>');
    stdout.writeln('Contoh:     dart run tool/create_module.dart order_history');
    exit(1);
  }

  final rawName = args.first.trim();
  final snakeCase = _toSnakeCase(rawName);
  final pascalCase = _toPascalCase(snakeCase);
  final camelCase = _toCamelCase(snakeCase);

  stdout.writeln('🚀 Membuat modul baru: "$snakeCase" (Kelas: "$pascalCase")...');

  final baseDir = 'lib/app/modules/$snakeCase';

  // 1. Buat hierarki folder modul sesuai Bagian 2 Rules
  final directories = [
    '$baseDir/bindings',
    '$baseDir/controllers',
    '$baseDir/views',
    '$baseDir/widgets',
    '$baseDir/data/models',
    '$baseDir/data/providers',
    '$baseDir/data/repo',
  ];

  for (final dir in directories) {
    Directory(dir).createSync(recursive: true);
  }

  // 2. Generate Model (Defensive Parsing & Zero-Float)
  final modelFile = File('$baseDir/data/models/${snakeCase}_model.dart');
  modelFile.writeAsStringSync(_generateModel(pascalCase, snakeCase));

  // 3. Generate Provider (ApiClient calls with Failure translation)
  final providerFile = File('$baseDir/data/providers/${snakeCase}_provider.dart');
  providerFile.writeAsStringSync(_generateProvider(pascalCase, snakeCase));

  // 4. Generate Repository (Single source of truth)
  final repoFile = File('$baseDir/data/repo/${snakeCase}_repository.dart');
  repoFile.writeAsStringSync(_generateRepository(pascalCase, snakeCase, camelCase));

  // 5. Generate Controller (5-State Contract, lifecycle disposal, granular obs)
  final controllerFile = File('$baseDir/controllers/${snakeCase}_controller.dart');
  controllerFile.writeAsStringSync(_generateController(pascalCase, snakeCase, camelCase));

  // 6. Generate Binding (Get.lazyPut)
  final bindingFile = File('$baseDir/bindings/${snakeCase}_binding.dart');
  bindingFile.writeAsStringSync(_generateBinding(pascalCase, snakeCase));

  // 7. Generate Widget (Delegasi ke Shared / Local with tokens)
  final widgetFile = File('$baseDir/widgets/${snakeCase}_item_card.dart');
  widgetFile.writeAsStringSync(_generateWidget(pascalCase, snakeCase));

  // 8. Generate View (SafeScreenWrapper, ScreenStateView 5-states, sliver virtualization, granular Obx)
  final viewFile = File('$baseDir/views/${snakeCase}_view.dart');
  viewFile.writeAsStringSync(_generateView(pascalCase, snakeCase, camelCase));

  stdout.writeln('✅ Seluruh berkas modul "$snakeCase" berhasil dibuat:');
  stdout.writeln('   📄 $baseDir/bindings/${snakeCase}_binding.dart');
  stdout.writeln('   📄 $baseDir/controllers/${snakeCase}_controller.dart');
  stdout.writeln('   📄 $baseDir/views/${snakeCase}_view.dart');
  stdout.writeln('   📄 $baseDir/widgets/${snakeCase}_item_card.dart');
  stdout.writeln('   📄 $baseDir/data/models/${snakeCase}_model.dart');
  stdout.writeln('   📄 $baseDir/data/providers/${snakeCase}_provider.dart');
  stdout.writeln('   📄 $baseDir/data/repo/${snakeCase}_repository.dart');

  stdout.writeln('\n📌 Langkah Pendaftaran Navigasi:');
  stdout.writeln('1. Tambahkan konstanta rute di "lib/app/routes/app_routes.dart":');
  stdout.writeln('   static const String $camelCase = "/$snakeCase";');
  stdout.writeln('   static const String ${_toConstantCase(snakeCase)} = $camelCase;');
  stdout.writeln('\n2. Daftarkan GetPage di "lib/app/routes/app_pages.dart":');
  stdout.writeln('''   GetPage(
     name: Routes.$camelCase,
     page: () => const ${pascalCase}View(),
     binding: ${pascalCase}Binding(),
     middlewares: [
       SecurityMiddleware(),
       AuthMiddleware(),
       SessionMiddleware(),
     ],
     transition: Transition.rightToLeft,
   ),''');
}

String _generateModel(String pascalCase, String snakeCase) {
  return '''class ${pascalCase}Model {
  final String id;
  final String title;
  final String description;
  final int price; // Zero-Float: bilangan bulat satuan minor (Rupiah)
  final String createdAt;

  const ${pascalCase}Model({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.createdAt,
  });

  /// Defensive fail-safe JSON parsing (Tanpa explicit type casting mentah)
  factory ${pascalCase}Model.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ${pascalCase}Model(
        id: '',
        title: '',
        description: '',
        price: 0,
        createdAt: '',
      );
    }

    return ${pascalCase}Model(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'created_at': createdAt,
    };
  }
}
''';
}

String _generateProvider(String pascalCase, String snakeCase) {
  return '''import 'package:testing_boilerplate/core/network/api_client.dart';
import 'package:testing_boilerplate/app/shared/models/base_api_response_model.dart';
import '../models/${snakeCase}_model.dart';

class ${pascalCase}Provider {
  final ApiClient _apiClient;

  ${pascalCase}Provider(this._apiClient);

  Future<BaseApiResponseModel<List<${pascalCase}Model>>> get${pascalCase}List({
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/$snakeCase',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    return BaseApiResponseModel<List<${pascalCase}Model>>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) {
        if (data is List) {
          return data
              .map((item) => ${pascalCase}Model.fromJson(item as Map<String, dynamic>?))
              .toList();
        }
        return <${pascalCase}Model>[];
      },
    );
  }
}
''';
}

String _generateRepository(String pascalCase, String snakeCase, String camelCase) {
  return '''import 'package:testing_boilerplate/core/network/error_handler.dart';
import 'package:testing_boilerplate/app/shared/models/base_api_response_model.dart';
import '../models/${snakeCase}_model.dart';
import '../providers/${snakeCase}_provider.dart';

class ${pascalCase}Repository {
  final ${pascalCase}Provider _provider;

  ${pascalCase}Repository(this._provider);

  Future<BaseApiResponseModel<List<${pascalCase}Model>>> fetch${pascalCase}List({
    required int page,
    required int pageSize,
  }) async {
    try {
      return await _provider.get${pascalCase}List(
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
''';
}

String _generateController(String pascalCase, String snakeCase, String camelCase) {
  return '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testing_boilerplate/core/network/error_handler.dart';
import 'package:testing_boilerplate/core/values/app_constants.dart';
import 'package:testing_boilerplate/app/shared/controllers/connectivity_controller.dart';
import 'package:testing_boilerplate/app/shared/widgets/screen_state_view.dart';
import '../data/models/${snakeCase}_model.dart';
import '../data/repo/${snakeCase}_repository.dart';

class ${pascalCase}Controller extends GetxController {
  final ${pascalCase}Repository _repository;

  ${pascalCase}Controller(this._repository);

  late final ScrollController scrollController;

  // Granular Observables
  final viewStatus = ViewStatus.initial.obs;
  final items = <${pascalCase}Model>[].obs;
  final errorMessage = ''.obs;

  // Pagination Variables
  int _currentPage = 1;
  final int _pageSize = AppConstants.defaultPageSize;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
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
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (maxScroll - currentScroll <= AppConstants.scrollThresholdPx) {
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
      hasMoreData.value = true;
      errorMessage.value = '';

      final response = await _repository.fetch${pascalCase}List(
        page: _currentPage,
        pageSize: _pageSize,
      );

      final fetchedItems = response.data ?? [];
      items.assignAll(fetchedItems);

      if (items.isEmpty) {
        viewStatus.value = ViewStatus.empty;
      } else {
        viewStatus.value = ViewStatus.success;
      }

      final pagination = response.pagination;
      if (pagination != null) {
        hasMoreData.value = pagination.hasNextPage;
      } else {
        hasMoreData.value = fetchedItems.length >= _pageSize;
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

      final response = await _repository.fetch${pascalCase}List(
        page: nextPage,
        pageSize: _pageSize,
      );

      final nextItems = response.data ?? [];
      if (nextItems.isNotEmpty) {
        _currentPage = nextPage;
        items.addAll(nextItems);
      }

      final pagination = response.pagination;
      if (pagination != null) {
        hasMoreData.value = pagination.hasNextPage;
      } else {
        hasMoreData.value = nextItems.length >= _pageSize;
      }
    } catch (_) {
      // Pertahankan data sebelumnya jika pagination gagal
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }
}
''';
}

String _generateBinding(String pascalCase, String snakeCase) {
  return '''import 'package:get/get.dart';
import 'package:testing_boilerplate/core/network/api_client.dart';
import '../controllers/${snakeCase}_controller.dart';
import '../data/providers/${snakeCase}_provider.dart';
import '../data/repo/${snakeCase}_repository.dart';

class ${pascalCase}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascalCase}Provider>(
      () => ${pascalCase}Provider(Get.find<ApiClient>()),
    );

    Get.lazyPut<${pascalCase}Repository>(
      () => ${pascalCase}Repository(Get.find<${pascalCase}Provider>()),
    );

    Get.lazyPut<${pascalCase}Controller>(
      () => ${pascalCase}Controller(Get.find<${pascalCase}Repository>()),
    );
  }
}
''';
}

String _generateWidget(String pascalCase, String snakeCase) {
  return '''import 'package:flutter/material.dart';
import 'package:testing_boilerplate/core/theme/app_colors.dart';
import 'package:testing_boilerplate/core/theme/spacing.dart';
import 'package:testing_boilerplate/core/theme/typography.dart';
import 'package:testing_boilerplate/core/utils/currency_formatter.dart';
import '../data/models/${snakeCase}_model.dart';

class ${pascalCase}ItemCard extends StatelessWidget {
  final ${pascalCase}Model item;
  final VoidCallback? onTap;

  const ${pascalCase}ItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.circular12,
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: AppSpacing.p16,
          title: Text(
            item.title,
            style: AppTypography.headingSmall,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGaps.vGap4,
              Text(
                item.description,
                style: AppTypography.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppGaps.vGap8,
              Text(
                CurrencyFormatter.formatRupiah(item.price),
                style: AppTypography.priceHighlightSmall,
              ),
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
''';
}

String _generateView(String pascalCase, String snakeCase, String camelCase) {
  return '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testing_boilerplate/core/theme/app_colors.dart';
import 'package:testing_boilerplate/core/theme/spacing.dart';
import 'package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart';
import 'package:testing_boilerplate/app/shared/widgets/screen_state_view.dart';
import '../controllers/${snakeCase}_controller.dart';
import '../widgets/${snakeCase}_item_card.dart';

class ${pascalCase}View extends GetView<${pascalCase}Controller> {
  const ${pascalCase}View({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      enableScreenShield: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('$pascalCase'),
        ),
        body: Obx(() {
          return ScreenStateView(
            status: controller.viewStatus.value,
            onRefresh: controller.refreshData,
            onRetry: controller.loadInitialData,
            errorMessage: controller.errorMessage.value,
            emptyMessage: 'Belum ada data $pascalCase tersedia saat ini.',
            successView: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: AppSpacing.p16,
                  sliver: Obx(() {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = controller.items[index];
                          return ${pascalCase}ItemCard(
                            item: item,
                            onTap: () {
                              // Navigasi ke detail item jika diperlukan
                            },
                          );
                        },
                        childCount: controller.items.length,
                      ),
                    );
                  }),
                ),
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (!controller.isLoadingMore.value) {
                      return const SizedBox.shrink();
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Center(
                        child: RepaintBoundary(
                          child: SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
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
''';
}

String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      )
      .replaceAll(RegExp(r'[\s\-]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '')
      .toLowerCase();
}

String _toPascalCase(String snake) {
  return snake
      .split('_')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
      .join();
}

String _toCamelCase(String snake) {
  final pascal = _toPascalCase(snake);
  if (pascal.isEmpty) return '';
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String _toConstantCase(String snake) {
  return snake.toUpperCase();
}
