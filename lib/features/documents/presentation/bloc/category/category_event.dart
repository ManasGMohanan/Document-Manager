part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final String name;
  final int colorValue;
  final int iconData;

  const AddCategory({
    required this.name,
    required this.colorValue,
    required this.iconData,
  });

  @override
  List<Object> get props => [name, colorValue, iconData];
}

class UpdateCategory extends CategoryEvent {
  final String id;
  final String? name;
  final int? colorValue;
  final int? iconData;

  const UpdateCategory({
    required this.id,
    this.name,
    this.colorValue,
    this.iconData,
  });

  @override
  List<Object?> get props => [id, name, colorValue, iconData];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object> get props => [id];
}
