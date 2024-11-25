import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';
import 'package:hot_diamond_admin/utils/style/custom_text_styles.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  AddItemScreenState createState() => AddItemScreenState();
}

class AddItemScreenState extends State<AddItemScreen> {
  bool isDeliveryAvailable = true;
  bool isPickupAvailable = true;
  final TextEditingController _itemName = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> categories = ['Broast', 'Sandwitch', 'Burger', 'Shawarma'];
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(1, 3)),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ITEM NAME',
                        style: CustomTextStyles.bodyText1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // Item Name TextField
                      CustomTextfield(
                        controller: _itemName,
                        hintText: 'Add Item',
                        labelText: 'Item Name',
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Container(
                width: 170,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(1, 3))
                    ],
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ADD PHOTO',
                        style: CustomTextStyles.bodyText1,
                      ),
                      const SizedBox(height: 10),

                      // Image Upload Section
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload, size: 50),
                              TextButton(
                                onPressed: () {
                                  // Add image picker logic
                                },
                                child: const Text(
                                  'Upload Image',
                                  style: CustomTextStyles.bodyText1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text('PRICE'),
              SizedBox(
                height: 10,
              ),
              // Price and Delivery Options Row
              Row(
                children: [
                  // Price TextField
                  Expanded(
                    flex: 2,
                    child: CustomTextfield(
                      controller: _amount,
                      isPassword: false,
                      labelText: 'Price',
                      hintText: '₹ 0.00',
                      prefixText: '₹ ',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Delivery Checkbox
                  Expanded(
                    flex: 2,
                    child: CheckboxListTile(
                      title: const Text(
                        'Delivery',
                        style: CustomTextStyles.bodyText2,
                      ),
                      value: isDeliveryAvailable,
                      onChanged: (value) {
                        setState(() {
                          isDeliveryAvailable = value!;
                        });
                      },
                      visualDensity: const VisualDensity(
                          horizontal: -4, vertical: -4), // Compact height
                      contentPadding:
                          EdgeInsets.zero, // Align with TextFormField
                    ),
                  ),

                  // Pickup Checkbox
                  Expanded(
                    flex: 2,
                    child: CheckboxListTile(
                      title: const Text('Pickup'),
                      value: isPickupAvailable,
                      onChanged: (value) {
                        setState(() {
                          isPickupAvailable = value!;
                        });
                      },
                      visualDensity: const VisualDensity(
                          horizontal: -4, vertical: -4), // Compact height
                      contentPadding:
                          EdgeInsets.zero, // Align with TextFormField
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'CATEGORY',
                style: CustomTextStyles.bodyText1,
              ),
              const SizedBox(
                height: 10,
              ),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Category',
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),

              SizedBox(
                height: 20,
              ),
              // Description TextField
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Add save logic here
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Add Item',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
