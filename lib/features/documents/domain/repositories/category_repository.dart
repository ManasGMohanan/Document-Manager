import 'package:document_manager/features/documents/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category> getCategoryById(String id);
  Future<Category> addCategory({
    required String name,
    required int colorValue,
    required int iconData,
  });
  Future<Category> updateCategory({
    required String id,
    String? name,
    int? colorValue,
    int? iconData,
  });
  Future<void> deleteCategory(String id);
}
