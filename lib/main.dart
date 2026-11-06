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
  final categoryBox = Hive.box('categories');
  if (categoryBox.isEmpty) {
    final defaults = <dynamic>[
      // Expense categories
      {'id': 'cat_food', 'name': 'Food & Dining', 'iconCodePoint': 0xe56c, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 1, 'isDefault': true},
      {'id': 'cat_transport', 'name': 'Transport', 'iconCodePoint': 0xe530, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 2, 'isDefault': true},
      {'id': 'cat_shopping', 'name': 'Shopping', 'iconCodePoint': 0xe8cb, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 3, 'isDefault': true},
      {'id': 'cat_bills', 'name': 'Bills', 'iconCodePoint': 0xe8b0, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 4, 'isDefault': true},
      {'id': 'cat_entertainment', 'name': 'Entertainment', 'iconCodePoint': 0xe0e4, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 5, 'isDefault': true},
      {'id': 'cat_health', 'name': 'Health', 'iconCodePoint': 0xe549, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 6, 'isDefault': true},
      {'id': 'cat_education', 'name': 'Education', 'iconCodePoint': 0xe80c, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 7, 'isDefault': true},
      {'id': 'cat_personal', 'name': 'Personal', 'iconCodePoint': 0xe7fd, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 8, 'isDefault': true},
      {'id': 'cat_other_expense', 'name': 'Other', 'iconCodePoint': 0xe5d3, 'iconFontFamily': 'MaterialIcons', 'type': 0, 'sortOrder': 99, 'isDefault': true},

      // Income categories
      {'id': 'cat_salary', 'name': 'Salary', 'iconCodePoint': 0xe8ef, 'iconFontFamily': 'MaterialIcons', 'type': 1, 'sortOrder': 1, 'isDefault': true},
      {'id': 'cat_freelance', 'name': 'Freelance', 'iconCodePoint': 0xe310, 'iconFontFamily': 'MaterialIcons', 'type': 1, 'sortOrder': 2, 'isDefault': true},
      {'id': 'cat_allowance', 'name': 'Allowance', 'iconCodePoint': 0xe850, 'iconFontFamily': 'MaterialIcons', 'type': 1, 'sortOrder': 3, 'isDefault': true},
      {'id': 'cat_gift', 'name': 'Gift', 'iconCodePoint': 0xe8d2, 'iconFontFamily': 'MaterialIcons', 'type': 1, 'sortOrder': 4, 'isDefault': true},
      {'id': 'cat_other_income', 'name': 'Other', 'iconCodePoint': 0xe5d3, 'iconFontFamily': 'MaterialIcons', 'type': 1, 'sortOrder': 99, 'isDefault': true},
    ];

    for (final cat in defaults) {
      await categoryBox.put(cat['id'], cat);
    }
  }

  runApp(const ProviderScope(child: MoneyTrackerApp()));
}