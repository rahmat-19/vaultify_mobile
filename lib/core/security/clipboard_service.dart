import 'dart:async';
import 'package:flutter/services.dart';

class SecureClipboardService {
  SecureClipboardService(this.clearDelay);
  final Duration clearDelay;
  Timer? _timer;

  Future<void> copy(String value) async {
    _timer?.cancel();
    await Clipboard.setData(ClipboardData(text: value));
    _timer = Timer(clearDelay, () {
      unawaited(Clipboard.setData(const ClipboardData(text: '')));
    });
  }

  void dispose() => _timer?.cancel();
}
