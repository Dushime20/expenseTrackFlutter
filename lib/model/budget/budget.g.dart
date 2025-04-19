// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
      id: json['id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      categoryId: json['categoryId'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'categoryId': instance.categoryId,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'userId': instance.userId,
    };
