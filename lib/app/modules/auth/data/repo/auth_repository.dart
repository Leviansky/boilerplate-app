import 'dart:convert';
import 'dart:typed_data';
import "package:testing_boilerplate/core/network/error_handler.dart";
import "package:testing_boilerplate/core/security/crypto/aes_encryption.dart";
import "package:testing_boilerplate/core/service/secure_storage_service.dart";
import "package:testing_boilerplate/core/values/storage_keys.dart";
import "package:testing_boilerplate/app/modules/auth/data/models/pin_verification_model.dart";
import "package:testing_boilerplate/app/modules/auth/data/models/user_model.dart";
import "package:testing_boilerplate/app/modules/auth/data/providers/auth_provider.dart";

class AuthRepository {
  final AuthProvider _provider;
  final SecureStorageService _storage;

  AuthRepository(this._provider, this._storage);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _provider.login(
      email: email,
      password: password,
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      await _storage.write(key: StorageKeys.accessToken, value: authData.accessToken);
      await _storage.write(key: StorageKeys.refreshToken, value: authData.refreshToken);
      await _storage.write(key: StorageKeys.userId, value: authData.user.id);
      await _storage.write(
        key: StorageKeys.userProfileJson,
        value: jsonEncode(authData.user.toJson()),
      );
      return authData.user;
    } else {
      throw ServerFailure(response.message, response.statusCode);
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _provider.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      await _storage.write(key: StorageKeys.accessToken, value: authData.accessToken);
      await _storage.write(key: StorageKeys.refreshToken, value: authData.refreshToken);
      await _storage.write(key: StorageKeys.userId, value: authData.user.id);
      return authData.user;
    } else {
      throw ServerFailure(response.message, response.statusCode);
    }
  }

  /// Verifies PIN with in-memory scrubbing
  Future<PinVerificationModel> verifyPin(Uint8List pinBytes) async {
    try {
      final pinString = utf8.decode(pinBytes);
      final encryptedPin = AesEncryption.encrypt(pinString);

      final response = await _provider.verifyPin(encryptedPin: encryptedPin);
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(response.message, response.statusCode);
      }
    } finally {
      // In-memory scrubbing of passed pin bytes
      pinBytes.fillRange(0, pinBytes.length, 0);
    }
  }

  Future<void> logout() async {
    try {
      await _provider.logout();
    } catch (_) {
      // Ignore network failure on logout; storage must be cleared regardless
    } finally {
      await _storage.clearAll();
    }
  }
}
