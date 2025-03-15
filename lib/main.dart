import 'package:document_manager/app.dart';
import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/data/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(DocumentModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  await Hive.openBox<DocumentModel>('documents');
  await Hive.openBox<CategoryModel>('categories');

  runApp(const App());
}
