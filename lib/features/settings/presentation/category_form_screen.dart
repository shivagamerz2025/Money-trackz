import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/repositories/category_repository.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CategoryType _type = CategoryType.expense;
  IconData _selectedIcon = Icons.category;
  int _sortOrder = 0;

  final List<IconData> _icons = [
    Icons.restaurant, Icons.directions_bus, Icons.shopping_bag, Icons.receipt_long,
    Icons.movie, Icons.local_hospital, Icons.school, Icons.person, Icons.more_horiz,
    Icons.work, Icons.laptop_mac, Icons.account_balance_wallet, Icons.card_giftcard,
    Icons.attach_money, Icons.savings, Icons.analytics, Icons.paid,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadCategory();
    }
  }

  Future<void> _loadCategory() async {
    final cat = await ref.read(categoryRepositoryProvider).get(widget.categoryId!);
    if (cat != null) {
      _nameController.text = cat.name;
      _type = cat.type;
      _selectedIcon = cat.icon;
      _sortOrder = cat.sortOrder;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Category' : 'Add Category')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(value: CategoryType.expense, label: Text('Expense'), icon: Icon(Icons.remove)),
                ButtonSegment(value: CategoryType.income, label: Text('Income'), icon: Icon(Icons.add)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            Text('Icon', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((icon) => FilterChip(
                avatar: Icon(icon, color: _selectedIcon == icon ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant),
                label: const SizedBox.shrink(),
                selected: _selectedIcon == icon,
                onSelected: (_) => setState(() => _selectedIcon = icon),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _sortOrder.toString(),
              decoration: const InputDecoration(labelText: 'Sort Order'),
              keyboardType: TextInputType.number,
              onChanged: (v) => _sortOrder = int.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save Changes' : 'Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = Category(
      id: widget.categoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      type: _type,
      sortOrder: _sortOrder,
      isDefault: false,
    );

    await ref.read(categoryRepositoryProvider).add(category);
    if (mounted) context.pop();
  }
}