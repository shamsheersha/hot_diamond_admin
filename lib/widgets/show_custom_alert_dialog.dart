import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final String? initialText;
  final Function(String)? onSubmit;
  final String? primaryButtonText;
  final Color? primaryButtonColor;
  final VoidCallback? onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final Color? backgroundColor;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.initialText,
    this.primaryButtonText,
    this.primaryButtonColor,
    this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.onSubmit,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: backgroundColor,
      title: Row(
        children: [
          if (icon != null)
            Icon(icon, color: primaryButtonColor ?? Colors.blue),
          if (icon != null) const SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(content, style: const TextStyle(fontSize: 16)),
      actions: [
        if (secondaryButtonText != null)
          TextButton(
            onPressed: onSecondaryButtonPressed,
            child: Text(
              secondaryButtonText!,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        if (primaryButtonText != null)
          ElevatedButton(
            onPressed: onPrimaryButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryButtonColor ??
                  Theme.of(context).primaryColor, // Correct color key
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Optional: round the button's edges
              ),
            ),
            child: Text(
              primaryButtonText!,
              style: const TextStyle(
                  color: Colors.white), // Text color for the button
            ),
          ),
      ],
    );
  }
}
