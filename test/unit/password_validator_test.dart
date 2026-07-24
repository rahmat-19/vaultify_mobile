import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify_mobile/features/auth/domain/usecases/password_validator.dart';

void main() {
  test('strong password requires every control', () {
    expect(PasswordValidator.isStrong('Vaultify#2026'), isTrue);
    expect(PasswordValidator.isStrong('vaultify'), isFalse);
    expect(PasswordValidator.isStrong('VAULTIFY1!'), isFalse);
  });
}
