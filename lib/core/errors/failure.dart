sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super('Koneksi ke server gagal.');
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Koneksi ke server melewati batas waktu.');
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
    : super('Sesi Anda telah berakhir. Silakan login kembali.');
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure() : super('Anda tidak memiliki akses.');
}

final class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Data yang dimasukkan tidak valid.',
  ]);
}

final class AccountLockedFailure extends Failure {
  const AccountLockedFailure()
    : super('Terlalu banyak percobaan login. Coba beberapa saat lagi.');
}

final class ServerFailure extends Failure {
  const ServerFailure() : super('Layanan sedang bermasalah. Coba kembali.');
}

final class DataFailure extends Failure {
  const DataFailure() : super('Data tidak dapat diproses.');
}

final class BiometricFailure extends Failure {
  const BiometricFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure() : super('Penyimpanan aman tidak dapat diakses.');
}
