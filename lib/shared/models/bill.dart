import 'package:hive/hive.dart';
import 'category.dart';
import 'transaction.dart';

part 'bill.g.dart';

@HiveType(typeId: 3)
class Bill extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  Category category;

  @HiveField(4)
  RecurrenceRule recurrence;

  @HiveField(5)
  DateTime nextDue;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String? note;

  Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.recurrence,
    required this.nextDue,
    this.isActive = true,
    this.note,
  });

  Bill copyWith({
    String? id,
    String? name,
    double? amount,
    Category? category,
    RecurrenceRule? recurrence,
    DateTime? nextDue,
    bool? isActive,
    String? note,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      nextDue: nextDue ?? this.nextDue,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bill &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Bill(id: $id, name: $name, amount: $amount, nextDue: $nextDue)';
}