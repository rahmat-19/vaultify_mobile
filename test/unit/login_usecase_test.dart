import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/user.dart';
import 'package:vaultify_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaultify_mobile/features/auth/domain/usecases/login_usecase.dart';

class _AuthRepositoryMock extends Mock implements AuthRepository {}
void main() {
  test('normalizes email and delegates credentials', () async {
    final repository = _AuthRepositoryMock();
    const session = AuthSession(
      user: User(id: '1', fullName: 'Demo', email: 'demo@example.com'),
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    when(() => repository.login(email: any(named: 'email'),
      password: any(named: 'password'))).thenAnswer((_) async => session);
    final result = await LoginUseCase(repository)(' demo@example.com ', 'Secret#123');
    expect(result, session);
    verify(() => repository.login(email: 'demo@example.com',
      password: 'Secret#123')).called(1);
  });
}
