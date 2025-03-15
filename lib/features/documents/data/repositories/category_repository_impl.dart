import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/domain/entities/category.dart';
import 'package:document_manager/features/documents/domain/repositories/category_repository.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final Box<CategoryModel> _categoriesBox;
  final Uuid _uuid = const Uuid();

  CategoryRepositoryImpl(this._categoriesBox);

  @override
  Future<List<Category>> getAllCategories() async {
    return _categoriesBox.values.toList();
  }

  @override
  Future<Category> getCategoryById(String id) async {
    final category = _categoriesBox.values.firstWhere(
      (cat) => cat.id == id,
      orElse: () => throw Exception('Category not found'),
    );
    return category;
  }

  @override
  Future<Category> addCategory({
    required String name,
    required int colorValue,
    required int iconData,
  }) async {
    final id = _uuid.v4();
    final category = CategoryModel(
      id: id,
      name: name,
      colorValue: colorValue,
      iconData: iconData,
    );

    await _categoriesBox.put(id, category);
    return category;
  }

  @override
  Future<Category> updateCategory({
    required String id,
    String? name,
    int? colorValue,
    int? iconData,
  }) async {
    final existingCategory = await getCategoryById(id) as CategoryModel;

    final updatedCategory = existingCategory.copyWith(
      name: name,
      colorValue: colorValue,
      iconData: iconData,
    );

    await _categoriesBox.put(id, updatedCategory);
    return updatedCategory;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }
}
