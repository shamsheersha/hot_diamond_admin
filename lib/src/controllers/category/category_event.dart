import 'package:equatable/equatable.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCategories extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final CategoryModel category;

  AddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends CategoryEvent {
  final CategoryModel category;

  UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;

  DeleteCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
