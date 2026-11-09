import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';
import "package:testing_boilerplate/core/security/session/session_tracker.dart";

class SafeScreenWrapper extends StatefulWidget {
  final Widget child;
  final bool enableScreenShield;

  const SafeScreenWrapper({
    super.key,
    required this.child,
    this.enableScreenShield = true,
  });

  @override
  State<SafeScreenWrapper> createState() => _SafeScreenWrapperState();
}

class _SafeScreenWrapperState extends State<SafeScreenWrapper> {
  @override
  void initState() {
    super.initState();
    if (widget.enableScreenShield && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _enableShield();
    }
  }

  Future<void> _enableShield() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      if (Platform.isIOS) {
        await ScreenProtector.protectDataLeakageWithBlur();
      } else if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOn();
      }
    } catch (_) {}
  }

  Future<void> _disableShield() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      if (Platform.isIOS) {
        await ScreenProtector.protectDataLeakageWithBlurOff();
      } else if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOff();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    if (widget.enableScreenShield && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _disableShield();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (Get.isRegistered<SessionTracker>()) {
          SessionTracker.to.recordUserActivity();
        }
      },
      child: widget.child,
    );
  }
}
