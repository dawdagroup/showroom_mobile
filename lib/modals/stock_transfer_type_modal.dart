// To parse this JSON data, do
//
//     final stockTransferTypeModal = stockTransferTypeModalFromJson(jsonString);

import 'dart:convert';

StockTransferTypeModal stockTransferTypeModalFromJson(String str) => StockTransferTypeModal.fromJson(json.decode(str));

String stockTransferTypeModalToJson(StockTransferTypeModal data) => json.encode(data.toJson());

class StockTransferTypeModal {
    String status;
    String name;
    int id;
    DateTime createdAt;

    StockTransferTypeModal({
        required this.status,
        required this.name,
        required this.id,
        required this.createdAt,
    });

    factory StockTransferTypeModal.fromJson(Map<String, dynamic> json) => StockTransferTypeModal(
        status: json["status"],
        name: json["name"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "name": name,
        "id": id,
        "created_at": createdAt.toIso8601String(),
    };
}
