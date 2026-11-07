import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 5)
enum CategoryType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

@HiveType(typeId: 6)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  String iconFontFamily;

  @HiveField(4)
  CategoryType type;

  @HiveField(5)
  int sortOrder;

  @HiveField(6)
  bool isDefault;

  Category({
    required this.id,
    required this.name,
    IconData? icon,
    required this.type,
    required this.sortOrder,
    this.isDefault = false,
  }) : iconCodePoint = icon?.codePoint ?? Icons.category.codePoint,
       iconFontFamily = icon?.fontFamily ?? 'MaterialIcons';

  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);

  factory Category.expense({
    required String id,
    required String name,
    required IconData icon,
    int sortOrder = 0,
    bool isDefault = false,
  }) {
    return Category(
      id: id,
      name: name,
      icon: icon,
      type: CategoryType.expense,
      sortOrder: sortOrder,
      isDefault: isDefault,
    );
  }

  factory Category.income({
    required String id,
    required String name,
    required IconData icon,
    int sortOrder = 0,
    bool isDefault = false,
  }) {
    return Category(
      id: id,
      name: name,
      icon: icon,
      type: CategoryType.income,
      sortOrder: sortOrder,
      isDefault: isDefault,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    CategoryType? type,
    int? sortOrder,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name, type: $type)';
}