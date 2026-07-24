import 'package:flutter_dotenv/flutter_dotenv.dart';

final class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sessionTimeout,
    required this.clipboardClearDelay,
  });

  factory AppConfig.fromEnvironment() {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || Uri.tryParse(url)?.hasScheme != true) {
      throw const FormatException('API_BASE_URL tidak valid.');
    }
    int seconds(String key, int fallback) =>
        int.tryParse(dotenv.env[key] ?? '') ?? fallback;
    return AppConfig(
      apiBaseUrl: url,
      connectTimeout: Duration(seconds: seconds('CONNECT_TIMEOUT_SECONDS', 15)),
      receiveTimeout: Duration(seconds: seconds('RECEIVE_TIMEOUT_SECONDS', 15)),
      sessionTimeout: Duration(seconds: seconds('SESSION_TIMEOUT_SECONDS', 120)),
      clipboardClearDelay:
          Duration(seconds: seconds('CLIPBOARD_CLEAR_SECONDS', 30)),
    );
  }

  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sessionTimeout;
  final Duration clipboardClearDelay;
}
