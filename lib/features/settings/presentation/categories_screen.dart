import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/repositories/category_repository.dart';
import '../../../../shared/models/models.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseCategories = ref.watch(expenseCategoriesProvider);
    final incomeCategories = ref.watch(incomeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/settings/categories/add'),
        child: const Icon(Icons.add),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Expenses'), Tab(text: 'Income')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CategoryList(
                    categoriesAsync: expenseCategories,
                    type: CategoryType.expense,
                  ),
                  _CategoryList(
                    categoriesAsync: incomeCategories,
                    type: CategoryType.income,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final AsyncValue<List<Category>> categoriesAsync;
  final CategoryType type;

  const _CategoryList({required this.categoriesAsync, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return categoriesAsync.when(
      data: (categories) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Card(
            child: ListTile(
              leading: Icon(cat.icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(cat.name),
              subtitle: cat.isDefault ? const Text('Default') : const Text('Custom'),
              trailing: cat.isDefault
                  ? null
                  : PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.go('/settings/categories/edit/${cat.id}');
                        } else if (value == 'delete') {
                          _deleteCategory(ref, cat.id, context);
                        }
                      },
                    ),
              onTap: cat.isDefault ? null : () => context.go('/settings/categories/edit/${cat.id}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text('Error', style: TextStyle(color: Theme.of(context).colorScheme.error))),
    );
  }

  void _deleteCategory(WidgetRef ref, String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('This will also affect transactions using this category.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(categoryRepositoryProvider).delete(id);
              if (context.mounted) context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}