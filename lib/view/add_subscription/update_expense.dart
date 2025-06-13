import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

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

  @override
  void initState() {
    super.initState();
    fetchAndSetSpendingData();
  }

  Future<void> fetchAndSetSpendingData() async {
    if (widget.id == null) return;

    await spendingCtrl.fetchUserSpendings();
    final spendingToEdit = spendingCtrl.spending
        .firstWhereOrNull((item) => item['id'] == widget.id);

    if (spendingToEdit != null) {
      spendingCtrl.subNameCtrl.text = spendingToEdit['name'] ?? '';
      spendingCtrl.subAmountCtrl.text =
          spendingToEdit['amount']?.toString() ?? '';
      selectedCategory = spendingToEdit['categoryId'];
      spendingCtrl.selectedExpenseId = spendingToEdit['categoryId'];
      setState(() {});
    }
  }

  void handleSubmit() async {
    if (spendingCtrl.subNameCtrl.text.trim().isEmpty ||
        spendingCtrl.subAmountCtrl.text.trim().isEmpty ||
        spendingCtrl.selectedExpenseId == null) {
      Get.snackbar("Error", "Please fill in all fields",
          colorText: TColor.secondary);
      return;
    }

    double? parsedAmount =
    double.tryParse(spendingCtrl.subAmountCtrl.text.trim());
    if (parsedAmount == null) {
      Get.snackbar("Error", "Enter a valid number for amount",
          colorText: TColor.secondary);
      return;
    }

    final success = await spendingCtrl.updateSpending(
      widget.id ?? '',
      spendingCtrl.subNameCtrl.text.trim(),
      double.tryParse(spendingCtrl.subAmountCtrl.text.trim()) ?? 0.0,
    );
    if (success) {
      Get.back(); // go back after update

      setState(() {
        spendingCtrl.subAmountCtrl.clear();
        spendingCtrl.subNameCtrl.clear();
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    final appInitController = Get.put(AppInitializationController());
    appInitController.initialize();

    return Scaffold(
      backgroundColor: TColor.back,
      appBar: AppBar(
        title: const Text("Update Your Spending"),
        backgroundColor: TColor.white,
        foregroundColor: TColor.gray70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Category Dropdown
            Obx(() {
              final categories = expenseCtrl.currentMonthCategories;

              if (categories.isEmpty) {
                return const Text(
                    "No categories available. Please add an expense first.");
              }

              return DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Select Category",
                  labelStyle: TextStyle(color: TColor.gray60),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: TColor.gray10),
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['categoryId'],
                    child: Text(cat['category'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    spendingCtrl.selectedExpenseId = value!; // ✅ Important
                  });
                },
              );
            }),

            const SizedBox(height: 20),

            // Name Field
            TextFormField(
              controller: spendingCtrl.subNameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: TColor.gray60),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: TColor.gray10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Amount Field
            TextFormField(
              controller: spendingCtrl.subAmountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: TextStyle(color: TColor.gray60),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: TColor.gray10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            PrimaryButton(
              title: "Update Spending",
              onPress: handleSubmit,
              color: TColor.white,
            ),
          ],
        ),
      ),
    );
  }
}
