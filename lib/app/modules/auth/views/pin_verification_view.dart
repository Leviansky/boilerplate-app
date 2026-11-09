import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/security/biometrics/biometric_service.dart";
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/app/shared/widgets/custom_pin_pad.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/modules/auth/controllers/auth_controller.dart";

class PinVerificationView extends GetView<AuthController> {
  const PinVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final canUseBiometrics = Get.isRegistered<BiometricService>() &&
        BiometricService.to.canAuthenticateWithBiometrics.value;

    return PopScope(
      canPop: false, // Prevent bypassing lock via hardware back button
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
                        width: 56.0,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_clock_outlined,
                            color: AppColors.primary,
                            size: 32.0,
                          ),
                        ),
                      ),
                      AppGaps.vGap24,
                      const Text(
                        'Verifikasi PIN Transaksi',
                        style: AppTypography.headingMedium,
                        textAlign: TextAlign.center,
                      ),
                      AppGaps.vGap8,
                      const Text(
                        'Aplikasi terkunci demi keamanan data Anda. Masukkan 6 digit PIN untuk melanjutkan.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      AppGaps.vGap24,

                      // Error message if any
                      Obx(() {
                        if (controller.errorMessage.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: AppSpacing.p12,
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: AppRadius.md,
                            border: Border.all(color: AppColors.error, width: 0.8),
                          ),
                          child: Text(
                            controller.errorMessage.value,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),

                      // CustomPinPad with in-memory scrubbing
                      CustomPinPad(
                        pinLength: 6,
                        showBiometric: canUseBiometrics,
                        onBiometricPressed: controller.triggerBiometricUnlock,
                        onPinCompleted: (pinBytes) {
                          controller.verifyPin(pinBytes);
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
