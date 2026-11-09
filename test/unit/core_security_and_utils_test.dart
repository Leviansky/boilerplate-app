import 'package:flutter_test/flutter_test.dart';
import 'package:testing_boilerplate/core/security/crypto/aes_encryption.dart';
import 'package:testing_boilerplate/core/security/crypto/hmac_signer.dart';
import 'package:testing_boilerplate/core/utils/currency_formatter.dart';
import 'package:testing_boilerplate/core/utils/validators.dart';
import 'package:testing_boilerplate/app/shared/models/pagination_meta_model.dart';
import 'package:testing_boilerplate/app/modules/product/data/models/product_model.dart';
import 'package:testing_boilerplate/app/modules/checkout/data/models/checkout_payload_model.dart';
import 'package:testing_boilerplate/core/config/env_config.dart';

void main() {
  group('Zero-Float Monetary Architecture Tests', () {
    test('formatRupiah formats integer minor units correctly without float decimals', () {
      expect(CurrencyFormatter.formatRupiah(50000), 'Rp50.000');
      expect(CurrencyFormatter.formatRupiah(1250000), 'Rp1.250.000');
      expect(CurrencyFormatter.formatRupiah(0), 'Rp0');
    });

    test('formatCompactRupiah returns readable short forms', () {
      expect(CurrencyFormatter.formatCompactRupiah(1500000), 'Rp1.5jt');
      expect(CurrencyFormatter.formatCompactRupiah(50000), 'Rp50rb');
    });
  });

  group('Zero-Trust Cryptography Engine Tests', () {
    test('AesEncryption encrypts and decrypts with AES-GCM 256-bit correctly', () {
      const plainText = '{"sensitive_pin":"123456","account_balance":5000000}';
      final encrypted = AesEncryption.encrypt(plainText);

      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(plainText)));

      final decrypted = AesEncryption.decrypt(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('HmacSigner generates and verifies HMAC-SHA256 signatures with nonce and timestamp', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const nonce = 'uuid-nonce-12345';
      const method = 'POST';
      const path = '/api/v1/checkout/order';
      const body = '{"item_id":"p1","quantity":2}';

      final signature = HmacSigner.generateSignature(
        timestamp: timestamp,
        nonce: nonce,
        httpMethod: method,
        path: path,
        payloadBody: body,
      );

      expect(signature, isNotEmpty);
      expect(signature.length, 64); // SHA-256 hex string

      final isValid = HmacSigner.verifySignature(
        signature: signature,
        timestamp: timestamp,
        nonce: nonce,
        httpMethod: method,
        path: path,
        payloadBody: body,
      );

      expect(isValid, isTrue);

      final isTamperedValid = HmacSigner.verifySignature(
        signature: signature,
        timestamp: timestamp,
        nonce: nonce,
        httpMethod: method,
        path: path,
        payloadBody: '{"item_id":"p1","quantity":999}', // Tampered body
      );

      expect(isTamperedValid, isFalse);
    });
  });

  group('Input Validation Tests', () {
    test('Email validator', () {
      expect(Validators.validateEmail('user@enterprise.com'), isNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('Indonesian phone validator', () {
      expect(Validators.validatePhone('081234567890'), isNull);
      expect(Validators.validatePhone('+6281234567890'), isNull);
      expect(Validators.validatePhone('12345'), isNotNull);
    });

    test('6-digit PIN validator', () {
      expect(Validators.validatePin('123456'), isNull);
      expect(Validators.validatePin('12345'), isNotNull);
      expect(Validators.validatePin('abcdef'), isNotNull);
    });
  });

  group('Defensive Model Parsing Tests', () {
    test('ProductModel parses safely with null or missing fields without throwing', () {
      final emptyProduct = ProductModel.fromJson(null);
      expect(emptyProduct.id, '');
      expect(emptyProduct.price, 0);
      expect(emptyProduct.stock, 0);
      expect(emptyProduct.images, isEmpty);

      final dirtyJson = {
        'id': 12345, // int instead of String
        'price': '75000', // String instead of int
        'stock': '15',
        'images': ['https://example.com/img1.png'],
        'category': {'id': 'c1', 'name': 'Electronics'},
        'variants': [
          {'id': 'v1', 'name': 'Red', 'price': '80000', 'stock': '5'}
        ],
      };

      final product = ProductModel.fromJson(dirtyJson);
      expect(product.id, '12345');
      expect(product.price, 75000);
      expect(product.stock, 15);
      expect(product.variants.first.price, 80000);
    });

    test('CheckoutInvoiceModel parses zero-float monetary values safely', () {
      final invoice = CheckoutInvoiceModel.fromJson({
        'checkout_token': 'tok-xyz',
        'subtotal_amount': '150000',
        'discount_amount': '20000',
        'shipping_fee': '10000',
        'admin_fee': '2500',
        'total_amount': '142500',
      });

      expect(invoice.subtotalAmount, 150000);
      expect(invoice.discountAmount, 20000);
      expect(invoice.totalAmount, 142500);
    });

    test('PaginationMetaModel parses safely with string numbers', () {
      final meta = PaginationMetaModel.fromJson({
        'current_page': '2',
        'total_pages': '5',
        'total_items': '100',
        'page_size': '20',
      });

      expect(meta.currentPage, 2);
      expect(meta.totalPages, 5);
      expect(meta.hasNextPage, isTrue);
    });
  });

  group('Environment Flavor Configuration Tests', () {
    test('EnvConfig configures development flavor correctly', () {
      EnvConfig.initialize(Environment.development);
      expect(EnvConfig.environment, Environment.development);
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isStaging, isFalse);
      expect(EnvConfig.isProduction, isFalse);
      expect(EnvConfig.appName, 'Marketplace Dev');
      expect(EnvConfig.baseUrl, 'https://dev-api.marketplace.enterprise.com');
      expect(EnvConfig.enableDetailedLogging, isTrue);
    });

    test('EnvConfig configures staging flavor correctly', () {
      EnvConfig.initialize(Environment.staging);
      expect(EnvConfig.environment, Environment.staging);
      expect(EnvConfig.isDevelopment, isFalse);
      expect(EnvConfig.isStaging, isTrue);
      expect(EnvConfig.isProduction, isFalse);
      expect(EnvConfig.appName, 'Marketplace Staging');
      expect(EnvConfig.baseUrl, 'https://stg-api.marketplace.enterprise.com');
      expect(EnvConfig.enableDetailedLogging, isTrue);
    });

    test('EnvConfig configures production flavor correctly', () {
      EnvConfig.initialize(Environment.production);
      expect(EnvConfig.environment, Environment.production);
      expect(EnvConfig.isDevelopment, isFalse);
      expect(EnvConfig.isStaging, isFalse);
      expect(EnvConfig.isProduction, isTrue);
      expect(EnvConfig.appName, 'Marketplace Enterprise');
      expect(EnvConfig.baseUrl, 'https://api.marketplace.enterprise.com');
      expect(EnvConfig.enableDetailedLogging, isFalse);
    });
  });
}
