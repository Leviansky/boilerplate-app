import 'dart:io';
import 'package:dio/dio.dart';

sealed class Failure implements Exception {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi internet bermasalah. Silakan periksa jaringan Anda.']);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Permintaan waktu habis. Silakan coba beberapa saat lagi.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesi Anda telah berakhir. Silakan masuk kembali.', super.statusCode = 401]);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi gangguan pada server. Silakan coba lagi nanti.', super.statusCode = 500]);
}

final class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure(super.message, [this.errors, super.statusCode = 422]);
}

final class SecurityFailure extends Failure {
  const SecurityFailure([super.message = 'Anomali keamanan terdeteksi. Permintaan ditolak.', super.statusCode = 403]);
}

abstract final class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutFailure();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 500;
          final responseData = error.response?.data;
          String message = 'Terjadi kesalahan pada respon server.';

          if (responseData is Map<String, dynamic>) {
            message = responseData['message']?.toString() ?? message;
          }

          if (statusCode == 401) {
            return AuthFailure(message, statusCode);
          } else if (statusCode == 403) {
            return SecurityFailure(message, statusCode);
          } else if (statusCode == 422 || statusCode == 400) {
            final errors = responseData is Map<String, dynamic> ? responseData['errors'] as Map<String, dynamic>? : null;
            return ValidationFailure(message, errors, statusCode);
          } else if (statusCode >= 500) {
            return ServerFailure(message, statusCode);
          }
          return ServerFailure(message, statusCode);

        case DioExceptionType.connectionError:
          return const NetworkFailure();

        case DioExceptionType.cancel:
          return const NetworkFailure('Permintaan dibatalkan.');

        case DioExceptionType.badCertificate:
          return const SecurityFailure('Sertifikat keamanan server tidak valid atau ditolak.');

        case DioExceptionType.unknown:
        default:
          if (error.error is SocketException) {
            return const NetworkFailure();
          }
          return ServerFailure(error.message ?? 'Terjadi kesalahan tidak terduga.');
      }
    } else if (error is SocketException) {
      return const NetworkFailure();
    } else if (error is Failure) {
      return error;
    }
    return ServerFailure(error?.toString() ?? 'Terjadi kesalahan sistem.');
  }
}
