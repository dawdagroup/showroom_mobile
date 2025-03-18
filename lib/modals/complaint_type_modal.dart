// To parse this JSON data, do
//
//     final complaintTypeModal = complaintTypeModalFromJson(jsonString);

import 'dart:convert';

ComplaintTypeModal complaintTypeModalFromJson(String str) => ComplaintTypeModal.fromJson(json.decode(str));

String complaintTypeModalToJson(ComplaintTypeModal data) => json.encode(data.toJson());

class ComplaintTypeModal {
    String name;
    String status;
    int id;
    DateTime createdAt;

    ComplaintTypeModal({
        required this.name,
        required this.status,
        required this.id,
        required this.createdAt,
    });

    factory ComplaintTypeModal.fromJson(Map<String, dynamic> json) => ComplaintTypeModal(
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

    @override
    String toString() {
        return name;
    }
}
