import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultify_mobile/app/providers.dart';
import 'package:vaultify_mobile/core/security/screenshot_protection.dart';
import 'package:vaultify_mobile/features/password_generator/domain/password_generator.dart';

class PasswordGeneratorPage extends ConsumerStatefulWidget {
  const PasswordGeneratorPage({super.key});
  @override
  ConsumerState<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}
class _PasswordGeneratorPageState extends ConsumerState<PasswordGeneratorPage> {
  double length = 20;
  bool upper = true, lower = true, numbers = true, symbols = true, ambiguous = true;
  String result = '';
  final generator = PasswordGenerator();
  @override
  void initState() { super.initState(); _generate(); }
  void _generate() {
    try {
      setState(() => result = generator.generate(PasswordOptions(
        length: length.round(), uppercase: upper, lowercase: lower,
        numbers: numbers, symbols: symbols, excludeAmbiguous: ambiguous)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  @override
  Widget build(BuildContext context) => SecureScreen(
    child: Scaffold(
      appBar: AppBar(title: const Text('Generator Kata Sandi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SelectableText(result,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          Text('Kekuatan: ${generator.strength(result).name}'),
          Text('Panjang: ${length.round()}'),
          Slider(value: length, min: 8, max: 64, divisions: 56,
            label: length.round().toString(), onChanged: (v) => setState(() => length = v)),
          _toggle('Huruf besar', upper, (v) => setState(() => upper = v)),
          _toggle('Huruf kecil', lower, (v) => setState(() => lower = v)),
          _toggle('Angka', numbers, (v) => setState(() => numbers = v)),
          _toggle('Simbol', symbols, (v) => setState(() => symbols = v)),
          _toggle('Hindari karakter ambigu', ambiguous, (v) => setState(() => ambiguous = v)),
          FilledButton.icon(onPressed: _generate,
            icon: const Icon(Icons.refresh), label: const Text('Buat kata sandi')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: result.isEmpty ? null : () async {
            await ref.read(clipboardServiceProvider).copy(result);
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Disalin dan akan dibersihkan otomatis.')));
            }
          }, icon: const Icon(Icons.copy), label: const Text('Salin')),
          const Text('Kata sandi tidak disimpan sampai Anda membuat item brankas.',
            textAlign: TextAlign.center),
        ],
      ),
    ),
  );
  Widget _toggle(String title, bool value, ValueChanged<bool> change) =>
    SwitchListTile(title: Text(title), value: value, onChanged: change);
}
