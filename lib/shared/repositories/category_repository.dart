import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';

/// Category repository interface
abstract class CategoryRepository {
  Stream<List<Category>> watchAll();
  Stream<List<Category>> watchByType(CategoryType type);
  Future<Category?> get(String id);
  Future<void> add(Category category);
  Future<void> update(Category category);
  Future<void> delete(String id);
  Future<void> seedDefaults();
}

/// Hive implementation
class HiveCategoryRepository implements CategoryRepository {
  final Box<Category> _box;

  HiveCategoryRepository(this._box);

  @override
  Stream<List<Category>> watchAll() => _box.watch().map((_) => _getAll());

  @override
  Stream<List<Category>> watchByType(CategoryType type) =>
      _box.watch().map((_) => _getByType(type));

  @override
  Future<Category?> get(String id) async => _box.get(id);

  @override
  Future<void> add(Category category) async => _box.put(category.id, category);

  @override
  Future<void> update(Category category) async => _box.put(category.id, category);

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Future<void> seedDefaults() async {
    if (_box.isNotEmpty) return;

    final defaults = <Category>[
      // Expense categories
      Category.expense(id: 'cat_food', name: 'Food & Dining', icon: Icons.restaurant, sortOrder: 1, isDefault: true),
      Category.expense(id: 'cat_transport', name: 'Transport', icon: Icons.directions_bus, sortOrder: 2, isDefault: true),
      Category.expense(id: 'cat_shopping', name: 'Shopping', icon: Icons.shopping_bag, sortOrder: 3, isDefault: true),
      Category.expense(id: 'cat_bills', name: 'Bills', icon: Icons.receipt_long, sortOrder: 4, isDefault: true),
      Category.expense(id: 'cat_entertainment', name: 'Entertainment', icon: Icons.movie, sortOrder: 5, isDefault: true),
      Category.expense(id: 'cat_health', name: 'Health', icon: Icons.local_hospital, sortOrder: 6, isDefault: true),
      Category.expense(id: 'cat_education', name: 'Education', icon: Icons.school, sortOrder: 7, isDefault: true),
      Category.expense(id: 'cat_personal', name: 'Personal', icon: Icons.person, sortOrder: 8, isDefault: true),
      Category.expense(id: 'cat_other_expense', name: 'Other', icon: Icons.more_horiz, sortOrder: 99, isDefault: true),

      // Income categories
      Category.income(id: 'cat_salary', name: 'Salary', icon: Icons.work, sortOrder: 1, isDefault: true),
      Category.income(id: 'cat_freelance', name: 'Freelance', icon: Icons.laptop_mac, sortOrder: 2, isDefault: true),
      Category.income(id: 'cat_allowance', name: 'Allowance', icon: Icons.account_balance_wallet, sortOrder: 3, isDefault: true),
      Category.income(id: 'cat_gift', name: 'Gift', icon: Icons.card_giftcard, sortOrder: 4, isDefault: true),
      Category.income(id: 'cat_other_income', name: 'Other', icon: Icons.more_horiz, sortOrder: 99, isDefault: true),
    ];

    for (final cat in defaults) {
      await _box.put(cat.id, cat);
    }
  }

  List<Category> _getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<Category> _getByType(CategoryType type) {
    return _getAll().where((c) => c.type == type).toList();
  }
}

/// Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final box = Hive.box<Category>('categories');
  return HiveCategoryRepository(box);
});