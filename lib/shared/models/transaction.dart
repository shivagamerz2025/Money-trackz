import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String note;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  TransactionType type;

  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  RecurrenceRule? recurrence;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.date,
    required this.type,
    this.isRecurring = false,
    this.recurrence,
  });

  Transaction copyWith({
    String? id,
    String? categoryId,
    double? amount,
    String? note,
    DateTime? date,
    TransactionType? type,
    bool? isRecurring,
    RecurrenceRule? recurrence,
  }) {
    return Transaction(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Transaction(id: $id, amount: $amount, type: $type, date: $date)';
}

@HiveType(typeId: 2)
class RecurrenceRule extends HiveObject {
  @HiveField(0)
  Frequency frequency;

  @HiveField(1)
  int interval;

  @HiveField(2)
  List<int>? daysOfWeek;

  @HiveField(3)
  int? dayOfMonth;

  @HiveField(4)
  DateTime? endDate;

  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
  });

  RecurrenceRule copyWith({
    Frequency? frequency,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
  }) {
    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      endDate: endDate ?? this.endDate,
    );
  }

  DateTime nextDate(DateTime from) {
    switch (frequency) {
      case Frequency.daily:
        return from.add(Duration(days: interval));
      case Frequency.weekly:
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          int daysUntilNext = 7;
          final currentWeekday = from.weekday % 7;
          for (final day in daysOfWeek!) {
            int diff = day - currentWeekday;
            if (diff <= 0) diff += 7;
            if (diff < daysUntilNext) daysUntilNext = diff;
          }
          return from.add(Duration(days: daysUntilNext));
        }
        return from.add(Duration(days: 7 * interval));
      case Frequency.monthly:
        int nextMonth = from.month + interval;
        int nextYear = from.year;
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        int day = dayOfMonth ?? from.day;
        // Handle month end
        final lastDayOfMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        if (day > lastDayOfMonth) day = lastDayOfMonth;
        return DateTime(nextYear, nextMonth, day);
      case Frequency.yearly:
        return DateTime(from.year + interval, from.month, from.day);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceRule &&
          runtimeType == other.runtimeType &&
          frequency == other.frequency &&
          interval == other.interval &&
          daysOfWeek == other.daysOfWeek &&
          dayOfMonth == other.dayOfMonth &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(frequency, interval, daysOfWeek, dayOfMonth, endDate);
}

@HiveType(typeId: 7)
enum Frequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}