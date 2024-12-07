import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_event.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/widgets/show_custom_alert_dialog.dart';
import 'package:hot_diamond_admin/widgets/show_custom_snackbar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch categories when the screen initializes
    context.read<CategoryBloc>().add(FetchCategories());
  }

  void _showCategoryDialog({
    String? initialText,
    required Function(String) onSubmit,
  }) {
    _controller.text = initialText ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialText == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter Category Name',
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isEmpty) {
                  showCustomSnackbar(context, 'Category name cannot be empty');
                  return;
                }
                onSubmit(_controller.text.trim());
                Navigator.pop(context); // Close dialog after submission
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        elevation: 1,
        backgroundColor: Colors.grey[50],
      ),
      body: Container(
        color: Colors.grey[100], // White background
        child: BlocConsumer<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryError) {
              showCustomSnackbar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (state is CategoryLoaded) {
              final categories = state.categories;

              // Display empty state if no categories
              if (categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No categories added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Display category list
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 0.5,
                          blurRadius: 8,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        child: const Icon(Icons.category, color: Colors.red),
                      ),
                      title: Text(
                        categories[index].name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: () {
                              _showCategoryDialog(
                                initialText: categories[index].name,
                                onSubmit: (updatedCategoryName) {
                                  final updatedCategory = CategoryModel(
                                    id: categories[index].id,
                                    name: updatedCategoryName,
                                  );
                                  context.read<CategoryBloc>().add(
                                      UpdateCategoryEvent(updatedCategory));
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return CustomAlertDialog(
                                    title: 'Delete Category',
                                    content:
                                        'Are you sure you want to delete this category?',
                                    primaryButtonText: 'Delete',
                                    primaryButtonColor: Colors.red,
                                    secondaryButtonText: 'Cancel',
                                    onSecondaryButtonPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    onPrimaryButtonPressed: () async {
                                      final categoryId =
                                          categories[index].id;
                                      final bloc =
                                          context.read<CategoryBloc>();

                                      bloc.add(DeleteCategoryEvent(categoryId));
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          _showCategoryDialog(
            onSubmit: (newCategoryName) {
              context.read<CategoryBloc>().add(AddCategoryEvent(
                    CategoryModel(id: '', name: newCategoryName),
                  ));
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
