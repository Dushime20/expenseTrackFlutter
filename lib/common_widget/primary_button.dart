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
  @override
Widget build(BuildContext context) {
  return SizedBox(
    width: double.infinity, 
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: TColor.line, // White background
        foregroundColor: Colors.black, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Border radius updated here
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shadowColor: TColor.gray.withOpacity(0.5),
        elevation: 5,
      ),
      onPressed: onPress,
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    ),
  );
}
}