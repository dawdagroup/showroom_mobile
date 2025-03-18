// To parse this JSON data, do
//
//     final townModal = townModalFromJson(jsonString);

import 'dart:convert';

TownModal townModalFromJson(String str) => TownModal.fromJson(json.decode(str));

String townModalToJson(TownModal data) => json.encode(data.toJson());

class TownModal {
    String name;
    int zoneId;
    int id;
    String status;
    DateTime createdAt;

    TownModal({
        required this.name,
        required this.zoneId,
        required this.id,
        required this.status,
        required this.createdAt,
    });

    factory TownModal.fromJson(Map<String, dynamic> json) => TownModal(
        name: json["name"],
        zoneId: json["zone_id"],
        id: json["id"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "zone_id": zoneId,
        "id": id,
        "status": status,
        "created_at": createdAt.toIso8601String(),
    };

  @override
  String toString() {
    return name;
  }
}
