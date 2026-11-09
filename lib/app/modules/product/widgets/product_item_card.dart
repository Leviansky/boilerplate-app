import 'package:flutter/material.dart';
import "package:testing_boilerplate/app/shared/widgets/universal_product_card.dart";
import "package:testing_boilerplate/app/modules/product/data/models/product_model.dart";

class ProductItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductItemCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalProductCard(
      id: product.id,
      title: product.title,
      price: product.price,
      imageUrl: product.images.isNotEmpty ? product.images.first : '',
      categoryName: product.category.name,
      onTap: onTap,
    );
  }
}
