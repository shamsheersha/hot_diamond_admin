import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';

class CategoryScrollController extends ChangeNotifier {
  final List<ItemModel> items;
  final ScrollController scrollController = ScrollController();
  String _selectedCategoryId = '';

  CategoryScrollController({required this.items}) {
    scrollController.addListener(_onScroll);
  }

  String get selectedCategoryId => _selectedCategoryId;

  void setSelectedCategory(String categoryId) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      notifyListeners();
    }
  }


  void _onScroll() {
    if (!scrollController.hasClients) return;

    final currentIndex = (scrollController.offset / 100.0).floor();
    if (currentIndex >= 0 && currentIndex < items.length) {
      final currentCategoryId = items[currentIndex].categoryId;
      if (currentCategoryId != _selectedCategoryId) {
        _selectedCategoryId = currentCategoryId;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
}