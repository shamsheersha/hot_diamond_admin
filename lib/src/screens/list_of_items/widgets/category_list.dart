import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';
import 'package:hot_diamond_admin/src/services/firebase_category_service/firebase_category_service.dart';

class CategoryList extends StatelessWidget {
  final String selectedCategoryId;
  final Function(String) onCategorySelected;

  const CategoryList({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 65,
      child: FutureBuilder<List<CategoryModel>>(
        future: FirebaseCategoryService().fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load categories'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available'));
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryItem(label: 'All Items', isSelected: selectedCategoryId.isEmpty, onTap: ()=> onCategorySelected(''));
                }

                final category = categories[index - 1];
                return _buildCategoryItem(label: category.name, isSelected: selectedCategoryId == category.id, onTap: ()=> onCategorySelected(''));
              },
            );
          }
        },
      ),
    );
  }

    Widget _buildCategoryItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
