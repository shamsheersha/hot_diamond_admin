import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/category_list.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/category_scroll_controller.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/edit_item_dialog.dart';
import 'package:hot_diamond_admin/src/services/firebase_category_service/firebase_category_service.dart';
import 'package:hot_diamond_admin/widgets/show_custom_snackbar.dart';

class ListOfItems extends StatefulWidget {
  const ListOfItems({super.key});

  @override
  State<ListOfItems> createState() => _ListOfItemsState();
}

class _ListOfItemsState extends State<ListOfItems> {
  // String selectedCategoryId = '';
  CategoryScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(FetchItemsEvent());
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

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
              child:
                  BlocBuilder<ItemBloc, ItemState>(builder: (context, state) {
                if (state is ItemLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  );
                } else if (state is ItemError) {
                  return Center(
                    child: Text('Error : ${state.message}'),
                  );
                } else if (state is ItemLoaded) {
                  _scrollController?.dispose();
                  _scrollController =
                      CategoryScrollController(items: state.items);
                  return Column(
                    children: [
                      CategoryList(
                        selectedCategoryId:
                            _scrollController!.selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          _scrollController!.setSelectedCategory(categoryId);
                        },
                      ),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: _scrollController!,
                          builder: (context, _) => GridView.builder(
                            controller: _scrollController!.scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(12)),
                                            child: Image.network(
                                              item.imageUrl,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                              const SizedBox(height: 4),
                                              Text(
                                                FirebaseCategoryService
                                                    .getCategoryName(
                                                        item.categoryId),
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
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
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.black,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            // Handle the edit action
                                          } else if (value == 'delete') {
                                            // Handle the delete action
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                           PopupMenuItem<String>(
                                            value: 'edit',
                                            onTap: () => showDialog(context: context,builder: (context)=> EditItemDialog(item: item)),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.edit,
                                                    ),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                           PopupMenuItem<String>(
                                            value: 'delete',
                                            onTap: () => context.read<ItemBloc>().add(DeleteItemEvent(item.id)),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.delete,
                                                   ),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: Text('No items available'));
              }),
            ),
          ],
        ),
      ),
    );
  }
}
