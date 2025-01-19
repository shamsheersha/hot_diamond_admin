import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _priceControllers = [];
  final List<PortionType> _selectedPortionTypes = [];
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  bool loading = false; // Track loading state
  bool hasVariations = false;
  List<File> images = [];
  bool hasOffer = false;
  final TextEditingController offerDiscountValue = TextEditingController();
  final TextEditingController offerDescription = TextEditingController();
  DateTime? offerStartDate;
  DateTime? offerEndDate;
  DiscountType selectedDiscountType = DiscountType.percentage;
  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemAddedSuccess) {
          _itemName.clear();
          _amount.clear();
          _description.clear();
          images.clear();
          setState(() {
            selectedCategory = null;
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
          backgroundColor: Colors.grey[100],
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
                    _buildImageUploadSection(),
                    const SizedBox(height: 24),
                    // Product Details Card
                    _buildProductDetailsCard(context),
                    const SizedBox(height: 20),
                    // Offer Section
                    _buildOfferSection(),
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

  _removeVariation(int index) {
    setState(() {
      _quantityControllers[index].dispose();
      _priceControllers[index].dispose();
      _quantityControllers.removeAt(index);
      _priceControllers.removeAt(index);
      _selectedPortionTypes.removeAt(index);
    });
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
        child: images.isNotEmpty
            ? _buildSelectedImagesGrid()
            : _buildEmptyImageUploadPrompt(),
      ),
    );
  }

  Widget _buildEmptyImageUploadPrompt() {
    return InkWell(
      onTap: _pickImages,
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
            itemCount: images.length,
            itemBuilder: (context, index) =>
                _buildImageTile(images[index], index),
          ),
        ),
        _buildAddMoreButton(),
      ],
    );
  }

  Widget _buildImageTile(File image, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(image),
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
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Main',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _pickImages,
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

  void _pickImages() async {
    final ImagePicker picker = ImagePicker();
    // Check if already at max images
    if (images.length >= 4) {
      showCustomSnackbar(
        context,
        'Maximum 4 images allowed',
        isError: true,
      );
      return;
    }
    final List<XFile> pickedFiles = await picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  void _removeImage(File image) {
    setState(() {
      images.remove(image);
    });
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
            onChanged: (_) {
              _formKey.currentState?.validate();
            },
            prefixIcon: const Icon(Icons.shopping_bag_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
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
                  onChanged: (_) {
                    _formKey.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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
                          _formKey.currentState?.validate();
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

          // Variations Toggle Switch
          SwitchListTile(
            title: Text(
              'Enable Variations',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Add different portion sizes and prices',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            value: hasVariations,
            onChanged: (bool value) {
              setState(() {
                hasVariations = value;
                if (!value) {
                  // Clear variations when disabled
                  _clearVariations();
                }
              });
            },
            activeColor: Colors.black87,
          ),

          const SizedBox(height: 20),

          // Show variations section only if enabled
          if (hasVariations) _buildVariationsSection(),

          const SizedBox(height: 20),

          // Description Field
          CustomTextfield(
            labelText: 'Description',
            hintText: 'Describe the product',
            isPassword: false,
            controller: _description,
            maxLines: 5,
            onChanged: (_) {
              _formKey.currentState?.validate();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _clearVariations() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    _quantityControllers.clear();
    _priceControllers.clear();
    _selectedPortionTypes.clear();
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
            ],
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
      ),
    );
  }

  // Add this method to create a new variation row
  void _addVariation() {
    setState(() {
      _quantityControllers.add(TextEditingController());
      _priceControllers.add(TextEditingController());
      _selectedPortionTypes.add(PortionType.pieces); // default to pieces
    });
  }

  void _submitItem() async {
    if (_formKey.currentState!.validate()) {
      if (hasVariations && _quantityControllers.isEmpty) {
        showCustomSnackbar(context, 'Please add at least one variation',
            isError: true);
        return;
      }
      OfferModel? offer;
      if (hasOffer) {
        // Validation is missing for required offer fields
        if (offerDiscountValue.text.isEmpty ||
            offerDescription.text.isEmpty ||
            offerStartDate == null ||
            offerEndDate == null) {
          showCustomSnackbar(context, 'Please fill all offer details',
              isError: true);
          return;
        }

        offer = OfferModel(
          isEnabled: true,
          discountType: selectedDiscountType,
          discountValue: double.parse(offerDiscountValue.text),
          startDate: offerStartDate!,
          endDate: offerEndDate!,
          description: offerDescription.text,
        );
      }
      setState(() {
        loading = true;
      });

      try {
        // Create variations list only if enabled
        List<VariationModel> itemVariations = [];
        if (hasVariations) {
          for (int i = 0; i < _quantityControllers.length; i++) {
            itemVariations.add(VariationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  i.toString(),
              quantity: int.parse(_quantityControllers[i].text),
              portionType: _selectedPortionTypes[i],
              price: double.parse(_priceControllers[i].text),
            ));
          }
        }

        // Dispatch item event with or without variations
        context.read<ItemBloc>().add(AddItemEvent(
              ItemModel(
                id: '',
                categoryId: selectedCategory!,
                name: _itemName.text.toUpperCase(),
                description: _description.text,
                variations: hasVariations ? itemVariations : [],
                price: double.parse(_amount.text),
                imageUrls: images.map((file) => file.path).toList(),
                offer: offer,
              ),
            ));
      } catch (e) {
        setState(() {
          loading = false;
        });
        showCustomSnackbar(context, 'Error adding item: ${e.toString()}',
            isError: true);
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
              });
            },
            activeColor: Colors.black87,
          ),

          if (hasOffer) ...[
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
                        initialDate: DateTime.now(),
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
                        initialDate: offerStartDate ?? DateTime.now(),
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

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
