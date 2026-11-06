import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/models/models.dart';
import 'package:intl/intl.dart';

class SpendingScreen extends ConsumerWidget {
  const SpendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final month = ref.watch(currentMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Filter logic here
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'expense', child: Text('Expenses')),
              const PopupMenuItem(value: 'income', child: Text('Income')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/spending/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          MonthPickerField(
            currentMonth: month,
            onMonthChanged: (m) => ref.read(currentMonthProvider.notifier).state = m,
          ),
          const Divider(height: 1),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return EmptyListState(
                    icon: Icons.receipt_long,
                    title: 'No transactions this month',
                    message: 'Add your first expense or income',
                    actionLabel: 'Add Transaction',
                    onAction: () => context.go('/spending/add'),
                  );
                }
                // Group by date
                final grouped = <DateTime, List<Transaction>>{};
                for (final t in transactions) {
                  final day = DateTime(t.date.year, t.date.month, t.date.day);
                  grouped.putIfAbsent(day, () => []).add(t);
                }
                final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDays.length,
                  itemBuilder: (context, index) {
                    final day = sortedDays[index];
                    final dayTransactions = grouped[day]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            DateFormat('EEEE, MMM d').format(day),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...dayTransactions.map((t) => Dismissible(
                          key: ValueKey(t.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => ref.read(transactionRepositoryProvider).delete(t.id),
                          child: Card(
                            child: ListTile(
                              leading: Consumer(
                                builder: (context, ref, _) {
                                  final cats = t.type == TransactionType.expense
                                      ? ref.watch(expenseCategoriesProvider).value ?? []
                                      : ref.watch(incomeCategoriesProvider).value ?? [];
                                  final cat = cats.firstWhere(
                                    (c) => c.id == t.categoryId,
                                    orElse: () => Category(
                                      id: '',
                                      name: 'Unknown',
                                      icon: Icons.help_outline,
                                      type: t.type == TransactionType.expense ? CategoryType.expense : CategoryType.income,
                                      sortOrder: 99,
                                    ),
                                  );
                                  return Icon(cat.icon, color: Theme.of(context).colorScheme.onSurfaceVariant);
                                },
                              ),
                              title: Text(t.note.isEmpty ? 'Transaction' : t.note),
                              subtitle: Text(t.categoryId),
                              trailing: AmountDisplay(amount: t.amount, type: t.type),
                              onTap: () => context.go('/spending/edit/${t.id}'),
                            ),
                          ),
                        )),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text('Error loading transactions', style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ),
          ),
        ],
      ),
    );
  }
}