import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/theme_controller.dart';

import '../../common_widget/custom_arc_painter.dart';
import '../../common_widget/income_barchat.dart';
import '../../common_widget/income_home_row.dart';
import '../../common_widget/segment_button.dart';
import '../../common_widget/up_coming_bill_row.dart';
import '../../common_widget/expense_barchat.dart';
import '../../view/add_subscription/update_expense.dart';
import '../../view/add_subscription/update_income_view.dart';
import '../../view/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isIncome = true;
  final SpendingController spendingCtrl = Get.put(SpendingController());
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = Theme.of(context).disabledColor; // for gray60 replacement
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBackground = Theme.of(context).cardColor;

    return GetBuilder<HomeController>(builder: (ctrl) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: media.width * 0.8,
                decoration: BoxDecoration(
                  color: TColor.gray60.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: media.width * 0.01),
                          width: media.width * 0.7,
                          height: media.width * 0.6,
                          child: CustomPaint(
                            painter: CustomArcPainter(
                              end: 0.6, // 60% (0.0 to 1.0)
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 20),
                          child: Row(
                            children: [
                              const Spacer(),
                              // // Theme toggle button
                              // Obx(() => IconButton(
                              //       icon: Icon(
                              //         themeController.themeMode.value == ThemeMode.dark
                              //             ? Icons.light_mode
                              //             : Icons.dark_mode,
                              //         color: grayColor,
                              //       ),
                              //       onPressed: () {
                              //         themeController.toggleTheme();
                              //       },
                              //     )),
                              // Settings icon
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsView(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.settings,
                                  size: 25,
                                  color: grayColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Obx(() => Text(
                              "${spendingCtrl.totalAmountSpending.value.toStringAsFixed(2)} Frw",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                        const SizedBox(height: 6),
                        Text(
                          "This monthly Expense",
                          style: TextStyle(
                            color: grayColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(() => Text(
                              "${ctrl.totalIncome.value.toStringAsFixed(0)} Frw",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                        const SizedBox(height: 6),
                        Text(
                          "This monthly income",
                          style: TextStyle(
                            color: grayColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Positioned(
                      bottom: 5,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Obx(() => _buildStatCard(
                              " expenses",
                              spendingCtrl.totalSpendingCount.value.toString(),
                              cardBackground,
                              textColor,
                              grayColor)),
                          const SizedBox(width: 8),
                          Obx(() => _buildStatCard(
                              "Low expense",
                              "${spendingCtrl.lowestSpending.value.toStringAsFixed(2)} Frw",
                              cardBackground,
                              textColor,
                              grayColor)),
                          const SizedBox(width: 8),
                          Obx(() => _buildStatCard(
                              "High expense",
                              "${spendingCtrl.highestSpending.value.toStringAsFixed(2)} Frw",
                              cardBackground,
                              textColor,
                              grayColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle buttons
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: 45,
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TColor.gray60
                      : TColor.back,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentButton(
                        title: 'Expense',
                        onPress: () {
                          setState(() {
                            isIncome = true; // Income tab active
                          });
                        },
                        isActive: isIncome, // active if isIncome true
                      ),
                    ),
                    Expanded(
                      child: SegmentButton(
                        title: 'Income',
                        onPress: () {
                          setState(() {
                            isIncome = false;
                          });
                        },
                        isActive: !isIncome,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isIncome)
                Obx(() {
                  if (ctrl.income.isEmpty) {
                    return Center(
                      child: Text(
                        "No Income available this Month",
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 300,
                        child: IncomeBarChart(),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: ctrl.income.length,
                        itemBuilder: (context, index) {
                          final income = ctrl.income[index];

                          return IncomeHomeRow(
                            sObj: {
                              "id": income.id,
                              "name": income.name,
                              "date": income.date,
                              "price": income.amount.toString()
                            },
                            onPressed: () {},
                            onUpdate: () {
                              Get.to(() => UpdateIncomeView(id: income.id!));
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Deletion"),
                                    content: const Text(
                                        "Are you sure you want to delete this income?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog first
                                          ctrl.deleteIncome(income
                                              .id!); // Call your delete function
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                }),

              if (isIncome)
                Obx(() {
                  if (spendingCtrl.spending.isEmpty) {
                    return Center(
                      child: Text(
                        "No Spending available this Month",
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 300,
                        child: ExpenseBarChart(),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: spendingCtrl.spending.length,
                        itemBuilder: (context, index) {
                          final spent = spendingCtrl.spending[index];
                          return UpcomingBillRow(
                            sObj: {
                              "id": spent['id'],
                              "name": spent['name'],
                              "date": (spent['date'] as Timestamp).toDate(),
                              "price": spent['amount'].toString()
                            },
                            onUpdate: () {
                              Get.to(() => UpdateExpenseView(spent['id']));
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Deletion"),
                                    content: const Text(
                                        "Are you sure you want to delete this expense?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          spendingCtrl
                                              .deleteSpending(spent['id']);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onPressed: () {},
                          );
                        },
                      ),
                    ],
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatCard(String title, String value, Color background,
      Color textColor, Color grayColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: grayColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: grayColor,
                    fontSize: 13)),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
