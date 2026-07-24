import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify_mobile/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('login form validates empty input', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: LoginPage()),
    ));
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Masukkan email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
  });
}
