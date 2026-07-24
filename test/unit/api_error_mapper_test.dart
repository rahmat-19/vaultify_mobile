import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify_mobile/core/errors/failure.dart';
import 'package:vaultify_mobile/core/network/api_error_mapper.dart';

void main() {
  test('maps unauthorized without exposing backend data', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/vault'),
      response: Response<Object?>(
        requestOptions: RequestOptions(path: '/vault'),
        statusCode: 401,
        data: <String, Object?>{'trace': 'secret stack'},
      ),
    );
    final failure = ApiErrorMapper.map(error);
    expect(failure, isA<UnauthorizedFailure>());
    expect(failure.message, isNot(contains('stack')));
  });
  test('maps timeout', () {
    final failure = ApiErrorMapper.map(DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionTimeout,
    ));
    expect(failure, isA<TimeoutFailure>());
  });
}
