import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import 'app_button.dart';

enum ViewStatus { initial, loading, success, empty, error, noConnection }

class ScreenStateView extends StatelessWidget {
  final ViewStatus status;
  final Widget successView;
  final Widget? shimmerLoadingView;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final String? emptyMessage;
  final String? errorMessage;
  final String? emptyCtaText;
  final VoidCallback? onEmptyCtaPressed;

  const ScreenStateView({
    super.key,
    required this.status,
    required this.successView,
    this.shimmerLoadingView,
    this.onRetry,
    this.onRefresh,
    this.emptyMessage,
    this.errorMessage,
    this.emptyCtaText,
    this.onEmptyCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (status) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        content = shimmerLoadingView ?? _buildDefaultShimmer();
        break;

      case ViewStatus.empty:
        content = _buildEmptyState();
        break;

      case ViewStatus.error:
        content = _buildErrorState();
        break;

      case ViewStatus.noConnection:
        content = _buildNoConnectionState();
        break;

      case ViewStatus.success:
        content = successView;
        break;
    }

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: content,
      );
    }

    return content;
  }

  Widget _buildDefaultShimmer() {
    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: ListView.builder(
          padding: AppSpacing.p16,
          itemCount: 6,
          itemBuilder: (_, _) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.md,
                  ),
                ),
                AppGaps.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16.0,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.sm,
                        ),
                      ),
                      AppGaps.vGap8,
                      Container(
                        width: 140.0,
                        height: 14.0,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.sm,
                        ),
                      ),
                      AppGaps.vGap8,
                      Container(
                        width: 80.0,
                        height: 14.0,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.sm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.p24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64.0,
              color: AppColors.textTertiary,
            ),
            AppGaps.vGap16,
            Text(
              emptyMessage ?? 'Tidak ada data ditemukan',
              style: AppTypography.headingSmall,
              textAlign: TextAlign.center,
            ),
            AppGaps.vGap8,
            const Text(
              'Belum ada konten yang dapat ditampilkan saat ini.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (emptyCtaText != null && onEmptyCtaPressed != null) ...[
              AppGaps.vGap24,
              AppButton(
                text: emptyCtaText!,
                onPressed: onEmptyCtaPressed,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: AppSpacing.p24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64.0,
              color: AppColors.error,
            ),
            AppGaps.vGap16,
            Text(
              errorMessage ?? 'Terjadi Kesalahan Server',
              style: AppTypography.headingSmall,
              textAlign: TextAlign.center,
            ),
            AppGaps.vGap8,
            const Text(
              'Gagal memuat informasi. Silakan periksa koneksi dan coba beberapa saat lagi.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppGaps.vGap24,
              AppButton(
                text: 'Coba Lagi',
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoConnectionState() {
    return Center(
      child: Padding(
        padding: AppSpacing.p24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 64.0,
              color: AppColors.warning,
            ),
            AppGaps.vGap16,
            const Text(
              'Koneksi Terputus',
              style: AppTypography.headingSmall,
              textAlign: TextAlign.center,
            ),
            AppGaps.vGap8,
            const Text(
              'Perangkat Anda sedang offline. Silakan periksa jaringan WiFi atau data seluler Anda.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppGaps.vGap24,
              AppButton(
                text: 'Periksa Koneksi',
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
