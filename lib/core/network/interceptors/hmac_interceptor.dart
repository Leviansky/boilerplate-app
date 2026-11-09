import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import "package:testing_boilerplate/core/security/crypto/hmac_signer.dart";
import "package:testing_boilerplate/core/service/device_service.dart";
import 'package:get/get.dart';

class HmacInterceptor extends Interceptor {
  static const String headerSignature = 'X-Signature';
  static const String headerTimestamp = 'X-Timestamp';
  static const String headerNonce = 'X-Nonce';
  static const String headerIntegrityToken = 'X-Device-Integrity-Token';

  static const Uuid _uuid = Uuid();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final method = options.method.toUpperCase();
    final isMutationMethod = method == 'POST' || method == 'PUT' || method == 'PATCH';

    if (isMutationMethod) {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final nonce = _uuid.v4();
      final path = options.uri.path;

      String payloadBody = '';
      if (options.data != null) {
        if (options.data is String) {
          payloadBody = options.data as String;
        } else if (options.data is Map || options.data is List) {
          payloadBody = jsonEncode(options.data);
        }
      }

      final signature = HmacSigner.generateSignature(
        timestamp: timestamp,
        nonce: nonce,
        httpMethod: method,
        path: path,
        payloadBody: payloadBody,
      );

      options.headers[headerTimestamp] = timestamp.toString();
      options.headers[headerNonce] = nonce;
      options.headers[headerSignature] = signature;

      // Attach hardware attestation token if DeviceService registered
      if (Get.isRegistered<DeviceService>()) {
        final token = await DeviceService.to.getDeviceAttestationToken();
        options.headers[headerIntegrityToken] = token;
      }
    }

    handler.next(options);
  }
}
