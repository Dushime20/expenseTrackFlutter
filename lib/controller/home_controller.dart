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
    await fetchMonthlyIncomeAndExpense();

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