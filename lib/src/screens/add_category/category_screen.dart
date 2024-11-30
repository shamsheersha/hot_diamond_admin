import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_event.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';
import 'package:hot_diamond_admin/utils/style/custom_text_styles.dart';
import 'package:hot_diamond_admin/src/model/category_model/category_model.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart'; // Import your CategoryBloc

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  // Controller for TextField input
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch categories when the screen loads
    context.read<CategoryBloc>().add(FetchCategories());
  }

  // Show dialog for adding or editing a category
  void _showCategoryDialog({
    String? initialText,
    required Function(String) onSubmit,
  }) {
    _controller.text = initialText ?? ''; // Set initial text for editing
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialText == null ? 'Add Category' : 'Edit Category'),
          content: CustomTextfield(
            controller: _controller,
            hintText: 'Add Category Name',
            isPassword: false,
            labelText: 'Category',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel',style: CustomTextStyles.bodyText1),
            ),
            ElevatedButton(
              onPressed: () {
                onSubmit(_controller.text);
                Navigator.pop(context); // Close dialog after saving
              },
              child: const Text('Save',style: CustomTextStyles.buttonText),
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
        elevation: 0,
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black,));
          }
          if (state is CategoryLoaded) {
            final categories = state.categories;
            return categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
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
                  )
                : ListView.builder(
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: Colors.red,
                            ),
                          ),
                          title: Text(
                            categories[index].name, // Use name property from CategoryModel
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showCategoryDialog(
                                    initialText: categories[index].name,
                                    onSubmit: (updatedCategory) {
                                      final updatedCategoryModel = CategoryModel(
                                        id: categories[index].id,
                                        name: updatedCategory,
                                      );
                                      context.read<CategoryBloc>().add(UpdateCategoryEvent(updatedCategoryModel));
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  context.read<CategoryBloc>().add(DeleteCategoryEvent(categories[index].id));
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          _showCategoryDialog(
            onSubmit: (newCategory) {
              final newCategoryModel = CategoryModel(
                id: DateTime.now().toString(), // Generate a unique ID for new category
                name: newCategory,
              );
              context.read<CategoryBloc>().add(AddCategoryEvent(newCategoryModel));
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
