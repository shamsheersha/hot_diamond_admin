import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';

class EditItemDialog extends StatefulWidget {
  final ItemModel item;

  const EditItemDialog({super.key, required this.item});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  String? newImagePath;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    descriptionController = TextEditingController(text: widget.item.description);
    priceController = TextEditingController(text: widget.item.price.toString());
    selectedCategory = widget.item.categoryId;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          newImagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[100],
      title: Text(
        'Edit Item',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageSection(),
              const SizedBox(height: 16),
              _buildFormFields(),
            ],
          ),
        ),
      ),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: newImagePath != null
                ? Image.file(File(newImagePath!), fit: BoxFit.cover)
                : Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.edit, color: Colors.black54),
            style: IconButton.styleFrom(backgroundColor: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextfield(
          controller: nameController,
          labelText: 'Name',
          hintText: nameController.text,
          isPassword: false,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a name' : null,
        ),
        const SizedBox(height: 16),
        
        BlocBuilder<CategoryBloc, CategoryState>(
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
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
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
                  if (newValue != null) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Select a category' : null,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 16),
        CustomTextfield(
          controller: descriptionController,
            labelText: 'Description',
            hintText: descriptionController.text,
            isPassword: false,
          
          maxLines: 3,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a description' : null,
        ),
        const SizedBox(height: 16),
        CustomTextfield(
          controller: priceController,
          hintText: priceController.text,
            labelText: 'Price',
            prefixText: '₹ ',

          isPassword: false,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter a price';
            if (double.tryParse(value!) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancel',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      ),
      TextButton(
        onPressed: () {
          if (formKey.currentState?.validate() ?? false) {
            final updatedItem = ItemModel(
              id: widget.item.id,
              name: nameController.text.toUpperCase(),
              description: descriptionController.text,
              price: double.parse(priceController.text),
              categoryId: selectedCategory,
              imageUrls: newImagePath != null ? [newImagePath!] : widget.item.imageUrls,
            );

            context.read<ItemBloc>().add(UpdateItemEvent(updatedItem));
            Navigator.pop(context);
          }
        },
        child: Text(
          'Save',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
      ),
    ];
  }
} 