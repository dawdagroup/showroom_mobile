// To parse this JSON data, do
//
//     final loyaltyClassModal = loyaltyClassModalFromJson(jsonString);

import 'dart:convert';

LoyaltyClassModal loyaltyClassModalFromJson(String str) => LoyaltyClassModal.fromJson(json.decode(str));

String loyaltyClassModalToJson(LoyaltyClassModal data) => json.encode(data.toJson());

class LoyaltyClassModal {
    String name;
    String description;
    dynamic minPoints;
    dynamic discountPercentage;
    String status;
    dynamic id;
    DateTime createdAt;

    LoyaltyClassModal({
        required this.name,
        required this.description,
        required this.minPoints,
        required this.discountPercentage,
        required this.status,
        required this.id,
        required this.createdAt,
    });

    factory LoyaltyClassModal.fromJson(Map<String, dynamic> json) => LoyaltyClassModal(
        name: json["name"],
        description: json["description"],
        minPoints: json["min_points"],
        discountPercentage: json["discount_percentage"],
        status: json["status"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "min_points": minPoints,
        "discount_percentage": discountPercentage,
        "status": status,
        "id": id,
        "created_at": createdAt.toIso8601String(),
    };
}
