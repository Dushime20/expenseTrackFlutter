import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';

class BudgetController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late CollectionReference budgetCollection;

  final TextEditingController amountCtrl = TextEditingController();

  RxList<Map<String, dynamic>> budgetList = <Map<String, dynamic>>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    budgetCollection = firestore.collection('budget');
    fetchBudget(); // Optionally fetch budgets when controller initializes
  }

  /// Add a budget to Firestore
  Future<void> addBudget({
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      final double parsedAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

      if (parsedAmount <= 0) {
        Get.snackbar("Invalid Amount", "Please enter a valid amount.");
        return;
      }

      DocumentReference doc = budgetCollection.doc();

      Map<String, dynamic> budgetData = {
        'id': doc.id,
        'userId': currentUser.uid,
        'categoryId': categoryId,
        'amount': parsedAmount,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),

      };

      await doc.set(budgetData);

      Get.snackbar("Success", "Budget added successfully",colorText: TColor.line);
      amountCtrl.clear();

      await fetchBudget(); // refresh list
    } catch (e) {
      Get.snackbar("Error", "Failed to add budget: $e");
    }
  }

  /// Fetch budgets for the currently logged-in user
  Future<void> fetchBudget() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      QuerySnapshot snapshot = await budgetCollection
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final List<Map<String, dynamic>> budgets = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      budgetList.assignAll(budgets);

      print("Fetched ${budgetList.length} budgets.");
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch budgets: $e");
    } finally {
      update();
    }
  }
}
