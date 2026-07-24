import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vaultify_mobile/core/errors/failure.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
            );

  static const _accessToken = 'session.access_token';
  static const _refreshToken = 'session.refresh_token';
  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) => _write(_accessToken, token);
  Future<String?> readAccessToken() => _read(_accessToken);
  Future<void> deleteAccessToken() => _delete(_accessToken);
  Future<void> saveRefreshToken(String token) => _write(_refreshToken, token);
  Future<String?> readRefreshToken() => _read(_refreshToken);
  Future<void> deleteRefreshToken() => _delete(_refreshToken);

  Future<void> clearSession() async {
    await Future.wait(<Future<void>>[
      deleteAccessToken(),
      deleteRefreshToken(),
    ]);
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      throw const StorageFailure();
    }
  }
}
