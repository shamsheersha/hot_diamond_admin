import 'package:equatable/equatable.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';

abstract class ItemState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final List<ItemModel> items;

  ItemLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ItemAddedSuccess extends ItemState {}

class ItemUpdatedSuccess extends ItemState {}

class ItemDeletedSuccess extends ItemState {}

class ItemError extends ItemState {
  final String message;

  ItemError(this.message);

  @override
  List<Object?> get props => [message];
}
