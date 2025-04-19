import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import '../model/category/category.dart';
  // Assuming TColor is from your theme

class CategoryController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late CollectionReference categoryCollection;

  TextEditingController categoryNameCtrl = TextEditingController();
  RxString selectedType = ''.obs;

  RxList<Category> categoryList = <Category>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    categoryCollection = firestore.collection('category');
    fetchCategory();
  }

  Future<void> addCategory() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      DocumentReference doc = categoryCollection.doc();
      Category category = Category(
        id: doc.id,
        name: categoryNameCtrl.text.trim(),
        type: selectedType.value,
        userId: currentUser.uid,
      );

      await doc.set(category.toJson());

      Get.snackbar("Success", "Category added successfully", colorText: TColor.line);

      categoryNameCtrl.clear();
      selectedType.value = '';
      await fetchCategory();
    } catch (e) {
      Get.snackbar("Error", "Failed to add category: $e", colorText: TColor.secondary);
    }
  }

  Future<void> fetchCategory() async {
    try {
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      QuerySnapshot snapshot = await categoryCollection
          .where("userId", isEqualTo: currentUser.uid)
          .get();

      final List<Category> categories = snapshot.docs.map((doc) {
        return Category.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      categoryList.assignAll(categories);

      print("Fetched ${categoryList.length} categories");
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e", colorText: TColor.secondary);
    } finally {
      update();
    }
  }

  //filter category by name
  Future<void> filterCategoryByName(String name) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      QuerySnapshot snapshot = await categoryCollection
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final List<Category> filtered = snapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .where((category) =>
          (category.name ?? '').toLowerCase().contains(name.toLowerCase()))
          .toList();

      categoryList.assignAll(filtered);

      update(); // Refresh UI if needed
    } catch (e) {
      Get.snackbar("Error", "Failed to filter categories: $e",
          colorText: TColor.secondary);
    }
  }


}
