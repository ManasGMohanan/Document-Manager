import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Category extends Equatable {
  String get id;
  String get name;
  Color get color;
  IconData get icon;

  @override
  List<Object> get props => [id, name, color, icon];
}
