import 'package:flutter/material.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/currency_formatter.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/payment_result_model.dart";

class PaymentChannelTile extends StatelessWidget {
  final PaymentChannelModel channel;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentChannelTile({
    super.key,
    required this.channel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 0.8,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.sm,
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 22.0,
            ),
          ),
        ),
        title: Text(
          channel.name,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Text(
          channel.fee > 0
              ? 'Biaya: ${CurrencyFormatter.formatRupiah(channel.fee)}'
              : 'Bebas Biaya Admin',
          style: AppTypography.caption,
        ),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
