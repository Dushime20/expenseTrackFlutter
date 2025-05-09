import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/expense_controller.dart';

class SpendingController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


  final ExpenseController expenseController =  Get.put(ExpenseController());



  late final CollectionReference spendingCollection = firestore.collection("spending");
  late final CollectionReference expenseCollection = firestore.collection("expense");

  final TextEditingController subAmountCtrl = TextEditingController();
  final TextEditingController subNameCtrl = TextEditingController();

  String selectedExpenseId = ''; // This should be set externally when a category is selected
  var totalAmountSpending = 0.0.obs;
  var totalSpendingCount = 0.obs;
  var lowestSpending = 0.0.obs;
  var highestSpending = 0.0.obs;

  var spending = <Map<String, dynamic>>[].obs;


  @override
  void onInit() {
     fetchSpendingStats();
     fetchUserSpendings();
    super.onInit();


  }



  Future<bool> addSpending() async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar("Error", "User not logged in.", colorText: TColor.secondary);
        return false;
      }

      final double subAmount = double.tryParse(subAmountCtrl.text.trim()) ?? 0.0;
      final String subName = subNameCtrl.text.trim();
      if (subAmount <= 0 || subName.isEmpty || selectedExpenseId == null || selectedExpenseId!.isEmpty) {
        Get.snackbar("Error", "Please provide valid spending details.",
            colorText: TColor.secondary);
        return false;
      }

      if (selectedExpenseId == null || selectedExpenseId!.isEmpty) {
        Get.snackbar("Error", "Invalid or missing expense category ID.",
            colorText: TColor.secondary);
        return false;
      }


      // Fetch the parent expense category document
      final expenseDoc = await expenseCollection.doc(selectedExpenseId).get();
      if (!expenseDoc.exists || expenseDoc.data() == null) {
        Get.snackbar("Error", "Expense category not found.",
            colorText: TColor.secondary);
        return false;
      }

      final Map<String, dynamic> expenseData = expenseDoc.data()! as Map<String, dynamic>;
      final double maxCategoryAmount = double.tryParse(expenseData['amount'].toString()) ?? 0.0;

      // Fetch existing spendings under this expense category
      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .where('expenseId', isEqualTo: selectedExpenseId)
          .get();

      double totalSpentInCategory = 0.0;
      for (var doc in spendingSnapshot.docs) {
        final data = doc.data();
        if (data != null) {
          final spend = data as Map<String, dynamic>;
          final amt = double.tryParse(spend['amount'].toString()) ?? 0.0;
          totalSpentInCategory += amt;
        }
      }

      final double remainingAmount = maxCategoryAmount - totalSpentInCategory;

      if (subAmount > remainingAmount) {
        Get.snackbar("Error",
            "Insufficient budget. Remaining for this category: ${remainingAmount.toStringAsFixed(2)}",
            colorText: TColor.secondary);
        return false;
      }

      // Add new spending record
      final doc = spendingCollection.doc();
      final spending = {
        'id': doc.id,
        'name': subName,
        'amount': subAmount,
        'date': Timestamp.fromDate(DateTime.now()),
        'userId': userId,
        'expenseId': selectedExpenseId,
      };

      await doc.set(spending);


      await fetchUserSpendings();
      await fetchSpendingStats();
      expenseController.loadExpenseStatus();
      Get.snackbar("Success", "Spending added successfully",
          colorText: TColor.line);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Spending Error: $e");
      return false;
    }
  }

  //update spending
  Future<bool> updateSpending(String spendingId) async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar("Error", "User not logged in.", colorText: TColor.secondary);
        return false;
      }

      final double subAmount = double.tryParse(subAmountCtrl.text.trim()) ?? 0.0;
      final String subName = subNameCtrl.text.trim();

      if (subAmount <= 0 || subName.isEmpty || selectedExpenseId == null || selectedExpenseId!.isEmpty) {
        Get.snackbar("Error", "Please provide valid spending details.",
            colorText: TColor.secondary);
        print("Please provide valid spending details");
        return false;
      }

      // Fetch the parent expense category document
      final expenseDoc = await expenseCollection.doc(selectedExpenseId).get();
      if (!expenseDoc.exists || expenseDoc.data() == null) {
        Get.snackbar("Error", "Expense category not found.",
            colorText: TColor.secondary);
        return false;
      }

      final Map<String, dynamic> expenseData = expenseDoc.data()! as Map<String, dynamic>;
      final double maxCategoryAmount = double.tryParse(expenseData['amount'].toString()) ?? 0.0;

      // Fetch all spendings in this category except the one being updated
      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .where('expenseId', isEqualTo: selectedExpenseId)
          .get();

      double totalSpentInCategory = 0.0;
      for (var doc in spendingSnapshot.docs) {
        final data = doc.data();
        if (data != null && doc.id != spendingId) {
          final spend = data as Map<String, dynamic>;
          final amt = double.tryParse(spend['amount'].toString()) ?? 0.0;
          totalSpentInCategory += amt;
        }
      }

      final double remainingAmount = maxCategoryAmount - totalSpentInCategory;
      if (subAmount > remainingAmount) {
        Get.snackbar("Error",
            "Insufficient budget. Remaining for this category: ${remainingAmount.toStringAsFixed(2)}",
            colorText: TColor.secondary);
        return false;
      }

      // Update the spending document
      final updateData = {
        'name': subName,
        'amount': subAmount,
        'date': Timestamp.fromDate(DateTime.now()),
        'expenseId': selectedExpenseId,
      };

      await spendingCollection.doc(spendingId).update(updateData);

      Get.snackbar("Success", "Spending updated successfully",
          colorText: TColor.line);
      await fetchUserSpendings();
      await fetchSpendingStats();
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Update Spending Error: $e");
      return false;
    }
  }


  //fetch the spending for current loggedin user


  Future<void> fetchUserSpendings() async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) {
        print("Error User not logged in.");
        return;
      }


      final spendingSnapshot =  await spendingCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      spending.value = spendingSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print("User spending in month: ${spending.value}");
    } catch (e) {
     // Get.snackbar("Error", "Failed to fetch spendings: $e", colorText: TColor.secondary);
      print("failed to fetch spending, ${e}");
      return;
    }
  }

  //fetch total spending amount, total number of spending , low amount spending , high amount by logged in use in current month
  Future<void> fetchSpendingStats() async {
    try {
      final String userId = auth.currentUser!.uid;
      final DateTime now = DateTime.now();
      final DateTime startOfMonth = DateTime(now.year, now.month, 1);
      final DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (spendingSnapshot.docs.isEmpty) {
        // If there is no spending data, set all values to 0
        totalAmountSpending.value = 0.0;
        totalSpendingCount.value = 0;
        lowestSpending.value = 0.0;
        highestSpending.value = 0.0;
        return;
      }

      double totalAmount = 0.0;
      double? lowestAmount;
      double? highestAmount;
      int totalCount = spendingSnapshot.docs.length;

      for (var doc in spendingSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
        totalAmount += amount;

        if (lowestAmount == null || amount < lowestAmount) {
          lowestAmount = amount;
        }
        if (highestAmount == null || amount > highestAmount) {
          highestAmount = amount;
        }
      }

      // Update the reactive variables
      totalAmountSpending.value = totalAmount;
      totalSpendingCount.value = totalCount;
      lowestSpending.value = lowestAmount ?? 0.0;
      highestSpending.value = highestAmount ?? 0.0;

      print("spending status fetched successfully");

    } catch (e) {
      print("Error fetching spending stats: $e");
      //Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      totalAmountSpending.value = 0.0;
      totalSpendingCount.value = 0;
      lowestSpending.value = 0.0;
      highestSpending.value = 0.0;
    }
  }



//delete spending for current logged in user
  Future<bool> deleteSpending(String spendingId) async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar("Error", "User not logged in.", colorText: TColor.secondary);
        return false;
      }

      // Optional: Verify if the spending belongs to the current user

      final doc = await spendingCollection.doc(spendingId).get();

      if (!doc.exists) {
        Get.snackbar("Error", "Spending not found.", colorText: TColor.secondary);
        return false;
      }

// Explicitly cast the data to a map
      final data = doc.data() as Map<String, dynamic>;

      if (data['userId'] != userId) {
        Get.snackbar("Error", "Unauthorized access.", colorText: TColor.secondary);
        return false;
      }

      await spendingCollection.doc(spendingId).delete();
      Get.snackbar("Success", "Spending deleted.", colorText: TColor.line);
      await fetchUserSpendings();
      await fetchSpendingStats();
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to delete spending: $e", colorText: TColor.secondary);
      return false;
    }
  }



}



