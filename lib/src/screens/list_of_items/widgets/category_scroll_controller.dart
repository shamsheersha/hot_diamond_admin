import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';

class CategoryScrollController extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  String _selectedCategoryId = '';
  final List<ItemModel> items;

  CategoryScrollController({required this.items}) {
    scrollController.addListener(_onScroll);
  }

  String get selectedCategoryId => _selectedCategoryId;

  void setSelectedCategory(String categoryId, {bool shouldScroll = true}) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      if (shouldScroll) {
        _scrollToCategory(categoryId);
      }
      notifyListeners();
    }
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      final offset = scrollController.offset;
      final maxScroll = scrollController.position.maxScrollExtent;
      
      // Find the current visible items
      final itemHeight = 116.0; // Approximate height of each item
      final currentIndex = (offset / itemHeight).floor();
      
      if (currentIndex >= 0 && currentIndex < items.length) {
        final currentItem = items[currentIndex];
        if (currentItem.categoryId != _selectedCategoryId) {
          setSelectedCategory(currentItem.categoryId, shouldScroll: false);
        }
      }
    }
  }

  void _scrollToCategory(String categoryId) {
    if (categoryId.isEmpty) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final index = items.indexWhere((item) => item.categoryId == categoryId);
    if (index != -1) {
      final offset = index * 116.0; // Same itemHeight as above
      scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}