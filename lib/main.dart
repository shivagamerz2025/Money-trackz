import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/hive_init.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await initHive();

  // Initialize default categories
  final categoryBox = Hive.box<Category>('categories');
  if (categoryBox.isEmpty) {
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
      await categoryBox.put(cat.id, cat);
    }
  }

  runApp(const ProviderScope(child: MoneyTrackerApp()));
}