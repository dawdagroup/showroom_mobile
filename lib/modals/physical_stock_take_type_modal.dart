// To parse this JSON data, do
//
//     final physicalStockTakeTypeModal = physicalStockTakeTypeModalFromJson(jsonString);

import 'dart:convert';

PhysicalStockTakeTypeModal physicalStockTakeTypeModalFromJson(String str) => PhysicalStockTakeTypeModal.fromJson(json.decode(str));

String physicalStockTakeTypeModalToJson(PhysicalStockTakeTypeModal data) => json.encode(data.toJson());

class PhysicalStockTakeTypeModal {
    String name;
    String status;
    int id;
    DateTime createdAt;

    PhysicalStockTakeTypeModal({
        required this.name,
        required this.status,
        required this.id,
        required this.createdAt,
    });

    factory PhysicalStockTakeTypeModal.fromJson(Map<String, dynamic> json) => PhysicalStockTakeTypeModal(
        name: json["name"],
        status: json["status"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "id": id,
        "created_at": createdAt.toIso8601String(),
    };
}
