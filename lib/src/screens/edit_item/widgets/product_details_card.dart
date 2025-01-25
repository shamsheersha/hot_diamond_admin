import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';

class ProductDetailsCard extends StatelessWidget {
  final TextEditingController itemNameController;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final bool isInStock;
  final ValueChanged<bool> onStockChanged;

  const ProductDetailsCard({
    super.key,
    required this.itemNameController,
    required this.amountController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isInStock,
    required this.onStockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: isInStock,
                onChanged: onStockChanged,
                activeColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildItemNameField(),
          const SizedBox(height: 20),
          _buildPriceAndCategoryRow(context),
          const SizedBox(height: 20),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  Widget _buildItemNameField() {
    return CustomTextfield(
      controller: itemNameController,
      hintText: 'Enter item name',
      labelText: 'Item Name',
      isPassword: false,
      prefixIcon: const Icon(Icons.shopping_bag_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter item name';
        }
        return null;
      },
    );
  }

  Widget _buildPriceAndCategoryRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextfield(
            controller: amountController,
            labelText: 'Price',
            hintText: '₹ 0.00',
            keyboardType: TextInputType.number,
            isPassword: false,
            prefixIcon: const Icon(Icons.currency_rupee),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter price';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoaded) {
                return _buildCategoryDropdown(state.categories);
              }
              return const Center();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(List<CategoryModel> categories) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelStyle: const TextStyle(color: Colors.black),
      ),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: onCategoryChanged,
      validator: (value) => value == null ? 'Select a category' : null,
    );
  }

  Widget _buildDescriptionField() {
    return CustomTextfield(
      labelText: 'Description',
      hintText: 'Describe the product',
      isPassword: false,
      controller: descriptionController,
      maxLines: 5,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter description';
        }
        return null;
      },
    );
  }
}
