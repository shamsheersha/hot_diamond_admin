import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';

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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    descriptionController = TextEditingController(text: widget.item.description);
    priceController = TextEditingController(text: widget.item.price.toString());
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
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a description' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: priceController,
          decoration: const InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder(),
            prefixText: '₹ ',
          ),
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
              name: nameController.text,
              description: descriptionController.text,
              price: double.parse(priceController.text),
              categoryId: widget.item.categoryId,
              imageUrl: newImagePath ?? widget.item.imageUrl,
            );

            context.read<ItemBloc>().add(UpdateItemEvent(updatedItem));
            Navigator.pop(context);
          }
        },
        child: Text(
          'Save',
          style: GoogleFonts.poppins(color: Colors.blue),
        ),
      ),
    ];
  }
} 