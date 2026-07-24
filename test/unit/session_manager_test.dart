import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify_mobile/core/security/session_manager.dart';

void main() {
  test('locks sensitive access after timeout', () async {
    final manager = SessionManager(const Duration(milliseconds: 10));
    manager.unlockSensitiveAccess();
    expect(manager.sensitiveLocked, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(manager.sensitiveLocked, isTrue);
    manager.dispose();
  });
}
