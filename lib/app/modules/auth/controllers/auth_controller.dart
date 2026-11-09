import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/network/error_handler.dart";
import "package:testing_boilerplate/core/security/biometrics/biometric_service.dart";
import "package:testing_boilerplate/core/security/session/session_tracker.dart";
import "package:testing_boilerplate/app/shared/widgets/screen_state_view.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/app/modules/auth/data/models/user_model.dart";
import "package:testing_boilerplate/app/modules/auth/data/repo/auth_repository.dart";

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  // Form Controllers
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController otpController;

  // Granular Observables
  final viewStatus = ViewStatus.initial.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final errorMessage = ''.obs;
  final currentUser = Rxn<UserModel>();
  final remainingPinAttempts = 3.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    otpController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Silakan isi email dan kata sandi Anda.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _repository.login(email: email, password: password);
      currentUser.value = user;

      // Navigate to products catalog after successful login
      Get.offAllNamed(Routes.PRODUCT_LIST);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      errorMessage.value = failure.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      currentUser.value = user;
      Get.offAllNamed(Routes.PRODUCT_LIST);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      errorMessage.value = failure.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPin(Uint8List pinBytes) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.verifyPin(pinBytes);
      if (result.isValid) {
        if (Get.isRegistered<SessionTracker>()) {
          SessionTracker.to.unlockSession();
        }
        Get.back();
      } else {
        remainingPinAttempts.value = result.remainingAttempts;
        errorMessage.value = 'PIN salah. Sisa percobaan: ${result.remainingAttempts}';
      }
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      errorMessage.value = failure.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> triggerBiometricUnlock() async {
    if (!Get.isRegistered<BiometricService>()) return;

    final authenticated = await BiometricService.to.authenticate(
      reason: 'Pindai sidik jari / FaceID untuk membuka kunci aplikasi',
    );

    if (authenticated) {
      if (Get.isRegistered<SessionTracker>()) {
        SessionTracker.to.unlockSession();
      }
      Get.back();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    Get.offAllNamed(Routes.LOGIN);
  }
}
