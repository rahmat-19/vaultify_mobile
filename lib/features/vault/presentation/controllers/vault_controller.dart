import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultify_mobile/app/providers.dart';
import 'package:vaultify_mobile/core/errors/failure.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';

class VaultState {
  const VaultState({
    this.items = const <VaultItem>[],
    this.loading = false,
    this.message,
    this.query = '',
    this.category,
  });
  final List<VaultItem> items;
  final bool loading;
  final String? message;
  final String query;
  final VaultCategory? category;
  VaultState copyWith({
    List<VaultItem>? items,
    bool? loading,
    String? message,
    String? query,
    VaultCategory? category,
    bool clearCategory = false,
  }) =>
      VaultState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        message: message,
        query: query ?? this.query,
        category: clearCategory ? null : category ?? this.category,
      );
}

class VaultController extends Notifier<VaultState> {
  @override
  VaultState build() {
    unawaited(Future<void>.microtask(load));
    return const VaultState(loading: true);
  }
  Future<void> load({String? query, VaultCategory? category, bool clear = false}) async {
    final nextQuery = query ?? state.query;
    final nextCategory = clear ? null : category ?? state.category;
    state = state.copyWith(
      loading: true,
      query: nextQuery,
      category: nextCategory,
      clearCategory: clear,
    );
    try {
      final items = await ref.read(vaultRepositoryProvider).getAll(
            query: nextQuery,
            category: nextCategory,
          );
      state = state.copyWith(items: items, loading: false);
    } on Failure catch (failure) {
      state = state.copyWith(loading: false, message: failure.message);
    }
  }
  Future<bool> save(VaultItemInput input, {String? id}) async {
    try {
      final repository = ref.read(vaultRepositoryProvider);
      if (id == null) {
        await repository.create(input);
      } else {
        await repository.update(id, input);
      }
      await load();
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(message: failure.message);
      return false;
    }
  }
  Future<void> delete(String id) async {
    try {
      await ref.read(vaultRepositoryProvider).delete(id);
      await load();
    } on Failure catch (failure) {
      state = state.copyWith(message: failure.message);
    }
  }
}
final vaultControllerProvider = NotifierProvider<VaultController, VaultState>(
  VaultController.new,
);
