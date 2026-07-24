import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';
import 'package:vaultify_mobile/core/widgets/app_widgets.dart';
import 'package:vaultify_mobile/features/auth/domain/usecases/password_validator.dart';
import 'package:vaultify_mobile/features/auth/presentation/controllers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends ConsumerState<RegisterPage> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  @override
  void dispose() {
    name.dispose(); email.dispose(); password.dispose(); confirmation.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.register)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: key,
              child: Column(
                children: <Widget>[
                  AppTextField(controller: name, label: AppStrings.fullName,
                    validator: (v) => (v?.trim().length ?? 0) >= 2 ? null : 'Nama wajib diisi.'),
                  const SizedBox(height: 12),
                  AppTextField(controller: email, label: AppStrings.email,
                    validator: (v) => v?.contains('@') == true ? null : 'Email tidak valid.'),
                  const SizedBox(height: 12),
                  PasswordTextField(controller: password,
                    validator: (v) => PasswordValidator.isStrong(v ?? '')
                        ? null : 'Kata sandi belum memenuhi persyaratan.'),
                  const SizedBox(height: 8),
                  const _Requirements(),
                  const SizedBox(height: 12),
                  PasswordTextField(
                    controller: confirmation,
                    label: AppStrings.confirmPassword,
                    validator: (v) => v == password.text ? null : 'Konfirmasi tidak sama.',
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: AppStrings.register,
                    loading: state.loading,
                    onPressed: () async {
                      if (key.currentState?.validate() != true) return;
                      final ok = await ref.read(authControllerProvider.notifier).register(
                        name: name.text, email: email.text,
                        password: password.text, confirmation: confirmation.text,
                      );
                      if (!ok && context.mounted) {
                        final message = ref.read(authControllerProvider).message;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message ?? AppStrings.genericError)),
                        );
                      }
                    },
                  ),
                  TextButton(onPressed: () => context.go('/login'),
                    child: const Text('Sudah punya akun? Masuk')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _Requirements extends StatelessWidget {
  const _Requirements();
  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.centerLeft,
    child: Text('Minimal 8 karakter • huruf besar • huruf kecil • angka • simbol',
      style: TextStyle(fontSize: 12)),
  );
}
