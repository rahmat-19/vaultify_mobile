import 'dart:math';
import 'package:vaultify_mobile/core/errors/failure.dart';

class PasswordOptions {
  const PasswordOptions({
    this.length = 20,
    this.uppercase = true,
    this.lowercase = true,
    this.numbers = true,
    this.symbols = true,
    this.excludeAmbiguous = true,
  });
  final int length;
  final bool uppercase;
  final bool lowercase;
  final bool numbers;
  final bool symbols;
  final bool excludeAmbiguous;
}

enum PasswordStrength { weak, fair, strong, veryStrong }

class PasswordGenerator {
  PasswordGenerator({Random? random}) : _random = random ?? Random.secure();
  final Random _random;
  static const _ambiguous = 'Il1O0o|`\'"';

  String generate(PasswordOptions options) {
    if (options.length < 8 || options.length > 64) {
      throw const ValidationFailure('Panjang kata sandi harus 8–64 karakter.');
    }
    final groups = <String>[
      if (options.uppercase) 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      if (options.lowercase) 'abcdefghijklmnopqrstuvwxyz',
      if (options.numbers) '0123456789',
      if (options.symbols) r'!@#$%^&*()-_=+[]{};:,.?/',
    ].map((group) {
      if (!options.excludeAmbiguous) return group;
      return group.split('').where((char) => !_ambiguous.contains(char)).join();
    }).toList();
    if (groups.isEmpty) {
      throw const ValidationFailure('Pilih setidaknya satu jenis karakter.');
    }
    final chars = <String>[
      for (final group in groups) group[_random.nextInt(group.length)],
    ];
    final pool = groups.join();
    while (chars.length < options.length) {
      chars.add(pool[_random.nextInt(pool.length)]);
    }
    for (var i = chars.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final value = chars[i];
      chars[i] = chars[j];
      chars[j] = value;
    }
    return chars.join();
  }

  PasswordStrength strength(String value) {
    var score = value.length >= 12 ? 1 : 0;
    if (value.length >= 20) score++;
    if (RegExp('[A-Z]').hasMatch(value) && RegExp('[a-z]').hasMatch(value)) score++;
    if (RegExp('[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    if (score >= 5) return PasswordStrength.veryStrong;
    if (score >= 4) return PasswordStrength.strong;
    if (score >= 3) return PasswordStrength.fair;
    return PasswordStrength.weak;
  }
}
