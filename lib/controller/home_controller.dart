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

  late final CollectionReference expenseCollection = firestore.collection("expense");
  late final CollectionReference incomeCollection = firestore.collection("income");

  final TextEditingController amountCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  double amountVal = 0.0;
  var monthlyExpense = 0.0.obs;
  var monthlyIncome = 0.0.obs;

  var totalIncome = 0.0.obs;


  List<Expense> expense = [];

  List<Income> income =[];

  void updateAmount(double newVal) {
    amountVal = newVal;
    update(); // notify widgets
  }

  @override
  Future<void> onInit() async {
    super.onInit();


   await calculateMonthlyIncome();



  }






  Future<bool> addIncome() async {
    try {
      final double parsedAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

      DocumentReference doc = incomeCollection.doc();
      Income income = Income(
        id: doc.id,
        name: descriptionCtrl.text,
        amount: parsedAmount,
        date: DateTime.now(),
        userId: auth.currentUser!.uid,
      );

      final incomeJson = income.toJson();

      await doc.set(incomeJson);

      Get.snackbar("Success", "Income added successfully", colorText: TColor.line);

      setValueDefault();
      await fetchIncome();
      await calculateMonthlyIncome();

      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
      return false;
    }
  }


  //update income
  Future<void> updateIncome({
    required String incomeId,

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
  Future<void> calculateMonthlyIncome() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(milliseconds: 1));

      QuerySnapshot querySnapshot = await incomeCollection
          .where("userId", isEqualTo: auth.currentUser!.uid)
          .where("date", isGreaterThanOrEqualTo: startOfMonth)
          .where("date", isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalIncomeAmount = 0;
      for (var doc in querySnapshot.docs) {
        totalIncomeAmount += (doc['amount'] ?? 0).toDouble();
      }

      totalIncome.value = totalIncomeAmount; // update the reactive variable
      print("print total income amount, ${totalIncomeAmount}");
    } catch (e) {
      print("Error calculating monthly income: $e");
      totalIncome.value = 0.0; // fallback to 0 if there's an error
    }
  }




  fetchIncome() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print("User not logged in");
        return;
      }

      final uid = currentUser.uid;
      final DateTime now = DateTime.now();

      // Define start and end of the current month
      final DateTime startOfMonth = DateTime(now.year, now.month, 1);
      final DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot incomeSnapshot = await incomeCollection
          .where("userId", isEqualTo: uid)
          .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final List<Income> retrievedIncome = incomeSnapshot.docs.map(
              (doc) => Income.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();

      income.clear();
      income.assignAll(retrievedIncome);

      for (var inc in income) {
        print("Fetched income => ID: ${inc.id}, Name: ${inc.name}, Amount: ${inc.amount}, Date: ${inc.date}");
      }

    } catch (e) {

      print("Error fetching income: $e");
    } finally {
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