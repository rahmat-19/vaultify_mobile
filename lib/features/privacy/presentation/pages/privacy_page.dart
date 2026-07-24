import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privasi & Informasi Keamanan')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: const <Widget>[
        _Section('Data yang disimpan',
          'Token sesi disimpan pada Android Keystore melalui encrypted secure storage. '
          'Item brankas disimpan di backend; aplikasi tidak membuat cache plaintext rahasia.'),
        _Section('Izin',
          'Aplikasi hanya menggunakan INTERNET dan USE_BIOMETRIC. Tidak ada izin lokasi, '
          'kontak, kamera, mikrofon, atau penyimpanan eksternal.'),
        _Section('Enkripsi & transport',
          'Rilis hanya mengizinkan HTTPS. Penyimpanan token terenkripsi oleh platform. '
          'Rahasia terdekripsi dipertahankan di memori sesingkat mungkin.'),
        _Section('Clipboard & screenshot',
          'Clipboard dibersihkan otomatis. Screenshot dan pratinjau recent-app diblokir '
          'pada layar sensitif menggunakan FLAG_SECURE di Android.'),
        _Section('Biometrik',
          'Biometrik hanya melindungi akses lokal ke konten sensitif dan tidak menggantikan '
          'autentikasi atau otorisasi server.'),
        _Section('Peringatan data dummy',
          'Aplikasi ini dibuat untuk proyek keamanan. Gunakan hanya akun dan data dummy, '
          'bukan kredensial produksi nyata.'),
        _Section('Logout & penghapusan',
          'Logout menghapus token lokal. Hapus data aplikasi menghapus sesi dan preferensi '
          'lokal; penghapusan akun/server harus dilakukan melalui backend.'),
      ],
    ),
  );
}
class _Section extends StatelessWidget {
  const _Section(this.title, this.body);
  final String title, body;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4), Text(body),
    ]),
  );
}
