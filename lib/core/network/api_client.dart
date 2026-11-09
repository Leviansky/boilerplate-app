import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import "package:testing_boilerplate/core/config/env_config.dart";
import "package:testing_boilerplate/core/security/cert_pinning/cert_pinning_client.dart";
import "package:testing_boilerplate/core/values/app_constants.dart";
import 'error_handler.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/crypto_interceptor.dart';
import 'interceptors/hmac_interceptor.dart';
import 'interceptors/idempotency_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class ApiClient extends getx.GetxService {
  static ApiClient get to => getx.Get.find<ApiClient>();

  late final Dio dio;

  Future<ApiClient> init() async {
    final baseOptions = BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-App-Version': EnvConfig.appVersion,
        'X-Platform': Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Web/Desktop'),
      },
    );

    dio = Dio(baseOptions);

    // SSL Pinning SecurityContext setup for IO platforms
    if (!kIsWeb) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: CertPinningClient.createPinnedHttpClient,
      );
    }

    // 5-layer Interceptors Stack
    dio.interceptors.addAll([
      AuthInterceptor(dio),
      CryptoInterceptor(),
      HmacInterceptor(),
      IdempotencyInterceptor(),
      LoggingInterceptor(),
    ]);

    return this;
  }

  /// Generic GET request with domain Failure handling
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Generic POST request with domain Failure handling
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
