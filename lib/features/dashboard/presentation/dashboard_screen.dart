import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/models/models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final month = ref.watch(currentMonthProvider);
    final monthString = ref.watch(currentMonthStringProvider);
    final spendProgress = ref.watch(spendProgressProvider);
    final savingsProgress = ref.watch(savingsProgressProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final upcomingBills = ref.watch(upcomingBillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(monthString),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(currentMonthProvider.notifier).state = DateTime(month.year, month.month - 1, 1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(currentMonthProvider.notifier).state = DateTime(month.year, month.month + 1, 1),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress Rings Row
          Row(
            children: [
              Expanded(child: ProgressRing(data: spendProgress, size: 100)),
              const SizedBox(width: 16),
              Expanded(child: ProgressRing(data: savingsProgress, size: 100)),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Add Expense'),
                  onPressed: () => context.go('/spending/add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Income'),
                  onPressed: () => context.go('/spending/add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    foregroundColor: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('Add Bill'),
              onPressed: () => context.go('/bills/add'),
            ),
          ),

          const SizedBox(height: 24),

          // Upcoming Bills
          if (upcomingBills.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming Bills', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => context.go('/bills'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...upcomingBills.take(3).map((bill) => Card(
              child: ListTile(
                leading: Icon(bill.category.icon, color: theme.colorScheme.onSurfaceVariant),
                title: Text(bill.name),
                subtitle: Text('Due ${DateFormat('MMM d').format(bill.nextDue)}'),
                trailing: AmountDisplay(amount: bill.amount, type: TransactionType.expense),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transactions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => context.go('/spending'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentTransactions.isEmpty)
            EmptyListState(
              icon: Icons.receipt_long,
              title: 'No transactions yet',
              message: 'Add your first expense or income',
              actionLabel: 'Add Transaction',
              onAction: () => context.go('/spending/add'),
            )
          else
            ...recentTransactions.map((t) => Card(
              child: ListTile(
                leading: Consumer(
                  builder: (context, ref, _) {
                    final cat = ref.watch(expenseCategoriesProvider).value?.firstWhere(
                      (c) => c.id == t.categoryId,
                      orElse: () => ref.watch(incomeCategoriesProvider).value!.firstWhere(
                        (c) => c.id == t.categoryId,
                        orElse: () => Category.income(id: '', name: '', icon: Icons.help_outline),
                      ),
                    );
                    return cat != null ? Icon(cat.icon, color: theme.colorScheme.onSurfaceVariant) : const Icon(Icons.help_outline);
                  },
                ),
                title: Text(t.note.isEmpty ? 'Transaction' : t.note),
                subtitle: Text(DateFormat('MMM d').format(t.date)),
                trailing: AmountDisplay(amount: t.amount, type: t.type),
              ),
            )),
        ],
      ),
    );
  }
}