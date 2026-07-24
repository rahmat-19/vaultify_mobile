import 'package:dio/dio.dart';
import 'package:vaultify_mobile/core/network/api_response.dart';
import 'package:vaultify_mobile/features/auth/data/models/user_model.dart';
import 'package:vaultify_mobile/features/auth/domain/entities/auth_session.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this.dio);
  final Dio dio;

  Future<AuthSession> login(String email, String password) => _authenticate(
    '/auth/login',
    <String, String>{'email': email, 'password': password},
  );

  Future<AuthSession> register(
    String fullName,
    String email,
    String password,
  ) => _authenticate('/auth/register', <String, String>{
    'fullname': fullName,
    'email': email,
    'password': password,
  });

  Future<AuthSession> _authenticate(
    String path,
    Map<String, String> payload,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(path, data: payload);
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? const <String, dynamic>{},
      (json) => json! as Map<String, dynamic>,
    );
    final data = envelope.data;
    if (!envelope.success || data == null) throw const FormatException();
    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];
    if (accessToken is! String || refreshToken is! String) {
      throw const FormatException();
    }
    return AuthSession(
      user: await _meWithToken(accessToken),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<UserModel> _meWithToken(String accessToken) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(
        headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      ),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) throw const FormatException();
    return UserModel.fromJson(data);
  }

  Future<UserModel> me() async {
    final response = await dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) throw const FormatException();
    return UserModel.fromJson(data);
  }

  Future<void> logout() => dio.post<void>('/auth/logout');
}
