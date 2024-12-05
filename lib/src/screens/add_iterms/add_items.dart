import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';
import 'package:hot_diamond_admin/widgets/show_custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  AddItemScreenState createState() => AddItemScreenState();
}

class AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _itemName = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  File? selectedImage;
  bool loading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemAddedSuccess) {
          _itemName.clear();
          _amount.clear();
          _description.clear();
          setState(() {
            selectedCategory = null;
            selectedImage = null;
            loading = false;
          });
          showCustomSnackbar(context, 'Item added successfully',
              isError: false);
        } else if (state is ItemError) {
          setState(() {
            loading = false;
          });
          showCustomSnackbar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Add New Item',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: _submitItem,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    _buildImageUploadSection(),

                    const SizedBox(height: 24),

                    // Product Details Card
                    _buildProductDetailsCard(context),
                  ],
                ),
              ),
            ),
            // Show Circular Progress Indicator when loading
            if (loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      width: double.infinity,
      height: 200,
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
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(20),
        color: Colors.grey.withOpacity(0.5),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        child: Center(
          child: selectedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        selectedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Product Image',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        'Browse Files',
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsCard(BuildContext context) {
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
          Text(
            'Product Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Item Name Field
          CustomTextfield(
            controller: _itemName,
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
          ),

          const SizedBox(height: 20),

          // Price and Category Row
          Row(
            children: [
              Expanded(
                child: CustomTextfield(
                  controller: _amount,
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
                      return DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        items: state.categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Select a category' : null,
                      );
                    }
                    return const Center();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Description Field
          CustomTextfield(
            labelText: 'Description',
            hintText: 'Describe the product',
            isPassword: false,
            controller: _description,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error if any
    }
  }

  void _submitItem() async {
    if (_formKey.currentState!.validate()) {
      if (selectedImage != null) {
        setState(() {
          loading = true;
        });

        // Dispatch item event
        context.read<ItemBloc>().add(AddItemEvent(
              ItemModel(
                id: '',
                categoryId: selectedCategory!,
                name: _itemName.text.toUpperCase(),
                description: _description.text,
                price: double.parse(_amount.text),
                imageUrl: selectedImage!.path,
              ),
            ));
      } else {
        showCustomSnackbar(context, 'Please select an image', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _itemName.clear();
    _amount.clear();
    _description.clear();
    super.dispose();
  }
}
