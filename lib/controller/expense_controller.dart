import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';

class ExpenseController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late final CollectionReference expenseCollection =
      firestore.collection("expense");
  late final CollectionReference budgetCollection =
      firestore.collection("budget");
  late final CollectionReference spendingCollection =
      firestore.collection("spending");

  RxList<Map<String, String>> currentMonthCategories =
      <Map<String, String>>[].obs;
  RxList<Map<String, dynamic>> currentMonthExpenses =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> expenseStatusList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("onInit triggered category");
    fetchCategories();
    fetchCurrentMonthExpenses();
    fetchCurrentMonthExpenseCategories();
    loadExpenseStatus();
  }

  Future<void> fetchCategories() async {
    final fetchedCategories = await fetchCurrentMonthExpenseCategories();
    currentMonthCategories.assignAll(fetchedCategories);
    print("fetched category, ${fetchedCategories}"); // KEEP RxList intact
    update(); // Only needed if using GetBuilder; not needed with Obx

    // After fetching, find and print the top spending category:
    final topCategory = getHighestSpendingCategory();
    print("Top spending category this month: $topCategory");
  }

  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();

  Future<void> loadExpenseStatus() async {
    final data = await fetchExpenseStatusForCurrentMonth();
    expenseStatusList.assignAll(data);
    print("Loaded expense status: ${expenseStatusList}");
  }

  Future<bool> addExpense() async {
    try {
      final String userId = auth.currentUser!.uid;
      final DateTime now = DateTime.now();

      final double amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
      final String category = categoryCtrl.text.trim();

      if (amount <= 0 || category.isEmpty) {
        Get.snackbar("Error", "Please enter valid category and amount.",
            colorText: TColor.secondary);
        return false;
      }

      // Fetch current month's budget
      final budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: userId)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now)
          .get();

      if (budgetSnapshot.docs.isEmpty) {
        Get.snackbar("Error", "No budget set for the current month.",
            colorText: TColor.secondary);
        return false;
      }

      final budgetRawData = budgetSnapshot.docs.first.data();
      if (budgetRawData == null) {
        Get.snackbar("Error", "Failed to load budget data.",
            colorText: TColor.secondary);
        return false;
      }

      final Map<String, dynamic> budgetData =
          budgetRawData as Map<String, dynamic>;
      final double totalBudget =
          double.tryParse(budgetData['amount'].toString()) ?? 0.0;
      final DateTime startDate =
          (budgetData['startDate'] as Timestamp).toDate();
      final DateTime endDate = (budgetData['endDate'] as Timestamp).toDate();

      // Fetch total spent in the same period
      final expensesSnapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      double totalSpent = 0.0;
      for (var doc in expensesSnapshot.docs) {
        final data = doc.data();
        if (data != null) {
          final expenseData = data as Map<String, dynamic>;
          final expAmount =
              double.tryParse(expenseData['amount'].toString()) ?? 0.0;
          totalSpent += expAmount;
        }
      }

      final double remainingBudget = totalBudget - totalSpent;

      // Check if expense fits in the remaining budget
      if (amount > remainingBudget) {
        Get.snackbar("Error",
            "Not enough budget left. Remaining: ${remainingBudget.toStringAsFixed(2)}",
            colorText: TColor.secondary);
        return false;
      }

      // Add the expense
      final doc = expenseCollection.doc();
      final expense = {
        'id': doc.id,
        'category': category,
        'amount': amount,
        'date': now,
        'userId': userId,
      };

      await doc.set(expense);

      Get.snackbar("Success", "Expense added successfully",
          colorText: TColor.line);

      await fetchCurrentMonthExpenses();
      await fetchCategories();

      await loadExpenseStatus();
      await fetchCurrentMonthExpenseCategories();
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
      return false;
    }
  }

  // fetch category name of current month expense for logged in user
  Future<List<Map<String, String>>> fetchCurrentMonthExpenseCategories() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        print('User not logged in');
        return [];
      }

      final userId = user.uid;
      final now = DateTime.now();

      // Define the date range for the current month
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      // Use a Map to track total amount per category
      final Map<String, double> categoryAmountMap = {};
      final Map<String, String> categoryIdMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final categoryId = doc.id;
        final category = data['category'] as String?;
        final amount = data['amount'] as num?; // Ensure it's a number

        if (category != null && category.trim().isNotEmpty && amount != null) {
          final trimmedCategory = category.trim();

          // Sum the amount by category
          categoryAmountMap[trimmedCategory] =
              (categoryAmountMap[trimmedCategory] ?? 0) + amount.toDouble();

          // Store categoryId once (or latest, depending on data structure)
          categoryIdMap[trimmedCategory] = categoryId;
        }
      }

      // Convert the map to a list of maps with string values
      final List<Map<String, String>> categories = categoryAmountMap.entries.map((entry) {
        final category = entry.key;
        final totalAmount = entry.value.toStringAsFixed(2); // format to 2 decimal places
        final categoryId = categoryIdMap[category] ?? '';
        return {
          'category': category,
          'categoryId': categoryId,
          'amount': totalAmount,
        };
      }).toList();

      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // fetch current month expense for current logged in user category and amount,
  Future<void> fetchCurrentMonthExpenses() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print("Error User not logged in");
        return;
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await expenseCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      List<Map<String, dynamic>> expenses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'category': data['category'],
          'amount': data['amount'],
        };
      }).toList();

      print("Current month expenses:");
      for (var exp in expenses) {
        print("Category: ${exp['category']}, Amount: ${exp['amount']}");
      }

      currentMonthExpenses.assignAll(expenses);
      await fetchCurrentMonthExpenseCategories();
    } catch (e) {
      print("Error Failed to fetch expenses: $e");
    }
  }

  // fetch current month expense status for showing remaining amount on category after removing spending subcategory on that category Id
  Future<List<Map<String, dynamic>>> fetchExpenseStatusForCurrentMonth() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return [];
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final expenseSnapshot = await expenseCollection
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      final List<Map<String, dynamic>> result = [];

      for (var expenseDoc in expenseSnapshot.docs) {
        final expenseData = expenseDoc.data() as Map<String, dynamic>?;

        if (expenseData == null) continue;

        final expenseId = expenseDoc.id;
        final expenseAmount = (expenseData['amount'] ?? 0).toDouble();
        final category = expenseData['category'] ?? '';

        final spendingSnapshot = await spendingCollection
            .where('userId', isEqualTo: user.uid)
            .where('expenseId', isEqualTo: expenseId)
            .where('date', isGreaterThanOrEqualTo: startOfMonth)
            .where('date', isLessThanOrEqualTo: endOfMonth)
            .get();

        double usedAmount = 0;
        List<Map<String, dynamic>> spendings = [];

        for (var spendingDoc in spendingSnapshot.docs) {
          final spendingData = spendingDoc.data() as Map<String, dynamic>?;

          if (spendingData != null) {
            final amount = (spendingData['amount'] ?? 0).toDouble();
            usedAmount += amount;

            spendings.add({
              'name': spendingData['name'] ?? '',
              'amount': amount,
              'spendingId':spendingData['id'] ?? '',
            });
          }
        }

        double remaining = expenseAmount - usedAmount;

        result.add({
          'name': expenseData['category'] ?? 'Uncategorized',
          'expenseId': expenseId,
          'category': category,
          
          'budget': expenseAmount,
          'used': usedAmount,
          'remaining': remaining,
          'spendings': spendings,
        });
      }

      for (var item in result) {
        print("CATEGORY: ${item['category']}");
        print("SPENDINGS: ${item['spendings']}");
      }

      for (var item in result) {
        double remaining = item['remaining'] ?? 0.0;
        String categoryId = item['expenseId'] ?? '';
        String category = item['category'] ?? '';

        if (remaining > 0 && categoryId.isNotEmpty) {
          await addSaving(categoryId: categoryId, category: category, amount: remaining);
        }
      }
      return result;
    } catch (e) {
      print("Error in fetchExpenseStatusForCurrentMonth: $e");
      return [];
    }
  }

  // delete expense
  deleteExpense(String id) async {
    try {
      await expenseCollection.doc(id).delete();

      Get.snackbar("Success", "expense deleted successfully",
          colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }


String getHighestSpendingCategory() {
  print("Current Month Categories: $currentMonthCategories");

  if (currentMonthCategories.isEmpty) return "No expenses";

  currentMonthCategories.sort((a, b) {
    double aAmount = double.tryParse(a['amount'] ?? '0') ?? 0;
    double bAmount = double.tryParse(b['amount'] ?? '0') ?? 0;
    return bAmount.compareTo(aAmount); // sort descending
  });

  return currentMonthCategories.first['category'] ?? "Unknown";
}
Future<void> updateExpense({
  required String expenseId,
  required String newCategory,
  required double newAmount,
}) async {
  try {
    if (newCategory.trim().isEmpty) {
      Get.snackbar("Error", "Category cannot be empty.", colorText: TColor.secondary);
      return;
    }
    if (newAmount <= 0) {
      Get.snackbar("Error", "Amount must be greater than zero.", colorText: TColor.secondary);
      return;
    }

    await expenseCollection.doc(expenseId).update({
      'category': newCategory.trim(),
      'amount': newAmount,
      'date': DateTime.now(), // Optionally update date to now or keep original
    });

    Get.snackbar("Success", "Expense updated successfully.", colorText: TColor.line);

    await fetchCurrentMonthExpenses();
    await fetchCategories();
    await loadExpenseStatus();
  } catch (e) {
    Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
    print("Error updating expense: $e");
  }
}

}



Future<void> addSaving({
  required String categoryId,
  required String category,
  required double amount,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    final savingCollection = FirebaseFirestore.instance.collection('saving');

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final existing = await savingCollection
        .where('userId', isEqualTo: user.uid)
        .where('categoryId', isEqualTo: categoryId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    if (existing.docs.isNotEmpty) {
      print("Saving already exists for this category this month");
      return;
    }

    await savingCollection.add({
      'userId': user.uid,
      'categoryId': categoryId,
      'categoryName': category,
      'amount': amount,
      'date': Timestamp.now(),
    });

    print("Saving added for category: $categoryId");
  } catch (e) {
    print("Error adding saving: $e");
  }

  
}
