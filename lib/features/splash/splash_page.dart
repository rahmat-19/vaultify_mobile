import 'package:flutter/material.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Icon(Icons.shield, size: 84),
        SizedBox(height: 16),
        Text(AppStrings.appName, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        Text(AppStrings.appTagline),
        SizedBox(height: 24),
        CircularProgressIndicator(),
      ]),
    ),
  );
}
