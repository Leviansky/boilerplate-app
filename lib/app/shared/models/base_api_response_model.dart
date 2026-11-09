import 'pagination_meta_model.dart';

class BaseApiResponseModel<T> {
  final bool success;
  final String message;
  final int statusCode;
  final T? data;
  final PaginationMetaModel? pagination;

  const BaseApiResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
    this.pagination,
  });

  /// Defensive JSON deserialization
  factory BaseApiResponseModel.fromJson(
    Map<String, dynamic>? json,
    T Function(dynamic rawData)? fromJsonT,
  ) {
    if (json == null) {
      return BaseApiResponseModel<T>(
        success: false,
        message: 'Data respon kosong.',
        statusCode: 500,
      );
    }

    final isSuccess = json['success'] == true ||
        (json['status']?.toString().toLowerCase() == 'success');

    final messageStr = json['message']?.toString() ??
        (isSuccess ? 'Operasi berhasil.' : 'Terjadi kesalahan sistem.');

    final status = int.tryParse(json['status_code']?.toString() ?? '200') ?? 200;

    T? parsedData;
    if (json['data'] != null && fromJsonT != null) {
      try {
        parsedData = fromJsonT(json['data']);
      } catch (_) {
        parsedData = null;
      }
    }

    final paginationData = json['pagination'] is Map<String, dynamic>
        ? PaginationMetaModel.fromJson(json['pagination'] as Map<String, dynamic>)
        : (json['meta'] is Map<String, dynamic>
            ? PaginationMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
            : null);

    return BaseApiResponseModel<T>(
      success: isSuccess,
      message: messageStr,
      statusCode: status,
      data: parsedData,
      pagination: paginationData,
    );
  }
}
