import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/core/values/app_constants.dart";

class SessionTracker extends GetxService with WidgetsBindingObserver {
  static SessionTracker get to => Get.find<SessionTracker>();

  DateTime _lastActiveTime = DateTime.now();
  DateTime? _appPausedTime;
  Timer? _inactivityTimer;

  final isSessionLocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.onClose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkInactivity();
    });
  }

  /// Called on user touches via SafeScreenWrapper
  void recordUserActivity() {
    if (isSessionLocked.value) return;
    _lastActiveTime = DateTime.now();
  }

  void _checkInactivity() {
    if (isSessionLocked.value) return;
    final now = DateTime.now();
    if (now.difference(_lastActiveTime) >= AppConstants.sessionIdleTimeout) {
      lockSession(reason: 'IDLE_TIMEOUT');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _appPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_appPausedTime != null) {
        final backgroundDuration = DateTime.now().difference(_appPausedTime!);
        if (backgroundDuration >= AppConstants.backgroundLockTimeout) {
          lockSession(reason: 'BACKGROUND_TIMEOUT');
        }
        _appPausedTime = null;
      }
      _lastActiveTime = DateTime.now();
    }
  }

  void lockSession({String reason = 'MANUAL_LOCK'}) {
    if (isSessionLocked.value) return;
    isSessionLocked.value = true;

    // Navigate to PIN / Biometric verification view if not already there
    final currentRoute = Get.currentRoute;
    if (currentRoute != Routes.PIN_VERIFICATION &&
        currentRoute != Routes.LOGIN &&
        currentRoute != Routes.DEVICE_COMPROMISED) {
      Get.toNamed(
        Routes.PIN_VERIFICATION,
        arguments: {'unlock_reason': reason},
      );
    }
  }

  void unlockSession() {
    isSessionLocked.value = false;
    _lastActiveTime = DateTime.now();
    _startInactivityTimer();
  }
}
