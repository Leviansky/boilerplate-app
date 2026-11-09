import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/app/shared/widgets/app_button.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/modules/auth/controllers/auth_controller.dart";
import "package:testing_boilerplate/app/modules/auth/widgets/auth_header_widget.dart";

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi OTP'),
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.p24,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeaderWidget(
                      title: 'Kode Verifikasi 6 Digit',
                      subtitle: 'Masukkan kode OTP yang dikirimkan melalui SMS ke nomor ponsel terdaftar.',
                    ),
                    AppGaps.vGap32,

                    TextFormField(
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: AppTypography.headingMedium.copyWith(letterSpacing: 8.0),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '• • • • • •',
                      ),
                    ),
                    AppGaps.vGap24,

                    Obx(() {
                      if (controller.errorMessage.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: AppSpacing.p12,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: AppRadius.md,
                          border: Border.all(color: AppColors.error, width: 0.8),
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      );
                    }),

                    Obx(
                      () => AppButton(
                        text: 'Verifikasi Kode',
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          // Handle OTP verification
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
