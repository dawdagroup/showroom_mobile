// To parse this JSON data, do
//
//     final printerLayoutModal = printerLayoutModalFromJson(jsonString);

import 'dart:convert';

PrinterLayoutModal printerLayoutModalFromJson(String str) => PrinterLayoutModal.fromJson(json.decode(str));

String printerLayoutModalToJson(PrinterLayoutModal data) => json.encode(data.toJson());

class PrinterLayoutModal {
    String name;
    dynamic layout;
    int id;
    DateTime createdAt;
    String status;

    PrinterLayoutModal({
        required this.name,
        required this.layout,
        required this.id,
        required this.createdAt,
        required this.status,
    });

    factory PrinterLayoutModal.fromJson(Map<String, dynamic> json) => PrinterLayoutModal(
        name: json["name"],
        layout: json["layout"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "layout": layout,
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "status": status,
    };
}
