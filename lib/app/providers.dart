import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultify_mobile/core/config/app_config.dart';
import 'package:vaultify_mobile/core/network/dio_factory.dart';
import 'package:vaultify_mobile/core/security/biometric_service.dart';
import 'package:vaultify_mobile/core/security/clipboard_service.dart';
import 'package:vaultify_mobile/core/security/session_manager.dart';
import 'package:vaultify_mobile/core/storage/secure_storage_service.dart';
import 'package:vaultify_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vaultify_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vaultify_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaultify_mobile/features/vault/data/datasources/vault_remote_data_source.dart';
import 'package:vaultify_mobile/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:vaultify_mobile/features/vault/domain/repositories/vault_repository.dart';

final appConfigProvider = Provider<AppConfig>((ref) => throw UnimplementedError());
final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());
final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);
final clipboardServiceProvider = Provider<SecureClipboardService>(
  (ref) => SecureClipboardService(ref.watch(appConfigProvider).clipboardClearDelay),
);
final sessionManagerProvider = Provider<SessionManager>(
  (ref) {
    final manager = SessionManager(ref.watch(appConfigProvider).sessionTimeout);
    ref.onDispose(manager.dispose);
    return manager;
  },
);
final dioProvider = Provider<Dio>(
  (ref) => DioFactory.create(
    config: ref.watch(appConfigProvider),
    storage: ref.watch(secureStorageProvider),
    onSessionExpired: () {
      final notifier = ref.read(sessionInvalidationProvider.notifier);
      notifier.state = notifier.state + 1;
    },
  ),
);
final sessionInvalidationProvider = StateProvider<int>((ref) => 0);
final onboardingCompleteProvider = StateProvider<bool>(
  (ref) => ref.watch(sharedPreferencesProvider)
      .getBool('onboarding_complete') ?? false,
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    AuthRemoteDataSource(ref.watch(dioProvider)),
    ref.watch(secureStorageProvider),
  ),
);
final vaultRepositoryProvider = Provider<VaultRepository>(
  (ref) => VaultRepositoryImpl(VaultRemoteDataSource(ref.watch(dioProvider))),
);
