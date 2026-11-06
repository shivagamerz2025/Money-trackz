import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/repositories/budget_repository.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/amount_input.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(currentMonthProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final totalSaved = ref.watch(totalSavedProvider);
    final spendLimit = ref.watch(spendLimitProvider);
    final savingGoal = ref.watch(savingGoalProvider);
    final spendProgress = ref.watch(spendProgressProvider);
    final savingsProgress = ref.watch(savingsProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
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
      body: budgetAsync.when(
        data: (budget) => _BudgetContent(
          budget: budget,
          totalSpent: totalSpent,
          totalSaved: totalSaved,
          spendLimit: spendLimit,
          savingGoal: savingGoal,
          spendProgress: spendProgress,
          savingsProgress: savingsProgress,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Error', style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ),
    );
  }
}

class _BudgetContent extends ConsumerWidget {
  final MonthlyBudget? budget;
  final double totalSpent;
  final double totalSaved;
  final double spendLimit;
  final double savingGoal;
  final ProgressData spendProgress;
  final ProgressData savingsProgress;

  const _BudgetContent({
    required this.budget,
    required this.totalSpent,
    required this.totalSaved,
    required this.spendLimit,
    required this.savingGoal,
    required this.spendProgress,
    required this.savingsProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final hasBudget = budget != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Month selector summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(ref.read(currentMonthProvider)),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (hasBudget)
                  Chip(
                    label: Text(hasBudget ? 'Active' : 'Not Set'),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Spend Limit Progress
        _ProgressCard(
          title: 'Spend Limit',
          progress: spendProgress,
          current: totalSpent,
          target: spendLimit,
          formatter: formatter,
          isOver: spendProgress.isOverLimit,
        ),
        const SizedBox(height: 12),

        // Saving Goal Progress
        _ProgressCard(
          title: 'Saving Goal',
          progress: savingsProgress,
          current: totalSaved,
          target: savingGoal,
          formatter: formatter,
          isOver: false,
        ),
        const SizedBox(height: 24),

        // Net Flow Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Month', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: 'Income',
                        value: formatter.format(totalSaved),
                        color: theme.colorScheme.tertiary,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Expenses',
                        value: formatter.format(totalSpent),
                        color: theme.colorScheme.error,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Net',
                        value: formatter.format(totalSaved - totalSpent),
                        color: (totalSaved - totalSpent) >= 0 ? theme.colorScheme.tertiary : theme.colorScheme.error,
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Budget Settings Form
        Text('Budget Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _BudgetForm(initialLimit: spendLimit, initialGoal: savingGoal, hasBudget: hasBudget),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final ProgressData progress;
  final double current;
  final double target;
  final NumberFormat formatter;
  final bool isOver;

  const _ProgressCard({
    required this.title,
    required this.progress,
    required this.current,
    required this.target,
    required this.formatter,
    required this.isOver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isOver ? theme.colorScheme.error : theme.colorScheme.tertiary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${formatter.format(current)} / ${formatter.format(target)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: theme.colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress.progress * 100).round()}%',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: color),
                ),
                if (target > 0)
                  Text(
                    progress.isOverLimit
                        ? 'Over by ${formatter.format(progress.remaining)}'
                        : '${formatter.format(progress.remaining)} remaining',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _BudgetForm extends ConsumerStatefulWidget {
  final double initialLimit;
  final double initialGoal;
  final bool hasBudget;

  const _BudgetForm({required this.initialLimit, required this.initialGoal, required this.hasBudget});

  @override
  ConsumerState<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends ConsumerState<_BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  final _goalController = TextEditingController();
  late bool _rolloverUnused;

  @override
  void initState() {
    super.initState();
    _limitController.text = widget.initialLimit > 0 ? widget.initialLimit.toString() : '';
    _goalController.text = widget.initialGoal > 0 ? widget.initialGoal.toString() : '';
    _rolloverUnused = false;
  }

  @override
  void dispose() {
    _limitController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = ref.watch(currentMonthProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Monthly Budget', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              AmountInput(
                controller: _limitController,
                label: 'Monthly Spend Limit',
                hint: '0.00',
              ),
              const SizedBox(height: 16),
              AmountInput(
                controller: _goalController,
                label: 'Monthly Saving Goal',
                hint: '0.00',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Rollover Unused'),
                subtitle: const Text('Carry over unused budget to next month'),
                value: _rolloverUnused,
                onChanged: (v) => setState(() => _rolloverUnused = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(widget.hasBudget ? 'Update Budget' : 'Set Budget'),
                ),
              ),
              if (widget.hasBudget) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _delete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    child: const Text('Remove Budget'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final limit = double.tryParse(_limitController.text) ?? 0;
    final goal = double.tryParse(_goalController.text) ?? 0;
    final month = ref.read(currentMonthProvider);

    if (limit == 0 && goal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least a spend limit or saving goal')),
      );
      return;
    }

    final budget = MonthlyBudget.forMonth(
      month,
      spendLimit: limit,
      savingGoal: goal,
      rolloverUnused: _rolloverUnused,
    );

    await ref.read(budgetRepositoryProvider).upsert(budget);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget saved')));
    }
  }

  Future<void> _delete() async {
    final month = ref.read(currentMonthProvider);
    await ref.read(budgetRepositoryProvider).delete(month);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget removed')));
    }
  }
}