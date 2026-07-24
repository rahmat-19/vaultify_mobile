import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaultify_mobile/app/providers.dart';
import 'package:vaultify_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vaultify_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:vaultify_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:vaultify_mobile/features/onboarding/onboarding_page.dart';
import 'package:vaultify_mobile/features/password_generator/presentation/pages/password_generator_page.dart';
import 'package:vaultify_mobile/features/privacy/presentation/pages/privacy_page.dart';
import 'package:vaultify_mobile/features/security_settings/presentation/pages/security_settings_page.dart';
import 'package:vaultify_mobile/features/splash/splash_page.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';
import 'package:vaultify_mobile/features/vault/presentation/pages/vault_dashboard_page.dart';
import 'package:vaultify_mobile/features/vault/presentation/pages/vault_detail_page.dart';
import 'package:vaultify_mobile/features/vault/presentation/pages/vault_form_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final onboarding = ref.watch(onboardingCompleteProvider);
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (auth.status == AuthStatus.checking) {
        return path == '/splash' ? null : '/splash';
      }
      if (!onboarding && path != '/onboarding') return '/onboarding';
      final public = path == '/login' || path == '/register' || path == '/onboarding';
      if (auth.status == AuthStatus.unauthenticated && !public) return '/login';
      if (auth.status == AuthStatus.authenticated && (public || path == '/splash')) {
        return '/vault';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/vault', builder: (_, _) => const VaultDashboardPage()),
      GoRoute(path: '/vault/new', builder: (_, _) => const VaultFormPage()),
      GoRoute(
        path: '/vault/:id',
        builder: (_, state) {
          final item = state.extra;
          if (item is! VaultItem) return const VaultDashboardPage();
          return VaultDetailPage(item: item);
        },
      ),
      GoRoute(
        path: '/vault/:id/edit',
        builder: (_, state) => VaultFormPage(item: state.extra as VaultItem?),
      ),
      GoRoute(path: '/generator', builder: (_, _) => const PasswordGeneratorPage()),
      GoRoute(path: '/settings', builder: (_, _) => const SecuritySettingsPage()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPage()),
    ],
  );
});
