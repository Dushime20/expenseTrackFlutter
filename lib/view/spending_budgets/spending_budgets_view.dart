import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/budgets_row.dart';
import 'package:untitled/common_widget/custom_arc_180_painter.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/view/add_subscription/add_subscription_view.dart';
import 'package:untitled/view/budget/add_budget_screen.dart';
import 'package:untitled/view/budget/update_budget_screen.dart';

class SpendingBudgetsView extends StatefulWidget {
  const SpendingBudgetsView({super.key});

  @override
  State<SpendingBudgetsView> createState() => _SpendingBudgetsViewState();
}

class _SpendingBudgetsViewState extends State<SpendingBudgetsView>
    with SingleTickerProviderStateMixin {
  final ExpenseController expenseCtrl = Get.put(ExpenseController());
  bool _dialogShown = false;
  BuildContext? _dialogContext;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller?.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    final backgroundColor = theme.scaffoldBackgroundColor;

    return GetBuilder<BudgetController>(builder: (ctrl) {
      final bool hasBudget = ctrl.budgetList.isNotEmpty;
      final bObj = hasBudget ? ctrl.budgetList.first : null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final total = ctrl.totalBudgetAmount.value;
        final used = ctrl.usedBudgetAmount.value;

        if (total > 0) {
          final percentUsed = (used / total) * 100;

          if (percentUsed >= 75 && !_dialogShown) {
            _dialogShown = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                _dialogContext = dialogContext;
                return AlertDialog(
                  title: const Text('Budget Alert'),
                  content: Text(
                    'Warning! You have used ${percentUsed.toStringAsFixed(1)}% of your total budget.',
                    style: const TextStyle(color: Colors.red),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(_dialogContext!).pop();
                        _dialogShown = false;
                        _dialogContext = null;
                      },
                      child: const Text('Dismiss'),
                    ),
                  ],
                );
              },
            );
          } else if (_dialogShown &&
              percentUsed < 75 &&
              _dialogContext != null) {
            Navigator.of(_dialogContext!).pop();
            _dialogShown = false;
            _dialogContext = null;
          }
        }
      });

      return Scaffold(
        backgroundColor: backgroundColor,
        body: _controller == null
            ? const SizedBox()
            : FadeTransition(
                opacity: _controller!,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 35, right: 10),
                        child: Row(
                          children: [
                            Spacer(),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            width: media.width * 0.7,
                            height: media.width * 0.30,
                            child: CustomPaint(
                              painter: CustomArcPainter(
                                totalBudget: ctrl.totalBudgetAmount.value,
                                usedBudget: ctrl.usedBudgetAmount.value,
                                end: (ctrl.totalBudgetAmount.value == 0)
                                    ? 0
                                    : (ctrl.usedBudgetAmount.value /
                                            ctrl.totalBudgetAmount.value)
                                        .clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              Obx(() => Text(
                                    "${ctrl.totalBudgetAmount.value.toStringAsFixed(2)} Rwf budget",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildBudgetCard(ctrl, bObj, context),
                      const Text("Expense History",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      _buildExpenseList(),
                      _buildAddCategoryButton(context),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildBudgetCard(
      BudgetController ctrl, dynamic bObj, BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TColor.gray80
            : TColor.back,
      ),
      child: Column(
        children: [
          Obx(() => Text(
                "${ctrl.usedBudgetAmount.value.toStringAsFixed(2)} Rwf used",
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )),
          const SizedBox(height: 5),
          Obx(() => Text(
                "${ctrl.remainingBudgetAmount.value.toStringAsFixed(2)} Rwf remaining",
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Get.to(() => const AddBudgetScreen()),
                child: const Text("ge your budget"),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                onSelected: (value) {
                  if (value == 'update' && bObj != null) {
                    DateTime _toDate(dynamic value) {
                      if (value is Timestamp) return value.toDate();
                      if (value is DateTime) return value;
                      return DateTime.now();
                    }

                    Get.to(() => UpdateBudgetScreen(
                          budgetId: bObj['id'] ?? '',
                          initialAmount: bObj['amount'] ?? 0.0,
                          initialStartDate: _toDate(bObj['startDate']),
                          initialEndDate: _toDate(bObj['endDate']),
                        ));
                  }
                },
                itemBuilder: (BuildContext context) => const [
                  PopupMenuItem(value: 'update', child: Text('Update')),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    return Obx(() {
      if (expenseCtrl.expenseStatusList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No Category added yet."),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: expenseCtrl.expenseStatusList.length,
        itemBuilder: (context, index) {
          var bObj = expenseCtrl.expenseStatusList[index];
          return BudgetsRow(
            bObj: bObj,
            onPressed: () {},
          );
        },
      );
    });
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DottedBorder(
        dashPattern: const [5, 4],
        strokeWidth: 1,
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        color: theme.dividerColor.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => const AddSubScriptionView()),
          child: Container(
            height: 64,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Add new category",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.add_circle_outline,
                  color: theme.iconTheme.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _confirmDeleteBudget(
  //     BuildContext context, BudgetController ctrl, dynamic bObj) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Confirm Deletion"),
  //         content: const Text("Are you sure you want to delete your budget?"),
  //         actions: [
  //           TextButton(
  //             child: const Text("Cancel"),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: const Text("Delete", style: TextStyle(color: Colors.red)),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               ctrl.deleteBudget(bObj['id'] ?? '');
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
