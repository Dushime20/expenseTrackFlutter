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
  late final CollectionReference expenseCollection =firestore.collection('expense');
  late final CollectionReference categoryCollection = firestore.collection('category');

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

    // Check if user is logged in
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      print("User not logged in. Skipping data fetch.");
      return;
    }


    fetchBudget();
    getCurrentMonthBudgetStatus();

    loadBudgetStatus();// Optionally fetch budgets when controller initializes
    loadBudgetsByCategory();
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

  var budgetsByCategory = <Map<String, dynamic>>[].obs;

  Future<void> loadBudgetsByCategory() async {
    final data = await fetchBudgetByCategoryWithNames();
    budgetsByCategory.value = data.entries.map((entry) => {
      "name": entry.key,
      "amount": entry.value,
    }).toList();
    update();
  }



//fetchBudgetByCategoryWithNames
  Future<Map<String, double>> fetchBudgetByCategoryWithNames() async {
    try {
      final userId = auth.currentUser!.uid;

      // 1. Fetch all budgets for the current user
      QuerySnapshot budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (budgetSnapshot.docs.isEmpty) {
        return {};
      }

      // 2. Group by categoryId and sum amount
      Map<String, double> categoryAmounts = {};

      for (var doc in budgetSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String categoryId = data['categoryId'];
        final double amount = (data['amount'] as num).toDouble();

        categoryAmounts[categoryId] = (categoryAmounts[categoryId] ?? 0.0) + amount;
      }

      // 3. Fetch all categories and map them: {categoryId: name}
      QuerySnapshot categorySnapshot = await categoryCollection.get();
      Map<String, String> categoryNames = {
        for (var doc in categorySnapshot.docs)
          doc.id: (doc['name'] as String)
      };

      // 4. Map category IDs to names
      Map<String, double> result = {};
      categoryAmounts.forEach((categoryId, amount) {
        final name = categoryNames[categoryId] ?? 'Unknown';
        result[name] = amount;
      });

      return result;
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      return {};
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


  //delete expense
  deleteExpense(String id) async{
    try {
      await budgetCollection.doc(id).delete();
      fetchBudget();
      Get.snackbar("Success", "expense added successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }
}
