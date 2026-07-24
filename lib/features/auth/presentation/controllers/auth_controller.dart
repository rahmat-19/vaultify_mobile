import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultify_mobile/app/providers.dart';
import 'package:vaultify_mobile/core/errors/failure.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/user.dart';
import 'package:vaultify_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:vaultify_mobile/features/auth/domain/usecases/register_usecase.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.loading = false,
    this.message,
  });
  final AuthStatus status;
  final User? user;
  final bool loading;
  final String? message;
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? loading,
    String? message,
    bool clearMessage = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        loading: loading ?? this.loading,
        message: clearMessage ? null : message ?? this.message,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.listen<int>(sessionInvalidationProvider, (_, _) => invalidateSession());
    unawaited(Future<void>.microtask(restore));
    return const AuthState();
  }

  Future<void> restore() async {
    try {
      final user = await ref.read(authRepositoryProvider).restoreSession();
      state = AuthState(
        status: user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
        user: user,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        message: 'Sesi Anda telah berakhir. Silakan login kembali.',
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, clearMessage: true);
    try {
      final session = await LoginUseCase(ref.read(authRepositoryProvider))(
        email,
        password,
      );
      state = AuthState(status: AuthStatus.authenticated, user: session.user);
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(loading: false, message: failure.message);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmation,
  }) async {
    state = state.copyWith(loading: true, clearMessage: true);
    try {
      final session = await RegisterUseCase(ref.read(authRepositoryProvider))(
        fullName: name,
        email: email,
        password: password,
        confirmation: confirmation,
      );
      state = AuthState(status: AuthStatus.authenticated, user: session.user);
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(loading: false, message: failure.message);
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true);
    await ref.read(authRepositoryProvider).logout();
    ref.read(sessionManagerProvider).lockSensitiveAccess();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void invalidateSession() {
    ref.read(sessionManagerProvider).lockSensitiveAccess();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      message: 'Sesi Anda telah berakhir. Silakan login kembali.',
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
