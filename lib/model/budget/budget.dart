import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "amount")
  final double? amount;

  @JsonKey(name: "categoryId")
  final String? categoryId;

  @JsonKey(name: "startDate")
  final DateTime? startDate;

  @JsonKey(name: "endDate")
  final DateTime? endDate;

  @JsonKey(name: "userId")
  final String? userId;

  Budget({
    required this.id,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.categoryId,
    required this.userId,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      startDate: (json['startDate'] as Timestamp?)?.toDate(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      categoryId: json['categoryId'] as String?,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'startDate': startDate,
      'endDate': endDate,
      'categoryId': categoryId,
      'userId': userId,
    };
  }
}
