import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_diamond_admin/src/enum/discount_type.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';

class OfferSection extends StatelessWidget {
  final bool hasOffer;
  final TextEditingController offerDiscountValue;
  final TextEditingController offerDescription;
  final DateTime? offerStartDate;
  final DateTime? offerEndDate;
  final DiscountType selectedDiscountType;
  final bool isOfferActive;
  final ValueChanged<bool> onToggleOffer;
  final ValueChanged<bool> onToggleOfferStatus;
  final ValueChanged<DiscountType?> onDiscountTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const OfferSection({super.key,
    required this.hasOffer,
    required this.offerDiscountValue,
    required this.offerDescription,
    required this.offerStartDate,
    required this.offerEndDate,
    required this.selectedDiscountType,
    required this.isOfferActive,
    required this.onToggleOffer,
    required this.onToggleOfferStatus,
    required this.onDiscountTypeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offer Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildEnableOfferSwitch(),
          if (hasOffer) ...[
            _buildOfferStatusSwitch(),
            const SizedBox(height: 20),
            _buildDiscountTypeDropdown(),
            const SizedBox(height: 20),
            _buildDiscountValueField(),
            const SizedBox(height: 20),
            _buildDateRangeFields(context),
            const SizedBox(height: 20),
            _buildOfferDescriptionField(),
          ],
        ],
      ),
    );
  }

  Widget _buildEnableOfferSwitch() {
    return SwitchListTile(
      title: Text(
        'Enable Offer',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: hasOffer,
      onChanged: onToggleOffer,
      activeColor: Colors.black87,
    );
  }

  Widget _buildOfferStatusSwitch() {
    return SwitchListTile(
      title: Text(
        'Offer Status',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        isOfferActive ? 'Active' : 'Inactive',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: isOfferActive ? Colors.green : Colors.red,
        ),
      ),
      value: isOfferActive,
      onChanged: onToggleOfferStatus,
      activeColor: Colors.black87,
    );
  }

  Widget _buildDiscountTypeDropdown() {
    return DropdownButtonFormField<DiscountType>(
      value: selectedDiscountType,
      decoration: InputDecoration(
        labelText: 'Discount Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: DiscountType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name.toUpperCase()),
        );
      }).toList(),
      onChanged: onDiscountTypeChanged,
    );
  }

  Widget _buildDiscountValueField() {
    return CustomTextfield(
      controller: offerDiscountValue,
      labelText: selectedDiscountType == DiscountType.percentage
          ? 'Discount (%)'
          : 'Discount Amount',
      hintText: selectedDiscountType == DiscountType.percentage
          ? 'Enter percentage'
          : 'Enter amount',
      keyboardType: TextInputType.number,
      isPassword: false,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final number = double.tryParse(value);
        if (number == null) return 'Enter valid number';
        if (selectedDiscountType == DiscountType.percentage && number > 100) {
          return 'Percentage cannot exceed 100';
        }
        return null;
      },
    );
  }

  Widget _buildDateRangeFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            context: context,
            label: 'Start Date',
            initialDate: offerStartDate,
            onDateSelected: onStartDateChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            context: context,
            label: 'End Date',
            initialDate: offerEndDate,
            onDateSelected: onEndDateChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: initialDate?.toString().split(' ')[0] ?? '',
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      validator: (value) => initialDate == null ? 'Required' : null,
    );
  }

  Widget _buildOfferDescriptionField() {
    return CustomTextfield(
      controller: offerDescription,
      labelText: 'Offer Description',
      hintText: 'Enter offer details',
      maxLines: 3,
      isPassword: false,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        return null;
      },
    );
  }
}
