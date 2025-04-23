import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/budgetController.dart';

import '../common/color_extension.dart';

class BudgetsRow extends StatelessWidget {
  final Map bObj;
  final VoidCallback onPressed;

  const BudgetsRow({super.key, required this.bObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var leftAmount = double.tryParse(bObj["left_amount"]?.toString() ?? "0") ?? 0;
    var totalBudget = double.tryParse(bObj["total_budget"]?.toString() ?? "1") ?? 1;
    var proVal = leftAmount / totalBudget;


    return GetBuilder<BudgetController>(builder: (ctrl) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(

            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: TColor.border.withOpacity(0.05),
              ),
              color: TColor.gray10,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bObj["name"] ?? "",
                          style: TextStyle(
                            color: TColor.gray80,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${bObj["amount"]} Rwf",
                          style: TextStyle(
                            color: TColor.gray60,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: TColor.gray60,
                  valueColor: AlwaysStoppedAnimation(bObj["color"]),
                  minHeight: 3,
                  value: proVal,
                ),
              ],
            ),

          ),
        ),
      );
    });
  }
}
