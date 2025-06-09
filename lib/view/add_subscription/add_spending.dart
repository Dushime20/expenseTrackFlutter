import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/saving_contoller.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/model/Saving/saving.dart';
import 'package:untitled/view/spending_budgets/spending_budgets_view.dart';

class AddSpendingView extends StatefulWidget {
  const AddSpendingView({super.key});

  @override
  State<AddSpendingView> createState() => _AddSpendingViewState();
}

class _AddSpendingViewState extends State<AddSpendingView> {
  final SpendingController spendingCtrl = Get.put(SpendingController());
  final ExpenseController expenseCtrl = Get.put(ExpenseController());
  final SavingController savingCtrl = Get.put(SavingController());

  double amountVal = 0.0;
  String? selectedCategoryName;
  String? selectedCategoryId;
  double selectedCategoryBudget = 0.0; // Track category budget for validation

  // New variables for savings functionality
  bool useFromSavings = false;
  String? selectedSavingCategoryId;
  String? selectedSavingCategoryName;
  double availableSavingAmount = 0.0;
  final TextEditingController savingAmountCtrl = TextEditingController();
  final TextEditingController regularAmountCtrl = TextEditingController();

  List subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];

  String? selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSavingsData();
    // Add listeners to automatically calculate total amount
    savingAmountCtrl.addListener(calculateTotalAmount);
    regularAmountCtrl.addListener(calculateTotalAmount);
  }

  @override
  void dispose() {
    savingAmountCtrl.removeListener(calculateTotalAmount);
    regularAmountCtrl.removeListener(calculateTotalAmount);
    savingAmountCtrl.dispose();
    regularAmountCtrl.dispose();
    super.dispose();
  }

  void loadSavingsData() async {
    await savingCtrl.loadsavingFromFirebase();
  }

  void calculateTotalAmount() {
    double savingAmount = double.tryParse(savingAmountCtrl.text) ?? 0.0;
    double regularAmount = double.tryParse(regularAmountCtrl.text) ?? 0.0;
    double totalAmount = savingAmount + regularAmount;

    // Update the main spending amount controller
    setState(() {
      spendingCtrl.subAmountCtrl.text =
          totalAmount > 0 ? totalAmount.toStringAsFixed(0) : '';
    });
  }

  void onSavingCategoryChanged(String? categoryId) {
    setState(() {
      selectedSavingCategoryId = categoryId;
      savingAmountCtrl.clear();
      if (categoryId != null) {
        final selectedSaving = savingCtrl.saving.firstWhere(
          (saving) => saving.id == categoryId,
          orElse: () => null as dynamic,
        );
        if (selectedSaving != null) {
          selectedSavingCategoryName = selectedSaving.categoryName;
          availableSavingAmount = selectedSaving.amount;
        }
      } else {
        selectedSavingCategoryName = null;
        availableSavingAmount = 0.0;
      }
    });
    calculateTotalAmount();
  }

  void onExpenseCategoryChanged(String? categoryId) {
    setState(() {
      selectedCategory = categoryId;
      selectedCategoryId = categoryId;

      if (categoryId != null) {
        final categories = expenseCtrl.currentMonthCategories;
        print("Selected category ID: $categoryId");
        print("Available categories: $categories");

        // Find the matching category
        for (var category in categories) {
          if (category['categoryId'] == categoryId) {
            // Get the amount value
            var amountValue = category['amount'];

            // Convert to double regardless of the original type
            if (amountValue != null) {
              selectedCategoryBudget =
                  double.tryParse(amountValue.toString()) ?? 0.0;
            } else {
              selectedCategoryBudget = 0.0;
            }

            print("Found category with amount: $selectedCategoryBudget");
            break;
          }
        }
      } else {
        selectedCategoryBudget = 0.0;
      }
    });
  }

  bool validateSpendingAmount() {
    double spendingAmount =
        double.tryParse(spendingCtrl.subAmountCtrl.text) ?? 0.0;
    double regularAmount = double.tryParse(regularAmountCtrl.text) ?? 0.0;
    double savingAmount = double.tryParse(savingAmountCtrl.text) ?? 0.0;

    if (spendingAmount <= 0) {
      return false;
    }

    // If not using savings, check if regular amount exceeds category budget
    if (!useFromSavings) {
      if (spendingAmount > selectedCategoryBudget) {
        Get.snackbar(
          "Budget Exceeded",
          "Amount (${spendingAmount.toStringAsFixed(0)} RWF) exceeds category budget (${selectedCategoryBudget.toStringAsFixed(0)} RWF). Consider using money from savings.",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
      return true;
    }

    // If using savings, validate the breakdown
    if (regularAmount > selectedCategoryBudget) {
      Get.snackbar(
        "Error",
        "Regular budget amount (${regularAmount.toStringAsFixed(0)} RWF) cannot exceed category budget (${selectedCategoryBudget.toStringAsFixed(0)} RWF)",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return false;
    }

    return true;
  }

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

    // Validate spending amount
    if (!validateSpendingAmount()) {
      return;
    }

    double spendingAmount =
        double.tryParse(spendingCtrl.subAmountCtrl.text) ?? 0.0;
    double savingAmountToUse = 0.0;

    // Check if using from savings and validate amount
    if (useFromSavings) {
      if (selectedSavingCategoryId == null) {
        Get.snackbar(
          "Error",
          "Please select a saving category",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      if (savingAmountCtrl.text.trim().isEmpty) {
        Get.snackbar(
          "Error",
          "Please enter amount to use from savings",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      savingAmountToUse = double.tryParse(savingAmountCtrl.text) ?? 0.0;

      if (savingAmountToUse <= 0) {
        Get.snackbar(
          "Error",
          "Please enter a valid amount from savings",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      if (savingAmountToUse > availableSavingAmount) {
        Get.snackbar(
          "Error",
          "Insufficient savings amount. Available: ${availableSavingAmount.toStringAsFixed(0)} RWF",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      // Validate that regular amount + saving amount = total spending amount
      double regularAmount = double.tryParse(regularAmountCtrl.text) ?? 0.0;
      double expectedTotal = savingAmountToUse + regularAmount;
      if ((expectedTotal - spendingAmount).abs() > 0.01) {
        Get.snackbar(
          "Error",
          "Total amount mismatch. Savings (${savingAmountToUse.toStringAsFixed(0)}) + Regular (${regularAmount.toStringAsFixed(0)}) should equal Total (${spendingAmount.toStringAsFixed(0)})",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }
    }

    spendingCtrl.selectedExpenseId = selectedCategoryId!;
    setState(() {
      _isLoading = true;
    });

    try {
      // Add spending first
      final addSpending = await spendingCtrl.addSpending();

      if (addSpending) {
        // If using from savings, update the saving amount
        if (useFromSavings &&
            selectedSavingCategoryId != null &&
            savingAmountToUse > 0) {
          double newSavingAmount = availableSavingAmount - savingAmountToUse;
          final updateSaving = await savingCtrl.updateSavingAmountAfterSpending(
            selectedSavingCategoryId!,
            newSavingAmount,
          );

          if (!updateSaving) {
            Get.snackbar(
              "Warning",
              "Spending added but failed to update savings",
              colorText: Theme.of(context).colorScheme.onError,
              backgroundColor: Colors.orange,
            );
          }
        }

        String successMessage = "Spending added successfully";
        if (useFromSavings && savingAmountToUse > 0) {
          successMessage =
              "Spending added! ${savingAmountToUse.toStringAsFixed(0)} RWF deducted from savings";
        }

        Get.snackbar(
          "Success",
          successMessage,
          colorText: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
        );

        Get.to(() => SpendingBudgetsView());

        // Clear all fields
        setState(() {
          spendingCtrl.subNameCtrl.clear();
          spendingCtrl.subAmountCtrl.clear();
          savingAmountCtrl.clear();
          regularAmountCtrl.clear();
          selectedCategoryId = null;
          selectedCategoryName = null;
          selectedSavingCategoryId = null;
          selectedSavingCategoryName = null;
          availableSavingAmount = 0.0;
          selectedCategoryBudget = 0.0;
          useFromSavings = false;
          selectedCategory = null;
        });
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to process the transaction: ${e.toString()}",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("=== Build method called ===");
    print("Selected category: $selectedCategory");
    print("Selected category budget: $selectedCategoryBudget");
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

              // Expense Category Dropdown
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Select expense category",
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
                        onChanged: onExpenseCategoryChanged,
                      ),
                      if (selectedCategoryBudget > 0) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Category Budget: ${selectedCategoryBudget.toStringAsFixed(0)} RWF",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),

              // Use from Savings Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Checkbox(
                      value: useFromSavings,
                      onChanged: (value) {
                        setState(() {
                          useFromSavings = value ?? false;
                          if (!useFromSavings) {
                            selectedSavingCategoryId = null;
                            selectedSavingCategoryName = null;
                            availableSavingAmount = 0.0;
                            savingAmountCtrl.clear();
                            regularAmountCtrl.clear();
                            spendingCtrl.subAmountCtrl.clear();
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        "Use money from savings (allows spending more than category budget)",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              // Savings Category Dropdown (only show if useFromSavings is true)
              if (useFromSavings)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Obx(() {
                    final List<SavingModel> savings = savingCtrl.saving;

                    if (savings.isEmpty) {
                      return const Center(
                        child: Text(
                          "No savings available",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Select saving category",
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
                          value: selectedSavingCategoryId,
                          items: savings.map((saving) {
                            return DropdownMenuItem<String>(
                              value: saving.id,
                              child: Text(
                                "${saving.categoryName} - ${saving.amount.toStringAsFixed(0)} RWF",
                              ),
                            );
                          }).toList(),
                          onChanged: onSavingCategoryChanged,
                        ),
                        if (selectedSavingCategoryId != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Available amount: ${availableSavingAmount.toStringAsFixed(0)} RWF",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          RoundedTextField(
                            title: "Amount from regular budget (RWF)",
                            titleAlign: TextAlign.center,
                            controller: regularAmountCtrl,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          RoundedTextField(
                            title: "Amount to use from savings (RWF)",
                            titleAlign: TextAlign.center,
                            controller: savingAmountCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ],
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

              // Total Amount Field - Auto-calculated when using savings
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    if (useFromSavings) ...[
                      // Show auto-calculated total with breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Amount (Auto-calculated)",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${spendingCtrl.subAmountCtrl.text} RWF",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (spendingCtrl.subAmountCtrl.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Regular: ${regularAmountCtrl.text} RWF + Savings: ${savingAmountCtrl.text} RWF",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.disabledColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ] else ...[
                      // Regular amount input when not using savings
                      RoundedTextField(
                        title: "Total Amount (RWF)",
                        titleAlign: TextAlign.center,
                        controller: spendingCtrl.subAmountCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: _isLoading ? "Adding..." : "Add new Spending",
                  onPress: _isLoading ? () {} : handleSubmit,
                  isLoading: _isLoading,
                  color: TColor.white,
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
