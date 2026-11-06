// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyBudgetAdapter extends TypeAdapter<MonthlyBudget> {
  @override
  final int typeId = 4;

  @override
  MonthlyBudget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyBudget(
      id: fields[0] as String,
      spendLimit: fields[1] as double,
      savingGoal: fields[2] as double,
      month: fields[3] as DateTime,
      rolloverUnused: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyBudget obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.spendLimit)
      ..writeByte(2)
      ..write(obj.savingGoal)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.rolloverUnused);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
