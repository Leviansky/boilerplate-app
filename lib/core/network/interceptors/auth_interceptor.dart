import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/core/config/env_config.dart";
import "package:testing_boilerplate/core/service/secure_storage_service.dart";
import "package:testing_boilerplate/core/values/storage_keys.dart";
import "package:testing_boilerplate/core/network/api_endpoints.dart";

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // If request already has Authorization header or is auth-exempt, continue
    if (!options.headers.containsKey('Authorization')) {
      if (getx.Get.isRegistered<SecureStorageService>()) {
        final token = await SecureStorageService.to.read(key: StorageKeys.accessToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 Unauthorized and not already during refresh/login
    final is401 = err.response?.statusCode == 401;
    final isAuthEndpoint = err.requestOptions.path.contains(ApiEndpoints.refreshToken) ||
        err.requestOptions.path.contains(ApiEndpoints.login);

    if (is401 && !isAuthEndpoint) {
      final refreshed = await _performTokenRefresh();
      if (refreshed) {
        try {
          // Re-fetch fresh access token
          final freshToken = await SecureStorageService.to.read(key: StorageKeys.accessToken);
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $freshToken';

          final response = await _dio.fetch(retryOptions);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      } else {
        // Refresh token failed or expired -> full session purge
        await _purgeSessionAndRedirect();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<bool> _performTokenRefresh() async {
    if (!getx.Get.isRegistered<SecureStorageService>()) return false;

    final currentRefreshToken = await SecureStorageService.to.read(key: StorageKeys.refreshToken);
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      return false;
    }

    try {
      // Independent unintercepted dio instance for token refresh to prevent circular loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': currentRefreshToken},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token']?.toString();
        final newRefreshToken = data['refresh_token']?.toString();

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await SecureStorageService.to.write(
            key: StorageKeys.accessToken,
            value: newAccessToken,
          );
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await SecureStorageService.to.write(
              key: StorageKeys.refreshToken,
              value: newRefreshToken,
            );
          }
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _purgeSessionAndRedirect() async {
    if (getx.Get.isRegistered<SecureStorageService>()) {
      await SecureStorageService.to.clearAll();
    }
    getx.Get.deleteAll(force: true);
    getx.Get.offAllNamed(Routes.LOGIN);
  }
}
