import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class IncomeHomeRow extends StatelessWidget {
  final Map incObj;
  final VoidCallback onPress;

  const IncomeHomeRow({
    super.key,
    required this.onPress,
    required this.incObj
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.only(left: 10,right: 10),
        height: 64,
          margin: const EdgeInsets.only(bottom:6),
        decoration: BoxDecoration(
          color: TColor.back,
          
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Image.asset(
              incObj["icon"],
              width: 40,  // Reduced from 55 to save space
              height: 40, // Reduced from 55 to save space
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                incObj["name"],
                style: TextStyle(
                  color: TColor.gray60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
              ),
            ),
            const SizedBox(width: 100),
            Flexible( 
              child: Text(
                "${incObj["price"]} RWF",
                style: const TextStyle(
                  color: Color.fromARGB(255, 21, 4, 4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                // textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}