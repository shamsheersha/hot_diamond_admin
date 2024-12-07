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

class EditItemScreen extends StatefulWidget {
  final ItemModel item; // Pass the existing item data to the screen

  const EditItemScreen({super.key, required this.item});

  @override
  EditItemScreenState createState() => EditItemScreenState();
}

class EditItemScreenState extends State<EditItemScreen> {
  final TextEditingController _itemName = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  List<dynamic> selectedImages = []; // Can contain URLs or Files
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Prefill data
    _itemName.text = widget.item.name;
    _amount.text = widget.item.price.toString();
    _description.text = widget.item.description;
    selectedCategory = widget.item.categoryId;
    selectedImages = widget.item.imageUrls; // Start with URLs of existing images
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemUpdatedSuccess) {
          showCustomSnackbar(context, 'Item updated successfully', isError: false);
          Navigator.pop(context); // Return to the previous screen
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
          backgroundColor: Colors.grey[100],
          elevation: 0,
          title: Text(
            'Edit Item',
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
                label: const Text('Update Item'),
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
                    _buildImageUploadSection(),
                    const SizedBox(height: 24),
                    _buildProductDetailsCard(context),
                  ],
                ),
              ),
            ),
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
        child: selectedImages.isNotEmpty
            ? _buildSelectedImagesGrid()
            : _buildEmptyImageUploadPrompt(),
      ),
    );
  }

  Widget _buildEmptyImageUploadPrompt() {
    return InkWell(
      onTap: _pickImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add Images',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'You can add multiple images',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImagesGrid() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: selectedImages.length,
            itemBuilder: (context, index) => _buildImageTile(selectedImages[index], index),
          ),
        ),
        _buildAddMoreButton(),
      ],
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

  Widget _buildImageTile(dynamic image, int index) {
    final isUrl = image is String;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: isUrl ? NetworkImage(image) : FileImage(image as File),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }
  Widget _buildAddMoreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
        label: Text(
          'Add More Images',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[800],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      // Handle error if any
    }
  }

  void _submitItem() async {
    if (_formKey.currentState!.validate()) {
      if (selectedImages.isNotEmpty) {
        setState(() {
          loading = true;
        });

        // Separate image URLs and new image files
        List<String> imageUrls = selectedImages.whereType<String>().toList();
        List<String> newImagePaths = selectedImages
            .whereType<File>()
            .map((file) => file.path)
            .toList();

        // Dispatch the update event
        context.read<ItemBloc>().add(UpdateItemEvent(
               widget.item.copyWith(
                name: _itemName.text.toUpperCase(),
                categoryId: selectedCategory!,
                price: double.parse(_amount.text),
                description: _description.text,
                imageUrls: imageUrls + newImagePaths,
              ),
            ));
      } else {
        showCustomSnackbar(context, 'Please select at least one image', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _itemName.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }
}
