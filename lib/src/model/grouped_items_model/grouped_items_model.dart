import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';

class GroupedItems {
  final String categoryId;
  final String categoryName;
  final List<ItemModel> items;

  GroupedItems({
    required this.categoryId,
    required this.categoryName,
    required this.items,
  });
} 