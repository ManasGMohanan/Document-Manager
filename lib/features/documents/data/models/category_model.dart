// ignore_for_file: deprecated_member_use

import 'package:document_manager/features/documents/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

//category model, added icon and color
@HiveType(typeId: 1)
class CategoryModel extends Category {
  @HiveField(0)
  final String _id;

  @HiveField(1)
  final String _name;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final int iconData;

  CategoryModel({
    required String id,
    required String name,
    required this.colorValue,
    required this.iconData,
  })  : _id = id,
        _name = name;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  Color get color => Color(colorValue);

  @override
  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      colorValue: category.color.value,
      iconData: category.icon.codePoint,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconData,
  }) {
    return CategoryModel(
      id: id ?? _id,
      name: name ?? _name,
      colorValue: colorValue ?? this.colorValue,
      iconData: iconData ?? this.iconData,
    );
  }
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      iconData: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.iconData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
