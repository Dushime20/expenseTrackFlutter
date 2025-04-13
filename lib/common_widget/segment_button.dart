import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class SegmentButton extends StatelessWidget {

  final String title;
  final VoidCallback onPress;
  final bool isActive;

  const SegmentButton({super.key, required this.title, required this.onPress, required this.isActive});


  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onPress,
      child: Container(
        decoration: isActive? BoxDecoration(
          
          border: Border.all(color: TColor.line),
          borderRadius: BorderRadius.circular(12),):null,
        alignment: Alignment.center,
        child: Text(title,style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),),

      ),
    );
  }
}
