import 'package:vaultify_mobile/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    fullName: (json['fullname'] ?? json['full_name']) as String? ?? '',
    email: json['email'] as String? ?? '',
  );
}
