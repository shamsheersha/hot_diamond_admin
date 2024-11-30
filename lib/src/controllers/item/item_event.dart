import 'package:equatable/equatable.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';

abstract class ItemEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Add Item
class AddItemEvent extends ItemEvent {
  final ItemModel item;

  AddItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// Fetch Items
class FetchItemsEvent extends ItemEvent {
  final String? categoryId;

  FetchItemsEvent({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

// Update Item
class UpdateItemEvent extends ItemEvent {
  final ItemModel item;

  UpdateItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// Delete Item
class DeleteItemEvent extends ItemEvent {
  final String itemId;

  DeleteItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
