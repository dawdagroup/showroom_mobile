// To parse this JSON data, do
//
//     final showroomModal = showroomModalFromJson(jsonString);

import 'dart:convert';

ShowroomModal showroomModalFromJson(String str) => ShowroomModal.fromJson(json.decode(str));

String showroomModalToJson(ShowroomModal data) => json.encode(data.toJson());

class ShowroomModal {
    dynamic name;
    dynamic regionId;
    dynamic showroom_id;
    dynamic status;

    ShowroomModal({
        required this.name,
        required this.regionId,
        required this.showroom_id,
        required this.status,
    });

    factory ShowroomModal.fromJson(Map<String, dynamic> json) => ShowroomModal(
        name: json["name"],
        regionId: json["region_id"],
        showroom_id: json["showroom_id"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "region_id": regionId,
        "id": showroom_id,
        "status": status,
    };
}
