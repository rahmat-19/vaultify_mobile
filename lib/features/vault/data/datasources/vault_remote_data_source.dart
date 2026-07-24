import 'package:dio/dio.dart';
import 'package:vaultify_mobile/features/vault/data/models/vault_item_model.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';

class VaultRemoteDataSource {
  const VaultRemoteDataSource(this.dio);
  final Dio dio;

  Future<List<VaultItemModel>> getAll({
    String? query,
    VaultCategory? category,
  }) async {
    final searching = query != null && query.trim().isNotEmpty;
    final response = await dio.get<Map<String, dynamic>>(
      searching ? '/vault/search' : '/vault',
      queryParameters: <String, dynamic>{
        if (searching) 'q': query.trim(),
        if (category != null) 'category': category.name,
      },
    );
    final raw = response.data?['data'];
    final list = raw is List<dynamic>
        ? raw
        : raw is Map<String, dynamic> && raw['items'] is List<dynamic>
            ? raw['items'] as List<dynamic>
            : throw const FormatException();
    return list
        .map((item) => VaultItemModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<VaultItemModel> getById(String id) async {
    final response = await dio.get<Map<String, dynamic>>('/vault/$id');
    return _item(response.data);
  }
  Future<VaultItemModel> create(VaultItemInput input) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/vault',
      data: vaultInputToJson(input),
    );
    return _item(response.data);
  }
  Future<VaultItemModel> update(String id, VaultItemInput input) async {
    final response = await dio.put<Map<String, dynamic>>(
      '/vault/$id',
      data: vaultInputToJson(input),
    );
    return _item(response.data);
  }
  Future<void> delete(String id) => dio.delete<void>('/vault/$id');

  VaultItemModel _item(Map<String, dynamic>? response) {
    final data = response?['data'];
    if (data is! Map<String, dynamic>) throw const FormatException();
    return VaultItemModel.fromJson(data);
  }
}
