import 'dart:io';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'secure_storage_service.dart';

class DeviceService extends GetxService {
  static DeviceService get to => Get.find<DeviceService>();

  static const String _deviceIdStorageKey = 'INTERNAL_DEVICE_UNIQUE_IDENTIFIER';
  late final String _deviceId;

  String get deviceId => _deviceId;

  Future<DeviceService> init() async {
    final existingId = await SecureStorageService.to.read(key: _deviceIdStorageKey);
    if (existingId != null && existingId.isNotEmpty) {
      _deviceId = existingId;
    } else {
      _deviceId = const Uuid().v4();
      await SecureStorageService.to.write(
        key: _deviceIdStorageKey,
        value: _deviceId,
      );
    }
    return this;
  }

  /// Generates hardware attestation token (Google Play Integrity API / Apple App Attest)
  /// Header: X-Device-Integrity-Token
  Future<String> getDeviceAttestationToken() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final platformTag = Platform.isAndroid ? 'PLAY_INTEGRITY' : (Platform.isIOS ? 'APP_ATTEST' : 'DESKTOP_ENV');
    final nonce = const Uuid().v4();
    // In production, bind to Google Play Integrity standard client or DeviceCheck / AppAttest
    return '$platformTag-$_deviceId-$timestamp-$nonce';
  }
}
