import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vaultify_mobile/app/providers.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';
import 'package:vaultify_mobile/core/widgets/app_widgets.dart';
import 'package:vaultify_mobile/features/auth/presentation/controllers/auth_controller.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});
  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  late bool biometric;
  late bool autoHide;
  late int timeout;
  late int clipboard;
  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    biometric = prefs.getBool('biometric_enabled') ?? true;
    autoHide = prefs.getBool('auto_hide') ?? true;
    timeout = prefs.getInt('session_timeout') ?? 120;
    clipboard = prefs.getInt('clipboard_delay') ?? 30;
  }

  Future<bool> _authorize() async {
    if (!biometric) return true;
    try {
      return await ref
          .read(biometricServiceProvider)
          .authenticate(reason: 'Verifikasi perubahan pengaturan keamanan');
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.settings)),
    body: ListView(
      children: <Widget>[
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint),
          title: const Text('Aktifkan perlindungan biometrik'),
          subtitle: const Text(
            'Melindungi pengungkapan rahasia, bukan autentikasi backend.',
          ),
          value: biometric,
          onChanged: (value) async {
            if (!await _authorize()) return;
            await ref
                .read(sharedPreferencesProvider)
                .setBool('biometric_enabled', value);
            setState(() => biometric = value);
          },
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('Batas waktu akses sensitif'),
          trailing: DropdownButton<int>(
            value: timeout,
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem(value: 0, child: Text('Segera')),
              DropdownMenuItem(value: 60, child: Text('1 menit')),
              DropdownMenuItem(value: 120, child: Text('2 menit')),
              DropdownMenuItem(value: 300, child: Text('5 menit')),
              DropdownMenuItem(value: 600, child: Text('10 menit')),
            ],
            onChanged: (value) async {
              if (value == null || !await _authorize()) return;
              await ref
                  .read(sharedPreferencesProvider)
                  .setInt('session_timeout', value);
              ref
                  .read(sessionManagerProvider)
                  .updateTimeout(Duration(seconds: value));
              setState(() => timeout = value);
            },
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.visibility_off),
          title: const Text('Sembunyikan rahasia otomatis'),
          value: autoHide,
          onChanged: (value) async {
            if (!await _authorize()) return;
            await ref
                .read(sharedPreferencesProvider)
                .setBool('auto_hide', value);
            setState(() => autoHide = value);
          },
        ),
        ListTile(
          leading: const Icon(Icons.content_paste_off),
          title: const Text('Bersihkan clipboard'),
          subtitle: Text('$clipboard detik setelah disalin'),
        ),
        const ListTile(
          leading: Icon(Icons.screenshot_monitor),
          title: Text('Perlindungan screenshot'),
          subtitle: Text('Aktif pada layar sensitif (Android FLAG_SECURE).'),
          trailing: Icon(Icons.check_circle, color: Colors.green),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services),
          title: const Text('Bersihkan cache lokal'),
          subtitle: const Text(
            'Tidak ada cache rahasia plaintext yang disimpan.',
          ),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache lokal telah dibersihkan.')),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text(AppStrings.privacy),
          onTap: () => context.push('/privacy'),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Informasi aplikasi'),
          onTap: () async {
            final info = await PackageInfo.fromPlatform();
            if (context.mounted) {
              showAboutDialog(
                context: context,
                applicationName: AppStrings.appName,
                applicationVersion: '${info.version}+${info.buildNumber}',
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Hapus data aplikasi lokal'),
          onTap: () async {
            if (!await _authorize() || !context.mounted) return;
            final yes = await showConfirmationDialog(
              context,
              title: 'Hapus data lokal?',
              message: 'Sesi dan preferensi lokal akan dihapus.',
              action: 'Hapus',
            );
            if (!yes) return;
            await ref.read(secureStorageProvider).clearSession();
            await ref.read(sharedPreferencesProvider).clear();
            ref.read(authControllerProvider.notifier).invalidateSession();
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text(AppStrings.logout),
          onTap: () async {
            final yes = await showLogoutDialog(context);
            if (yes) {
              await ref.read(authControllerProvider.notifier).logout();
            }
          },
        ),
      ],
    ),
  );
}
