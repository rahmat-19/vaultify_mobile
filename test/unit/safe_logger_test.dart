import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify_mobile/core/utils/safe_logger.dart';

void main() {
  test('redacts sensitive values and masks email', () {
    final sanitized = SafeLogger().sanitize(<String, Object?>{
      'password': 'Secret#123',
      'Authorization': 'Bearer token',
      'email': 'user@example.com',
      'status': 200,
    });
    expect(sanitized['password'], '[DIHAPUS]');
    expect(sanitized['Authorization'], '[DIHAPUS]');
    expect(sanitized['email'], 'u***@example.com');
    expect(sanitized['status'], 200);
  });
}
