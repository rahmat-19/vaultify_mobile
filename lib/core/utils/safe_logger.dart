import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final class SafeLogger {
  SafeLogger({Logger? logger}) : _logger = logger ?? Logger();
  final Logger _logger;

  static const _sensitive = <String>{
    'authorization',
    'password',
    'secret',
    'token',
    'refresh_token',
    'access_token',
    'pin',
    'notes',
    'api_key',
    'encryption_key',
    'input',
  };

  Map<String, Object?> sanitize(Map<String, Object?> value) => value.map(
    (key, item) => MapEntry(
      key,
      _sensitive.any((word) => key.toLowerCase().contains(word))
          ? '[DIHAPUS]'
          : key.toLowerCase().contains('email')
          ? _maskIdentifier(item?.toString() ?? '')
          : _sanitizeValue(item),
    ),
  );

  void request(String method, String path, {int? statusCode}) {
    if (kReleaseMode) return;
    _logger.d('$method $path${statusCode == null ? '' : ' [$statusCode]'}');
  }

  void warning(String category) {
    if (!kReleaseMode) _logger.w('Kategori kesalahan: $category');
  }

  void response(Object? data) {
    if (kReleaseMode || data == null) return;
    _logger.d('Response: ${_sanitizeValue(data)}');
  }

  Object? _sanitizeValue(Object? value) {
    if (value is Map) {
      return sanitize(value.map((key, item) => MapEntry(key.toString(), item)));
    }
    if (value is List) return value.map(_sanitizeValue).toList();
    return value;
  }

  String _maskIdentifier(String value) {
    final at = value.indexOf('@');
    if (at <= 1) return '***';
    return '${value[0]}***${value.substring(at)}';
  }
}
