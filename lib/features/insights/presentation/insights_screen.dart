import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/models/models.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);
    final month = ref.watch(currentMonthProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final totalSaved = ref.watch(totalSavedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
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
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Total Spent', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text('\$${totalSpent.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Total Income', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text('\$${totalSaved.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.tertiary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Net Flow', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(totalSaved - totalSpent).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: totalSaved >= totalSpent ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category Breakdown
          Text('Expenses by Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          categoryBreakdown.when(
            data: (breakdown) {
              if (breakdown.isEmpty) {
                return EmptyListState(
                  icon: Icons.pie_chart_outline,
                  title: 'No expense data',
                  message: 'Add transactions to see breakdown',
                );
              }
              return SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: breakdown.entries.map((e) {
                      final total = breakdown.values.fold(0.0, (a, b) => a + b);
                      final percentage = (e.value / total * 100);
                      return PieChartSectionData(
                        value: e.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        color: _getColorForCategory(e.key),
                        radius: 80,
                        titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text('Error', style: TextStyle(color: Theme.of(context).colorScheme.error))),
          ),

          const SizedBox(height: 24),

          // Category List
          Text('Category Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          categoryBreakdown.when(
            data: (breakdown) {
              final total = breakdown.values.fold(0.0, (a, b) => a + b);
              final sorted = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
              return Column(
                children: sorted.map((e) {
                  final percentage = total > 0 ? (e.value / total * 100) : 0;
                  return Card(
                    child: ListTile(
                      leading: Consumer(
                        builder: (context, ref, _) {
                          final cats = ref.watch(expenseCategoriesProvider).value ?? [];
                          final cat = cats.firstWhere((c) => c.id == e.key, orElse: () => Category(id: '', name: 'Unknown', icon: Icons.help_outline, type: CategoryType.expense, sortOrder: 99));
                          return Icon(cat.icon, color: _getColorForCategory(e.key));
                        },
                      ),
                      title: Text(e.key),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${e.value.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Text('${percentage.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Color _getColorForCategory(String categoryId) {
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.red,
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
      Colors.amber, Colors.cyan,
    ];
    final hash = categoryId.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }
}