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

  Future<bool> authenticate({
    String reason = 'Verifikasi untuk membuka rahasia',
  }) async {
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
      if (error.code == LocalAuthExceptionCode.noCredentialsSet) {
        throw const BiometricFailure(
          'Atur PIN atau pola layar pada emulator terlebih dahulu.',
        );
      }
      if (error.code == LocalAuthExceptionCode.noBiometricsEnrolled) {
        throw const BiometricFailure(
          'Belum ada sidik jari yang didaftarkan pada emulator.',
        );
      }
      if (error.code == LocalAuthExceptionCode.noBiometricHardware) {
        throw const BiometricFailure(
          'Emulator ini tidak mendukung perangkat biometrik.',
        );
      }
      if (error.code ==
          LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable) {
        throw const BiometricFailure(
          'Sensor biometrik sedang tidak tersedia. Coba kembali.',
        );
      }
      if (error.code == LocalAuthExceptionCode.biometricLockout ||
          error.code == LocalAuthExceptionCode.temporaryLockout) {
        throw const BiometricFailure(
          'Biometrik terkunci. Gunakan autentikasi perangkat.',
        );
      }
      throw const BiometricFailure('Autentikasi biometrik gagal.');
    } catch (_) {
      throw const BiometricFailure(
        'Biometrik belum tersedia atau belum dikonfigurasi pada perangkat.',
      );
    }
  }
}
