import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../controller/app_initialization_controller.dart';
import '../../controller/categoryController.dart';
import '../../controller/home_controller.dart';

class UpdateIncomeView extends StatefulWidget {
  final String? id;
  const UpdateIncomeView({super.key, this.id});

  @override
  State<UpdateIncomeView> createState() => _UpdateIncomeViewState();
}

class _UpdateIncomeViewState extends State<UpdateIncomeView> {
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

  void handleUpdate() async {
    // if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
    //   Get.snackbar("Error", "Please select a category",
    //       colorText: TColor.secondary);
    //   return;
    // }
    //
    // if (homeCtrl.descriptionCtrl.text.trim().isEmpty) {
    //   Get.snackbar("Error", "Please enter a description",
    //       colorText: TColor.secondary);
    //   return;
    // }
    //
    // if (homeCtrl.amountCtrl.text.trim().isEmpty) {
    //   Get.snackbar("Error", "Please enter an amount",
    //       colorText: TColor.secondary);
    //   return;
    // }

    double? amount = double.tryParse(homeCtrl.amountCtrl.text.trim());
    if (amount == null) {
      Get.snackbar("Error", "Invalid amount entered",
          colorText: TColor.secondary);
      return;
    }

    await homeCtrl.updateIncome(
      categoryId: selectedCategoryId!,
      incomeId: widget.id!, // Use `widget.id` here
      newName: homeCtrl.descriptionCtrl.text.trim(), // Convert to string
      newAmount: amount, // Use parsed double
    );

    Get.snackbar("Success", "Income updated successfully",
        colorText: TColor.line);

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

    // Ensure initialization happens when the screen is built
    final appInitController = Get.put(AppInitializationController());
    appInitController.initialize();

  return Scaffold(
    appBar: AppBar(
      title: const Text("Update Expense"),
      backgroundColor: TColor.white,
      foregroundColor: TColor.gray80,
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
              title: "Update Income",
              onPress: ()  {
                handleUpdate();
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

