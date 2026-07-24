import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';

class VaultItemModel extends VaultItem {
  const VaultItemModel({
    required super.id,
    required super.title,
    required super.username,
    required super.secret,
    required super.website,
    required super.category,
    required super.notes,
    required super.createdAt,
    required super.updatedAt,
  });
  factory VaultItemModel.fromJson(Map<String, dynamic> json) => VaultItemModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        username: json['username'] as String? ?? '',
        secret: (json['password'] ?? json['secret']) as String? ?? '',
        website: json['website'] as String? ?? '',
        category: VaultCategory.parse(json['category'] as String? ?? ''),
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

Map<String, dynamic> vaultInputToJson(VaultItemInput input) =>
    <String, dynamic>{
      'title': input.title,
      'username': input.username,
      'password': input.secret,
      'website': input.website,
      'category': input.category.name,
      'notes': input.notes,
    };
