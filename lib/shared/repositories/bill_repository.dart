import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';

/// Bill repository interface
abstract class BillRepository {
  Stream<List<Bill>> watchActive();
  Stream<List<Bill>> watchAll();
  Future<Bill?> get(String id);
  Future<void> add(Bill bill);
  Future<void> update(Bill bill);
  Future<void> delete(String id);
  Future<void> markPaid(Bill bill);
}

/// Hive implementation
class HiveBillRepository implements BillRepository {
  final Box<Bill> _box;

  HiveBillRepository(this._box);

  @override
  Stream<List<Bill>> watchActive() => _box.watch().map((_) => _box.values.where((b) => b.isActive).toList()
    ..sort((a, b) => a.nextDue.compareTo(b.nextDue)));

  @override
  Stream<List<Bill>> watchAll() => _box.watch().map((_) => _box.values.toList()
    ..sort((a, b) => a.nextDue.compareTo(b.nextDue)));

  @override
  Future<Bill?> get(String id) async => _box.get(id);

  @override
  Future<void> add(Bill bill) async => _box.put(bill.id, bill);

  @override
  Future<void> update(Bill bill) async => _box.put(bill.id, bill);

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Future<void> markPaid(Bill bill) async {
    final nextDue = bill.recurrence.nextDate(bill.nextDue);
    // Check if recurrence has ended
    if (bill.recurrence.endDate != null && nextDue.isAfter(bill.recurrence.endDate!)) {
      await _box.put(bill.id, bill.copyWith(isActive: false));
    } else {
      await _box.put(bill.id, bill.copyWith(nextDue: nextDue));
    }
  }
}

/// Provider
final billRepositoryProvider = Provider<BillRepository>((ref) {
  final box = Hive.box<Bill>('bills');
  return HiveBillRepository(box);
});