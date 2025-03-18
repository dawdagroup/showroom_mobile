// To parse this JSON data, do
//
//     final zoneModal = zoneModalFromJson(jsonString);

import 'dart:convert';

ZoneModal zoneModalFromJson(String str) => ZoneModal.fromJson(json.decode(str));

String zoneModalToJson(ZoneModal data) => json.encode(data.toJson());

class ZoneModal {
    String name;
    int regionId;
    int id;
    String status;
    DateTime createdAt;

    ZoneModal({
        required this.name,
        required this.regionId,
        required this.id,
        required this.status,
        required this.createdAt,
    });

    factory ZoneModal.fromJson(Map<String, dynamic> json) => ZoneModal(
        name: json["name"],
        regionId: json["region_id"],
        id: json["id"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "region_id": regionId,
        "id": id,
        "status": status,
        "created_at": createdAt.toIso8601String(),
    };

  @override
  String toString() {
    return name;
  }
}
