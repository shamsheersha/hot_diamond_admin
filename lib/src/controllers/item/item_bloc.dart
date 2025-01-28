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
      // Upload multiple images to Cloudinary
      final imageUrls =
          await _cloudinaryService.uploadImages(event.item.imageUrls);

      // Create new item with uploaded image URLs
      final newItem = ItemModel(
        id: event.item.id,
        name: event.item.name,
        description: event.item.description,
        price: event.item.price,
        categoryId: event.item.categoryId,
        imageUrls: imageUrls,
        variations: event.item.variations,
        offer: event.item.offer,
      );

      // Add to Firebase
      await _firebaseItemService.addItem(newItem);

      emit(ItemAddedSuccess());
      add(FetchItemsEvent());
    } catch (e) {
      emit(ItemError('Failed to add item: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateItem(
      UpdateItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    try {
      final existingItem = await _firebaseItemService.getItem(event.item.id);
      if (existingItem == null) {
        throw Exception('Item not found');
      }

      // Find images that were in the existing item but not in the updated item
      final removedImages = existingItem.imageUrls
          .where((url) => !event.item.imageUrls.contains(url))
          .toList();

      // Delete removed images from Cloudinary
      if (removedImages.isNotEmpty) {
        await _cloudinaryService.deleteImagesByUrls(removedImages);
      }

      // Update item in Firebase
      await _firebaseItemService.updateItem(event.item);

      emit(ItemUpdatedSuccess());
      add(FetchItemsEvent()); // Fetch updated items to refresh the UI
    } catch (e) {
      emit(ItemError('Failed to update item: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteItem(
      DeleteItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    try {
      final item = await _firebaseItemService.getItem(event.itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      // Delete all images from Cloudinary
      if (item.imageUrls.isNotEmpty) {
        await _cloudinaryService.deleteImagesByUrls(item.imageUrls);
      }

      // Delete item from Firebase
      await _firebaseItemService.deleteItem(event.itemId);

      emit(ItemDeletedSuccess());
      add(FetchItemsEvent());
    } catch (e) {
      emit(ItemError('Failed to delete item: ${e.toString()}'));
    }
  }

  Future<void> _onFetchItems(
      FetchItemsEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    try {
      final items = await _firebaseItemService.fetchItems();
      emit(ItemLoaded(items));
    } catch (e) {
      emit(ItemError('Failed to fetch items: ${e.toString()}'));
    }
  }
}
