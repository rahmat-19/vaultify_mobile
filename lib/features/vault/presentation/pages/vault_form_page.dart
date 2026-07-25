import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';
import 'package:vaultify_mobile/core/security/screenshot_protection.dart';
import 'package:vaultify_mobile/core/widgets/app_notifier.dart';
import 'package:vaultify_mobile/core/widgets/app_widgets.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';
import 'package:vaultify_mobile/features/vault/presentation/controllers/vault_controller.dart';

class VaultFormPage extends ConsumerStatefulWidget {
  const VaultFormPage({this.item, super.key});
  final VaultItem? item;
  @override
  ConsumerState<VaultFormPage> createState() => _VaultFormPageState();
}

class _VaultFormPageState extends ConsumerState<VaultFormPage> {
  final formKey = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.item?.title);
  late final username = TextEditingController(text: widget.item?.username);
  late final secret = TextEditingController(text: widget.item?.secret);
  late final website = TextEditingController(text: widget.item?.website);
  late final notes = TextEditingController(text: widget.item?.notes);
  late VaultCategory category = widget.item?.category ?? VaultCategory.login;
  bool saving = false;
  @override
  void dispose() {
    title.dispose();
    username.dispose();
    secret.dispose();
    website.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SecureScreen(
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? AppStrings.addItem : AppStrings.editItem,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              AppTextField(
                controller: title,
                label: 'Judul',
                validator: (v) =>
                    v?.trim().isNotEmpty == true ? null : 'Judul wajib diisi.',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<VaultCategory>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: VaultCategory.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => category = value ?? category),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: username,
                label: 'Username / identifier',
              ),
              const SizedBox(height: 12),
              PasswordTextField(
                controller: secret,
                label: 'Kata sandi / rahasia',
                validator: (v) =>
                    v?.isNotEmpty == true ? null : 'Rahasia wajib diisi.',
              ),
              const SizedBox(height: 12),
              AppTextField(controller: website, label: 'Website'),
              const SizedBox(height: 12),
              AppTextField(
                controller: notes,
                label: 'Catatan aman',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: AppStrings.save,
                loading: saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Future<void> _save() async {
    if (formKey.currentState?.validate() != true) return;
    setState(() => saving = true);
    final ok = await ref
        .read(vaultControllerProvider.notifier)
        .save(
          VaultItemInput(
            title: title.text.trim(),
            username: username.text.trim(),
            secret: secret.text,
            website: website.text.trim(),
            category: category,
            notes: notes.text,
          ),
          id: widget.item?.id,
        );
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) {
      AppNotifier.success(
        widget.item == null
            ? 'Item vault berhasil ditambahkan.'
            : 'Item vault berhasil diperbarui.',
      );
      context.pop();
    } else {
      final message = ref.read(vaultControllerProvider).message;
      AppNotifier.error(message ?? 'Item vault gagal disimpan.');
    }
  }
}
