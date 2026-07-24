import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify_mobile/features/password_generator/domain/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('uses requested length and all enabled groups', () {
      final value = PasswordGenerator().generate(const PasswordOptions(length: 32));
      expect(value, hasLength(32));
      expect(value, matches('[A-Z]'));
      expect(value, matches('[a-z]'));
      expect(value, matches('[0-9]'));
      expect(value, matches(r'[^A-Za-z0-9]'));
    });
    test('rejects unsafe lengths', () {
      expect(
        () => PasswordGenerator().generate(const PasswordOptions(length: 7)),
        throwsA(anything),
      );
    });
    test('does not return ambiguous characters when excluded', () {
      final value = PasswordGenerator().generate(
        const PasswordOptions(length: 64, symbols: false),
      );
      expect(value.contains(RegExp(r'[Il1O0o]')), isFalse);
    });
  });
}
