import 'package:bloc/bloc.dart';
import 'package:document_manager/features/documents/domain/entities/category.dart';
import 'package:document_manager/features/documents/domain/repositories/category_repository.dart';
import 'package:equatable/equatable.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await repository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoriesLoaded) {
      emit(CategoryOperationInProgress(currentState.categories));
      try {
        final category = await repository.addCategory(
          name: event.name,
          colorValue: event.colorValue,
          iconData: event.iconData,
        );

        final updatedCategories = [...currentState.categories, category];
        emit(CategoryOperationSuccess(
            updatedCategories, 'Category added successfully'));
      } catch (e) {
        emit(CategoryError('Failed to add category: ${e.toString()}',
            previousCategories: currentState.categories));
      }
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoriesLoaded) {
      emit(CategoryOperationInProgress(currentState.categories));
      try {
        final category = await repository.updateCategory(
          id: event.id,
          name: event.name,
          colorValue: event.colorValue,
          iconData: event.iconData,
        );

        final updatedCategories = currentState.categories.map((cat) {
          return cat.id == event.id ? category : cat;
        }).toList();

        emit(CategoryOperationSuccess(
            updatedCategories, 'Category updated successfully'));
      } catch (e) {
        emit(CategoryError('Failed to update category: ${e.toString()}',
            previousCategories: currentState.categories));
      }
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoriesLoaded) {
      emit(CategoryOperationInProgress(currentState.categories));
      try {
        await repository.deleteCategory(event.id);

        final updatedCategories =
            currentState.categories.where((cat) => cat.id != event.id).toList();
        emit(CategoryOperationSuccess(
            updatedCategories, 'Category deleted successfully'));
      } catch (e) {
        emit(CategoryError('Failed to delete category: ${e.toString()}',
            previousCategories: currentState.categories));
      }
    }
  }
}
