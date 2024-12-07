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
      FirebaseCategoryService.categoryIdToName = {for(var category in categories)category.id : category.name};
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
      final currentState = state;
      if(currentState is! CategoryLoaded){
        emit(CategoryError('Failed to delete: Invalid state'));
        return;
      }

      // Check for items before deletion
      final hasItems = await _service.categoryHasItems(event.categoryId);
      if (hasItems) {
        emit(CategoryError('Cannot delete category that contains items'));
        // Maintain the current categories in the UI
        emit(CategoryLoaded(currentState.categories));
        return;
      }
      
      await _service.deleteCategory(event.categoryId);
      add(FetchCategories());
      log('Deleted Category');
    } catch (e) {
      emit(CategoryError('Failed to delete category'));
    }
  }
}
