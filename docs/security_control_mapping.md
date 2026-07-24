# Pemetaan Kontrol Keamanan UAS

| Kontrol | Tujuan | Implementasi / source | Test case | Bukti yang diharapkan |
|---|---|---|---|---|
| S1 Authentication & session | Hanya sesi valid mengakses vault | `auth_controller.dart`, `auth_interceptor.dart`, `router.dart`, `session_manager.dart` | `login_usecase_test.dart`, integration protected flow | Login, redirect sesudah logout, pesan sesi berakhir |
| S2 Secure storage | Token tidak disimpan plaintext | `secure_storage_service.dart`; Android Keystore options | review service + device storage inspection | Source dan hasil inspeksi tanpa token di preferences biasa |
| S3 Sensitive encryption | Hindari plaintext lokal | Tidak ada cache vault; token encrypted platform storage | repository/storage review | Network-off test menunjukkan rahasia tidak tersedia dari cache |
| S4 Secure API | Bearer, timeout, refresh satu kali, HTTPS release | `dio_factory.dart`, `auth_interceptor.dart`, debug network config, main manifest | `api_error_mapper_test.dart`; interceptor integration | Proxy menunjukkan header Bearer dan release menolak HTTP |
| S5 Authorization | Akses item wajib sesuai user aktif | Route guard client; ownership wajib divalidasi endpoint backend | integration request item user lain harus 403/404 | Respons aman tanpa data milik user lain |
| S6 Permission/privacy | Minimum permission dan transparansi | Manifest hanya INTERNET/USE_BIOMETRIC; `privacy_page.dart` | manifest audit | Screenshot halaman privasi dan permission listing |
| S7 Logging/error | Rahasia tidak masuk log; error aman | `safe_logger.dart`, `api_error_mapper.dart` | `safe_logger_test.dart`, `api_error_mapper_test.dart` | Logcat tanpa body/token dan UI pesan Indonesia |
| S8 Basic hardening | Kurangi attack surface | allowBackup false, cleartext false release, explicit exported, R8/shrink | release manifest/APK inspection | MobSF/apkanalyzer report |
| P1 Biometric | Lindungi pengungkapan lokal | `biometric_service.dart`, `vault_detail_page.dart` | MethodChannel/local_auth fake flow | Detail masked sebelum fingerprint |
| P5 Secure delete | Hapus sesi/cache lokal | `clearSession()`, clear app data settings; tidak ada secret cache | logout integration | Token tidak dapat dibaca setelah logout |
| P7 Clipboard/screenshot | Kurangi kebocoran rahasia | `clipboard_service.dart`, `screenshot_protection.dart`, `MainActivity.kt` | clipboard timer + manual screenshot | Clipboard kosong setelah delay; screenshot diblokir |
| P8 Rate limit/lockout | Tahan brute force | HTTP 423/429 dipetakan ke `AccountLockedFailure`; enforcement backend | `api_error_mapper_test.dart` dan backend rate-limit test | Pesan lockout aman, respons 429 |

## Catatan verifikasi

Gunakan data dummy saat merekam bukti. Pada proxy, redact header Authorization.
Validasi S5 dan P8 harus dilakukan terhadap backend karena client tidak boleh
menjadi enforcement point otorisasi atau rate limiting.
