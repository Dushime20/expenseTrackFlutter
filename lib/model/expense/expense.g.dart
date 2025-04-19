// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      id: json['id'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      userId: json['userId'] as String?,
      categoryId: json['categoryId'] as String?,
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'date': instance.date?.toIso8601String(),
      'userId': instance.userId,
      'categoryId': instance.categoryId,
    };
