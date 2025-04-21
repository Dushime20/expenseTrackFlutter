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


  late CollectionReference budgetCollection;
  late CollectionReference expenseCollection;

  final TextEditingController amountCtrl = TextEditingController();

  var totalBudget= 0.0.obs;
  double totalBudgetAmount = 0.0;
  double usedBudget = 0.0;
  double remainingBudget = 0.0;
  bool isBudgetFound = false;




  RxList<Map<String, dynamic>> budgetList = <Map<String, dynamic>>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    expenseCollection =firestore.collection('expense');
    budgetCollection = firestore.collection('budget');
    fetchBudget();
    getCurrentMonthBudgetStatus();
    loadBudgetStatus();// Optionally fetch budgets when controller initializes
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

      await fetchBudget();
      await getCurrentMonthBudgetStatus();// refresh list
    } catch (e) {
      Get.snackbar("Error", "Failed to add budget: $e");
    }
  }


  Future<void> loadBudgetStatus() async {
    final result = await getCurrentMonthBudgetStatus();
    isBudgetFound = result['found'] ?? false;
    usedBudget = result['used'] ?? 0.0;
    remainingBudget = result['remaining'] ?? 0.0;
    totalBudgetAmount = result['totalBudgetAmount'] ?? 0.0;
    update(); // Notify listeners
  }
  
//total budget
  Future<double> calculateMonthlyBudget() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) return 0.0;

      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(milliseconds: 1));

      QuerySnapshot querySnapshot = await budgetCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('startDate', isLessThanOrEqualTo: endOfMonth)
          .where('endDate', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      double totalBudget = 0.0;
      for (var doc in querySnapshot.docs) {
        totalBudget += (doc['amount'] ?? 0).toDouble();
      }

      return totalBudget;
    } catch (e) {
      print("Error calculating monthly budget: $e");
      return 0.0;
    }
  }


  //used and remaining budget for current logged in user
  Future<Map<String, dynamic>> getCurrentMonthBudgetStatus() async {
    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("No user is currently logged in.");
        return {
          "found": false,
          "used": 0.0,
          "remaining": 0.0,
          "totalBudgetAmount": 0.0
        };
      }
      final String currentUserId = currentUser.uid;

      // Get current month date range
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Find budget for current month
      final budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: currentUserId)
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      if (budgetSnapshot.docs.isEmpty) {
        print("No budget found for current month.");
        return {
          "found": false,
          "used": 0.0,
          "remaining": 0.0,
          "totalBudgetAmount": 0.0
        };
      }

      // Use the first applicable budget (in case there are multiple)
      final budgetDoc = budgetSnapshot.docs.first;
      final data = budgetDoc.data() as Map<String, dynamic>;

      final String categoryId = data['categoryId'];
      final double totalBudgetAmount = await calculateMonthlyBudget() ;

      // Get expenses for this category in the current month
      final expenseSnapshot = await expenseCollection
          .where('userId', isEqualTo: currentUserId)
          .where('categoryId', isEqualTo: categoryId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double totalUsed = await homeController.calculateMonthlyExpense();


      double remaining = totalBudgetAmount - totalUsed;

      print("total budget: $totalBudgetAmount");
      print("used budget: $totalUsed");
      print("remaining budget: $remaining");

      return {
        "found": true,
        "used": totalUsed,
        "remaining": remaining < 0 ? 0.0 : remaining,
        "totalBudgetAmount": totalBudgetAmount,
        "budgetId": budgetDoc.id,  // Including the budget ID in case you need it
        "budgetName": data['name'] ?? "Monthly Budget"
      };
    } catch (e) {
      print("Error calculating current month budget: $e");
      return {
        "found": false,
        "used": 0.0,
        "remaining": 0.0,
        "totalBudgetAmount": 0.0
      };
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
