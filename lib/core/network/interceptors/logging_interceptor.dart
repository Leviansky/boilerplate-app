import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  static const List<String> _sensitiveKeys = [
    'password',
    'token',
    'pin',
    'cvv',
    'authorization',
    'refresh_token',
    'card_number',
    'x-signature',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kReleaseMode) {
      final sanitizedHeaders = _sanitizeMap(options.headers);
      final sanitizedData = _sanitizeBody(options.data);

      developer.log(
        '--> [HTTP REQ] ${options.method} ${options.uri}\n'
        'Headers: $sanitizedHeaders\n'
        'Body: $sanitizedData',
        name: 'NetworkAudit',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kReleaseMode) {
      final sanitizedData = _sanitizeBody(response.data);
      developer.log(
        '<-- [HTTP RES ${response.statusCode}] ${response.requestOptions.uri}\n'
        'Body: $sanitizedData',
        name: 'NetworkAudit',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kReleaseMode) {
      developer.log(
        '<-- [HTTP ERR ${err.response?.statusCode}] ${err.requestOptions.uri}\n'
        'Message: ${err.message}',
        name: 'NetworkAudit',
        error: err.error,
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> map) {
    final sanitized = <String, dynamic>{};
    map.forEach((key, value) {
      final keyStr = key.toString();
      if (_isSensitiveKey(keyStr)) {
        sanitized[keyStr] = '***REDACTED***';
      } else if (value is Map) {
        sanitized[keyStr] = _sanitizeMap(value);
      } else {
        sanitized[keyStr] = value;
      }
    });
    return sanitized;
  }

  dynamic _sanitizeBody(dynamic body) {
    if (body == null) return null;
    if (body is Map) {
      return _sanitizeMap(body);
    }
    return body;
  }

  bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    return _sensitiveKeys.any((s) => lower.contains(s));
  }
}
