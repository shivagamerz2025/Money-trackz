import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/repositories/bill_repository.dart';
import '../../../../shared/widgets/widgets.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  final String? billId;

  const BillFormScreen({super.key, this.billId});

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategoryId = '';
  Frequency _frequency = Frequency.monthly;
  int _interval = 1;
  DateTime _nextDue = DateTime.now();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.billId != null) {
      _loadBill();
    }
  }

  Future<void> _loadBill() async {
    final bill = await ref.read(billRepositoryProvider).get(widget.billId!);
    if (bill != null) {
      _nameController.text = bill.name;
      _amountController.text = bill.amount.toStringAsFixed(2);
      _noteController.text = bill.note ?? '';
      _selectedCategoryId = bill.category.id;
      _frequency = bill.recurrence.frequency;
      _interval = bill.recurrence.interval;
      _nextDue = bill.nextDue;
      _isActive = bill.isActive;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = ref.watch(expenseCategoriesProvider);
    final isEditing = widget.billId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Bill' : 'Add Bill')),
      body: expenseCategories.when(
        data: (categories) {
          if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Bill Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AmountInput(
                  controller: _amountController,
                  label: 'Amount',
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                CategoryPicker(
                  type: CategoryType.expense,
                  selectedCategoryId: _selectedCategoryId,
                  onSelect: (id) => setState(() => _selectedCategoryId = id),
                  label: 'Category',
                ),
                const SizedBox(height: 16),
                DatePickerField(
                  initialDate: _nextDue,
                  onDateSelected: (d) => setState(() => _nextDue = d),
                  label: 'Next Due Date',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Frequency>(
                  value: _frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: Frequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name.capitalize()))).toList(),
                  onChanged: (v) => setState(() => _frequency = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _interval.toString(),
                  decoration: const InputDecoration(labelText: 'Interval (every N)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _interval = int.tryParse(v) ?? 1,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save Changes' : 'Add Bill'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Error', style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final bill = Bill(
      id: widget.billId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0,
      category: Category(
        id: _selectedCategoryId,
        name: '',
        icon: Icons.help_outline,
        type: CategoryType.expense,
        sortOrder: 0,
      ),
      recurrence: RecurrenceRule(frequency: _frequency, interval: _interval),
      nextDue: _nextDue,
      isActive: _isActive,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    await ref.read(billRepositoryProvider).add(bill);
    if (mounted) context.pop();
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}