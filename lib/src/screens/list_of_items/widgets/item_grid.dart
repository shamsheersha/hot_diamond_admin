import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/model/item_model/item_model.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/widgets/item_list.dart';

class ItemGrid extends StatelessWidget {
  final List<ItemModel> items;

  const ItemGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No products available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemList(items: [item], scrollController: ScrollController());
      },
    );
  }
}
