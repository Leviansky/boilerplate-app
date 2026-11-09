import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/validators.dart";
import "package:testing_boilerplate/app/shared/widgets/app_button.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/app/modules/auth/controllers/auth_controller.dart";
import "package:testing_boilerplate/app/modules/auth/widgets/auth_header_widget.dart";

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      child: Scaffold(
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
                      title: 'Selamat Datang',
                      subtitle: 'Masuk dengan kredensial terverifikasi untuk melanjutkan transaksi aman.',
                    ),
                    AppGaps.vGap32,

                    // Email Input
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email Akun',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    AppGaps.vGap16,

                    // Password Input with granular visibility toggle
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        validator: Validators.validatePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                    ),
                    AppGaps.vGap16,

                    // Error Message Reactive Banner
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),

                    // Submit Button with Granular Obx
                    Obx(
                      () => AppButton(
                        text: 'Masuk Sekarang',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.login,
                      ),
                    ),
                    AppGaps.vGap24,

                    // Navigation to Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum memiliki akun? ',
                          style: AppTypography.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.REGISTER),
                          child: Text(
                            'Daftar Akun',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
