class CategoryModel {
  final String id;
  final String name;
  final String iconUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CategoryModel(id: '', name: '', iconUrl: '');
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
    };
  }
}
