# Vaultify — Secure Password Vault

Vaultify adalah aplikasi Flutter/Android untuk proyek akhir Mobile Application
Security. Aplikasi menyimpan kredensial dummy, API key, PIN, dan catatan aman
melalui FastAPI. Jangan gunakan kredensial produksi nyata.

## Fitur

- Register, login, restore/refresh/logout session dan protected route guard
- Dashboard, pencarian, filter kategori, serta CRUD item vault
- Rahasia selalu masked; reveal sementara memerlukan autentikasi perangkat
- Password generator berbasis `Random.secure()` (8–64 karakter)
- Auto-lock ketika idle/background, clipboard auto-clear, Android `FLAG_SECURE`
- Light/dark Material 3, empty/loading/error/confirmation states
- Security Settings dan halaman penjelasan privasi

## Kontrol keamanan

Token hanya berada di `flutter_secure_storage` yang ditopang Android Keystore.
Password login tidak disimpan. Release menolak cleartext, sementara HTTP
`10.0.2.2` hanya diizinkan oleh manifest/network config debug. Dio menambahkan
Bearer token, melakukan satu refresh terantre, mencegah retry loop, lalu
menghapus sesi jika refresh gagal. Logger tidak menerima body/header sensitif.
Vault tidak membuat cache lokal plaintext.

Detail bukti UAS tersedia di [security_control_mapping.md](docs/security_control_mapping.md).

## Arsitektur

Feature-first Clean Architecture:

```text
lib/
  app/                  # bootstrap, providers, router, theme
  core/                 # config, error, network, security, storage, widgets
  features/
    auth/               # data/domain/presentation
    vault/              # data/domain/presentation
    password_generator/ # domain/presentation
    security_settings/  # presentation
    privacy/            # presentation
```

Repository interface berada di domain, implementasi dan remote data source di
data, state/controller dan widget di presentation. Riverpod bertindak sebagai
dependency injection dan state management.

## Persyaratan

- Flutter stable dengan Dart 3.9+
- Android SDK, JDK 17, emulator API 23+
- FastAPI backend dengan endpoint yang tercantum pada spesifikasi proyek

## Instalasi dan environment

```bash
flutter pub get
cp .env.example .env
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Konfigurasi emulator memakai `API_BASE_URL=http://10.0.2.2:8000/api/v1`.
`10.0.2.2` menunjuk ke host komputer dari Android emulator. `.env` diabaikan
Git; jangan masukkan secret API ke environment client karena aplikasi mobile
tidak dapat menjaga secret statis.

## Pengujian dan build

```bash
flutter test
flutter test integration_test
flutter build apk --debug
flutter build apk --release
```

Integration test memerlukan fake FastAPI dan mock MethodChannel biometrik.
Release saat ini menggunakan debug signing agar contoh dapat dibangun. Untuk
distribusi, buat keystore privat, simpan konfigurasi di `android/key.properties`
yang diabaikan Git, lalu ganti `signingConfig` release.

## Backend dan akun dummy

Jalankan FastAPI pada port 8000. Backend harus mempertahankan ownership item
berdasarkan user token dan mengembalikan envelope `{success,message,data}`.
Buat akun dummy dari halaman Register, misalnya `demo@vaultify.local`; password
dummy tetap harus memenuhi seluruh indikator dan tidak dicantumkan di README.

## Checklist screenshot

- Onboarding dan login validation
- Register password requirements
- Dashboard loading/empty/populated
- Detail masked dan dialog biometric
- Detail revealed dengan konten dummy
- Password generator dan clipboard notice
- Security Settings dan Privacy Information
- Bukti screenshot diblokir pada layar sensitif

## Batasan keamanan

- Keamanan ownership, rate limiting, revocation, TLS certificate, serta enkripsi
  at-rest database wajib diterapkan backend.
- Rooted device, runtime instrumentation, overlay, dan compromised OS tidak dapat
  ditangani sepenuhnya oleh aplikasi.
- Clipboard Android versi tertentu dapat ditampilkan OS/keyboard sebelum timeout.
- Secure delete flash storage tidak dapat dijamin; aplikasi menghapus referensi
  token dan tidak menyimpan cache rahasia.
- Certificate pinning belum diaktifkan agar backend pengujian dapat diganti.

## Troubleshooting

- `Connection refused`: pastikan backend bind ke `0.0.0.0:8000`, lalu gunakan
  `10.0.2.2`, bukan `localhost`.
- HTTP gagal pada release: ini disengaja; gunakan endpoint HTTPS.
- Biometrik tidak muncul: daftarkan fingerprint/PIN pada emulator.
- Setelah model berubah, jalankan kembali build runner dengan
  `--delete-conflicting-outputs`.
- Jika secure storage berubah setelah reinstall, hapus data aplikasi emulator.

## Hardening Android

Manifest menonaktifkan backup dan cleartext release. `FLAG_SECURE` dipasang
melalui `MainActivity` pada layar detail/form/generator. R8 dan resource shrink
aktif untuk release. Audit exported component dan release signing setiap kali
plugin baru ditambahkan.
