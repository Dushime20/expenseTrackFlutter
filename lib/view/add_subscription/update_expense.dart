import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../controller/categoryController.dart';
import '../../controller/home_controller.dart';

class UpdateExpenseView extends StatefulWidget {
  final String? id;

  const UpdateExpenseView(this.id, {super.key});

  @override
  State<UpdateExpenseView> createState() => _UpdateExpenseState();
}

class _UpdateExpenseState extends State<UpdateExpenseView> {
  final CategoryController categoryCtrl = Get.put(CategoryController());
  final HomeController homeCtrl = Get.put(HomeController());

  double amountVal = 0.0;
  String? selectedCategoryName;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    categoryCtrl.filterCategoryByName("");
  }

  void handleSubmit() async {
    // if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
    //   Get.snackbar("Error", "Please select a category",
    //       colorText: TColor.secondary);
    //   return;
    // }

    if (homeCtrl.descriptionCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a description",
          colorText: TColor.secondary);
      return;
    }

    if (homeCtrl.amountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter an amount",
          colorText: TColor.secondary);
      return;
    }

    double? parsedAmount = double.tryParse(homeCtrl.amountCtrl.text.trim());
    if (parsedAmount == null) {
      Get.snackbar("Error", "Please enter a valid number for amount",
          colorText: TColor.secondary);
      return;
    }

    await homeCtrl.updateExpense(
      categoryId: selectedCategoryId!,
      expenseId: widget.id!, // ensure `widget.id` is not null
      newName: homeCtrl.descriptionCtrl.text.trim(),
      newAmount: parsedAmount,
    );

    Get.snackbar("Success", "Transaction updated successfully",
        colorText: TColor.line);

    // Reset state
    setState(() {
      amountVal = 0.0;
      homeCtrl.descriptionCtrl.clear();
      homeCtrl.amountCtrl.clear();
      selectedCategoryId = null;
      selectedCategoryName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Expense"),
        backgroundColor: TColor.white,
        foregroundColor: TColor.gray70,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GetBuilder<CategoryController>(
                builder: (catCtrl) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TextField(
                      //   decoration: InputDecoration(
                      //     hintText: 'Search category',
                      //     prefixIcon: Icon(Icons.search),
                      //     border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(12)),
                      //   ),
                      //   onChanged: (val) {
                      //     catCtrl.filterCategoryByName(val);
                      //   },
                      // ),

                      DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        hint: Text('Select Category', style: TextStyle(color: TColor.gray60)),
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: catCtrl.categoryList.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat.id,
                            child: Text(cat.name ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryId = value;
                            selectedCategoryName = catCtrl.categoryList
                                .firstWhere((cat) => cat.id == value)
                                .name;
                          });
                        },
                      ),

                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: homeCtrl.descriptionCtrl,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: homeCtrl.amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Custom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                title: "Update Expense",
                onPress: ()  {
                   handleSubmit();
                },
                color: TColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
