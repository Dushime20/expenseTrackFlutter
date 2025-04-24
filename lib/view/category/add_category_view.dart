import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/categoryController.dart';

class AddCategoryView extends StatelessWidget {
  const AddCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> typeOptions = ["income", "expense"];

    return GetBuilder<CategoryController>(builder: (ctrl) {
      return Scaffold(
        backgroundColor: TColor.back,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Image.asset("assets/img/back.png",
                                    width: 25,
                                    height: 25,
                                    color: TColor.gray30),
                              ),
                            ],
                          ),
                          const Text(
                            "Add Category",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Create a new category",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.gray80,
                              fontSize: 30,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Category Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundedTextField(
                  title: "Category Name",
                  controller: ctrl.categoryNameCtrl,
                ),
              ),

              const SizedBox(height: 20),

              // Type Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Type",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: TColor.gray30),
                          ),
                          child: DropdownButton<String>(
                            value: ctrl.selectedType.value.isNotEmpty
                                ? ctrl.selectedType.value
                                : null,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text("Select type"),
                            items: typeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value.capitalize!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ctrl.selectedType.value = value;
                              }
                            },
                          ),
                        ),
                      ],
                    )),
              ),

              const SizedBox(height: 40),

              // Add Category Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: "Add Category",
                  onPress: () async {
                    if (ctrl.categoryNameCtrl.text
                        .trim()
                        .isEmpty ||
                        ctrl.selectedType.value.isEmpty) {
                      Get.snackbar("Error", "Please enter all fields",
                          colorText: TColor.secondary);

                      return;
                    }

                    await ctrl.addCategory();
                  },
                  color: TColor.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
