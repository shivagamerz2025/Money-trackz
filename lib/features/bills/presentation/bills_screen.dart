import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/repositories/bill_repository.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/bills/add'),
        child: const Icon(Icons.add),
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return EmptyListState(
              icon: Icons.receipt_long,
              title: 'No bills yet',
              message: 'Add recurring bills to track them',
              actionLabel: 'Add Bill',
              onAction: () => context.go('/bills/add'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return Dismissible(
                key: ValueKey(bill.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => ref.read(billRepositoryProvider).delete(bill.id),
                child: Card(
                  child: ListTile(
                    leading: Icon(bill.category.icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    title: Text(bill.name),
                    subtitle: Text('Next due: ${DateFormat('MMM d, yyyy').format(bill.nextDue)} • ${bill.recurrence.frequency.name}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${bill.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        if (!bill.isActive)
                          Text('Paused', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
                      ],
                    ),
                    onTap: () => context.go('/bills/edit/${bill.id}'),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Error loading bills', style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ),
    );
  }
}