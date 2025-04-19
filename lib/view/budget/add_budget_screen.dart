import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/controller/categoryController.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final CategoryController categoryCtrl = Get.find();
  final BudgetController budgetCtrl = Get.find();

  DateTime? startDate;
  DateTime? endDate;

  String? selectedCategoryName;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    categoryCtrl.fetchCategory();
  }

  void handleSubmit() async {
    if (selectedCategoryId == null || startDate == null || endDate == null) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    await budgetCtrl.addBudget(
      categoryId: selectedCategoryId!,
      startDate: startDate!,
      endDate: endDate!,
    );
  }

  Future<void> pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BudgetController>(builder: (_) {
      return Scaffold(
        backgroundColor: TColor.back,
        appBar: AppBar(
          backgroundColor: TColor.back,
          elevation: 0,
          title: Text("Add Budget",
              style: TextStyle(
                  color: TColor.gray80, fontWeight: FontWeight.w600)),
          iconTheme: IconThemeData(color: TColor.gray80),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: selectedCategoryName,
                  items: categoryCtrl.categoryList.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.name ?? '',
                      child: Text(category.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryName = value;
                      final selected = categoryCtrl.categoryList
                          .firstWhereOrNull((c) => c.name == value);
                      selectedCategoryId = selected?.id;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Select Category",
                    labelStyle: TextStyle(color: TColor.gray60),
                    border: const OutlineInputBorder(),
                  ),
                );
              }),
              const SizedBox(height: 15),
              TextField(
                controller: budgetCtrl.amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (Rwf)",
                  labelStyle: TextStyle(color: TColor.gray60),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                title: Text(
                  startDate != null
                      ? "Start Date: ${formatDate(startDate)}"
                      : "Select Start Date",
                  style: TextStyle(color: TColor.gray80),
                ),
                trailing: Icon(Icons.calendar_today, color: TColor.gray60),
                onTap: pickStartDate,
              ),
              ListTile(
                title: Text(
                  endDate != null
                      ? "End Date: ${formatDate(endDate)}"
                      : "Select End Date",
                  style: TextStyle(color: TColor.gray80),
                ),
                trailing: Icon(Icons.calendar_today, color: TColor.gray60),
                onTap: pickEndDate,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: handleSubmit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.line,
                    minimumSize: const Size.fromHeight(50)),
                child: const Text("Save Budget"),
              )
            ],
          ),
        ),
      );
    });
  }
}
