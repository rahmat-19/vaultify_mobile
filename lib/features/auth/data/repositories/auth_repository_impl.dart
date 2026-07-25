import 'package:vaultify_mobile/core/network/api_error_mapper.dart';
import 'package:vaultify_mobile/core/storage/secure_storage_service.dart';
import 'package:vaultify_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/user.dart';
import 'package:vaultify_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remote, this.storage);
  final AuthRemoteDataSource remote;
  final SecureStorageService storage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _guard(() => remote.login(email, password));
  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) => _guard(() => remote.register(fullName, email, password));

  Future<AuthSession> _guard(Future<AuthSession> Function() action) async {
    try {
      final session = await action();
      await storage.saveAccessToken(session.accessToken);
      await storage.saveRefreshToken(session.refreshToken);
      return session;
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<User?> restoreSession() async {
    if (await storage.readAccessToken() == null) return null;
    try {
      return await remote.me();
    } catch (error) {
      await storage.clearSession();
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await remote.logout(refreshToken);
      }
    } catch (_) {
      // Local logout must succeed even when the backend is unavailable.
    } finally {
      await storage.clearSession();
    }
  }
}
