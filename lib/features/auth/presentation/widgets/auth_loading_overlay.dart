import 'package:flutter/material.dart';

class AuthLoadingOverlay extends StatelessWidget {
  const AuthLoadingOverlay({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      const ModalBarrier(dismissible: false, color: Colors.black38),
      Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: 285,
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox.square(
                  dimension: 58,
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
                const SizedBox(height: 28),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Mohon tunggu sebentar.'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
