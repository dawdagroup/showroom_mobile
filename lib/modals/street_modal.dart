// To parse this JSON data, do
//
//     final streetModal = streetModalFromJson(jsonString);

import 'dart:convert';

StreetModal streetModalFromJson(String str) => StreetModal.fromJson(json.decode(str));

String streetModalToJson(StreetModal data) => json.encode(data.toJson());

class StreetModal {
    String name;
    int townId;
    int id;
    String status;
    DateTime createdAt;

    StreetModal({
        required this.name,
        required this.townId,
        required this.id,
        required this.status,
        required this.createdAt,
    });

    factory StreetModal.fromJson(Map<String, dynamic> json) => StreetModal(
        name: json["name"],
        townId: json["town_id"],
        id: json["id"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "town_id": townId,
        "id": id,
        "status": status,
        "created_at": createdAt.toIso8601String(),
    };

  @override
  String toString() {
    return name;
  }
}
