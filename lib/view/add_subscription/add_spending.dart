import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/view/main_tab/main_tab_view.dart';

class AddSpendingView extends StatefulWidget {
  const AddSpendingView({super.key});

  @override
  State<AddSpendingView> createState() => _AddSpendingViewState();
}

class _AddSpendingViewState extends State<AddSpendingView> {
  final SpendingController spendingCtrl = Get.put(SpendingController());
  final ExpenseController expenseCtrl = Get.put(ExpenseController());

  double amountVal = 0.0;
  String? selectedCategoryName;
  String? selectedCategoryId;

  List subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];

  String? selectedCategory;
  bool _isLoading = false;

  void handleSubmit() async {
    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select a category",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (spendingCtrl.subAmountCtrl.text.trim().isEmpty ||
        spendingCtrl.subNameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter amount and name",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    spendingCtrl.selectedExpenseId = selectedCategoryId!;
    setState(() {
      _isLoading = true;
    });
    final addSpending = await spendingCtrl.addSpending();
    setState(() {
      _isLoading = false;
    });
    if (addSpending) {
      Get.snackbar(
        "Success",
        "Spending added successfully",
        colorText: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      );

      Get.to(() => MainTabView());

      setState(() {
        spendingCtrl.subNameCtrl.clear();
        spendingCtrl.subAmountCtrl.clear();
        selectedCategoryId = null;
        selectedCategoryName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return GetBuilder<HomeController>(builder: (_) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.asset(
                                "assets/img/back.png",
                                width: 25,
                                height: 25,
                                color: theme.disabledColor,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "Add new spending",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: TColor.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: media.width,
                        height: media.width * 0.5,
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            autoPlay: false,
                            aspectRatio: 1,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.65,
                            enlargeFactor: 0.4,
                            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                          ),
                          itemCount: subArr.length,
                          itemBuilder: (context, index, _) {
                            var sObj = subArr[index];
                            return Container(
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      sObj["icon"],
                                      width: media.width * 0.4,
                                      height: media.width * 0.4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    sObj["name"],
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.disabledColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Obx(() {
                  final List<Map<String, String>> categories =
                      expenseCtrl.currentMonthCategories;

                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        "No categories available, please add expense first",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select category",
                      labelStyle: TextStyle(color: theme.disabledColor),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1,
                        ),
                      ),
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

              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: RoundedTextField(
                  title: "name",
                  titleAlign: TextAlign.center,
                  controller: spendingCtrl.subNameCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: RoundedTextField(
                  title: "Amount",
                  titleAlign: TextAlign.center,
                  controller: spendingCtrl.subAmountCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: _isLoading ? "Adding..." : "Add new Spending",
                  onPress: _isLoading ? () {} : handleSubmit,
                  isLoading: _isLoading,
                  color:TColor.white,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
