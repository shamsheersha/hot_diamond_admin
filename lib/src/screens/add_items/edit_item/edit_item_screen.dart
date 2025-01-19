import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/enum/discount_type.dart';
import 'package:hot_diamond_admin/src/enum/portion_type.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/model/offer_model/offer_model.dart';
import 'package:hot_diamond_admin/src/model/variation_model/variation_model.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';
import 'package:hot_diamond_admin/widgets/show_custom_snackbar.dart';

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
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _priceControllers = [];
  List<PortionType> _selectedPortionTypes = [];
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  List<dynamic> selectedImages = []; // Can contain URLs or Files
  bool loading = false;
  bool hasVariations = false;
  bool hasOffer = false;
  final TextEditingController offerDiscountValue = TextEditingController();
  final TextEditingController offerDescription = TextEditingController();
  DateTime? offerStartDate;
  DateTime? offerEndDate;
  DiscountType selectedDiscountType = DiscountType.percentage; 
  bool isOfferActive = true;
  @override
  void initState() {
    super.initState();
    // Prefill data
    _itemName.text = widget.item.name;
    _amount.text = widget.item.price.toString();
    _description.text = widget.item.description;
    selectedCategory = widget.item.categoryId;
    selectedImages =
        widget.item.imageUrls; // Start with URLs of existing images
    // Check if item has variations and set toggle accordingly
    hasVariations = widget.item.variations.isNotEmpty;
    // Prefill variations
    if (hasVariations) {
      for (var variation in widget.item.variations) {
        final quantityController = TextEditingController(text: variation.quantity.toString());
        final priceController = TextEditingController(text: variation.price.toString());
        _quantityControllers.add(quantityController);
        _priceControllers.add(priceController);
        _selectedPortionTypes.add(variation.portionType);
      }
    }

    if(widget.item.offer != null){
      hasOffer = true;
      isOfferActive = widget.item.offer!.isEnabled;
      offerDiscountValue.text = widget.item.offer!.discountValue.toString();
      offerDescription.text = widget.item.offer!.description;
      offerStartDate = widget.item.offer!.startDate;
      offerEndDate = widget.item.offer!.endDate;
      selectedDiscountType = widget.item.offer!.discountType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemUpdatedSuccess) {
          showCustomSnackbar(context, 'Item updated successfully',
              isError: false);
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
                    const SizedBox(height: 20),
                    _buildOfferSection(),
                    const SizedBox(height: 24),
                    _buildVariationsSection(),
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
            itemBuilder: (context, index) =>
                _buildImageTile(selectedImages[index], index),
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

 Widget _buildVariationsSection() {
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
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item Variations',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: hasVariations,
              onChanged: (value) {
                setState(() {
                  hasVariations = value;
                  if (!value) {
                    _quantityControllers.clear();
                    _priceControllers.clear();
                    _selectedPortionTypes.clear();
                  }
                });
              },
              activeColor: Colors.black87,
            ),
          ],
        ),
        if (hasVariations) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addVariation,
            icon: const Icon(Icons.add),
            label: const Text('Add Variation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_quantityControllers.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Add variations for different serving sizes',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ..._quantityControllers.asMap().entries.map((entry) {
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Quantity field
                      Expanded(
                        child: CustomTextfield(
                          controller: _quantityControllers[index],
                          hintText: 'e.g., 4',
                          labelText: 'Quantity',
                          isPassword: false,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Enter number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Portion type dropdown
                      Expanded(
                        child: DropdownButtonFormField<PortionType>(
                          value: _selectedPortionTypes[index],
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            labelStyle: const TextStyle(color: Colors.black),
                          ),
                          items: PortionType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.name),
                            );
                          }).toList(),
                          onChanged: (PortionType? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPortionTypes[index] = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextfield(
                          controller: _priceControllers[index],
                          labelText: 'Price',
                          hintText: '₹ 0.00',
                          keyboardType: TextInputType.number,
                          isPassword: false,
                          prefixIcon: const Icon(Icons.currency_rupee),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter valid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeVariation(index),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.grey[800],
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
        ],
      ],
    ),
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
    
  try {
    // Open the file picker for image selection
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, 
      allowMultiple: true, 
    );

    if (result != null && result.paths.isNotEmpty) {
      setState(() {
        selectedImages.add(File(result.paths.first!)); 
      });
    }
  } catch (e) {
    // Handle any errors
    log('Error picking image: $e');
  }
  }

  void _submitItem() async {
  if (_formKey.currentState!.validate()) {
    if (selectedImages.isEmpty) {
      showCustomSnackbar(context, 'Please select at least one image', isError: true);
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // Create offer model
      OfferModel? offer;
      if (hasOffer) {
        if (offerDiscountValue.text.isEmpty ||
            offerDescription.text.isEmpty ||
            offerStartDate == null ||
            offerEndDate == null) {
          showCustomSnackbar(context, 'Please fill all offer details', isError: true);
          setState(() {
            loading = false;
          });
          return;
        }

        offer = OfferModel(
          isEnabled: isOfferActive,
          discountType: selectedDiscountType,
          discountValue: double.parse(offerDiscountValue.text),
          startDate: offerStartDate!,
          endDate: offerEndDate!,
          description: offerDescription.text,
        );
      }

      // Create variations list if any
      List<VariationModel> variations = [];
      if (_quantityControllers.isNotEmpty) {
        for (int i = 0; i < _quantityControllers.length; i++) {
          variations.add(VariationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            quantity: int.parse(_quantityControllers[i].text),
            portionType: _selectedPortionTypes[i],
            price: double.parse(_priceControllers[i].text),
          ));
        }
      }

      // Separate image URLs and new image files
      List<String> imageUrls = selectedImages.whereType<String>().toList();
      List<String> newImagePaths =
          selectedImages.whereType<File>().map((file) => file.path).toList();

      // Dispatch the update event
      context.read<ItemBloc>().add(UpdateItemEvent(
            widget.item.copyWith(
              name: _itemName.text.toUpperCase(),
              categoryId: selectedCategory!,
              price: double.parse(_amount.text),
              description: _description.text,
              imageUrls: imageUrls + newImagePaths,
              variations: variations.isNotEmpty ? variations : null,
              offer: offer,
            ),
          ));
    } catch (e) {
      setState(() {
        loading = false;
      });
      showCustomSnackbar(context, 'Error updating item: ${e.toString()}', isError: true);
    }
  }
}

  // Add this method to build the offer section
  Widget _buildOfferSection() {
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
            'Offer Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Enable Offer Switch
          SwitchListTile(
            title: Text(
              'Enable Offer',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: hasOffer,
            onChanged: (bool value) {
              setState(() {
                hasOffer = value;
                if (!value) {
                  // Clear offer data when disabled
                  offerDiscountValue.clear();
                  offerDescription.clear();
                  offerStartDate = null;
                  offerEndDate = null;
                  selectedDiscountType = DiscountType.percentage;
                  isOfferActive = false;
                }
              });
            },
            activeColor: Colors.black87,
          ),

          if (hasOffer) ...[
             SwitchListTile(
              title: Text(
                'Offer Status',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                isOfferActive ? 'Active' : 'Inactive',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isOfferActive ? Colors.green : Colors.red,
                ),
              ),
              value: isOfferActive,
              onChanged: (bool value) {
                setState(() {
                  isOfferActive = value;
                });
              },
              activeColor: Colors.black87,
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),

            // Discount Type
            DropdownButtonFormField<DiscountType>(
              value: selectedDiscountType,
              decoration: InputDecoration(
                labelText: 'Discount Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: DiscountType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (DiscountType? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedDiscountType = newValue;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // Discount Value
            CustomTextfield(
              controller: offerDiscountValue,
              labelText: selectedDiscountType == DiscountType.percentage
                  ? 'Discount (%)'
                  : 'Discount Amount',
              hintText: selectedDiscountType == DiscountType.percentage
                  ? 'Enter percentage'
                  : 'Enter amount',
              keyboardType: TextInputType.number,
              isPassword: false,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final number = double.tryParse(value);
                if (number == null) return 'Enter valid number';
                if (selectedDiscountType == DiscountType.percentage &&
                    number > 100) {
                  return 'Percentage cannot exceed 100';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: offerStartDate?.toString().split(' ')[0] ?? '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: offerStartDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          offerStartDate = date;
                        });
                      }
                    },
                    validator: (value) =>
                        offerStartDate == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: offerEndDate?.toString().split(' ')[0] ?? '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: offerEndDate ?? DateTime.now(),
                        firstDate: offerStartDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          offerEndDate = date;
                        });
                      }
                    },
                    validator: (value) =>
                        offerEndDate == null ? 'Required' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Offer Description
            CustomTextfield(
              controller: offerDescription,
              labelText: 'Offer Description',
              hintText: 'Enter offer details',
              maxLines: 3,
              isPassword: false,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
  void _addVariation() {
    setState(() {
      _quantityControllers.add(TextEditingController());
      _priceControllers.add(TextEditingController());
      _selectedPortionTypes.add(PortionType.pieces);
    });
  }

  void _removeVariation(int index) {
    setState(() {
      _quantityControllers[index].dispose();
      _priceControllers[index].dispose();
      _quantityControllers.removeAt(index);
      _priceControllers.removeAt(index);
      _selectedPortionTypes.removeAt(index);
    });
  }

  @override
  void dispose() {
    _itemName.dispose();
    _amount.dispose();
    _description.dispose();
    offerDiscountValue.dispose();
      offerDescription.dispose();
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
