import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    validator: validator,
    keyboardType: keyboardType,
    maxLines: maxLines,
    onChanged: onChanged,
  );
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    required this.controller,
    this.label = AppStrings.password,
    this.validator,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: hidden,
    enableSuggestions: false,
    autocorrect: false,
    validator: widget.validator,
    decoration: InputDecoration(
      labelText: widget.label,
      suffixIcon: IconButton(
        tooltip: hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
        onPressed: () => setState(() => hidden = !hidden),
        icon: Icon(hidden ? Icons.visibility : Icons.visibility_off),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, required this.onRetry, super.key});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.cloud_off, size: 48),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        TextButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
      ],
    ),
  );
}

class EmptyVaultView extends StatelessWidget {
  const EmptyVaultView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.lock_outline, size: 64),
        SizedBox(height: 12),
        Text(AppStrings.noItems),
        Text('Tambahkan kredensial dummy pertama Anda.'),
      ],
    ),
  );
}

class VaultItemCard extends StatelessWidget {
  const VaultItemCard({required this.item, required this.onTap, super.key});
  final VaultItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Icon(_icon(item.category))),
      title: Text(item.title),
      subtitle: Text(
        '${item.username.isEmpty ? '••••••' : item.username} · '
        '${DateFormat.yMMMd('id').format(item.updatedAt)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Chip(label: Text(item.category.label)),
    ),
  );
  IconData _icon(VaultCategory category) => switch (category) {
    VaultCategory.login => Icons.login,
    VaultCategory.apiKey => Icons.key,
    VaultCategory.pin => Icons.pin,
    VaultCategory.secureNote => Icons.note,
    VaultCategory.other => Icons.shield,
  };
}

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Lanjutkan',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

Future<bool> showLogoutDialog(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.logout_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 14),
                Text(
                  'Keluar dari akun?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Anda akan keluar dari aplikasi dan harus login kembali '
                  'untuk mengakses data Anda.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(AppStrings.logout),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ) ??
    false;

Future<void> showLogoutSuccessDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.check_rounded, color: Colors.green, size: 38),
            ),
            const SizedBox(height: 18),
            Text(
              'Logout berhasil',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sesi Anda telah berakhir dengan aman. '
              'Silakan login kembali untuk mengakses data.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
