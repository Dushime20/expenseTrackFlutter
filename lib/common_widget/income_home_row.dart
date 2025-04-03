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
    return InkWell(
      onTap: onPress,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: TColor.gray60.withOpacity(0.2),
          border: Border.all(color: TColor.border.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    color: TColor.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
                ),
              ),
              const SizedBox(width: 8),
              Flexible(  // Changed from Expanded to Flexible to prevent taking too much space
                child: Text(
                  "${incObj["price"]} RWF",
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}