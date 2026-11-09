import 'category_model.dart';
import 'variant_model.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final int price; // Zero-Float: integer minor units (Rupiah)
  final int stock;
  final List<String> images;
  final CategoryModel category;
  final List<VariantModel> variants;
  final int ratingCount;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.images,
    required this.category,
    required this.variants,
    this.ratingCount = 0,
  });

  /// Defensive fail-safe parsing
  factory ProductModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProductModel(
        id: '',
        title: '',
        description: '',
        price: 0,
        stock: 0,
        images: [],
        category: CategoryModel(id: '', name: '', iconUrl: ''),
        variants: [],
      );
    }

    final parsedImages = (json['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    final parsedVariants = (json['variants'] as List<dynamic>?)
            ?.map((e) => VariantModel.fromJson(e as Map<String, dynamic>?))
            .toList() ??
        const <VariantModel>[];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      images: parsedImages,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>?),
      variants: parsedVariants,
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'stock': stock,
      'images': images,
      'category': category.toJson(),
      'variants': variants.map((v) => v.toJson()).toList(),
      'rating_count': ratingCount,
    };
  }
}
