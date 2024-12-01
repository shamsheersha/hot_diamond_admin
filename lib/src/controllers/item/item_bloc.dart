import 'package:bloc/bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/services/firebase_item_service/firebase_item_service.dart';
import 'package:hot_diamond_admin/src/services/image_cloudinary_service/image_cloudinary_service.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final ImageCloudinaryService _cloudinaryService;
  final FirebaseItemService _firebaseItemService;

  ItemBloc(this._cloudinaryService, this._firebaseItemService)
      : super(ItemInitial()) {
    on<AddItemEvent>(_onAddItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<DeleteItemEvent>(_onDeleteItem);
    on<FetchItemsEvent>(_onFetchItems);
  }

  Future<void> _onAddItem(AddItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    try {
      // Upload image to Cloudinary
      final imageUrl = await _cloudinaryService.uploadImage(event.item.imageUrl);

      // Create new item with uploaded image URL
      final newItem = ItemModel(
        id: event.item.id,
        name: event.item.name,
        description: event.item.description,
        price: event.item.price,
        categoryId: event.item.categoryId,
        imageUrl: imageUrl,
      );

      // Add to Firebase
      await _firebaseItemService.addItem(newItem);

      emit(ItemAddedSuccess());
      add(FetchItemsEvent());
    } catch (e) {
      emit(ItemError('Failed to add item: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateItem(UpdateItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    try {
      final existingItem = await _firebaseItemService.getItem(event.item.id);
      if (existingItem == null) {
        throw Exception('Item not found');
      }

      String imageUrl = event.item.imageUrl;

      // Handle image update if changed
      if (event.item.imageUrl != existingItem.imageUrl && 
          !event.item.imageUrl.startsWith('http')) {
        imageUrl = await _cloudinaryService.updateImage(
          existingItem.imageUrl,
          event.item.imageUrl,
        ) ?? existingItem.imageUrl;
      }

      // Update item with new image URL
      final updatedItem = ItemModel(
        id: event.item.id,
        name: event.item.name,
        description: event.item.description,
        price: event.item.price,
        categoryId: event.item.categoryId,
        imageUrl: imageUrl,
      );

      await _firebaseItemService.updateItem(updatedItem);

      emit(ItemUpdatedSuccess());
      add(FetchItemsEvent());
    } catch (e) {
      emit(ItemError('Failed to update item: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteItem(DeleteItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    try {
      final item = await _firebaseItemService.getItem(event.itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      // Delete image from Cloudinary if exists
      if (item.imageUrl.isNotEmpty) {
        await _cloudinaryService.deleteImageByUrl(item.imageUrl);
      }

      // Delete item from Firebase
      await _firebaseItemService.deleteItem(event.itemId);
      
      emit(ItemDeletedSuccess());
      add(FetchItemsEvent());
    } catch (e) {
      emit(ItemError('Failed to delete item: ${e.toString()}'));
    }
  }

  Future<void> _onFetchItems(FetchItemsEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    try {
      final items = await _firebaseItemService.fetchItems();
      emit(ItemLoaded(items));
    } catch (e) {
      emit(ItemError('Failed to fetch items: ${e.toString()}'));
    }
  }

  
}
