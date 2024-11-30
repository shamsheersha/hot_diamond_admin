import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_event.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/services/firebase_category_service/firebase_category_service.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final FirebaseCategoryService _service;
  CategoryBloc(this._service) : super(CategoryInitial()) {
    on<FetchCategories>(_onFetchCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  //! FETCH CATEGORIES
  Future _onFetchCategories(
      FetchCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());

    try {
      final categories = await _service.fetchCategories();
      emit(CategoryLoaded(categories));
      log('Fetched Category');
    } catch (e) {
      emit(CategoryError('Failed to fetch categories'));
    }
  }

  //! ADD CATEGORY
  Future _onAddCategory(
      AddCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await _service.addCategory(event.category);
      add(FetchCategories());
      log('Successfully Added');
    } catch (e) {
      emit(CategoryError('Failed to add category'));
    }
  }

  //! UPDATE CATEGORY
  Future _onUpdateCategory(
      UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await _service.updateCategory(event.category);
      add(FetchCategories());
      log('Updated category');
    } catch (e) {
      emit(CategoryError('Failed to update category'));
    }
  }

  //! DELETE CATEGORY
  Future _onDeleteCategory(
      DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await _service.deleteCategory(event.categoryId);
      add(FetchCategories());
      log('Deleted Category');
    } catch (e) {
      emit(CategoryError('Failed to delete category'));
    }
  }
}
