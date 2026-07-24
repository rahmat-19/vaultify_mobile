import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaultify_mobile/app/providers.dart';
import 'package:vaultify_mobile/core/security/screenshot_protection.dart';
import 'package:vaultify_mobile/core/widgets/app_widgets.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';
import 'package:vaultify_mobile/features/vault/presentation/controllers/vault_controller.dart';

class VaultDetailPage extends ConsumerStatefulWidget {
  const VaultDetailPage({required this.item, super.key});
  final VaultItem item;
  @override
  ConsumerState<VaultDetailPage> createState() => _VaultDetailPageState();
}
class _VaultDetailPageState extends ConsumerState<VaultDetailPage>
    with WidgetsBindingObserver {
  bool revealed = false;
  Timer? hideTimer;
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _hide();
    }
  }
  @override
  void dispose() {
    hideTimer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.dispose();
  }
  void _hide() {
    hideTimer?.cancel();
    if (mounted) setState(() => revealed = false);
  }
  Future<void> _reveal() async {
    try {
      final preferences = ref.read(sharedPreferencesProvider);
      final biometricEnabled = preferences.getBool('biometric_enabled') ?? true;
      final ok = !biometricEnabled ||
          await ref.read(biometricServiceProvider).authenticate();
      if (!ok || !mounted) {
        return;
      }
      ref.read(sessionManagerProvider).unlockSensitiveAccess();
      setState(() => revealed = true);
      hideTimer = Timer(const Duration(seconds: 30), _hide);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('BiometricFailure: ', ''))),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) => SecureScreen(
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit',
            onPressed: () => context.push('/vault/${widget.item.id}/edit', extra: widget.item)),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Hapus', onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Chip(label: Text(widget.item.category.label)),
          _row('Username', widget.item.username, copy: widget.item.username),
          _row('Kata sandi / rahasia',
            revealed ? widget.item.secret : '••••••••••••',
            copy: revealed ? widget.item.secret : null),
          if (widget.item.notes.isNotEmpty)
            _row('Catatan aman', revealed ? widget.item.notes : '••••••••'),
          if (!revealed)
            FilledButton.icon(
              onPressed: _reveal,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Verifikasi & tampilkan sementara'),
            )
          else
            OutlinedButton.icon(
              onPressed: _hide,
              icon: const Icon(Icons.visibility_off),
              label: const Text('Sembunyikan sekarang'),
            ),
          if (widget.item.website.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                final uri = Uri.tryParse(widget.item.website);
                if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
                  unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka website'),
            ),
        ],
      ),
    ),
  );
  Widget _row(String label, String value, {String? copy}) => Card(
    child: ListTile(
      title: Text(label),
      subtitle: Text(value, maxLines: revealed ? 8 : 1),
      trailing: copy == null ? null : IconButton(
        icon: const Icon(Icons.copy), tooltip: 'Salin',
        onPressed: () async {
          await ref.read(clipboardServiceProvider).copy(copy);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Disalin. Clipboard akan dibersihkan otomatis.')));
          }
        },
      ),
    ),
  );
  Future<void> _delete() async {
    final yes = await showConfirmationDialog(context,
      title: 'Hapus item?', message: 'Tindakan ini tidak dapat dibatalkan.', action: 'Hapus');
    if (!yes) return;
    await ref.read(vaultControllerProvider.notifier).delete(widget.item.id);
    if (mounted) context.go('/vault');
  }
}
