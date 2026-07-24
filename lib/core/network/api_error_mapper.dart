import 'package:dio/dio.dart';
import 'package:vaultify_mobile/core/errors/failure.dart';

abstract final class ApiErrorMapper {
  static Failure map(Object error) {
    if (error is! DioException) return const DataFailure();
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (error.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      403 => const ForbiddenFailure(),
      422 => ValidationFailure(_safeMessage(error.response?.data)),
      423 || 429 => const AccountLockedFailure(),
      int value when value >= 500 => const ServerFailure(),
      _ => const DataFailure(),
    };
  }

  static String _safeMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.length <= 160) return message;
    }
    return 'Data yang dimasukkan tidak valid.';
  }
}
