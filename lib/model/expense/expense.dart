import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "category")
  final String? category;

  @JsonKey(name: "amount")
  final double? amount;

  @JsonKey(name: "date")
  final DateTime? date;

  @JsonKey(name: "userId") // ADDED userId field
  final String? userId;


  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.userId,

  });

  // From JSON: Convert Timestamp to DateTime
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String?,
      category: json['category'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: (json['date'] as Timestamp?)?.toDate(),  // Convert Timestamp to DateTime
      userId: json['userId'] as String?,

    );
  }

  // To JSON: Firestore expects DateTime as a Timestamp
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date,           // Firestore will convert DateTime to Timestamp
      'userId': userId,

    };
  }
}
