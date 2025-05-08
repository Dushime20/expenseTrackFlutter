
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'income.g.dart';
@JsonSerializable()
class Income{

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


  Income( {
  required this.id,
  required this.name,
  required this.amount,
  required this.date,
  required this.userId,

});

  // From JSON: Convert Timestamp to DateTime
  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: (json['date'] as Timestamp?)?.toDate(),  // Convert Timestamp to DateTime
      userId: json['userId'] as String?,
     // ADDED userId parsing
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

    };
  }

}