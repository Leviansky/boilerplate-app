import 'package:flutter/material.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/currency_formatter.dart";
import "package:testing_boilerplate/app/modules/product/data/models/variant_model.dart";

class VariantSelector extends StatelessWidget {
  final List<VariantModel> variants;
  final VariantModel? selectedVariant;
  final ValueChanged<VariantModel> onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilihan Varian',
          style: AppTypography.headingSmall,
        ),
        AppGaps.vGap12,
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: variants.map((variant) {
            final isSelected = selectedVariant?.id == variant.id;
            final isOutOfStock = variant.stock <= 0;

            return ChoiceChip(
              label: Text(
                '${variant.name} (${CurrencyFormatter.formatRupiah(variant.price)})',
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.surface
                      : (isOutOfStock ? AppColors.textTertiary : AppColors.textPrimary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: isOutOfStock ? null : (_) => onVariantSelected(variant),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.md,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
