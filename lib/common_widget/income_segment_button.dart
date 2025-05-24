import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class IncomeSegmentButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;

  const IncomeSegmentButton({
    super.key,
    required this.title,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      hoverColor: TColor.line,
      child: Container(
        alignment: Alignment.center,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
