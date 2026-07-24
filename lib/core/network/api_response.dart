final class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.errors = const <Object?>[],
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] == null ? null : fromJsonT(json['data']),
      errors: (json['errors'] as List<dynamic>?) ?? const <Object?>[],
    );
  }

  final bool success;
  final String message;
  final T? data;
  final List<Object?> errors;
}
