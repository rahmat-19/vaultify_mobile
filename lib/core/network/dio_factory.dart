import 'package:dio/dio.dart';
import 'package:vaultify_mobile/core/config/app_config.dart';
import 'package:vaultify_mobile/core/network/auth_interceptor.dart';
import 'package:vaultify_mobile/core/storage/secure_storage_service.dart';
import 'package:vaultify_mobile/core/utils/safe_logger.dart';

abstract final class DioFactory {
  static Dio create({
    required AppConfig config,
    required SecureStorageService storage,
    required VoidCallback onSessionExpired,
    SafeLogger? logger,
  }) {
    final safeLogger = logger ?? SafeLogger();
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.connectTimeout,
        headers: const <String, String>{'Accept': 'application/json'},
      ),
    );
    dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(
        dio: dio,
        storage: storage,
        onSessionExpired: onSessionExpired,
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          safeLogger.request(options.method, options.path);
          handler.next(options);
        },
        onResponse: (response, handler) {
          safeLogger.request(
            response.requestOptions.method,
            response.requestOptions.path,
            statusCode: response.statusCode,
          );
          safeLogger.response(response.data);
          handler.next(response);
        },
        onError: (error, handler) {
          safeLogger.request(
            error.requestOptions.method,
            error.requestOptions.path,
            statusCode: error.response?.statusCode,
          );
          safeLogger.warning(error.type.name);
          safeLogger.response(error.response?.data);
          handler.next(error);
        },
      ),
    ]);
    return dio;
  }
}

typedef VoidCallback = void Function();
