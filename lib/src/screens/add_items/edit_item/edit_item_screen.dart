import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/enum/discount_type.dart';
import 'package:hot_diamond_admin/src/enum/portion_type.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/model/offer_model/offer_model.dart';
import 'package:hot_diamond_admin/src/model/variation_model/variation_model.dart';
import 'package:hot_diamond_admin/src/screens/add_items/edit_item/widgets/image_upload_section.dart';
import 'package:hot_diamond_admin/src/screens/add_items/edit_item/widgets/offer_section.dart';
import 'package:hot_diamond_admin/src/screens/add_items/edit_item/widgets/product_details_card.dart';
import 'package:hot_diamond_admin/src/screens/add_items/edit_item/widgets/variation_section.dart';

import 'package:hot_diamond_admin/widgets/show_custom_snackbar.dart';

class EditItemScreen extends StatefulWidget {
  final ItemModel item;

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
  List<dynamic> selectedImages = [];
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
    _prefillData();
  }

  void _prefillData() {
    _itemName.text = widget.item.name;
    _amount.text = widget.item.price.toString();
    _description.text = widget.item.description;
    selectedCategory = widget.item.categoryId;
    selectedImages = widget.item.imageUrls;
    hasVariations = widget.item.variations.isNotEmpty;

    if (hasVariations) {
      for (var variation in widget.item.variations) {
        _quantityControllers.add(TextEditingController(text: variation.quantity.toString()));
        _priceControllers.add(TextEditingController(text: variation.price.toString()));
        _selectedPortionTypes.add(variation.portionType);
      }
    }

    if (widget.item.offer != null) {
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
          showCustomSnackbar(context, 'Item updated successfully', isError: false);
          Navigator.pop(context);
        } else if (state is ItemError) {
          setState(() {
            loading = false;
          });
          showCustomSnackbar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildForm(),
            if (loading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageUploadSection(
              selectedImages: selectedImages,
              onPickImage: _pickImage,
              onRemoveImage: _removeImage,
            ),
            const SizedBox(height: 24),
            ProductDetailsCard(
              itemNameController: _itemName,
              amountController: _amount,
              descriptionController: _description,
              selectedCategory: selectedCategory,
              onCategoryChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),
            OfferSection(
              hasOffer: hasOffer,
              offerDiscountValue: offerDiscountValue,
              offerDescription: offerDescription,
              offerStartDate: offerStartDate,
              offerEndDate: offerEndDate,
              selectedDiscountType: selectedDiscountType,
              isOfferActive: isOfferActive,
              onToggleOffer: (value) {
                setState(() {
                  hasOffer = value;
                  if (!value) {
                    _clearOfferData();
                  }
                });
              },
              onToggleOfferStatus: (value) {
                setState(() {
                  isOfferActive = value;
                });
              },
              onDiscountTypeChanged: (value) {
                setState(() {
                  selectedDiscountType = value!;
                });
              },
              onStartDateChanged: (value) {
                setState(() {
                  offerStartDate = value;
                });
              },
              onEndDateChanged: (value) {
                setState(() {
                  offerEndDate = value;
                });
              },
            ),
            const SizedBox(height: 24),
            VariationsSection(
              hasVariations: hasVariations,
              quantityControllers: _quantityControllers,
              priceControllers: _priceControllers,
              selectedPortionTypes: _selectedPortionTypes,
              onToggleVariations: (value) {
                setState(() {
                  hasVariations = value;
                  if (!value) {
                    _clearVariationData();
                  }
                });
              },
              onAddVariation: _addVariation,
              onRemoveVariation: _removeVariation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _clearOfferData() {
    offerDiscountValue.clear();
    offerDescription.clear();
    offerStartDate = null;
    offerEndDate = null;
    selectedDiscountType = DiscountType.percentage;
    isOfferActive = false;
  }

  void _clearVariationData() {
    _quantityControllers.clear();
    _priceControllers.clear();
    _selectedPortionTypes.clear();
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _pickImage() async {
    try {
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

        List<String> imageUrls = selectedImages.whereType<String>().toList();
        List<String> newImagePaths =
            selectedImages.whereType<File>().map((file) => file.path).toList();

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
