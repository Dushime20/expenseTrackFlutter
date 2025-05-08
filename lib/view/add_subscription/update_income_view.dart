import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../controller/app_initialization_controller.dart';

import '../../controller/home_controller.dart';

class UpdateIncomeView extends StatefulWidget {
  final String? id;
  const UpdateIncomeView({super.key, this.id});

  @override
  State<UpdateIncomeView> createState() => _UpdateIncomeViewState();
}

class _UpdateIncomeViewState extends State<UpdateIncomeView> {

final HomeController homeCtrl = Get.put(HomeController());

double amountVal = 0.0;
String? selectedCategoryName;
String? selectedCategoryId;

@override
void initState() {
  super.initState();

}

  void handleUpdate() async {


    double? amount = double.tryParse(homeCtrl.amountCtrl.text.trim());
    if (amount == null) {
      Get.snackbar("Error", "Invalid amount entered",
          colorText: TColor.secondary);
      return;
    }

    await homeCtrl.updateIncome(

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

    });
  }

  @override
Widget build(BuildContext context) {

    // Ensure initialization happens when the screen is built
    final appInitController = Get.put(AppInitializationController());
    appInitController.initialize();

  return Scaffold(
    appBar: AppBar(
      title: const Text("Update Income"),
      backgroundColor: TColor.white,
      foregroundColor: TColor.gray80,
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),


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

