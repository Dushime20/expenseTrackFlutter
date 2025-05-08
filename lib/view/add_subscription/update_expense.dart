import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/spending_controller.dart';

import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../controller/app_initialization_controller.dart';

class UpdateExpenseView extends StatefulWidget {
  final String? id;

  const UpdateExpenseView(this.id, {super.key});

  @override
  State<UpdateExpenseView> createState() => _UpdateExpenseState();
}

class _UpdateExpenseState extends State<UpdateExpenseView> {
  final SpendingController spendingCtrl = Get.put(SpendingController());
  final ExpenseController expenseCtrl = Get.put(ExpenseController());


  String? selectedCategory;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Optionally: Pre-fill fields if needed
  }

  void handleSubmit() async {
    if (spendingCtrl.subNameCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a description",
          colorText: TColor.secondary);
      return;
    }

    if (spendingCtrl.subAmountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter an amount",
          colorText: TColor.secondary);
      return;
    }

    double? parsedAmount =
    double.tryParse(spendingCtrl.subAmountCtrl.text.trim());
    if (parsedAmount == null) {
      Get.snackbar("Error", "Please enter a valid number for amount",
          colorText: TColor.secondary);
      return;
    }

    final updateSpending = await spendingCtrl.updateSpending(widget.id ?? '');
    if (updateSpending) {
      Get.snackbar("Success", "Transaction updated successfully",
          colorText: TColor.line);

      setState(() {
        spendingCtrl.subNameCtrl.clear();
        spendingCtrl.subAmountCtrl.clear();
        selectedCategoryId = null;
        selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appInitController = Get.put(AppInitializationController());
    appInitController.initialize();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Your Spending"),
        backgroundColor: TColor.white,
        foregroundColor: TColor.gray70,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Category Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Obx(() {
                final List<Map<String, String>> categories =
                    expenseCtrl.currentMonthCategories;

                if (categories.isEmpty) {
                  return const Center(
                    child: Text("No categories available, please add expense first"),
                  );
                }

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Category",
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  value: selectedCategory,
                  items: categories.map((categoryMap) {
                    return DropdownMenuItem<String>(
                      value: categoryMap['categoryId'],
                      child: Text(categoryMap['category'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedCategoryId = value;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: spendingCtrl.subNameCtrl,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: spendingCtrl.subAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                title: "Update Spending",
                onPress: handleSubmit,
                color: TColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
