import 'package:local_auth/local_auth.dart';
import 'package:vaultify_mobile/core/errors/failure.dart';

class BiometricService {
  BiometricService({LocalAuthentication? authentication})
      : _authentication = authentication ?? LocalAuthentication();
  final LocalAuthentication _authentication;

  Future<bool> isAvailable() async {
    try {
      return await _authentication.isDeviceSupported() &&
          (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Verifikasi untuk membuka rahasia'}) async {
    try {
      return await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: true,
      );
    } on LocalAuthException catch (error) {
      if (error.code == LocalAuthExceptionCode.userCanceled ||
          error.code == LocalAuthExceptionCode.systemCanceled) {
        throw const BiometricFailure('Autentikasi biometrik dibatalkan.');
      }
      if (error.code == LocalAuthExceptionCode.biometricLockout ||
          error.code == LocalAuthExceptionCode.temporaryLockout) {
        throw const BiometricFailure(
          'Biometrik terkunci. Gunakan autentikasi perangkat.',
        );
      }
      throw const BiometricFailure('Autentikasi biometrik gagal.');
    }
  }
}
