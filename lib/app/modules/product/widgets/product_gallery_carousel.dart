import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";

class ProductGalleryCarousel extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const ProductGalleryCarousel({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 320.0,
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 64.0,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: 320.0,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  memCacheWidth: 720,
                  memCacheHeight: 720,
                  placeholder: (_, _) => Container(
                    color: AppColors.shimmerBase,
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 48.0,
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
          if (images.length > 1) ...[
            AppGaps.vGap12,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isSelected = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxs),
                  width: isSelected ? 20.0 : 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    borderRadius: AppRadius.full,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
