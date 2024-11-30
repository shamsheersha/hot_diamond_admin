import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_state.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/category_list.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/category_scroll_controller.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/item_list.dart';
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
              child: BlocBuilder<ItemBloc, ItemState>(builder: (context, state) {
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
                  _scrollController = CategoryScrollController(items: state.items);
                  return Column(
                    children: [
                      CategoryList(
                        selectedCategoryId: _scrollController!.selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          _scrollController!.setSelectedCategory(categoryId);
                        },
                      ),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: _scrollController!,
                          builder: (context, child) {
                            return ItemList(
                              items: state.items,
                              scrollController: _scrollController!.scrollController,
                            );
                          },
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
