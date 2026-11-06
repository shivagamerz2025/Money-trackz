import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'models/models.dart';
import 'repositories/category_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/bill_repository.dart';
import 'repositories/budget_repository.dart';
import 'repositories/settings_repository.dart';

/// Current month being viewed (first day of month)
final currentMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Formatted month string for display
final currentMonthStringProvider = Provider<String>((ref) {
  final month = ref.watch(currentMonthProvider);
  return DateFormat('MMMM yyyy').format(month);
});

/// All categories stream
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

/// Expense categories stream
final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchByType(CategoryType.expense);
});

/// Income categories stream
final incomeCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchByType(CategoryType.income);
});

/// Transactions for current month
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final month = ref.watch(currentMonthProvider);
  return ref.watch(transactionRepositoryProvider).watchByMonth(month);
});

/// All transactions stream
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// Active bills stream
final billsProvider = StreamProvider<List<Bill>>((ref) {
  return ref.watch(billRepositoryProvider).watchActive();
});

/// All bills stream
final allBillsProvider = StreamProvider<List<Bill>>((ref) {
  return ref.watch(billRepositoryProvider).watchAll();
});

/// Budget for current month
final budgetProvider = StreamProvider<MonthlyBudget?>((ref) {
  final month = ref.watch(currentMonthProvider);
  return ref.watch(budgetRepositoryProvider).watch(month);
});

/// Spend limit for current month
final spendLimitProvider = Provider<double>((ref) {
  return ref.watch(budgetProvider).value?.spendLimit ?? 0;
});

/// Saving goal for current month
final savingGoalProvider = Provider<double>((ref) {
  return ref.watch(budgetProvider).value?.savingGoal ?? 0;
});

/// Total spent this month (expenses only)
final totalSpentProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Total saved this month (income only)
final totalSavedProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Net flow (saved - spent)
final netFlowProvider = Provider<double>((ref) {
  return ref.watch(totalSavedProvider) - ref.watch(totalSpentProvider);
});

/// Spend progress data
final spendProgressProvider = Provider<ProgressData>((ref) {
  final spent = ref.watch(totalSpentProvider);
  final limit = ref.watch(spendLimitProvider);
  return ProgressData(
    current: spent,
    target: limit,
    label: 'Spend Limit',
    isPositive: spent <= limit,
  );
});

/// Savings progress data
final savingsProgressProvider = Provider<ProgressData>((ref) {
  final saved = ref.watch(totalSavedProvider);
  final goal = ref.watch(savingGoalProvider);
  return ProgressData(
    current: saved,
    target: goal,
    label: 'Saving Goal',
    isPositive: saved >= goal,
  );
});

/// Net progress (how close to breaking even or saving)
final netProgressProvider = Provider<ProgressData>((ref) {
  final net = ref.watch(netFlowProvider);
  final goal = ref.watch(savingGoalProvider);
  return ProgressData(
    current: net.clamp(0, goal),
    target: goal,
    label: 'Net Progress',
    isPositive: net >= 0,
  );
});

/// Category breakdown for current month
final categoryBreakdownProvider = FutureProvider<Map<String, double>>((ref) async {
  final month = ref.watch(currentMonthProvider);
  return ref.watch(transactionRepositoryProvider).getTotalsByCategory(month, TransactionType.expense);
});

/// Income category breakdown
final incomeBreakdownProvider = FutureProvider<Map<String, double>>((ref) async {
  final month = ref.watch(currentMonthProvider);
  return ref.watch(transactionRepositoryProvider).getTotalsByCategory(month, TransactionType.income);
});

/// Upcoming bills (next 7 days)
final upcomingBillsProvider = Provider<List<Bill>>((ref) {
  final bills = ref.watch(billsProvider).value ?? [];
  final now = DateTime.now();
  final weekLater = now.add(const Duration(days: 7));
  return bills
      .where((b) => b.nextDue.isBefore(weekLater) && b.nextDue.isAfter(now.subtract(const Duration(days: 1))))
      .toList()
    ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
});

/// Recent transactions (last 5)
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  return transactions.take(5).toList();
});

/// Settings provider
final settingsProvider = Provider<SettingsRepository>((ref) {
  return ref.watch(settingsRepositoryProvider);
});

/// Selected currency provider
final selectedCurrencyProvider = Provider<Currency>((ref) {
  return ref.watch(settingsProvider).getCurrency();
});

/// Theme mode provider (0=system, 1=light, 2=dark)
final themeModeProvider = StateProvider<int>((ref) {
  return ref.watch(settingsProvider).getThemeMode();
});

/// Currency formatter - uses selected currency
final currencyFormatterProvider = Provider<NumberFormat>((ref) {
  final currency = ref.watch(selectedCurrencyProvider);
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: currency.symbol,
    decimalDigits: currency == Currency.jpy || currency == Currency.cny ? 0 : 2,
  );
});

/// Progress data class
class ProgressData {
  final double current;
  final double target;
  final String label;
  final bool isPositive;

  const ProgressData({
    required this.current,
    required this.target,
    required this.label,
    required this.isPositive,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  double get remaining => (target - current).clamp(0.0, double.infinity);

  bool get isOverLimit => current > target && target > 0;

  bool get isComplete => target > 0 && current >= target;

  String get formattedCurrent => NumberFormat.currency(locale: 'en_US', symbol: '\$').format(current);

  String get formattedTarget => NumberFormat.currency(locale: 'en_US', symbol: '\$').format(target);

  String get formattedRemaining => NumberFormat.currency(locale: 'en_US', symbol: '\$').format(remaining);
}