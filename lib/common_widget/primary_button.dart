import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPress;
  final Color color;

  const PrimaryButton({super.key, required this.title, this.fontSize=14,  this.fontWeight = FontWeight.w600, required this.onPress, required this.color});




  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: double.infinity, // Full width button
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.gray20, // White background
          foregroundColor: Colors.black, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(vertical: 16), // Button height
          shadowColor: TColor.gray.withOpacity(0.5), // Box shadow effect
          elevation: 5, // Add elevation for a better look
        ),
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color, // Change to black or blue as needed
          ),
        ),
      ),
    );

  }
}
