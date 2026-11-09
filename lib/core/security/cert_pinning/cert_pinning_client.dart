import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import "package:testing_boilerplate/core/config/security_config.dart";

abstract final class CertPinningClient {
  /// Configures SecurityContext and badCertificateCallback for SSL/TLS Pinning
  static HttpClient createPinnedHttpClient() {
    final securityContext = SecurityContext(withTrustedRoots: true);
    final client = HttpClient(context: securityContext);

    // Timeout thresholds
    client.connectionTimeout = const Duration(seconds: 15);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return verifyCertificate(cert, host);
    };

    return client;
  }

  /// Verifies certificate DER digest against pinned SHA-256 hashes
  static bool verifyCertificate(X509Certificate cert, String host) {
    // Check if host is whitelisted
    final isHostWhitelisted = SecurityConfig.whitelistedDomains.any(
      (domain) => host == domain || host.endsWith('.$domain'),
    );

    if (!isHostWhitelisted) {
      return false; // Reject unknown hosts immediately
    }

    // Calculate SHA-256 hash of certificate DER bytes
    final certSha256 = sha256.convert(cert.der);
    final certBase64Hash = base64.encode(certSha256.bytes);

    // Verify against pinned hashes
    final matches = SecurityConfig.pinnedCertificateHashes.contains(certBase64Hash);
    return matches;
  }
}
