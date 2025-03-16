// ignore_for_file: deprecated_member_use

import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/domain/entities/category.dart';
import 'package:flutter/material.dart';

//As category is not optional, but for tracking assigning a default category

const String defaultCategoryId = 'uncategorized';

final Category defaultCategory = CategoryModel(
  id: defaultCategoryId,
  name: 'Uncategorized',
  colorValue: Colors.grey.value,
  iconData: Icons.category.codePoint,
);
