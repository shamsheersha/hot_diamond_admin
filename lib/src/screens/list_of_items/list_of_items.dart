import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/screens/item_details/item_details.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/category_list.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/edit_item_dialog.dart';
import 'package:hot_diamond_admin/src/services/firebase_category_service/firebase_category_service.dart';
import 'package:hot_diamond_admin/utils/style/custom_text_styles.dart';
import 'package:hot_diamond_admin/widgets/show_custom_alert_dialog.dart';
import 'package:hot_diamond_admin/widgets/show_custom_snackbar.dart';

class ListOfItems extends StatefulWidget {
  const ListOfItems({super.key});

  @override
  State<ListOfItems> createState() => _ListOfItemsState();
}

class _ListOfItemsState extends State<ListOfItems> {
  String selectedCategoryId = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemUpdatedSuccess) {
          showCustomSnackbar(
            context,
            'Item updated successfully',
            isError: false,
          );
        } else if (state is ItemError) {
          showCustomSnackbar(
            context,
            state.message,
            isError: true,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Text(
            'My Products',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Categories',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ItemBloc, ItemState>(
                builder: (context, state) {
                  if (state is ItemLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  } else if (state is ItemError) {
                    return Center(
                      child: Text('Error : ${state.message}'),
                    );
                  } else if (state is ItemLoaded) {
                    return Column(
                      children: [
                        CategoryList(
                          selectedCategoryId: selectedCategoryId,
                          onCategorySelected: (categoryId) {
                            setState(() {
                              selectedCategoryId = categoryId;
                            });
                          },
                        ),
                        Expanded(
                          child: selectedCategoryId.isEmpty
                              ? _buildCategorizedItems(state.items)
                              : _buildFilteredItems(state.items),
                        ),
                      ],
                    );
                  }
                  return const Center(child: Text('No items available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizedItems(List<ItemModel> items) {
    // Group items by category
    final groupedItems = <String, List<ItemModel>>{};
    for (var item in items) {
      if (!groupedItems.containsKey(item.categoryId)) {
        groupedItems[item.categoryId] = [];
      }
      groupedItems[item.categoryId]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final categoryId = groupedItems.keys.elementAt(index);
        final categoryItems = groupedItems[categoryId]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                FirebaseCategoryService.getCategoryName(categoryId),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categoryItems.length,
              itemBuilder: (context, index) =>
                  _buildItemCard(categoryItems[index]),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildFilteredItems(List<ItemModel> items) {
    final filteredItems =
        items.where((item) => item.categoryId == selectedCategoryId).toList();
        if(filteredItems.isEmpty){
          return const Center(
            child: Text('No items available',style: CustomTextStyles.profilePhone,),
          );
        }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) => _buildItemCard(filteredItems[index]),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ItemDetails(
                      itemId: item.id,
                    ))),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(0, 2),
                        color: Colors.grey)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        item.imageUrl, 
                        width: double.infinity,
                        fit: BoxFit.cover,
                        
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child; 
                          }
                          return Image.asset(
                            'assets/—Pngtree—gray network placeholder_6398266.png', 
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/—Pngtree—gray network placeholder_6398266.png', 
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: _buildItemMenu(item),
          ),
        ],
      ),
    );
  }

  Widget _buildItemMenu(ItemModel item) {
    return Container(
      width: 32,
      height: 35,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        color: Colors.grey[100],
        icon: const Icon(
          Icons.more_vert,
          color: Colors.black,
        ),
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'edit',
            onTap: () => showDialog(
              context: context,
              builder: (context) => EditItemDialog(item: item),
            ),
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
                  builder: (context) {
                    return CustomAlertDialog(
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
                        context.read<ItemBloc>().add(DeleteItemEvent(item.id));
                        Navigator.pop(context);
                      },
                    );
                  });
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
    );
  }
}
