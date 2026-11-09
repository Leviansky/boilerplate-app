import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class IdempotencyInterceptor extends Interceptor {
  static const String headerIdempotencyKey = 'Idempotency-Key';
  static const Uuid _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final isMutationMethod = method == 'POST' || method == 'PUT' || method == 'PATCH';

    if (isMutationMethod) {
      // If caller hasn't explicitly supplied an idempotency key, generate a unique UUID v4
      if (!options.headers.containsKey(headerIdempotencyKey)) {
        options.headers[headerIdempotencyKey] = _uuid.v4();
      }
    }

    handler.next(options);
  }
}
