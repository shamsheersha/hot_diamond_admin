import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';

class FirebaseCategoryService {
  final CollectionReference _categoriesRef =
      FirebaseFirestore.instance.collection('categories');

  static Map<String, String> categoryIdToName = {};

//! FETCH CATEGORY
  Future<List<CategoryModel>> fetchCategories() async {
    final snapshot = await _categoriesRef.get();
    final categories = snapshot.docs.map((doc) {
      final category = CategoryModel(id: doc.id, name: doc['name']);
      categoryIdToName[doc.id] = doc['name'];
      return category;
    }).toList();
    return categories;
  }

  static String getCategoryName(String categoryId) {
    if (categoryIdToName.isEmpty) {
      FirebaseCategoryService().fetchCategories();
    }
    return categoryIdToName[categoryId] ?? 'Loading...';
  }

//! ADD CATEGORY
  Future addCategory(CategoryModel category) async {
    await _categoriesRef.add(
        {'name': category.name, 'createdAt': FieldValue.serverTimestamp()});
  }

//! UPDATE CATEGORY
  Future updateCategory(CategoryModel category) async {
    await _categoriesRef.doc(category.id).update({'name': category.name});
  }

//! DELETE CATEGORY
  Future deleteCategory(String categoryId) async {
    try {
      final hasItems = await categoryHasItems(categoryId);
      if (hasItems) {
        throw Exception('Category contains items and cannot be deleted');
      }
      await _categoriesRef.doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  //! CHECK DELETION
  Future<bool> categoryHasItems(String categoryId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check items for category: ${e.toString()}');
    }
  }
}
