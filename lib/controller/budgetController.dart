import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/home_controller.dart';

class BudgetController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final homeController = Get.find<HomeController>();


  late final CollectionReference budgetCollection = firestore.collection('budget');
  late final CollectionReference incomeCollection =firestore.collection('income');
  late final CollectionReference expenseCollection =firestore.collection('expense');


  final TextEditingController amountCtrl = TextEditingController();
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);



  bool isBudgetFound = false;

  RxDouble totalBudgetAmount = 0.0.obs;
  RxDouble usedBudgetAmount = 0.0.obs;
  RxDouble remainingBudgetAmount = 0.0.obs;






  RxList<Map<String, dynamic>> budgetList = <Map<String, dynamic>>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchBudgetStatus();



  }

  //Add budget for current loggedin user
  Future<bool> addBudget() async {
    try {
      final double enteredAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
      final String userId = auth.currentUser!.uid;

      // Ensure dates are selected
      if (selectedStartDate.value == null || selectedEndDate.value == null) {
        Get.snackbar("Error", "Please select both start and end dates.",
            colorText: TColor.secondary);
        return false;
      }

      // Step 1: Get total income for the current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

      final incomeSnapshot = await incomeCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThan: startOfNextMonth)
          .get();

      double totalIncome = 0.0;
      for (var doc in incomeSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = data['amount'] ?? 0.0;
          totalIncome += double.tryParse(amount.toString()) ?? 0.0;
        }
      }

      // Step 2: Get total existing budgets for the current month
      final budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: userId)
          .where('startDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('startDate', isLessThan: startOfNextMonth)
          .get();

      double existingBudgetTotal = 0.0;
      for (var doc in budgetSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = data['amount'] ?? 0.0;
          existingBudgetTotal += double.tryParse(amount.toString()) ?? 0.0;
        }
      }

      // Step 3: Check if new budget would exceed total income
      if (enteredAmount + existingBudgetTotal > totalIncome) {
        Get.snackbar("Error", "Adding this budget will exceed your total income.",
            colorText: TColor.secondary);
        return false;
      }

      // Step 4: Save budget
      final doc = budgetCollection.doc();
      final budget = {
        'id': doc.id,
        'amount': enteredAmount,
        'startDate': selectedStartDate.value,
        'endDate': selectedEndDate.value,
        'userId': userId,
      };

      await doc.set(budget);
      await fetchBudgetStatus();

      Get.snackbar("Success", "Budget added successfully", colorText: TColor.line);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
      return false;
    }
  }



  // Fetch budgets for the currently logged-in user in current month
  Future<void> fetchBudget() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print("Error: User not logged in");
        return;
      }

      // Get the start and end of the current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await budgetCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final List<Map<String, dynamic>> budgets = snapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id, // Include document ID
        };
      }).toList();

      budgetList.assignAll(budgets);

      print("Fetched ${budgetList.length} budgets for the current month.");
    } catch (e) {
      print("Error: Failed to fetch budgets - $e");
    } finally {
      update();
    }
  }



  //fetch total amount of budget
  // Future<void> fetchTotalBudgetForCurrentMonth() async {
  //   double total = 0.0;
  //
  //   try {
  //     final currentUser = auth.currentUser;
  //     if (currentUser == null) {
  //       Get.snackbar("Error", "User not logged in");
  //       return;
  //     }
  //
  //     final now = DateTime.now();
  //     final startOfMonth = DateTime(now.year, now.month, 1);
  //     final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  //
  //     final snapshot = await budgetCollection
  //         .where('userId', isEqualTo: currentUser.uid)
  //         .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
  //         .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
  //         .get();
  //
  //     for (var doc in snapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       final amount = data['amount'];
  //       if (amount is num) {
  //         total += amount.toDouble();
  //       }
  //     }
  //
  //     totalBudgetAmount.value = total;
  //     print("Total budget: $total");
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to fetch total budget: $e");
  //   } finally {
  //     update();
  //   }
  // }

  Future<void> fetchBudgetStatus() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print("Error User not logged in");
        return;
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      double totalBudget = 0.0;
      double usedBudget = 0.0;

      // 1. Fetch total budgets
      final budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      for (var doc in budgetSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['amount'] is num) {
          totalBudget += (data['amount'] as num).toDouble();
        }
      }

      // 2. Fetch total expenses
      final expenseSnapshot = await expenseCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      for (var doc in expenseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['amount'] is num) {
          usedBudget += (data['amount'] as num).toDouble();
        }
      }

      // 3. Update state
      totalBudgetAmount.value = totalBudget;
      usedBudgetAmount.value = usedBudget;
      remainingBudgetAmount.value = totalBudget - usedBudget;
      print("Total: $totalBudget, Used: $usedBudget, Remaining: ${totalBudget - usedBudget}");
    } catch (e) {
      print("Error Failed to fetch budget status: $e");
    }
  }


  //update current month budget of current logged in user
  Future<void> updateBudget({
    required String id,
    double? newAmount,
    DateTime? newStartDate,
    DateTime? newEndDate,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      Map<String, dynamic> updatedData = {};

      if (newAmount != null) {
        updatedData['amount'] = newAmount;
      }
      if (newStartDate != null) {
        updatedData['startDate'] = newStartDate;
      }
      if (newEndDate != null) {
        updatedData['endDate'] = newEndDate;
      }

      if (updatedData.isEmpty) {
        Get.snackbar("Error", "No data provided to update");
        return;
      }

      await budgetCollection.doc(id).update(updatedData);

      // Refresh UI
      fetchBudgetStatus();

      Get.snackbar("Success", "Budget updated successfully", colorText: TColor.line);

    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Error updating budget: $e");
    }
  }








  //delete expense
  Future<void> deleteBudget(String id) async {
    try {
      await budgetCollection.doc(id).delete();
      fetchBudgetStatus();
      Get.snackbar("Success", "Budget deleted successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Error deleting budget: $e");
    }
  }

 Future<List<Map<String, dynamic>>> fetchExpenseStatusForCurrentMonth() async {
  final user = auth.currentUser;
  if (user == null) {
    print("User not logged in");
    return [];
  }

  final userId = user.uid;
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 1);

  // Fetch all budgets for the current month
  final budgetSnapshot = await budgetCollection
      .where('userId', isEqualTo: userId)
      .where('startDate', isGreaterThanOrEqualTo: startOfMonth)
      .where('startDate', isLessThan: endOfMonth)
      .get();

  List<Map<String, dynamic>> result = [];

  for (var doc in budgetSnapshot.docs) {
    final budgetData = doc.data() as Map<String, dynamic>;
    final amount = (budgetData['amount'] ?? 0.0).toDouble();
    final startDate = (budgetData['startDate'] as Timestamp).toDate();
    final endDate = (budgetData['endDate'] as Timestamp).toDate();

    // Fetch ALL expenses in the month
    final expenseSnapshot = await expenseCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThan: endOfMonth)
        .get();

    double used = 0.0;
    List<Map<String, dynamic>> spendings = [];

    for (var expenseDoc in expenseSnapshot.docs) {
      final expenseData = expenseDoc.data() as Map<String, dynamic>;
      final amt = (expenseData['amount'] ?? 0.0).toDouble();
      used += amt;
      spendings.add({
        'name': expenseData['description'] ?? 'Unknown',
        'amount': amt,
      });
    }

    result.add({
      'budget': amount,
      'used': used,
      'remaining': amount - used,
      'spendings': spendings,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  return result;
}



}
