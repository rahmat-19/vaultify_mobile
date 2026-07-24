import 'package:vaultify_mobile/core/errors/failure.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:vaultify_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaultify_mobile/features/auth/domain/usecases/password_validator.dart';

class RegisterUseCase {
  const RegisterUseCase(this.repository);
  final AuthRepository repository;
  Future<AuthSession> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmation,
  }) {
    if (fullName.trim().length < 2 || !email.contains('@')) {
      throw const ValidationFailure();
    }
    if (!PasswordValidator.isStrong(password)) {
      throw const ValidationFailure('Kata sandi belum memenuhi persyaratan.');
    }
    if (password != confirmation) {
      throw const ValidationFailure('Konfirmasi kata sandi tidak sama.');
    }
    return repository.register(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
    );
  }
}
