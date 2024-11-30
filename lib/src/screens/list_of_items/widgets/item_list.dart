import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/services/firebase_category_service/firebase_category_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/edit_item_dialog.dart';

class ItemList extends StatelessWidget {
  final List<ItemModel> items;
  final ScrollController scrollController;

  const ItemList( {super.key, required this.items, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      controller: scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                title: Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      FirebaseCategoryService.getCategoryName(item.categoryId),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  children: [
                    PopupMenuButton(
                      color: Colors.grey[100],
                        icon: const Icon(Icons.more_vert),
                        onSelected: (String value) {
                          if (value == 'edit') {
                            _showEditDialog(context, item);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, item);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.edit_outlined,
                                  ),
                                  title: Text('Edit',style: GoogleFonts.poppins(fontSize: 14),),
                                ),
                              ),
                              PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: const Icon(Icons.delete_outline),
                                    title: Text(
                                      'delete',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ))
                            ]),
                  ],
                )
                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     IconButton(
                //       icon: const Icon(
                //         Icons.edit_outlined,
                //         color: Colors.blue,
                //       ),
                //       onPressed: () {
                //         _showEditDialog(context, item);
                //       },
                //     ),
                //     IconButton(
                //       icon: const Icon(
                //         Icons.delete_outline,
                //         color: Colors.red,
                //       ),
                //       onPressed: () {
                //         _showDeleteConfirmation(context, item);
                //       },
                //     ),
                //   ],
                // ),
                ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ItemModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete Item',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${item.name}"?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<ItemBloc>().add(DeleteItemEvent(item.id));
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, ItemModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) => EditItemDialog(item: item),
    );
  }
}
