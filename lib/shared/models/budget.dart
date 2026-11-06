import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 4)
class MonthlyBudget extends HiveObject {
  @HiveField(0)
  String id; // "YYYY-MM"

  @HiveField(1)
  double spendLimit;

  @HiveField(2)
  double savingGoal;

  @HiveField(3)
  DateTime month; // First day of month

  @HiveField(4)
  bool rolloverUnused;

  MonthlyBudget({
    required this.id,
    required this.spendLimit,
    required this.savingGoal,
    required this.month,
    this.rolloverUnused = false,
  });

  factory MonthlyBudget.forMonth(DateTime month, {double spendLimit = 0, double savingGoal = 0, bool rolloverUnused = false}) {
    final id = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return MonthlyBudget(
      id: id,
      spendLimit: spendLimit,
      savingGoal: savingGoal,
      month: DateTime(month.year, month.month, 1),
      rolloverUnused: rolloverUnused,
    );
  }

  MonthlyBudget copyWith({
    String? id,
    double? spendLimit,
    double? savingGoal,
    DateTime? month,
    bool? rolloverUnused,
  }) {
    return MonthlyBudget(
      id: id ?? this.id,
      spendLimit: spendLimit ?? this.spendLimit,
      savingGoal: savingGoal ?? this.savingGoal,
      month: month ?? this.month,
      rolloverUnused: rolloverUnused ?? this.rolloverUnused,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBudget &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MonthlyBudget(id: $id, limit: $spendLimit, goal: $savingGoal)';
}

