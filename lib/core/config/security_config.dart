abstract final class SecurityConfig {
  /// Whitelisted domains for SSL Pinning & network traffic
  static const List<String> whitelistedDomains = [
    'api.marketplace.enterprise.com',
    'dev-api.marketplace.enterprise.com',
    'stg-api.marketplace.enterprise.com',
    'auth.marketplace.enterprise.com',
    'pay.marketplace.enterprise.com',
  ];

  /// SHA-256 SPKI fingerprint hashes for SSL Certificate Pinning
  static const List<String> pinnedCertificateHashes = [
    // Primary leaf / intermediate SHA-256 digest
    'WoiWRyIOVNa9ihaIhR+mbJ7UhBCwbq0cgFjlTt97BRU=',
    // Backup disaster recovery SHA-256 digest
    'r/mItsNd4etnmK+xmAYsFcYbkTLPXeiYSBWCGGW1304=',
  ];

  /// Obfuscated byte array for signature salt (Zero-Trust string de-obfuscation)
  /// Non-plain-text representation
  static const List<int> obfuscatedHmacSaltBytes = [
    0x4D, 0x4B, 0x54, 0x50, 0x4C, 0x41, 0x43, 0x45,
    0x5F, 0x53, 0x45, 0x43, 0x55, 0x52, 0x49, 0x54,
    0x59, 0x5F, 0x53, 0x41, 0x4C, 0x54, 0x5F, 0x32,
    0x30, 0x32, 0x36, 0x5F, 0x5A, 0x45, 0x52, 0x4F,
  ];

  /// Obfuscated AES key seeds for payload encryption
  static const List<int> obfuscatedAesKeySeed = [
    0x1A, 0x3F, 0x89, 0xC4, 0x5E, 0x7B, 0x22, 0x90,
    0xD3, 0x44, 0x11, 0x7E, 0x6A, 0x05, 0x9F, 0x33,
    0x88, 0x2D, 0xC0, 0x74, 0xB1, 0x55, 0x6E, 0xFA,
    0x0D, 0x3B, 0x92, 0x67, 0x14, 0x8F, 0xEC, 0x42,
  ];
}
