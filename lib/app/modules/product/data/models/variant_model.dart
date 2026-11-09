class VariantModel {
  final String id;
  final String name;
  final int price; // Zero-Float: minor integer unit (Rupiah)
  final int stock;

  const VariantModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory VariantModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VariantModel(id: '', name: '', price: 0, stock: 0);
    }

    return VariantModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
    };
  }
}
