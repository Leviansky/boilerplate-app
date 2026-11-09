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
import "package:testing_boilerplate/app/modules/checkout/controllers/checkout_controller.dart";
import "package:testing_boilerplate/app/modules/checkout/widgets/checkout_summary_card.dart";

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      enableScreenShield: true, // Sensitive financial screen: shield against screenshots/recordings
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Konfirmasi Pesanan'),
        ),
        body: Obx(() {
          return ScreenStateView(
            status: controller.viewStatus.value,
            onRetry: controller.initializeCheckout,
            errorMessage: controller.errorMessage.value,
            successView: _buildContent(context),
          );
        }),
        bottomNavigationBar: _buildBottomPayBar(),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final invoice = controller.invoice.value;
    if (invoice == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: AppSpacing.p16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Overview Card
          Container(
            padding: AppSpacing.p16,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.circular12,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.md,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                      size: 28.0,
                    ),
                  ),
                ),
                AppGaps.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.itemName.isNotEmpty ? invoice.itemName : 'Produk Pilihan',
                        style: AppTypography.headingSmall,
                      ),
                      if (invoice.variantName.isNotEmpty) ...[
                        AppGaps.vGap4,
                        Text(
                          'Varian: ${invoice.variantName} x ${controller.quantity}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppGaps.vGap16,

          // Payment Channel Selection Tile
          Container(
            padding: AppSpacing.p16,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.circular12,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Metode Pembayaran',
                      style: AppTypography.headingSmall,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.PAYMENT_SELECTION),
                      child: const Text('Ganti'),
                    ),
                  ],
                ),
                AppGaps.vGap8,
                Obx(() {
                  final channel = controller.selectedChannel.value;
                  if (channel == null) {
                    return const Text(
                      'Belum ada metode pembayaran dipilih',
                      style: AppTypography.bodyMedium,
                    );
                  }
                  return Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 20.0,
                      ),
                      AppGaps.hGap8,
                      Text(
                        channel.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          AppGaps.vGap16,

          // Voucher Input Tile
          Container(
            padding: AppSpacing.p16,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.circular12,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.voucherController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan Kode Voucher',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                ),
                AppGaps.hGap12,
                ElevatedButton(
                  onPressed: controller.initializeCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: const Text('Gunakan'),
                ),
              ],
            ),
          ),
          AppGaps.vGap24,

          // Server Calculated Summary Card
          CheckoutSummaryCard(invoice: invoice),
        ],
      ),
    );
  }

  Widget _buildBottomPayBar() {
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
            // Total Price Display
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Tagihan',
                  style: AppTypography.caption,
                ),
                Obx(() {
                  final total = controller.invoice.value?.totalAmount ?? 0;
                  return Text(
                    CurrencyFormatter.formatRupiah(total),
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
              ],
            ),
            AppGaps.hGap24,

            // Pessimistic Locking Pay Button
            Expanded(
              child: Obx(
                () => AppButton(
                  text: 'Bayar Sekarang',
                  isLoading: controller.isSubmittingPayment.value,
                  onPressed: controller.submitPayment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
