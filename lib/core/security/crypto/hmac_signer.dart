import 'dart:convert';
import 'package:crypto/crypto.dart';
import "package:testing_boilerplate/core/config/security_config.dart";

abstract final class HmacSigner {
  /// Generates HMAC-SHA256 signature for API requests:
  /// rawString = "$timestamp|$nonce|$httpMethod|$path|$payloadBody"
  static String generateSignature({
    required int timestamp,
    required String nonce,
    required String httpMethod,
    required String path,
    required String payloadBody,
  }) {
    final saltBytes = SecurityConfig.obfuscatedHmacSaltBytes;
    final message = '$timestamp|$nonce|${httpMethod.toUpperCase()}|$path|$payloadBody';
    final messageBytes = utf8.encode(message);

    final hmac = Hmac(sha256, saltBytes);
    final digest = hmac.convert(messageBytes);
    return digest.toString();
  }

  /// Verifies incoming HMAC signature against payload
  static bool verifySignature({
    required String signature,
    required int timestamp,
    required String nonce,
    required String httpMethod,
    required String path,
    required String payloadBody,
  }) {
    final expectedSignature = generateSignature(
      timestamp: timestamp,
      nonce: nonce,
      httpMethod: httpMethod,
      path: path,
      payloadBody: payloadBody,
    );
    return signature == expectedSignature;
  }
}
