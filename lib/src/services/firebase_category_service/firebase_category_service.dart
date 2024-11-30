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
    return categoryIdToName[categoryId] ?? 'Unknown Category';
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
    await _categoriesRef.doc(categoryId).delete();
  }
}
