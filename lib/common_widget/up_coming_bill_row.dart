import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class UpcomingBillRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;

  const UpcomingBillRow(
      {super.key, required this.sObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        // borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
       child: Container(
        padding: const EdgeInsets.only(left: 10,right: 10),
        height: 64,
          margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: TColor.back,
          
          borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
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
                  children: [
                    Text(
                      "Jun",
                      style: TextStyle(
                          color: TColor.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                    ),

                    Text(
                      "25",
                      style: TextStyle(
                          color: TColor.gray80,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  sObj["name"],
                  style: TextStyle(
                      color: TColor.gray60,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "${sObj["price"]}frw",
                style: TextStyle(
                    color: TColor.gray80,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ),
    );
  }
}
