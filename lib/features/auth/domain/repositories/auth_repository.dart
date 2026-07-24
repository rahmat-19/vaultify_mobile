import 'package:vaultify_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  });
  Future<User?> restoreSession();
  Future<void> logout();
}
