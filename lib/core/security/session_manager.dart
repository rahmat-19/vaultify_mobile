import 'dart:async';
import 'package:flutter/widgets.dart';

class SessionManager extends ChangeNotifier {
  SessionManager(this.timeout);
  Duration timeout;
  Timer? _timer;
  bool _sensitiveLocked = true;
  bool get sensitiveLocked => _sensitiveLocked;

  void recordActivity() {
    _timer?.cancel();
    _timer = Timer(timeout, lockSensitiveAccess);
  }
  void unlockSensitiveAccess() {
    _sensitiveLocked = false;
    recordActivity();
    notifyListeners();
  }
  void lockSensitiveAccess() {
    _timer?.cancel();
    if (_sensitiveLocked) return;
    _sensitiveLocked = true;
    notifyListeners();
  }
  void updateTimeout(Duration value) {
    timeout = value;
    recordActivity();
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver(this.onBackground);
  final VoidCallback onBackground;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      onBackground();
    }
  }
}
