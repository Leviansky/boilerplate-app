import 'package:dio/dio.dart';
import "package:testing_boilerplate/core/network/api_client.dart";
import "package:testing_boilerplate/core/network/api_endpoints.dart";
import "package:testing_boilerplate/app/shared/models/base_api_response_model.dart";
import "package:testing_boilerplate/app/modules/auth/data/models/auth_response_model.dart";
import "package:testing_boilerplate/app/modules/auth/data/models/pin_verification_model.dart";

class AuthProvider {
  final ApiClient _apiClient;

  AuthProvider(this._apiClient);

  Future<BaseApiResponseModel<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
      options: Options(extra: {'encrypt': true}), // Payload AES-GCM encrypted
    );

    return BaseApiResponseModel<AuthResponseModel>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => AuthResponseModel.fromJson(data as Map<String, dynamic>?),
    );
  }

  Future<BaseApiResponseModel<AuthResponseModel>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone_number': phone,
        'password': password,
      },
      options: Options(extra: {'encrypt': true}),
    );

    return BaseApiResponseModel<AuthResponseModel>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => AuthResponseModel.fromJson(data as Map<String, dynamic>?),
    );
  }

  Future<BaseApiResponseModel<bool>> verifyOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'verification_id': verificationId,
        'otp_code': otpCode,
      },
    );

    return BaseApiResponseModel<bool>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => data == true,
    );
  }

  Future<BaseApiResponseModel<PinVerificationModel>> verifyPin({
    required String encryptedPin,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyPin,
      data: {'pin': encryptedPin},
      options: Options(extra: {'encrypt': true}),
    );

    return BaseApiResponseModel<PinVerificationModel>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => PinVerificationModel.fromJson(data as Map<String, dynamic>?),
    );
  }

  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}
