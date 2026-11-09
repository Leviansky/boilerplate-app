import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/currency_formatter.dart";

class UniversalProductCard extends StatelessWidget {
  final String id;
  final String title;
  final int price; // Zero-Float: integer minor units (Rupiah)
  final String imageUrl;
  final String categoryName;
  final VoidCallback? onTap;

  const UniversalProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.categoryName = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.circular12,
        child: InkWell(
          borderRadius: AppRadius.circular12,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.circular12,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with Cache Sizing to prevent OOM
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.r12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 320,
                      memCacheHeight: 320,
                      placeholder: (context, url) => Container(
                        color: AppColors.shimmerBase,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textTertiary,
                            size: 32.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Details
                Padding(
                  padding: AppSpacing.p12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categoryName.isNotEmpty) ...[
                        Text(
                          categoryName.toUpperCase(),
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppGaps.vGap4,
                      ],
                      Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppGaps.vGap8,
                      // Zero-float Rupiah format
                      Text(
                        CurrencyFormatter.formatRupiah(price),
                        style: AppTypography.priceHighlightSmall,
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
}
