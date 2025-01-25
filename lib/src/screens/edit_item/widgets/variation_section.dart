import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/enum/portion_type.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';

class VariationsSection extends StatelessWidget {
  final bool hasVariations;
  final List<TextEditingController> quantityControllers;
  final List<TextEditingController> priceControllers;
  final List<PortionType> selectedPortionTypes;
  final ValueChanged<bool> onToggleVariations;
  final VoidCallback onAddVariation;
  final ValueChanged<int> onRemoveVariation;

  const VariationsSection({
    required this.hasVariations,
    required this.quantityControllers,
    required this.priceControllers,
    required this.selectedPortionTypes,
    required this.onToggleVariations,
    required this.onAddVariation,
    required this.onRemoveVariation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item Variations',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: hasVariations,
                onChanged: onToggleVariations,
                activeColor: Colors.black87,
              ),
            ],
          ),
          if (hasVariations) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddVariation,
              icon: const Icon(Icons.add),
              label: const Text('Add Variation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (quantityControllers.isEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Add variations for different serving sizes',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...quantityControllers.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuantityField(index),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPortionTypeDropdown(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceField(index),
                        ),
                        IconButton(
                          onPressed: () => onRemoveVariation(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.grey[800],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityField(int index) {
    return CustomTextfield(
      controller: quantityControllers[index],
      hintText: 'e.g., 4',
      labelText: 'Quantity',
      isPassword: false,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (int.tryParse(value) == null) {
          return 'Enter number';
        }
        return null;
      },
    );
  }

  Widget _buildPortionTypeDropdown(int index) {
    return DropdownButtonFormField<PortionType>(
      value: selectedPortionTypes[index],
      decoration: InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelStyle: const TextStyle(color: Colors.black),
      ),
      items: PortionType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name),
        );
      }).toList(),
      onChanged: (PortionType? newValue) {
        if (newValue != null) {
          selectedPortionTypes[index] = newValue;
        }
      },
    );
  }

  Widget _buildPriceField(int index) {
    return CustomTextfield(
      controller: priceControllers[index],
      labelText: 'Price',
      hintText: '₹ 0.00',
      keyboardType: TextInputType.number,
      isPassword: false,
      prefixIcon: const Icon(Icons.currency_rupee),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Enter valid price';
        }
        return null;
      },
    );
  }
}
