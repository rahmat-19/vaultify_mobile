import 'package:vaultify_mobile/features/auth/domain/entities/user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
  final User user;
  final String accessToken;
  final String refreshToken;
}
