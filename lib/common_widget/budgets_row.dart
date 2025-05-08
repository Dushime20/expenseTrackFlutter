import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/expense_controller.dart';
import '../common/color_extension.dart';

class BudgetsRow extends StatelessWidget {
  final Map bObj;
  final VoidCallback onPressed;

  const BudgetsRow({super.key, required this.bObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var usedAmount = double.tryParse(bObj["used"]?.toString() ?? "0") ?? 0;
    var remainingAmount = double.tryParse(bObj["remaining"]?.toString() ?? "0") ?? 0;
    var totalBudget = double.tryParse(bObj["budget"]?.toString() ?? "1") ?? 1;
    var proVal = usedAmount / totalBudget;

    return GetBuilder<ExpenseController>(builder: (ctrl) {
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
              color: TColor.white,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      bObj["category"] ?? "",
                      style: TextStyle(
                        color: TColor.gray80,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${bObj["budget"]} Rwf",
                      style: TextStyle(
                        color: TColor.gray60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Used: ${usedAmount.toStringAsFixed(0)} Rwf",
                      style: TextStyle(
                        color: TColor.gray80,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Remaining: ${remainingAmount.toStringAsFixed(0)} Rwf",
                      style: TextStyle(
                        color: TColor.gray60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: TColor.gray60,
                  valueColor: AlwaysStoppedAnimation(bObj["color"] ?? TColor.line),
                  minHeight: 3,
                  value: proVal > 1.0 ? 1.0 : proVal,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
