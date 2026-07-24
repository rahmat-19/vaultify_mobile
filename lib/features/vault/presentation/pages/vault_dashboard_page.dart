import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaultify_mobile/core/constants/app_strings.dart';
import 'package:vaultify_mobile/core/widgets/app_widgets.dart';
import 'package:vaultify_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vaultify_mobile/features/vault/domain/entities/vault_item.dart';
import 'package:vaultify_mobile/features/vault/presentation/controllers/vault_controller.dart';

class VaultDashboardPage extends ConsumerWidget {
  const VaultDashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaultControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: <Widget>[
          IconButton(
            tooltip: AppStrings.generator,
            onPressed: () => context.push('/generator'),
            icon: const Icon(Icons.password),
          ),
          IconButton(
            tooltip: AppStrings.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.security),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ref.read(vaultControllerProvider.notifier).load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Halo, ${user?.fullName.split(' ').first ?? 'Pengguna'}',
                style: Theme.of(context).textTheme.headlineSmall),
            const Text('Kredensial Anda dilindungi dan tidak ditampilkan di daftar.'),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: <Widget>[
                  const Icon(Icons.shield_outlined, size: 44),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text('${state.items.length}', style: Theme.of(context).textTheme.headlineMedium),
                    const Text('Total item brankas'),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            SearchBar(
              hintText: 'Cari judul atau username',
              leading: const Icon(Icons.search),
              onSubmitted: (value) =>
                  ref.read(vaultControllerProvider.notifier).load(query: value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: <Widget>[
                FilterChip(
                  label: const Text('Semua'),
                  selected: state.category == null,
                  onSelected: (_) =>
                      ref.read(vaultControllerProvider.notifier).load(clear: true),
                ),
                const SizedBox(width: 6),
                for (final category in VaultCategory.values) ...<Widget>[
                  FilterChip(
                    label: Text(category.label),
                    selected: state.category == category,
                    onSelected: (_) => ref
                        .read(vaultControllerProvider.notifier).load(category: category),
                  ),
                  const SizedBox(width: 6),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            Text('Terakhir diperbarui', style: Theme.of(context).textTheme.titleMedium),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.message != null)
              ErrorView(
                message: state.message!,
                onRetry: ref.read(vaultControllerProvider.notifier).load,
              )
            else if (state.items.isEmpty)
              const SizedBox(height: 240, child: EmptyVaultView())
            else
              for (final item in state.items)
                VaultItemCard(
                  item: item,
                  onTap: () => context.push('/vault/${item.id}', extra: item),
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vault/new'),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addItem),
      ),
    );
  }
}
