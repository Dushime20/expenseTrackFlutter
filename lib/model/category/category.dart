import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "name")
  final String? name;

  @JsonKey(name: "type")
  final String? type;
  @JsonKey(name: "userId")
  final String? userId;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'userId':userId,
    };
  }
}
