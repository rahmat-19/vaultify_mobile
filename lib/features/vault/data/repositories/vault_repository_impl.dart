import 'package:vaultify_mobile/core/network/api_error_mapper.dart';
import 'package:vaultify_mobile/features/vault/data/datasources/vault_remote_data_source.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';
import 'package:vaultify_mobile/features/vault/domain/repositories/vault_repository.dart';

class VaultRepositoryImpl implements VaultRepository {
  const VaultRepositoryImpl(this.remote);
  final VaultRemoteDataSource remote;
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }
  @override
  Future<List<VaultItem>> getAll({String? query, VaultCategory? category}) =>
      _guard(() => remote.getAll(query: query, category: category));
  @override
  Future<VaultItem> getById(String id) => _guard(() => remote.getById(id));
  @override
  Future<VaultItem> create(VaultItemInput input) =>
      _guard(() => remote.create(input));
  @override
  Future<VaultItem> update(String id, VaultItemInput input) =>
      _guard(() => remote.update(id, input));
  @override
  Future<void> delete(String id) => _guard(() => remote.delete(id));
}
