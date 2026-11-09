import 'dart:convert';

abstract final class StringCipher {
  /// De-obfuscates a byte array using XOR mask with a runtime secondary key
  static String deobfuscate(List<int> obfuscatedBytes, [int mask = 0x5A]) {
    final decoded = obfuscatedBytes.map((b) => b ^ mask).toList();
    return utf8.decode(decoded);
  }

  /// Converts byte array directly to UTF-8 without mask
  static String bytesToString(List<int> bytes) {
    return utf8.decode(bytes);
  }

  /// Converts String to UTF-8 bytes
  static List<int> stringToBytes(String input) {
    return utf8.encode(input);
  }
}
