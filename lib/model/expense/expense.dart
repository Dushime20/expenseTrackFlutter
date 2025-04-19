import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "name")
  final String? name;

  @JsonKey(name: "amount")
  final double? amount;

  @JsonKey(name: "date")
  final DateTime? date;

  @JsonKey(name: "userId") // ADDED userId field
  final String? userId;
  @JsonKey(name: "categoryId") // ADDED userId field
  final String? categoryId;//  ADDED userId field

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.userId,
    required this.categoryId,
    // ADDED userId to constructor
  });

  // From JSON: Convert Timestamp to DateTime
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: (json['date'] as Timestamp?)?.toDate(),  // Convert Timestamp to DateTime
      userId: json['userId'] as String?,
      categoryId: json['categoryId'] as String?,// ADDED userId parsing
    );
  }

  // To JSON: Firestore expects DateTime as a Timestamp
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date,           // Firestore will convert DateTime to Timestamp
      'userId': userId,
      'categoryId': categoryId,//  ADDED userId to JSON output
    };
  }
}
