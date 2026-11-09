import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/app/shared/widgets/app_button.dart";

class DeviceCompromisedView extends StatelessWidget {
  const DeviceCompromisedView({super.key});

  @override
  Widget build(BuildContext context) {
    final threatReason = Get.arguments?['threat_reason']?.toString() ??
        'Integritas Perangkat Tidak Memenuhi Standar Keamanan';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
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
                        color: AppColors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.gpp_bad_outlined,
                          color: AppColors.error,
                          size: 48.0,
                        ),
                      ),
                    ),
                    AppGaps.vGap24,
                    const Text(
                      'Peringatan Keamanan Kritis',
                      style: AppTypography.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    AppGaps.vGap12,
                    const Text(
                      'Aplikasi Marketplace Enterprise mendeteksi anomali pada lingkungan perangkat Anda '
                      '(seperti akses Root, Jailbreak, emulator tidak aman, atau framework modifikasi).',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    AppGaps.vGap16,
                    Container(
                      padding: AppSpacing.p12,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppRadius.md,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Indikator: $threatReason',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AppGaps.vGap32,
                    AppButton(
                      text: 'Tutup Aplikasi',
                      backgroundColor: AppColors.error,
                      onPressed: () {
                        SystemNavigator.pop();
                      },
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
