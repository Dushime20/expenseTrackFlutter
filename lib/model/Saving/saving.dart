import 'package:cloud_firestore/cloud_firestore.dart';

class SavingModel {
  final String id;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String userId;

  SavingModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.userId,
  });

  factory SavingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }
}
