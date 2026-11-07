import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/widgets/widgets.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final String? transactionId;

  const TransactionFormScreen({super.key, this.transactionId});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _selectedCategoryId = '';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    final t = await ref.read(transactionRepositoryProvider).get(widget.transactionId!);
    if (t != null) {
      _amountController.text = t.amount.toStringAsFixed(2);
      _noteController.text = t.note;
      _type = t.type;
      _selectedCategoryId = t.categoryId;
      _date = t.date;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionId != null;
    final expenseCategories = ref.watch(expenseCategoriesProvider);
    final incomeCategories = ref.watch(incomeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type selector
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.remove_circle_outline)),
                ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.add_circle_outline)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _selectedCategoryId = '';
              }),
            ),
            const SizedBox(height: 16),

            // Amount
            AmountInput(
              controller: _amountController,
              label: 'Amount',
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),

            // Category picker
            (_type == TransactionType.expense ? expenseCategories : incomeCategories).when(
              data: (categories) {
                if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
                  _selectedCategoryId = categories.first.id;
                }
                return CategoryPicker(
                  type: _type == TransactionType.expense ? CategoryType.expense : CategoryType.income,
                  selectedCategoryId: _selectedCategoryId,
                  onSelect: (id) => setState(() => _selectedCategoryId = id),
                  label: 'Category',
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text('Error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
            const SizedBox(height: 16),

            // Date picker
            DatePickerField(
              initialDate: _date,
              onDateSelected: (d) => setState(() => _date = d),
              label: 'Date',
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Save button
            FilledButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save Changes' : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      id: widget.transactionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: _selectedCategoryId,
      amount: double.tryParse(_amountController.text) ?? 0,
      note: _noteController.text.trim(),
      date: _date,
      type: _type,
    );

    await ref.read(transactionRepositoryProvider).add(transaction);
    if (mounted) context.pop();
  }
}