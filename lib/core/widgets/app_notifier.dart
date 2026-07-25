import 'package:flutter/material.dart';

abstract final class AppNotifier {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void success(String message) {
    _show(message, Colors.green.shade700);
  }

  static void error(String message) {
    _show(message, Colors.red.shade700);
  }

  static void _show(String message, Color backgroundColor) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
