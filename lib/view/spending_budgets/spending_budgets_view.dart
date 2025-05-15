import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/budgets_row.dart';
import 'package:untitled/common_widget/custom_arc_180_painter.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/view/add_subscription/add_spending.dart';
import 'package:untitled/view/budget/add_budget_screen.dart';

import '../../controller/expense_controller.dart';
import '../add_subscription/add_subscription_view.dart';
import '../budget/update_budget_screen.dart';
import '../settings/settings_view.dart';
import 'package:get/get.dart';

class SpendingBudgetsView extends StatefulWidget {
  const SpendingBudgetsView({super.key});

  @override
  State<SpendingBudgetsView> createState() => _SpendingBudgetsViewState();
}

class _SpendingBudgetsViewState extends State<SpendingBudgetsView> {
  final ExpenseController expenseCtrl = Get.put(ExpenseController());

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return GetBuilder<BudgetController>(builder: (ctrl) {
      final bool hasBudget = ctrl.budgetList.isNotEmpty;
      final bObj = hasBudget ? ctrl.budgetList.first : null;

      return Scaffold(
        backgroundColor: TColor.back,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35, right: 10),
                child: Row(
                  children: [
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsView()));
                        },
                        icon: Image.asset("assets/img/settings.png",
                            width: 25, height: 25, color: TColor.gray30))
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
                      painter: CustomArc180Painter(
                        totalBudget: ctrl.totalBudgetAmount.value,
                        usedBudget: ctrl.usedBudgetAmount.value,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() => Text(
                            "${ctrl.totalBudgetAmount.value.toStringAsFixed(2)} Rwf budget",
                            style: TextStyle(
                                color: TColor.gray80,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          )),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Container(
                      height: 180,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: TColor.border.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() => Text(
                                  "${ctrl.usedBudgetAmount.value.toStringAsFixed(2)} Rwf used budget",
                                  style: TextStyle(
                                      color: TColor.gray60,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                )),
                            const SizedBox(height: 5),
                            Obx(() => Text(
                                  "${ctrl.remainingBudgetAmount.value.toStringAsFixed(2)} Rwf remaining budget",
                                  style: TextStyle(
                                      color: TColor.gray60,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                )),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => const AddBudgetScreen());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: TColor.border),
                                      color: TColor.back,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      "Manage your budget",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: TColor.gray80),
                                  onSelected: (value) {
                                    if (value == 'update' && bObj != null) {
                                      DateTime _toDate(dynamic value) {
                                        if (value is Timestamp) return value.toDate();
                                        if (value is DateTime) return value;
                                        return DateTime.now();
                                      }

                                      final startDate = _toDate(bObj['startDate']);
                                      final endDate = _toDate(bObj['endDate']);

                                      Get.to(() => UpdateBudgetScreen(
                                        budgetId: bObj['id'] ?? '',
                                        initialAmount: bObj['amount'] ?? 0.0,
                                        initialStartDate: startDate,
                                        initialEndDate: endDate,
                                      ));

                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirm Deletion"),
                                            content: const Text("Are you sure you want to delete your budget?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Close the dialog
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Close the dialog first
                                                  if (bObj != null) {
                                                    ctrl.deleteBudget(bObj['id'] ?? '');
                                                  }// Call the delete function
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'update',
                                      child: Text('Update'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Your budgets are on track 👍",
                              style: TextStyle(
                                  color: TColor.gray60,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                ),
              ),

              Obx(() {
                if (expenseCtrl.expenseStatusList.isEmpty) {
                  return const Text("No budgets added yet.");
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              }),

              //listView
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: DottedBorder(
                    dashPattern: const [5, 4],
                    strokeWidth: 1,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(16),
                    color: TColor.border.withOpacity(0.1),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.to(()=> const AddSubScriptionView());
                            },
                            child: Text(
                              "Add new category ",
                              style: TextStyle(
                                  color: TColor.gray60,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Image.asset(
                            "assets/img/add.png",
                            width: 12,
                            height: 12,
                            color: TColor.gray60,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 110,
              ),
            ],
          ),
        ),
      );
    });
  }
}
