import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/custom_arc_painter.dart';
import 'package:untitled/common_widget/income_barchat.dart';
import 'package:untitled/common_widget/income_home_row.dart';
import 'package:untitled/common_widget/segment_button.dart';
import 'package:untitled/common_widget/up_coming_bill_row.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/view/add_subscription/update_expense.dart';
import 'package:untitled/view/add_subscription/update_income_view.dart';

import 'package:untitled/view/settings/settings_view.dart';

import '../../common_widget/expense_barchat.dart';



class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isIncome = true;
  final SpendingController spendingCtrl = Get.put(SpendingController());








  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return GetBuilder<HomeController>(builder: (ctrl) {
      return Scaffold(
        backgroundColor: TColor.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: media.width * 0.8,
                decoration: BoxDecoration(
                  color: TColor.back,
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
                            painter: CustomArcPainter(end: 0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 20),
                          child: Row(
                            children: [
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (
                                          context) => const SettingsView(),
                                    ),
                                  );
                                },
                                icon: Image.asset(
                                  "assets/img/settings.png",
                                  width: 25,
                                  height: 25,
                                  color: TColor.gray60,
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
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                        const SizedBox(height: 6),
                        Text(
                          "This month Expense",
                          style: TextStyle(
                            color: TColor.gray60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(() => Text(
                          "${ctrl.totalIncome.value.toStringAsFixed(0)} Frw",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                        const SizedBox(height: 6),
                        Text(
                          "This month income",
                          style: TextStyle(
                            color: TColor.gray60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Replace this inside the Stack (the one under the Container)
                    Positioned(
                      bottom: 5,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Obx(() => _buildStatCard("Active expenses",spendingCtrl.totalSpendingCount.value.toString())),
                          const SizedBox(width: 8),
                          Obx(() => _buildStatCard("Low expense", "${spendingCtrl.lowestSpending.value.toStringAsFixed(2)} Frw")),
                          const SizedBox(width: 8),
                          Obx(() => _buildStatCard("High expense", "${spendingCtrl.highestSpending.value.toStringAsFixed(2)} Frw")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle buttons
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                height: 45,
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: TColor.back,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentButton(
                        title: ' Income',
                        onPress: () {
                          setState(() {
                            isIncome = false;
                          });
                        },
                        isActive: !isIncome,
                      ),
                    ),
                    Expanded(
                      child: SegmentButton(
                        title: 'subCategory',
                        onPress: () {
                          setState(() {
                            isIncome = true;
                          });
                        },
                        isActive: isIncome,
                      ),
                    ),
                  ],
                ),
              ),

              // Conditional content
              if (!isIncome)
                Obx(() {
                  if (ctrl.income.isEmpty) {
                    return const Center(child: Text("No Income available this Month"));
                  }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Show income Chart
              SizedBox(
              height: 300, // Adjust height as needed
              child: IncomeBarChart(),
                  ),

              ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                            TextButton(
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator
                                    .of(context)
                                    .pop(); // Close the dialog first
                                ctrl.deleteIncome(
                                    income.id!); // Call your delete function
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
                    return const Center(child: Text("No Spending available this Month"));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show Expense Chart
                      SizedBox(
                        height: 300, // Adjust height as needed
                        child: ExpenseBarChart(),
                      ),

                      // List of Spending Rows
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                    content: const Text("Are you sure you want to delete this expense?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          spendingCtrl.deleteSpending(spent['id']);
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

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: TColor.back,
          border: Border.all(color: TColor.gray10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: TColor.gray60, fontSize: 10),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
