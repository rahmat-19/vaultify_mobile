import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaultify_mobile/app/providers.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Icon(Icons.admin_panel_settings, size: 100),
          const SizedBox(height: 20),
          Text('Rahasia tetap rahasia', style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text(
            'Vaultify menggunakan penyimpanan token terenkripsi, autentikasi biometrik, '
            'penguncian otomatis, dan perlindungan screenshot. Gunakan hanya data dummy.',
            textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () async {
              await ref.read(sharedPreferencesProvider).setBool('onboarding_complete', true);
              ref.read(onboardingCompleteProvider.notifier).state = true;
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Mulai dengan aman'),
          ),
        ]),
      ),
    ),
  );
}
