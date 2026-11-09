import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/validators.dart";
import "package:testing_boilerplate/app/shared/widgets/app_button.dart";
import "package:testing_boilerplate/app/shared/widgets/safe_screen_wrapper.dart";
import "package:testing_boilerplate/app/modules/auth/controllers/auth_controller.dart";
import "package:testing_boilerplate/app/modules/auth/widgets/auth_header_widget.dart";

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pendaftaran Akun'),
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
                      title: 'Buat Akun Baru',
                      subtitle: 'Lengkapi data diri Anda sesuai identitas resmi untuk proteksi transaksi perbankan.',
                    ),
                    AppGaps.vGap24,

                    TextFormField(
                      controller: controller.nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap (Sesuai KTP)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    AppGaps.vGap16,

                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    AppGaps.vGap16,

                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validatePhone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Ponsel (WhatsApp)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    AppGaps.vGap16,

                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        validator: Validators.validatePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru (Min. 8 Karakter)',
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
                    AppGaps.vGap20,

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
                        text: 'Daftar Sekarang',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.register,
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
