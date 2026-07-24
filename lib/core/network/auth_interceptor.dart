import 'package:dio/dio.dart';
import 'package:vaultify_mobile/core/storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required SecureStorageService storage,
    required this.onSessionExpired,
  }) : _dio = dio,
       _storage = storage;

  final Dio _dio;
  final SecureStorageService _storage;
  final void Function() onSessionExpired;
  bool _refreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (!options.headers.containsKey('Authorization') &&
        token != null &&
        token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        request.extra['retried'] == true ||
        request.path.endsWith('/auth/refresh') ||
        _refreshing) {
      return handler.next(err);
    }
    _refreshing = true;
    try {
      final refresh = await _storage.readRefreshToken();
      if (refresh == null) throw StateError('Missing refresh token');
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: <String, String>{'refresh_token': refresh},
        options: Options(extra: <String, Object?>{'retried': true}),
      );
      final envelope = response.data?['data'];
      if (envelope is! Map<String, dynamic>) throw const FormatException();
      final access = envelope['access_token'];
      if (access is! String) throw const FormatException();
      await _storage.saveAccessToken(access);
      final newRefresh = envelope['refresh_token'];
      if (newRefresh is String) await _storage.saveRefreshToken(newRefresh);
      request.headers['Authorization'] = 'Bearer $access';
      request.extra['retried'] = true;
      final retried = await _dio.fetch<dynamic>(request);
      handler.resolve(retried);
    } catch (_) {
      await _storage.clearSession();
      onSessionExpired();
      handler.next(err);
    } finally {
      _refreshing = false;
    }
  }
}
