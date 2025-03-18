// To parse this JSON data, do
//
//     final regionModal = regionModalFromJson(jsonString);

import 'dart:convert';

RegionModal regionModalFromJson(String str) => RegionModal.fromJson(json.decode(str));

String regionModalToJson(RegionModal data) => json.encode(data.toJson());

class RegionModal {
    String name;
    int id;
    String status;
    DateTime createdAt;

    RegionModal({
        required this.name,
        required this.id,
        required this.status,
        required this.createdAt,
    });

    factory RegionModal.fromJson(Map<String, dynamic> json) => RegionModal(
        name: json["name"],
        id: json["id"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "status": status,
        "created_at": createdAt.toIso8601String(),
    };

  @override
  String toString() {
    return name;
  }
}
