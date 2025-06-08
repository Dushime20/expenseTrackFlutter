import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/saving_contoller.dart';
import '../common/color_extension.dart';

class BudgetsRow extends StatefulWidget {
  final Map bObj;
  final VoidCallback onPressed;

  const BudgetsRow({
    super.key,
    required this.bObj,
    required this.onPressed,
  });

  @override
  State<BudgetsRow> createState() => _BudgetsRowState();
}

class _BudgetsRowState extends State<BudgetsRow> {
  // Track last remaining amount for THIS specific category
  double? _lastRemainingAmount;
  String? _currentCategoryId;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeForCategory();
  }

  void _initializeForCategory() {
    String categoryId = widget.bObj["expenseId"]?.toString() ?? "";
    var remainingAmount =
        double.tryParse(widget.bObj["remaining"]?.toString() ?? "0") ?? 0;

    if (categoryId.isNotEmpty && !_hasInitialized) {
      _currentCategoryId = categoryId;
      _lastRemainingAmount = remainingAmount;
      _hasInitialized = true;
    }
  }

  @override
  void didUpdateWidget(BudgetsRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    String newCategoryId = widget.bObj["expenseId"]?.toString() ?? "";
    String oldCategoryId = oldWidget.bObj["expenseId"]?.toString() ?? "";

    if (newCategoryId != oldCategoryId) {
      _hasInitialized = false;
      _initializeForCategory();
    } else if (oldWidget.bObj != widget.bObj) {
      var newRemainingAmount =
          double.tryParse(widget.bObj["remaining"]?.toString() ?? "0") ?? 0;
      _updateSavingIfNeeded(newRemainingAmount, newCategoryId);
    }
  }

  void _updateSavingIfNeeded(double currentRemainingAmount, String categoryId) {
    if (categoryId.isNotEmpty &&
        categoryId == _currentCategoryId &&
        _hasInitialized &&
        _lastRemainingAmount != null &&
        _lastRemainingAmount != currentRemainingAmount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (Get.isRegistered<SavingController>()) {
            Get.find<SavingController>()
                .updateSaving(
                  categoryId: categoryId,
                  newAmount: currentRemainingAmount,
                )
                .then((_) {})
                .catchError((error) {});
          } else {}
        } catch (e) {}
      });

      _lastRemainingAmount = currentRemainingAmount;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    var usedAmount =
        double.tryParse(widget.bObj["used"]?.toString() ?? "0") ?? 0;
    var remainingAmount =
        double.tryParse(widget.bObj["remaining"]?.toString() ?? "0") ?? 0;
    var totalBudget =
        double.tryParse(widget.bObj["budget"]?.toString() ?? "1") ?? 1;
    var proVal = usedAmount / totalBudget;
    var category = widget.bObj["category"] ?? "";
    String categoryId = widget.bObj["expenseId"]?.toString() ?? "";

    // Only check for updates if we're properly initialized
    if (_hasInitialized && categoryId == _currentCategoryId) {
      _updateSavingIfNeeded(remainingAmount, categoryId);
    }

    return GetBuilder<ExpenseController>(builder: (ctrl) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: TColor.border.withOpacity(0.05),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? TColor.gray80
                  : TColor.white,
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
                      category,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? TColor.white
                            : TColor.gray60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${widget.bObj["budget"]} Rwf",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? TColor.white
                            : TColor.gray60,
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? TColor.white
                            : TColor.gray60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Remaining: ${remainingAmount.toStringAsFixed(0)} Rwf",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? TColor.white
                            : TColor.gray60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Spendings List
                Container(
                  constraints: const BoxConstraints(maxHeight: 80),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (widget.bObj["spendings"] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      final spending =
                          (widget.bObj["spendings"] as List)[index] ?? {};
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              spending["name"] ?? "",
                              style: TextStyle(
                                color: TColor.gray80,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "${(spending["amount"] as num?)?.toStringAsFixed(0) ?? '0'} Rwf",
                              style: TextStyle(
                                color: TColor.gray60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: TColor.gray60,
                  valueColor: AlwaysStoppedAnimation(
                      widget.bObj["color"] ?? TColor.line),
                  minHeight: 1,
                  value: proVal > 1.0 ? 1.0 : proVal,
                ),

                // Auto-savings indicator
                if (remainingAmount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Auto-save: ${remainingAmount.toStringAsFixed(0)} Rwf",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
