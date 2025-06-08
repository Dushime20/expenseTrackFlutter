import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:untitled/model/Saving/saving.dart';


class SavingController extends GetxController {
  var saving = <SavingModel>[].obs;
  var isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'saving';

  @override
  void onInit() {
    super.onInit();
    loadsavingFromFirebase();
  }

  // ✅ Load saving
  Future<void> loadsavingFromFirebase() async {
    try {
      isLoading.value = true;

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('savedDate', descending: true)
          .get();

      final loaded = querySnapshot.docs
          .map((doc) => SavingModel.fromFirestore(doc))
          .toList();

      saving.value = loaded;
    } catch (e) {
      print('Failed to load saving: $e');
    } finally {
      isLoading.value = false;
    }
  }



// Future<void> addSaving({
//   required String category,
//   required double amount,
// }) async {
//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       print("User not logged in");
//       return;
//     }

//     final savingCollection = FirebaseFirestore.instance.collection('saving');

//     final now = DateTime.now();
//     final startOfMonth = DateTime(now.year, now.month, 1);
//     final endOfMonth = DateTime(now.year, now.month + 1, 0);

//     final existing = await savingCollection
//         .where('userId', isEqualTo: user.uid)
//         .where('category', isEqualTo: category)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
//         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
//         .get();

//     if (existing.docs.isNotEmpty) {
//       print("Saving already exists for category: $category this month");
//       return;
//     }

//     await savingCollection.add({
//       'userId': user.uid,
//       'category': category,
//       'amount': amount,
//       'date': Timestamp.now(),
//     });

//     print("Saving added for category: $category");
//   } catch (e) {
//     print("Error adding saving: $e");
//   }
// }


Future<void> updateSaving({
  required String categoryId,
  required double newAmount,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    final savingCollection = _firestore.collection(_collectionName);

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final querySnapshot = await savingCollection
        .where('userId', isEqualTo: user.uid)
        .where('categoryId', isEqualTo: categoryId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update the first matching saving document
      final docId = querySnapshot.docs.first.id;
      await savingCollection.doc(docId).update({
        'amount': newAmount,
        'date': Timestamp.now(),
      });
      print("Saving updated for categoryId: $categoryId");
    } else {
      // If no existing saving, add a new one
      await savingCollection.add({
        'userId': user.uid,
        'categoryId': categoryId,
        'amount': newAmount,
        'date': Timestamp.now(),
      });
      print("New saving added for categoryId: $categoryId");
    }
  } catch (e) {
    print("Error updating saving: $e");
  }
}

}


