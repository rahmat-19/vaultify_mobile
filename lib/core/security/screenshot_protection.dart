import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract final class ScreenshotProtectionService {
  static const _channel = MethodChannel('vaultify/security');
  static Future<void> enable() => _channel.invokeMethod<void>('enableSecure');
  static Future<void> disable() => _channel.invokeMethod<void>('disableSecure');
}

class SecureScreen extends StatefulWidget {
  const SecureScreen({required this.child, super.key});
  final Widget child;
  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(ScreenshotProtectionService.enable());
  }
  @override
  void dispose() {
    unawaited(ScreenshotProtectionService.disable());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => widget.child;
}
