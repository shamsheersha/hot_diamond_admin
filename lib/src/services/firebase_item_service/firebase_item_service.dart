import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';

class FirebaseItemService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //! Add Item
  Future<DocumentReference> addItem(ItemModel item) async {
    try {
      final docRef = await _firebaseFirestore.collection('items').add(item.toMap());
      return docRef;
    } catch (e) {
      throw Exception('Failed to add item to Firebase');
    }
  }

  //! FETCH ITEM
  Future<List<ItemModel>> fetchItems() async {
    try {
      final snapshot = await _firebaseFirestore.collection('items').get();
      return snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items');
    }
  }

  //! FETCH ITEM BY CATEGORY
  Future<List<ItemModel>> fetchItemsByCategory(String categoryId) async {
    final snapshot = await _firebaseFirestore.collection('items').where('categoryId', isEqualTo: categoryId).get();
    return snapshot.docs.map((doc) => ItemModel.fromMap(doc.data(), doc.id)).toList();
  }

  //! UPDATE ITEM
  Future updateItem(ItemModel item) async {
    try {
      await _firebaseFirestore
          .collection('items')
          .doc(item.id)
          .update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item');
    }
  }

  //! DELET ITEM
  Future deleteItem(String itemId) async {
    try {
      await _firebaseFirestore.collection('items').doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item');
    }
  }

  //! FILTER ITEM
  Stream<List<ItemModel>> getItemByCategory(String categoryId) {
    return _firebaseFirestore
        .collection('items')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ItemModel.fromMap(doc.data(), doc.id)).toList());
  }

  //! To get Image For Delete
  Future<ItemModel?> getItem(String itemId)async{
    try{
      final doc = await _firebaseFirestore.collection('items').doc(itemId).get();
      if(doc.exists){
        return ItemModel.fromMap(doc.data()!, doc.id);
      }return null;
    }catch (e){
      throw Exception('Failed to get item:  $e');
    }
  }
}
