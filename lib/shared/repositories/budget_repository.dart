import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';

/// Budget repository interface
abstract class BudgetRepository {
  Stream<MonthlyBudget?> watch(DateTime month);
  Future<MonthlyBudget?> get(DateTime month);
  Future<void> upsert(MonthlyBudget budget);
  Future<void> delete(DateTime month);
}

/// Hive implementation
class HiveBudgetRepository implements BudgetRepository {
  final Box<MonthlyBudget> _box;

  HiveBudgetRepository(this._box);

  String _key(DateTime month) => '${month.year}-${month.month.toString().padLeft(2, '0')}';

  @override
  Stream<MonthlyBudget?> watch(DateTime month) => _box.watch(key: _key(month)).map((_) => _box.get(_key(month)));

  @override
  Future<MonthlyBudget?> get(DateTime month) async => _box.get(_key(month));

  @override
  Future<void> upsert(MonthlyBudget budget) async => _box.put(_key(budget.month), budget);

  @override
  Future<void> delete(DateTime month) async => _box.delete(_key(month));
}

/// Provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final box = Hive.box<MonthlyBudget>('budgets');
  return HiveBudgetRepository(box);
});