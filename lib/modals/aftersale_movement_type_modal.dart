// To parse this JSON data, do
//
//     final aftersalesMovementTypeModal = aftersalesMovementTypeModalFromJson(jsonString);

import 'dart:convert';

AftersalesMovementTypeModal aftersalesMovementTypeModalFromJson(String str) => AftersalesMovementTypeModal.fromJson(json.decode(str));

String aftersalesMovementTypeModalToJson(AftersalesMovementTypeModal data) => json.encode(data.toJson());

class AftersalesMovementTypeModal {
    int id;
    dynamic name;
    DateTime createdAt;

    AftersalesMovementTypeModal({
        required this.name,
        required this.id,
        required this.createdAt,
    });

    factory AftersalesMovementTypeModal.fromJson(Map<String, dynamic> json) => AftersalesMovementTypeModal(
        name: json["name"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "created_at": createdAt.toIso8601String(),
    };

    
  @override
  String toString() {
    return name;
  }
}
