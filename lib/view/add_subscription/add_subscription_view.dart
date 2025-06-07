import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/income_segment_button.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/view/add_subscription/add_income.dart';
import 'package:untitled/view/add_subscription/add_spending.dart';
import 'package:untitled/view/spending_budgets/spending_budgets_view.dart';

class AddSubScriptionView extends StatefulWidget {
  const AddSubScriptionView({super.key});

  @override
  State<AddSubScriptionView> createState() => _AddSubScriptionViewState();
}

class _AddSubScriptionViewState extends State<AddSubScriptionView> {
  bool isIncome = true;

  final ExpenseController expenseCtrl = Get.put(ExpenseController());
  final List<Map<String, String>> subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];

  bool _isLoading = false;

  String? selectedCategory;

  void handleSubmit() async {
    if (expenseCtrl.categoryCtrl.text.trim().isEmpty ||
        expenseCtrl.amountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a description",
          colorText: Theme.of(context).colorScheme.error);
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final addExpense = await expenseCtrl.addExpense();

    setState(() {
      _isLoading = false;
    });

    if (addExpense) {
      Get.snackbar("Success", "Transaction added successfully",
          colorText: Theme.of(context).colorScheme.primary);
      Get.to(() => const SpendingBudgetsView());

      expenseCtrl.categoryCtrl.clear();
      expenseCtrl.amountCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final borderColor = theme.dividerColor;

    return GetBuilder<HomeController>(builder: (_) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TColor.gray80
                      : TColor.back,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Image.asset(
                                "assets/img/back.png",
                                width: 25,
                                height: 25,
                                color: theme.iconTheme.color,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "Set your expense category",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
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
                                      sObj["icon"]!,
                                      width: media.width * 0.4,
                                      height: media.width * 0.4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    sObj["name"]!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.hintColor,
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
              const SizedBox(height: 20),

              /// Segment Button
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: 45,
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? TColor.gray60 : TColor.back,

                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: IncomeSegmentButton(
                        title: 'Add subCategory',
                        onPress: () => Get.to(() => const AddSpendingView()),
                      ),
                    ),
                    Expanded(
                      child: IncomeSegmentButton(
                        title: 'Add Income',
                        onPress: () => Get.to(() => const AddIncomeView()),
                      ),
                    ),
                  ],
                ),
              ),

              /// Category input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundedTextField(
                  title: "Category",
                  titleAlign: TextAlign.center,
                  controller: expenseCtrl.categoryCtrl,
                ),
              ),

              /// Amount input
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: RoundedTextField(
                  title: "Amount",
                  titleAlign: TextAlign.center,
                  controller: expenseCtrl.amountCtrl,
                ),
              ),

              /// Add Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: _isLoading ? "Adding..." : "Add new Expense",
                  onPress: _isLoading ? () {} : handleSubmit,
                  color: textColor,
                  isLoading: _isLoading,
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
