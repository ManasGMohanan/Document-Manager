part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoryOperationInProgress extends CategoriesLoaded {
  const CategoryOperationInProgress(super.categories);
}

class CategoryOperationSuccess extends CategoriesLoaded {
  final String message;

  const CategoryOperationSuccess(super.categories, this.message);

  @override
  List<Object> get props => [categories, message];
}

class CategoryError extends CategoryState {
  final String message;
  final List<Category>? previousCategories;

  const CategoryError(this.message, {this.previousCategories});

  @override
  List<Object?> get props => [message, previousCategories];
}
