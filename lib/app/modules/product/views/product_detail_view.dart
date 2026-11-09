import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/currency_formatter.dart";
import "package:testing_boilerplate/app/shared/widgets/app_button.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/shared/widgets/screen_state_view.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/app/modules/product/controllers/product_detail_controller.dart";
import "package:testing_boilerplate/app/modules/product/widgets/product_gallery_carousel.dart";
import "package:testing_boilerplate/app/modules/product/widgets/variant_selector.dart";

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      enableScreenShield: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Detail Produk'),
        ),
        body: Obx(() {
          return ScreenStateView(
            status: controller.viewStatus.value,
            onRetry: () {
              final id = controller.product.value?.id ?? Get.arguments?['product_id'] ?? '';
              controller.loadProductDetail(id.toString());
            },
            errorMessage: controller.errorMessage.value,
            successView: _buildContent(context),
          );
        }),
        bottomNavigationBar: _buildBottomCheckoutBar(),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final product = controller.product.value;
    if (product == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gallery Carousel
          Obx(
            () => ProductGalleryCarousel(
              images: product.images,
              currentIndex: controller.currentImageIndex.value,
              onPageChanged: controller.setImageIndex,
            ),
          ),
          AppGaps.vGap16,

          Padding(
            padding: AppSpacing.p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Highlight
                Obx(() {
                  final price = controller.selectedVariant.value?.price ?? product.price;
                  return Text(
                    CurrencyFormatter.formatRupiah(price),
                    style: AppTypography.headingLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
                AppGaps.vGap8,

                // Title
                Text(
                  product.title,
                  style: AppTypography.headingMedium,
                ),
                AppGaps.vGap16,
                const Divider(),
                AppGaps.vGap16,

                // Variant Selector
                Obx(
                  () => VariantSelector(
                    variants: product.variants,
                    selectedVariant: controller.selectedVariant.value,
                    onVariantSelected: controller.selectVariant,
                  ),
                ),
                AppGaps.vGap24,

                // Description
                const Text(
                  'Deskripsi Produk',
                  style: AppTypography.headingSmall,
                ),
                AppGaps.vGap8,
                Text(
                  product.description,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar() {
    return Container(
      padding: AppSpacing.p16,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: AppRadius.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: controller.decrementQuantity,
                  ),
                  Obx(
                    () => Text(
                      controller.quantity.value.toString(),
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: controller.incrementQuantity,
                  ),
                ],
              ),
            ),
            AppGaps.hGap16,

            // Buy Now CTA Button
            Expanded(
              child: AppButton(
                text: 'Beli Sekarang',
                onPressed: () {
                  final currentProd = controller.product.value;
                  if (currentProd == null) return;

                  Get.toNamed(
                    Routes.CHECKOUT,
                    arguments: {
                      'item_id': currentProd.id,
                      'variant_id': controller.selectedVariant.value?.id ?? '',
                      'quantity': controller.quantity.value,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
