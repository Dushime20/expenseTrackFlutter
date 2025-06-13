import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/saving_contoller.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/view/spending_budgets/spending_budgets_view.dart';

// Import components
import 'components/spending_header.dart';
import 'components/expense_category_dropdown.dart';
import 'components/savings_toggle.dart';
import 'components/savings_category_dropdown.dart';
import 'components/amount_input_section.dart';

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
  double selectedCategoryBudget = 0.0;

  // New variables for savings functionality
  bool useFromSavings = false;
  String? selectedSavingCategoryId;
  String? selectedSavingCategoryName;
  double availableSavingAmount = 0.0;
  final TextEditingController savingAmountCtrl = TextEditingController();
  final TextEditingController regularAmountCtrl = TextEditingController();

  final List<Map<String, String>> subArr = [
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
    print("=== calculateTotalAmount called ===");
    print("savingAmountCtrl.text=======: '${savingAmountCtrl.text}'");
    print("regularAmountCtrl.text=====: '${regularAmountCtrl.text}'");

    double savingAmount = double.tryParse(savingAmountCtrl.text) ?? 0.0;
    double regularAmount = double.tryParse(regularAmountCtrl.text) ?? 0.0;
    double totalAmount = savingAmount + regularAmount;

    print(
        "Parsed values - Saving: $savingAmount, Regular: $regularAmount, Total: $totalAmount");
    print("useFromSavings: $useFromSavings");

    setState(() {
      if (useFromSavings) {
        spendingCtrl.subAmountCtrl.text =
            totalAmount > 0 ? totalAmount.toStringAsFixed(0) : '';
      }
      // If not using savings, don't auto-calculate
    });

    print(
        "Final spendingCtrl.subAmountCtrl.text: '${spendingCtrl.subAmountCtrl.text}'");
  }

  void onSavingCategoryChanged(String? categoryId) {
    print("Saving category changed to: $categoryId");

    setState(() {
      selectedSavingCategoryId = categoryId;
      savingAmountCtrl.clear();
      regularAmountCtrl.clear(); // Clear this too when changing categories

      if (categoryId != null && categoryId.isNotEmpty) {
        // FIX: Use categoryId instead of id for comparison
        final selectedSaving = savingCtrl.saving.firstWhereOrNull(
          (saving) => saving.categoryId == categoryId,
        );

        print(
            "Found saving: ${selectedSaving?.categoryName}, Amount: ${selectedSaving?.amount}");

        if (selectedSaving != null) {
          selectedSavingCategoryName = selectedSaving.categoryName;
          availableSavingAmount = selectedSaving.amount ?? 0.0;
        } else {
          selectedSavingCategoryName = null;
          availableSavingAmount = 0.0;
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

        for (var category in categories) {
          if (category['categoryId'] == categoryId) {
            var amountValue = category['amount'];
            if (amountValue != null) {
              selectedCategoryBudget =
                  double.tryParse(amountValue.toString()) ?? 0.0;
            } else {
              selectedCategoryBudget = 0.0;
            }
            break;
          }
        }
      } else {
        selectedCategoryBudget = 0.0;
      }
    });
  }

  void onSavingsToggleChanged(bool? value) {
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
  }

  bool validateSpendingAmount() {
    double spendingAmount =
        double.tryParse(spendingCtrl.subAmountCtrl.text) ?? 0.0;
    double regularAmount = double.tryParse(regularAmountCtrl.text) ?? 0.0;

    if (spendingAmount <= 0) {
      return false;
    }

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

  // Enhanced validation method to ensure saving amount > 0
  bool validateSavingAmount() {
    // If not using savings, skip this validation
    if (!useFromSavings) {
      return true;
    }

    // Check if saving category is selected
    if (selectedSavingCategoryId == null || selectedSavingCategoryId!.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select a saving category",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return false;
    }

    // Get and validate saving amount
    String savingAmountText = savingAmountCtrl.text.trim();

    // Check if saving amount field is empty
    if (savingAmountText.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter amount to use from savings",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return false;
    }

    // Parse saving amount
    double savingAmountToUse = double.tryParse(savingAmountText) ?? 0.0;

    // CRITICAL CHECK: Saving amount must be > 0
    if (savingAmountToUse <= 0) {
      Get.snackbar(
        "Invalid Saving Amount",
        "Amount from savings must be greater than 0. Current: ${savingAmountToUse.toStringAsFixed(2)} RWF",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    // Check if saving amount exceeds available savings
    if (savingAmountToUse > availableSavingAmount) {
      Get.snackbar(
        "Insufficient Savings",
        "Not enough savings available. Available: ${availableSavingAmount.toStringAsFixed(0)} RWF, Requested: ${savingAmountToUse.toStringAsFixed(0)} RWF",
        colorText: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    return true;
  }

  // Enhanced handleSubmit method with stronger validation
  void handleSubmit() async {
    print("=== SUBMIT DEBUG ===");
    print("useFromSavings: $useFromSavings");
    print("selectedSavingCategoryId: $selectedSavingCategoryId");
    print("savingAmountCtrl.text: '${savingAmountCtrl.text}'");
    print("regularAmountCtrl.text: '${regularAmountCtrl.text}'");
    print(
        "spendingCtrl.subAmountCtrl.text: '${spendingCtrl.subAmountCtrl.text}'");

    // Basic validations
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

    if (!validateSpendingAmount()) {
      return;
    }

    if (!validateSavingAmount()) {
      return;
    }

    double spendingAmount =
        double.tryParse(spendingCtrl.subAmountCtrl.text) ?? 0.0;
    double savingAmountToUse = 0.0;

    if (useFromSavings) {
      savingAmountToUse = double.tryParse(savingAmountCtrl.text.trim()) ?? 0.0;

      if (savingAmountToUse <= 0) {
        Get.snackbar(
          "Critical Error",
          "Invalid saving amount detected. Please refresh and try again.",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      double regularAmount =
          double.tryParse(regularAmountCtrl.text.trim()) ?? 0.0;

      if (regularAmountCtrl.text.trim().isNotEmpty && regularAmount <= 0) {
        Get.snackbar(
          "Invalid Amount",
          "Regular budget amount must be greater than 0 if specified",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      // Validate total amount calculation
      double expectedTotal = savingAmountToUse + regularAmount;
      if ((expectedTotal - spendingAmount).abs() > 0.01) {
        Get.snackbar(
          "Amount Mismatch",
          "Total amount mismatch. Savings (${savingAmountToUse.toStringAsFixed(0)}) + Regular (${regularAmount.toStringAsFixed(0)}) = ${expectedTotal.toStringAsFixed(0)} should equal Total (${spendingAmount.toStringAsFixed(0)})",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      if (savingAmountToUse <= 0 && regularAmount <= 0) {
        Get.snackbar(
          "Invalid Transaction",
          "Cannot create spending with 0 amount from both savings and regular budget",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

     
    }

    // Set the selected expense ID
    spendingCtrl.selectedExpenseId = selectedCategoryId!;

    setState(() {
      _isLoading = true;
    });

    try {
      // Only proceed if all validations pass
      print("🚀 Proceeding with spending addition...");

      final addSpending =
          await spendingCtrl.addSpending(useFromSavings: useFromSavings);

      if (addSpending) {
        // If using savings, update the savings amount
        if (useFromSavings &&
            selectedSavingCategoryId != null &&
            savingAmountToUse > 0) {
          print("💰 Updating savings amount...");
          double newSavingAmount = availableSavingAmount - savingAmountToUse;

          final updateSaving = await savingCtrl.updateSavingAmountAfterSpending(
            selectedSavingCategoryId!,
            newSavingAmount,
          );

          if (!updateSaving) {
            print("❌ Savings update failed - aborting transaction");
            Get.snackbar(
              "Transaction Failed",
              "Failed to update savings. The spending transaction has been cancelled for data consistency.",
              colorText: Theme.of(context).colorScheme.onError,
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 5),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          print("✅ Savings updated successfully");
        }

        // Success message and navigation
        print(
            "✅ Spending added successfully with savings: $savingAmountToUse RWF");
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

        // Navigate and clear fields
        Get.to(() => const SpendingBudgetsView());
        _clearAllFields();
      } else {
        Get.snackbar(
          "Error",
          "Failed to add spending. Please try again.",
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (e) {
      print("❌ Error in handleSubmit: $e");
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

  // Helper method to clear all fields
  void _clearAllFields() {
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

  // Enhanced input validation for saving amount field
  void onSavingAmountChanged(String value) {
    // Real-time validation as user types
    if (useFromSavings && value.isNotEmpty) {
      double amount = double.tryParse(value) ?? 0.0;
      if (amount <= 0) {
        print("⚠️ Warning: User entered saving amount <= 0: $amount");
        // You could show a subtle warning here without blocking input
      }
    }
  }

  List<String> get alreadySelectedCategories {
    List<String> excluded = [];

    // Exclude the selected expense category from savings dropdown
    if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
      excluded.add(selectedCategoryId!);
    }
    print("Excluded categories: $excluded");
    return excluded;
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
              SpendingHeader(
                carouselItems: subArr,
                screenWidth: media.width,
              ),
              ExpenseCategoryDropdown(
                selectedCategory: selectedCategory,
                selectedCategoryBudget: selectedCategoryBudget,
                onChanged: onExpenseCategoryChanged,
                expenseCtrl: expenseCtrl,
              ),
              SavingsToggle(
                useFromSavings: useFromSavings,
                onChanged: onSavingsToggleChanged,
              ),
              if (useFromSavings)
                SavingsCategoryDropdown(
                  selectedSavingCategoryId: selectedSavingCategoryId,
                  availableSavingAmount: availableSavingAmount,
                  regularAmountCtrl: regularAmountCtrl,
                  savingAmountCtrl: savingAmountCtrl,
                  onSavingCategoryChanged: onSavingCategoryChanged,
                  savingCtrl: savingCtrl,
                  excludedCategoryIds: alreadySelectedCategories,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: RoundedTextField(
                  title: "name",
                  titleAlign: TextAlign.center,
                  controller: spendingCtrl.subNameCtrl,
                ),
              ),
              AmountInputSection(
                useFromSavings: useFromSavings,
                spendingCtrl: spendingCtrl,
                regularAmountCtrl: regularAmountCtrl,
                savingAmountCtrl: savingAmountCtrl,
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
