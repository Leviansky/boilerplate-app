import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/shared/widgets/screen_state_view.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/app/modules/product/controllers/product_controller.dart";
import "package:testing_boilerplate/app/modules/product/widgets/product_item_card.dart";

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      enableScreenShield: false, // Public catalog does not require screen shield
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Katalog Marketplace'),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () => Get.toNamed(Routes.CHECKOUT),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0.0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari produk berkualitas...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 18.0),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.loadInitialData();
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                    horizontal: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          return ScreenStateView(
            status: controller.viewStatus.value,
            onRefresh: controller.refreshCatalog,
            onRetry: controller.loadInitialData,
            emptyMessage: 'Tidak ada produk yang cocok dengan pencarian Anda.',
            errorMessage: controller.errorMessage.value,
            successView: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Category Filter Horizontal Row
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.categories.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      height: 48.0,
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: controller.categories.length,
                        separatorBuilder: (_, _) => AppGaps.hGap8,
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          final isSelected = controller.selectedCategoryId.value == category.id;

                          return ChoiceChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (_) => controller.selectCategory(category.id),
                            selectedColor: AppColors.primary,
                            labelStyle: AppTypography.bodySmall.copyWith(
                              color: isSelected ? AppColors.surface : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.md,
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),

                // Virtualized Dynamic Grid for Products
                SliverPadding(
                  padding: AppSpacing.p16,
                  sliver: Obx(() {
                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = controller.products[index];
                          return ProductItemCard(
                            product: product,
                            onTap: () {
                              Get.toNamed(
                                Routes.PRODUCT_DETAIL,
                                arguments: {'product_id': product.id},
                              );
                            },
                          );
                        },
                        childCount: controller.products.length,
                      ),
                    );
                  }),
                ),

                // Footer Loading Indicator for Infinite Pagination
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (!controller.isLoadingMore.value) {
                      return const SizedBox.shrink();
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
