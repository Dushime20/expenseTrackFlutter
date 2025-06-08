// lib/view/home/components/expense_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/spending_controller.dart';
import '../../../common_widget/expense_barchat.dart';
import '../../../common_widget/up_coming_bill_row.dart';
import '../../add_subscription/update_expense.dart';
import 'shared_widgets.dart';

class ExpenseSection extends StatelessWidget {
  final SpendingController spendingController;

  const ExpenseSection({
    super.key,
    required this.spendingController,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = Theme.of(context).disabledColor;
    final cardBackground = Theme.of(context).cardColor;

    return Obx(() {
      if (spendingController.spending.isEmpty) {
        return SharedWidgets.buildEmptyState(
          "No Expenses This Month",
          "Start tracking your expenses to see insights here.",
          Icons.receipt_outlined,
          textColor,
          grayColor,
        );
      }

      return SharedWidgets.buildContentSection(
        title: "Expense Overview",
        child: Column(
          children: [
            Container(
              height: 300,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExpenseBarChart(),
              ),
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: spendingController.spending.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final spent = spendingController.spending[index];
                return SharedWidgets.buildEnhancedListItem(
                  context: context,
                  child: UpcomingBillRow(
                    sObj: {
                      "id": spent['id'],
                      "name": spent['name'],
                      "date": (spent['date'] as Timestamp).toDate(),
                      "price": spent['amount'].toString()
                    },
                    onUpdate: () {
                      Get.to(() => UpdateExpenseView(spent['id']));
                    },
                    onDelete: () => SharedWidgets.showDeleteDialog(
                      context,
                      "expense",
                      () => spendingController.deleteSpending(spent['id']),
                    ),
                    onPressed: () {},
                  ),
                );
              },
            ),
          ],
        ),
        textColor: textColor,
        cardBackground: cardBackground,
      );
    });
  }
}