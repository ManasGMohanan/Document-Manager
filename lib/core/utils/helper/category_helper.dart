import 'package:document_manager/core/utils/constants/default_category.dart';
import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:hive/hive.dart';

//Can be checked during app loading
Future<void> ensureDefaultCategoryExists() async {
  final box = Hive.box<CategoryModel>('categories');
  if (!box.containsKey(defaultCategoryId)) {
    await box.put(defaultCategoryId, defaultCategory as CategoryModel);
  }
}
