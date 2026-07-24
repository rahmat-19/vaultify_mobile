import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultify_mobile/app/providers.dart';
import 'package:vaultify_mobile/app/router.dart';
import 'package:vaultify_mobile/app/theme.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';
import 'package:vaultify_mobile/core/security/session_manager.dart';

class VaultifyApp extends ConsumerStatefulWidget {
  const VaultifyApp({super.key});
  @override
  ConsumerState<VaultifyApp> createState() => _VaultifyAppState();
}
class _VaultifyAppState extends ConsumerState<VaultifyApp> {
  AppLifecycleObserver? observer;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    observer ??= AppLifecycleObserver(
      ref.read(sessionManagerProvider).lockSensitiveAccess,
    );
    WidgetsBinding.instance.addObserver(observer!);
  }
  @override
  void dispose() {
    if (observer != null) WidgetsBinding.instance.removeObserver(observer!);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return Listener(
      onPointerDown: (_) => ref.read(sessionManagerProvider).recordActivity(),
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: VaultifyTheme.light(),
        darkTheme: VaultifyTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
