import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';
import 'package:hot_diamond_admin/utils/style/custom_text_styles.dart';



class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // List to store categories
  List<String> categories = [];

  // Controller for TextField input
  TextEditingController _controller = TextEditingController();

  // Add a new category (Create)
  void _addCategory(String category) {
    if (category.isEmpty) return;

    setState(() {
      categories.add(category);
    });
    _controller.clear();
  }

  // Edit an existing category (Update)
  void _editCategory(int index, String updatedCategory) {
    if (updatedCategory.isEmpty) return;

    setState(() {
      categories[index] = updatedCategory;
    });
  }

  // Delete a category (Delete)
  void _deleteCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
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
              child: Text('Cancel',style: CustomTextStyles.bodyText1,),
            ),
            ElevatedButton(
              onPressed: () {
                onSubmit(_controller.text);
                Navigator.pop(context); // Close dialog after saving
              },
              child: Text('Save',style: CustomTextStyles.buttonText,),
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
        title: Text('Category Management'),
        elevation: 0,
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
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
              padding: EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      categories[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_rounded,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _showCategoryDialog(
                              initialText: categories[index],
                              onSubmit: (updatedCategory) =>
                                  _editCategory(index, updatedCategory),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteCategory(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          _showCategoryDialog(
            onSubmit: (newCategory) => _addCategory(newCategory),
          );
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
