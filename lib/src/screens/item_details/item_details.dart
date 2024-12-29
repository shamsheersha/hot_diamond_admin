import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hot_diamond_admin/src/screens/add_items/edit_item/edit_item_screen.dart';
import 'package:hot_diamond_admin/utils/style/custom_text_styles.dart';
import 'package:hot_diamond_admin/widgets/show_custom_alert_dialog.dart'; 
import 'package:hot_diamond_admin/src/model/variation_model/variation_model.dart';

class ItemDetails extends StatelessWidget {
  final String itemId;

  const ItemDetails({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Details',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            color: Colors.grey[100],
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                onTap: () {
                  final state = context.read<ItemBloc>().state;
                  if (state is ItemLoaded) {
                    final item =
                        state.items.firstWhere((item) => item.id == itemId);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditItemScreen(item: item)));
                  }
                },
                value: 'edit',
                child: const Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomAlertDialog(
                      title: 'Delete Item',
                      content: 'Are you sure you want to delete this Item',
                      primaryButtonText: 'Delete',
                      primaryButtonColor: Colors.red,
                      secondaryButtonText: 'Cancel',
                      onSecondaryButtonPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.white,
                      onPrimaryButtonPressed: () {
                        context.read<ItemBloc>().add(DeleteItemEvent(itemId));
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          } else if (state is ItemError) {
            return Center(child: Text(state.message));
          } else if (state is ItemLoaded) {
            final item = state.items.firstWhere((item) => item.id == itemId);
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CarouselSlider.builder(
                      itemCount: item.imageUrls.length,
                      itemBuilder: (context, index, realIndex) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imageUrls[index],
                              fit: BoxFit.fill,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // If image is loaded, show it
                                }
                                return Center(
                                    child: Image.asset(
                                  'assets/—Pngtree—gray network placeholder_6398266.png',
                                  fit: BoxFit.fill,
                                ) // Loading indicator
                                    );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Use a local asset image if the network image fails to load
                                return Image.asset(
                                  'assets/—Pngtree—gray network placeholder_6398266.png', // Path to your asset image
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        viewportFraction: 1.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name, style: CustomTextStyles.headline2),
                        Text('Price: ₹${item.price}',
                            style: CustomTextStyles.bodyText1),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.grey[250],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 0.5)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: CustomTextStyles.bodyText1,
                            ),
                            Text(item.description,
                                style: CustomTextStyles.bodyText2),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildVariationsSection(item.variations),
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildVariationsSection(List<VariationModel> variations) {
    if (variations.isEmpty) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Variations',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...variations.map((variation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${variation.quantity} ${variation.portionType.name}',
                    style: CustomTextStyles.bodyText1,
                  ),
                  Text(
                    '₹${variation.price}',
                    style: CustomTextStyles.bodyText1,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getCategoryName(BuildContext context, String categoryId) {
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoaded) {
      final category = state.categories.firstWhere(
        (category) => category.id == categoryId,
        orElse: () => CategoryModel(id: categoryId, name: 'Unknown Category'),
      );
      return category.name;
    }
    return categoryId; // Fallback to showing ID if categories aren't loaded
  }
}
