import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import "package:testing_boilerplate/core/config/security_config.dart";

/// Zero-Trust Cryptographic Engine:
/// AES-GCM 256-bit authenticated encryption with cryptographically random IV.
abstract final class AesEncryption {
  static const int _ivLength = 12; // 96-bit standard GCM IV
  static const int _tagLengthBits = 128; // 128-bit MAC tag

  static Uint8List get _keyBytes {
    return Uint8List.fromList(SecurityConfig.obfuscatedAesKeySeed);
  }

  static Uint8List _generateSecureIv() {
    final secureRandom = Random.secure();
    final iv = Uint8List(_ivLength);
    for (var i = 0; i < _ivLength; i++) {
      iv[i] = secureRandom.nextInt(256);
    }
    return iv;
  }

  /// Encrypts plain text string to Base64-encoded payload (IV + CipherText with MAC)
  static String encrypt(String plainText) {
    final iv = _generateSecureIv();
    final plainBytes = Uint8List.fromList(utf8.encode(plainText));

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(_keyBytes),
      _tagLengthBits,
      iv,
      Uint8List(0),
    );
    cipher.init(true, params);

    final cipherText = cipher.process(plainBytes);

    final combined = Uint8List(iv.length + cipherText.length);
    combined.setRange(0, iv.length, iv);
    combined.setRange(iv.length, combined.length, cipherText);

    return base64.encode(combined);
  }

  /// Decrypts Base64-encoded payload (IV + CipherText with MAC) back to plain text
  static String decrypt(String base64Encrypted) {
    final combined = base64.decode(base64Encrypted);
    final iv = combined.sublist(0, _ivLength);
    final cipherBytes = combined.sublist(_ivLength);

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(_keyBytes),
      _tagLengthBits,
      Uint8List.fromList(iv),
      Uint8List(0),
    );
    cipher.init(false, params);

    final decryptedBytes = cipher.process(Uint8List.fromList(cipherBytes));
    return utf8.decode(decryptedBytes);
  }
}
