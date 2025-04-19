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

  TextEditingController descriptionCtrl = TextEditingController();
  double amountVal = 0.0;

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
    super.onInit();
  }

  //expense
  Future<void> addExpenses({required String categoryId}) async {
    try {
      DocumentReference doc = expenseCollection.doc();

      Expense expense = Expense(
        id: doc.id,
        name: descriptionCtrl.text,
        amount: amountVal,
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