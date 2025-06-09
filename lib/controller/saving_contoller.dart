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

  // // ✅ Load saving
  // Future<void> loadsavingFromFirebase() async {
  //   try {
  //     isLoading.value = true;

  //     final querySnapshot = await _firestore
  //         .collection(_collectionName)
  //         .orderBy('savedDate', descending: true)
  //         .get();

  //     final loaded = querySnapshot.docs
  //         .map((doc) => SavingModel.fromFirestore(doc))
  //         .toList();

  //     saving.value = loaded;
  //   } catch (e) {
  //     print('Failed to load saving: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }


// In your SavingController
Future<void> loadsavingFromFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    print('No user logged in');
    return;
  }
  
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('saving')
        .where('userId', isEqualTo: user.uid) // Changed from user to user.uid
        .get();
    
    List<SavingModel> loadedSavings = querySnapshot.docs
        .map((doc) => SavingModel.fromFirestore(doc))
        .toList();
    
    saving.value = loadedSavings;
    print('Loaded ${loadedSavings.length} savings'); // Add this for debugging
    
  } catch (e) {
    print('Error loading savings: $e');
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


  // Add these methods to your existing SavingController class

// Method to update saving amount after spending from savings
Future<bool> updateSavingAmountAfterSpending(String categoryId, double spentAmount) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in");
      return false;
    }

    final savingCollection = _firestore.collection(_collectionName);
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final querySnapshot = await savingCollection
        .where('userId', isEqualTo: user.uid)
        .where('categoryId', isEqualTo: categoryId)
        .where('savedDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('savedDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final currentAmount = doc.data()['amount'] as double;
      final newAmount = currentAmount - spentAmount;
      
      if (newAmount < 0) {
        print("Insufficient savings amount");
        return false;
      }

      // Update the saving amount
      await savingCollection.doc(doc.id).update({
        'amount': newAmount,
        'savedDate': Timestamp.now(),
      });

      // Refresh local data
      await loadsavingFromFirebase();
      
      print("Saving updated. New amount: $newAmount");
      return true;
    } else {
      print("No saving found for categoryId: $categoryId");
      return false;
    }
  } catch (e) {
    print("Error updating saving amount: $e");
    return false;
  }
}

// Method to get available savings for current month
List<Map<String, dynamic>> get currentMonthSavings {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  
  return saving.where((savingModel) {
    final savedDate = savingModel.date;
    return savedDate.isAfter(startOfMonth) && savedDate.isBefore(endOfMonth);
  }).map((savingModel) {
    return {
      'id': savingModel.id,
      'categoryId': savingModel.categoryId,
      'categoryName': savingModel.categoryName,
      'amount': savingModel.amount,
      'savedDate': savingModel.date,
    };
  }).toList();
}

// Method to get specific saving by categoryId
SavingModel? getSavingByCategoryId(String categoryId) {
  try {
    return saving.firstWhere((savingModel) => savingModel.categoryId == categoryId);
  } catch (e) {
    return null;
  }
}

// Method to check if sufficient amount is available in savings
bool hasSufficientSavings(String categoryId, double requiredAmount) {
  final savingModel = getSavingByCategoryId(categoryId);
  if (savingModel != null) {
    return savingModel.amount >= requiredAmount;
  }
  return false;
}

}


