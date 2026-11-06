import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/models/category.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/bill.dart';
import '../../shared/models/budget.dart';
import '../../shared/models/currency.dart';

/// Initialize Hive and register adapters
Future<void> initHive() async {
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TransactionAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(RecurrenceRuleAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(BillAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(MonthlyBudgetAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(CategoryTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(FrequencyAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(CurrencyAdapter());
  }

  // Open boxes
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Bill>('bills');
  await Hive.openBox<MonthlyBudget>('budgets');
  await Hive.openBox('settings');
}

/// Box names
class HiveBoxes {
  static const String categories = 'categories';
  static const String transactions = 'transactions';
  static const String bills = 'bills';
  static const String budgets = 'budgets';
  static const String settings = 'settings';
}