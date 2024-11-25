import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/utils/colors/custom_colors.dart';
import 'package:hot_diamond_admin/utils/style/custom_text_styles.dart';


class CustomButtonStyles {
  // Elevated Button Style
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: CustomColors.buttonTextColor, backgroundColor: CustomColors.accentColor, // Button text color
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16), // Padding around the button
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ),
    textStyle: CustomTextStyles.buttonText, // Button text style
  );

  // Transparent Button Style (for icon buttons or buttons with no background)
  static ButtonStyle transparentButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: CustomColors.redButtonTextColor, backgroundColor: Colors.transparent,shadowColor: Colors.transparent, // Text color
  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: -1),  // Reduce vertical padding
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(12), // Rounded corners
    // ),
    // side: const BorderSide(color: CustomColors.primaryColor), // Border around the button
    textStyle: CustomTextStyles.buttonText, // Button text style
  );

  // Outlined Button Style (with border but transparent background)
  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: CustomColors.accentColor, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding around the button
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ),
    side: const BorderSide(color: CustomColors.accentColor), // Border color
    textStyle: CustomTextStyles.buttonText, // Button text style
  );

  // Icon Button Style
  static ButtonStyle iconButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: CustomColors.buttonTextColor, backgroundColor: CustomColors.primaryColor, // Icon color
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding around the button
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ),
  );
}
