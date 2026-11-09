import 'package:flutter/material.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/values/app_constants.dart";

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  DateTime _lastClickTime = DateTime.fromMillisecondsSinceEpoch(0);

  void _handleTap() {
    if (widget.isLoading || widget.onPressed == null) return;

    final now = DateTime.now();
    if (now.difference(_lastClickTime) < AppConstants.actionThrottle) {
      return; // Throttle multiple clicks
    }
    _lastClickTime = now;
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = widget.backgroundColor ?? AppColors.primary;
    final effectiveTextColor = widget.textColor ?? AppColors.surface;

    final childContent = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          const RepaintBoundary(
            child: SizedBox(
              width: 18.0,
              height: 18.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
              ),
            ),
          ),
          AppGaps.hGap12,
        ] else if (widget.icon != null) ...[
          widget.icon!,
          AppGaps.hGap8,
        ],
        Text(
          widget.text,
          style: AppTypography.buttonText.copyWith(
            color: widget.isOutlined ? effectiveBgColor : effectiveTextColor,
          ),
        ),
      ],
    );

    final buttonWidget = widget.isOutlined
        ? OutlinedButton(
            onPressed: widget.isLoading ? null : _handleTap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: effectiveBgColor, width: 1.5),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.md,
              ),
            ),
            child: childContent,
          )
        : ElevatedButton(
            onPressed: widget.isLoading ? null : _handleTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBgColor,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.md,
              ),
              elevation: 0,
            ),
            child: childContent,
          );

    if (widget.isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 48.0,
        child: buttonWidget,
      );
    }

    return SizedBox(
      height: 48.0,
      child: buttonWidget,
    );
  }
}
