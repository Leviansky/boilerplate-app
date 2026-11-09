import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/modules/checkout/controllers/checkout_controller.dart";
import "package:testing_boilerplate/app/modules/checkout/widgets/payment_channel_tile.dart";

class PaymentSelectionView extends GetView<CheckoutController> {
  const PaymentSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      enableScreenShield: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pilih Metode Pembayaran'),
        ),
        body: Obx(() {
          if (controller.paymentChannels.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada metode pembayaran tersedia.',
                style: AppTypography.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.p16,
            itemCount: controller.paymentChannels.length,
            itemBuilder: (context, index) {
              final channel = controller.paymentChannels[index];
              return Obx(() {
                final isSelected = controller.selectedChannel.value?.code == channel.code;
                return PaymentChannelTile(
                  channel: channel,
                  isSelected: isSelected,
                  onTap: () {
                    controller.selectPaymentChannel(channel);
                    Get.back();
                  },
                );
              });
            },
          );
        }),
      ),
    );
  }
}
