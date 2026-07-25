import 'package:flutter/material.dart';

abstract final class AppNotifier {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void success(String message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
