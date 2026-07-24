import 'package:vaultify_mobile/core/errors/failure.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:vaultify_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this.repository);
  final AuthRepository repository;
  Future<AuthSession> call(String email, String password) {
    if (!email.contains('@') || password.isEmpty) {
      throw const ValidationFailure('Email atau password tidak valid.');
    }
    return repository.login(email: email.trim(), password: password);
  }
}
