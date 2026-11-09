import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/currency_formatter.dart";
import "package:testing_boilerplate/app/shared/widgets/app_button.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/app/modules/checkout/controllers/checkout_controller.dart";

class OrderSuccessView extends GetView<CheckoutController> {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.arguments?['order_id']?.toString() ??
        controller.paymentResult.value?.orderId ??
        'INV-20261109-001';

    final totalPaid = controller.paymentResult.value?.totalPaid ??
        controller.invoice.value?.totalAmount ??
        0;

    return PopScope(
      canPop: false,
      child: SafeScreenWrapper(
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.p24,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                            size: 48.0,
                          ),
                        ),
                      ),
                      AppGaps.vGap24,
                      const Text(
                        'Pembayaran Berhasil!',
                        style: AppTypography.headingLarge,
                        textAlign: TextAlign.center,
                      ),
                      AppGaps.vGap8,
                      Text(
                        'Pesanan Anda dengan nomor referensi $orderId telah terverifikasi oleh sistem perbankan kami.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppGaps.vGap24,

                      // Payment Badge Card
                      Container(
                        width: double.infinity,
                        padding: AppSpacing.p16,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.circular12,
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Jumlah Dana Dibayarkan',
                              style: AppTypography.caption,
                            ),
                            AppGaps.vGap8,
                            Text(
                              CurrencyFormatter.formatRupiah(totalPaid),
                              style: AppTypography.headingLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppGaps.vGap32,

                      // Return to catalog CTA
                      AppButton(
                        text: 'Kembali ke Katalog Produk',
                        onPressed: () {
                          Get.offAllNamed(Routes.PRODUCT_LIST);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
