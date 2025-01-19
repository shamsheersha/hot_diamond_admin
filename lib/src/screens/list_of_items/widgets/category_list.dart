import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';

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
      height: 70,
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          } else if (state is CategoryError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          } else if (state is CategoryLoaded) {
            final categories = state.categories;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryItem(
                    label: 'All Items',
                    isSelected: selectedCategoryId.isEmpty,
                    onTap: () => onCategorySelected(''),
                  );
                }
                final category = categories[index - 1];
                return _buildCategoryItem(
                  label: category.name,
                  isSelected: category.id == selectedCategoryId,
                  onTap: () => onCategorySelected(category.id),
                );
              },
            );
          }
          return const Center(child: Text('No categories available'));
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
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
