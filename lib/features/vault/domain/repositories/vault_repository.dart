import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';

abstract interface class VaultRepository {
  Future<List<VaultItem>> getAll({String? query, VaultCategory? category});
  Future<VaultItem> getById(String id);
  Future<VaultItem> create(VaultItemInput input);
  Future<VaultItem> update(String id, VaultItemInput input);
  Future<void> delete(String id);
}
