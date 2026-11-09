class PaginationMetaModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNextPage;

  const PaginationMetaModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNextPage,
  });

  /// Defensive JSON parsing with fail-safe fallbacks
  factory PaginationMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaginationMetaModel(
        currentPage: 1,
        totalPages: 1,
        totalItems: 0,
        pageSize: 20,
        hasNextPage: false,
      );
    }

    final current = int.tryParse(json['current_page']?.toString() ?? '1') ?? 1;
    final totalP = int.tryParse(json['total_pages']?.toString() ?? '1') ?? 1;
    final totalI = int.tryParse(json['total_items']?.toString() ?? '0') ?? 0;
    final limit = int.tryParse(json['page_size']?.toString() ?? '20') ?? 20;
    final hasNext = json['has_next_page'] == true || current < totalP;

    return PaginationMetaModel(
      currentPage: current,
      totalPages: totalP,
      totalItems: totalI,
      pageSize: limit,
      hasNextPage: hasNext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'page_size': pageSize,
      'has_next_page': hasNextPage,
    };
  }
}
