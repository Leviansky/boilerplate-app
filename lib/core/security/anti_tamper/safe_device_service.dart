import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';

class SafeDeviceService extends GetxService {
  static SafeDeviceService get to => Get.find<SafeDeviceService>();

  final isJailbrokenOrRooted = false.obs;
  final isRealDevice = true.obs;
  final isOnExternalStorage = false.obs;
  final isDevelopmentModeEnable = false.obs;

  bool get isDeviceSecure {
    // In production, rooted/jailbroken devices or emulators are prohibited
    if (kReleaseMode) {
      if (isJailbrokenOrRooted.value) return false;
      if (!isRealDevice.value) return false;
    }
    return !isJailbrokenOrRooted.value;
  }

  Future<SafeDeviceService> init() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        isJailbrokenOrRooted.value = await SafeDevice.isJailBroken;
        isRealDevice.value = await SafeDevice.isRealDevice;
        isOnExternalStorage.value = await SafeDevice.isOnExternalStorage;
        isDevelopmentModeEnable.value = await SafeDevice.isDevelopmentModeEnable;
      } catch (_) {
        // Safe fallback in test/mock environments
      }
    }
    return this;
  }
}
