import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
  static SecureStorageService get to => Get.find<SecureStorageService>();

  late final FlutterSecureStorage _storage;

  Future<SecureStorageService> init() async {
    // OWASP MASVS compliant hardware-backed secure storage options
    const androidOptions = AndroidOptions(
      resetOnError: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    );

    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    );

    _storage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );

    return this;
  }

  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key: key);
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
