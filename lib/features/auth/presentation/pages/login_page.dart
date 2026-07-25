import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';
import 'package:vaultify_mobile/core/widgets/app_notifier.dart';
import 'package:vaultify_mobile/core/widgets/app_widgets.dart';
import 'package:vaultify_mobile/features/auth/presentation/controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      if (next.message != null && next.message != state.message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }
    });
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.shield,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text(
                      AppStrings.appTagline,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: email,
                      label: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value?.contains('@') == true
                          ? null
                          : 'Masukkan email yang valid.',
                    ),
                    const SizedBox(height: 14),
                    PasswordTextField(
                      controller: password,
                      validator: (value) => value?.isNotEmpty == true
                          ? null
                          : 'Kata sandi wajib diisi.',
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: AppStrings.login,
                      loading: state.loading,
                      onPressed: () async {
                        if (formKey.currentState?.validate() != true) return;
                        final ok = await ref
                            .read(authControllerProvider.notifier)
                            .login(email.text, password.text);
                        if (ok) AppNotifier.success('Login berhasil.');
                      },
                    ),
                    TextButton(
                      onPressed: state.loading
                          ? null
                          : () => context.go('/register'),
                      child: const Text('Belum punya akun? Daftar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
