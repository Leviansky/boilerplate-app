import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService extends GetxService {
  static BiometricService get to => Get.find<BiometricService>();

  final LocalAuthentication _auth = LocalAuthentication();
  final canAuthenticateWithBiometrics = false.obs;
  final availableBiometrics = <BiometricType>[].obs;

  Future<BiometricService> init() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      canAuthenticateWithBiometrics.value = isSupported && canCheck;

      if (canAuthenticateWithBiometrics.value) {
        final biometrics = await _auth.getAvailableBiometrics();
        availableBiometrics.assignAll(biometrics);
      }
    } catch (_) {
      canAuthenticateWithBiometrics.value = false;
    }
    return this;
  }

  Future<bool> authenticate({
    String reason = 'Silakan verifikasi biometrik Anda untuk melanjutkan transaksi',
  }) async {
    if (!canAuthenticateWithBiometrics.value) {
      return false;
    }

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    }
  }
}
