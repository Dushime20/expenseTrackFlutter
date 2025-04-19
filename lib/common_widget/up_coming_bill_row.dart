import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../common/color_extension.dart';

class UpcomingBillRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;

  const UpcomingBillRow({super.key, required this.sObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final DateFormat monthFormat = DateFormat('MMM');
    final DateFormat dayFormat = DateFormat('dd');

    // Parse the date string to DateTime if needed
    final date = sObj["date"] is String
        ? DateTime.parse(sObj["date"])
        : sObj["date"] ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          height: 64,
          decoration: BoxDecoration(
            color: TColor.back,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthFormat.format(date),
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dayFormat.format(date),
                      style: TextStyle(
                        color: TColor.gray80,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sObj["name"] ?? "",
                  style: TextStyle(
                    color: TColor.gray60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${sObj["price"]} Frw',
                style: TextStyle(
                  color: TColor.gray80,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
