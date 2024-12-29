import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool? autoFocus;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final bool? readOnly;
  final String? prefixText;
  final Icon? prefixIcon;
  final int? maxLines;
  final String? initialValue;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.keyboardType,
    required this.isPassword,
    this.prefixText,
    this.autoFocus,
    this.validator,
    this.onChanged,
    this.decoration,
    this.readOnly,
    this.prefixIcon,
    this.maxLines,
    this.initialValue
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscured : false,
      keyboardType: widget.isPassword && !_isObscured
          ? TextInputType.number
          : widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      initialValue: widget.initialValue,
      autofocus: widget.autoFocus ?? false,
      cursorColor: Colors.black,
      readOnly: widget.readOnly ?? false,
      maxLines: widget.isPassword ? 1 : widget.maxLines,  // Fix: set maxLines to 1 if password field
      decoration: InputDecoration(
        prefixText: widget.prefixText,
        prefixIcon: widget.prefixIcon,
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
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
    );
  }
}
