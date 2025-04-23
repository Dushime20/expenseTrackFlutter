import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/model/expense/expense.dart';
import 'package:untitled/model/income/income.dart';

import '../common/color_extension.dart';

class HomeController extends GetxController{

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late CollectionReference expenseCollection;
  late CollectionReference incomeCollection;
  final TextEditingController amountCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  double amountVal = 0.0;
  var monthlyExpense = 0.0.obs;
  var monthlyIncome = 0.0.obs;

  List<Expense> expense = [];

  List<Income> income =[];

  void updateAmount(double newVal) {
    amountVal = newVal;
    update(); // notify widgets
  }

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    expenseCollection = firestore.collection("expense");
    incomeCollection = firestore.collection("income");
    await fetchIncome();
    await  fetchExpense();
    await fetchExpenseStatus();
    await fetchMonthlyIncomeAndExpense();
    await loadExpenseStats();

    super.onInit();
  }

  //expense
  Future<void> addExpenses({required String categoryId}) async {
    try {
      DocumentReference doc = expenseCollection.doc();

      final double parsedAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

      Expense expense = Expense(
        id: doc.id,
        name: descriptionCtrl.text,
        amount: parsedAmount,
        date: DateTime.now(),
        userId: auth.currentUser!.uid,
        categoryId: categoryId, // Make sure your Expense model has this field
      );

      final expenseJson = expense.toJson();

      await doc.set(expenseJson);

      Get.snackbar("Success", "Expense added successfully", colorText: TColor.line);
      setValueDefault();
      await fetchExpense();
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }

  //update expense
  Future<void> updateExpense({
    required String incomeId,
    required String categoryId,
    required String newName,
    required double newAmount,
  }) async {
    try {
      DocumentReference doc = expenseCollection.doc(incomeId);

      Expense updatedExpense = Expense(
        id: incomeId,
        name: newName,
        amount: newAmount,
        date: DateTime.now(), // Optionally keep original date if needed
        userId: auth.currentUser!.uid,
        categoryId: categoryId,
      );

      final expenseJson = updatedExpense.toJson();

      await doc.update(expenseJson); // update instead of set

      Get.snackbar("Success", "Income updated successfully", colorText: TColor.line);
      setValueDefault(); // Optional: Reset form values
      await fetchIncome(); // Refresh income list
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }
  RxDouble totalExpense = RxDouble(0.0);
  RxDouble highestExpense = RxDouble(0.0);
  RxDouble lowestExpense = RxDouble(0.0);

  Future<void> loadExpenseStats() async {
    final stats = await fetchExpenseStatus();
    totalExpense.value = stats['total']??0.0;
    highestExpense.value = stats['highest'] ?? 0.0;
    lowestExpense.value = stats['lowest'] ?? 0.0;
    update();
  }

  //fetch expense status low,high and total
  Future<Map<String, dynamic>> fetchExpenseStatus() async {
    try {
      final userId = auth.currentUser!.uid;

      QuerySnapshot snapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        print("No expenses found.");
        return {
          "total": 0.0,   // total count of expenses (number of documents)
          "highest": 0.0,
          "lowest": 0.0,
        };
      }

      List<double> amounts = snapshot.docs
          .map((doc) => (doc['amount'] as num).toDouble())
          .toList();

      double highest = amounts.reduce((a, b) => a > b ? a : b);
      double lowest = amounts.reduce((a, b) => a < b ? a : b);

      print("Highest: $highest");
      print("Lowest: $lowest");
      return {
        "total": snapshot.docs.length.toDouble(), // total count as a double
        "highest": highest,
        "lowest": lowest,
      };
    } catch (e) {
      print("Error fetching expenses: $e");
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      return {
        "total": 0.0,
        "highest": 0.0,
        "lowest": 0.0,
      };
    }
  }






  fetchExpense() async {
    try {
      final String uid = auth.currentUser!.uid;
      QuerySnapshot expenseSnapshot = await expenseCollection
          .where("userId", isEqualTo: uid)
          .get();

      final List<Expense> retrievedExpense = expenseSnapshot.docs.map(
              (doc) => Expense.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();

      expense.clear();
      expense.assignAll(retrievedExpense);

      // Print each expense nicely
      for (var exp in expense) {
        print("Fetched Expense => ID: ${exp.id}, Name: ${exp.name}, Amount: ${exp.amount}, Date: ${exp.date}");
      }

      Get.snackbar("Success", "Fetched expenses successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Error fetching expenses: $e");
    }finally{
      update();
    }

  }

  //totalMonthly expense

  Future<double> calculateMonthlyExpense() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(milliseconds: 1));

      QuerySnapshot querySnapshot = await expenseCollection
          .where("userId", isEqualTo: auth.currentUser!.uid)
          .where("date", isGreaterThanOrEqualTo: startOfMonth)
          .where("date", isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalExpense = 0;
      for (var doc in querySnapshot.docs) {
        totalExpense += (doc['amount'] ?? 0).toDouble();
      }

      return totalExpense;
    } catch (e) {
      print("Error calculating monthly expense: $e");
      return 0.0;
    }
  }

  //fetch total monthly income and expense
  Future<void> fetchMonthlyIncomeAndExpense() async {
    monthlyExpense.value = await calculateMonthlyExpense();
    monthlyIncome.value = await calculateMonthlyIncome();
  }

 //delete expense
  deleteExpense(String id) async{
   try {
     await expenseCollection.doc(id).delete();
     fetchExpense();
     Get.snackbar("Success", "expense added successfully", colorText: TColor.line);
   } catch (e) {
     Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
     print(e);
   }
  }


  //income
  addIncome({required String categoryId}) async{
    try{
      DocumentReference doc = incomeCollection.doc();
      Income income= Income(
        id: doc.id,
        name: descriptionCtrl.text,
        amount: amountVal,
        date: DateTime.now(),
        userId: auth.currentUser!.uid,
        categoryId: categoryId, // Make sure your Expense model has this field

      );

      final incomeJson = income.toJson();


      doc.set(incomeJson);


      Get.snackbar("Success", "income added successfully", colorText: TColor.line);
      setValueDefault();
      await  fetchIncome();
    }catch(e){
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);

    }



  }

  //update income
  Future<void> updateIncome({
    required String incomeId,
    required String categoryId,
    required String newName,
    required double newAmount,
  }) async {
    try {
      DocumentReference doc = incomeCollection.doc(incomeId);

      Income updatedIncome = Income(
        id: incomeId,
        name: newName,
        amount: newAmount,
        date: DateTime.now(), // Optionally keep original date if needed
        userId: auth.currentUser!.uid,
        categoryId: categoryId,
      );

      final incomeJson = updatedIncome.toJson();

      await doc.update(incomeJson); // update instead of set

      Get.snackbar("Success", "Income updated successfully", colorText: TColor.line);
      setValueDefault(); // Optional: Reset form values
      await fetchIncome(); // Refresh income list
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }


  // total income in month
  Future<double> calculateMonthlyIncome() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(milliseconds: 1));

      QuerySnapshot querySnapshot = await incomeCollection
          .where("userId", isEqualTo: auth.currentUser!.uid)
          .where("date", isGreaterThanOrEqualTo: startOfMonth)
          .where("date", isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalIncome = 0;
      for (var doc in querySnapshot.docs) {
        totalIncome += (doc['amount'] ?? 0).toDouble();
      }

      return totalIncome;
    } catch (e) {
      print("Error calculating monthly income: $e");
      return 0.0;
    }
  }



  fetchIncome() async {
    try {
      final String uid = auth.currentUser!.uid;
      QuerySnapshot incomeSnapshot = await incomeCollection
          .where("userId", isEqualTo: uid)
          .get();

      final List<Income> retrievedIncome = incomeSnapshot.docs.map(
              (doc) => Income.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();

      income.clear();
      income.assignAll(retrievedIncome);

      // Print each expense nicely
      for (var inc in income) {
        print("Fetched Expense => ID: ${inc.id}, Name: ${inc.name}, Amount: ${inc.amount}, Date: ${inc.date}");
      }

      Get.snackbar("Success", "Fetched income successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Error fetching income: $e");
    }finally{
      update();
    }

  }
//delete income
  deleteIncome(String id) async{
    try {
      await incomeCollection.doc(id).delete();
      fetchIncome();
      Get.snackbar("Success", "income deleted successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }


  setValueDefault(){
    amountVal = 0.0;
    descriptionCtrl.clear();
    update();
  }
}