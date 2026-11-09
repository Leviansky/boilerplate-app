import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import "package:testing_boilerplate/core/security/crypto/aes_encryption.dart";

class CryptoInterceptor extends Interceptor {
  static const String headerEncrypted = 'X-Payload-Encrypted';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final shouldEncrypt = options.extra['encrypt'] == true;

    if (shouldEncrypt && options.data != null) {
      final rawJsonString = options.data is String ? options.data as String : jsonEncode(options.data);

      // Offload encryption to background thread for payloads > 10KB
      final encryptedBase64 = rawJsonString.length > 10240
          ? await compute(AesEncryption.encrypt, rawJsonString)
          : AesEncryption.encrypt(rawJsonString);

      options.data = {'encrypted_payload': encryptedBase64};
      options.headers[headerEncrypted] = 'true';
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    final isEncryptedHeader = response.headers.value(headerEncrypted) == 'true';
    final responseData = response.data;

    if (isEncryptedHeader || (responseData is Map && responseData.containsKey('encrypted_payload'))) {
      final encryptedPayload = responseData is Map
          ? responseData['encrypted_payload']?.toString()
          : responseData?.toString();

      if (encryptedPayload != null && encryptedPayload.isNotEmpty) {
        // Offload decryption to background isolate if large
        final decryptedPlain = encryptedPayload.length > 10240
            ? await compute(AesEncryption.decrypt, encryptedPayload)
            : AesEncryption.decrypt(encryptedPayload);

        response.data = jsonDecode(decryptedPlain);
      }
    }

    handler.next(response);
  }
}
