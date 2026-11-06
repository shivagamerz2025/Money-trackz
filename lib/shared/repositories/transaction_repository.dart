import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';

/// Transaction repository interface
abstract class TransactionRepository {
  Stream<List<Transaction>> watchByMonth(DateTime month);
  Stream<List<Transaction>> watchAll();
  Future<Transaction?> get(String id);
  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Future<List<Transaction>> getByCategory(String categoryId);
  Future<double> getTotalByType(DateTime month, TransactionType type);
  Future<Map<String, double>> getTotalsByCategory(DateTime month, TransactionType type);
}

/// Hive implementation
class HiveTransactionRepository implements TransactionRepository {
  final Box<Transaction> _box;

  HiveTransactionRepository(this._box);

  DateTime _monthStart(DateTime month) => DateTime(month.year, month.month, 1);
  DateTime _monthEnd(DateTime month) => DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  @override
  Stream<List<Transaction>> watchByMonth(DateTime month) {
    final start = _monthStart(month);
    final end = _monthEnd(month);
    return _box.watch().map((_) => _box.values
        .where((t) => t.date.isAfter(start.subtract(const Duration(days: 1))) && t.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)));
  }

  @override
  Stream<List<Transaction>> watchAll() => _box.watch().map((_) => _box.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date)));

  @override
  Future<Transaction?> get(String id) async => _box.get(id);

  @override
  Future<void> add(Transaction transaction) async => _box.put(transaction.id, transaction);

  @override
  Future<void> update(Transaction transaction) async => _box.put(transaction.id, transaction);

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Future<List<Transaction>> getByCategory(String categoryId) async =>
      _box.values.where((t) => t.categoryId == categoryId).toList();

  @override
  Future<double> getTotalByType(DateTime month, TransactionType type) async {
    final start = _monthStart(month);
    final end = _monthEnd(month);
    final transactions = _box.values
        .where((t) => t.type == type && t.date.isAfter(start.subtract(const Duration(days: 1))) && t.date.isBefore(end.add(const Duration(days: 1))));
    double sum = 0.0;
    for (final t in transactions) {
      sum += t.amount;
    }
    return sum;
  }

  @override
  Future<Map<String, double>> getTotalsByCategory(DateTime month, TransactionType type) async {
    final start = _monthStart(month);
    final end = _monthEnd(month);
    final map = <String, double>{};
    for (final t in _box.values) {
      if (t.type == type && t.date.isAfter(start.subtract(const Duration(days: 1))) && t.date.isBefore(end.add(const Duration(days: 1)))) {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    return map;
  }
}

/// Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final box = Hive.box<Transaction>('transactions');
  return HiveTransactionRepository(box);
});