import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/enum/discount_type.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hot_diamond_admin/src/model/offer_model/offer_model.dart';
import 'package:hot_diamond_admin/src/screens/add_items/edit_item/edit_item_screen.dart';
import 'package:hot_diamond_admin/utils/style/custom_text_styles.dart';
import 'package:hot_diamond_admin/widgets/show_custom_alert_dialog.dart'; 
import 'package:hot_diamond_admin/src/model/variation_model/variation_model.dart';

class ItemDetails extends StatelessWidget {
  final String itemId;

  const ItemDetails({super.key, required this.itemId});

  bool isOfferValid(OfferModel? offer){
    if(offer == null || !offer.isEnabled){
      return false;
    }
    final now = DateTime.now();
    return now.isAfter(offer.startDate) && now.isBefore(offer.endDate);
  }

  double _calculateDiscountedPrice(double originalPrice, OfferModel offer){
    if(offer.discountType == DiscountType.percentage){
      return originalPrice - (originalPrice * (offer.discountValue / 100));
    }else{
      return originalPrice - offer.discountValue;
    }
  }

  List<VariationModel> _applyDiscountToVariations(List<VariationModel> variations, OfferModel offer) {
    return variations.map((variation) {
      final discountedPrice = _calculateDiscountedPrice(variation.price, offer);
      return VariationModel(
        id: variation.id,
        quantity: variation.quantity,
        portionType: variation.portionType,
        price: discountedPrice,
      );
    }).toList();
  }

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
            final hasValidOffer = isOfferValid(item.offer);
            final discountedPrice = hasValidOffer && item.variations.isEmpty
                ? _calculateDiscountedPrice(item.price, item.offer!)
                : null;
            final discountedVariations = hasValidOffer && item.variations.isNotEmpty
                ? _applyDiscountToVariations(item.variations, item.offer!)
                : item.variations;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Carousel
                    Stack(
                      children: [
                        CarouselSlider.builder(
                          itemCount: item.imageUrls.length,
                          itemBuilder: (context, index, realIndex) {
                            return Container(
                              height: 300,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  item.imageUrls[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: Image.asset(
                                        'assets/—Pngtree—gray network placeholder_6398266.png',
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/—Pngtree—gray network placeholder_6398266.png',
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
                            viewportFraction: 0.9,
                          ),
                        ),
                        if (hasValidOffer)
                          Positioned(
                            top: 04,
                            right: 22,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.offer!.discountType == DiscountType.percentage
                                    ? '${item.offer!.discountValue.toStringAsFixed(0)}% OFF'
                                    : '₹${item.offer!.discountValue} OFF',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Title and Category
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCategoryName(context, item.categoryId),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasValidOffer && item.variations.isEmpty) ...[
                                Text(
                                  '₹${discountedPrice!.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${item.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  '₹${item.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.description,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Variations Section
                    _buildVariationsSection(discountedVariations, hasValidOffer, item.offer),

                    const SizedBox(height: 20),

                    // Offer Details (if active)
                    if (hasValidOffer) _buildOfferDetails(item.offer!),
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

  Widget _buildOfferDetails(OfferModel offer) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Offer',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            offer.description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Valid till ${offer.endDate.toString().split(' ')[0]}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationsSection(List<VariationModel> variations, bool hasValidOffer, OfferModel? offer) {
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
            final originalPrice = variation.price;
            final discountedPrice = hasValidOffer ? _calculateDiscountedPrice(originalPrice, offer!) : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${variation.quantity} ${variation.portionType.name}',
                    style: CustomTextStyles.bodyText1,
                  ),
                  Row(
                    children: [
                      if (hasValidOffer) ...[
                        Text(
                          '₹${discountedPrice!.toStringAsFixed(2)}',
                          style: CustomTextStyles.bodyText1,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${originalPrice.toStringAsFixed(2)}',
                          style: CustomTextStyles.bodyText1.copyWith(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '₹${originalPrice.toStringAsFixed(2)}',
                          style: CustomTextStyles.bodyText1,
                        ),
                      ],
                    ],
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