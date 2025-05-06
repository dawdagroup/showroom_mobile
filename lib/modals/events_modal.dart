// To parse this JSON data, do
//
//     final eventsModal = eventsModalFromJson(jsonString);

import 'dart:convert';

EventsModal eventsModalFromJson(String str) => EventsModal.fromJson(json.decode(str));

String eventsModalToJson(EventsModal data) => json.encode(data.toJson());

class EventsModal {
    int id;
    String eventCode;
    String eventName;
    String status;
    DateTime startDate;
    DateTime endDate;
    DateTime createdAt;
    int createdBy;

    EventsModal({
        required this.eventCode,
        required this.eventName,
        required this.status,
        required this.startDate,
        required this.endDate,
        required this.id,
        required this.createdAt,
        required this.createdBy,
    });

    factory EventsModal.fromJson(Map<String, dynamic> json) => EventsModal(
        eventCode: json["event_code"],
        eventName: json["event_name"],
        status: json["status"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
    );

    Map<String, dynamic> toJson() => {
        "event_code": eventCode,
        "event_name": eventName,
        "status": status,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "created_by": createdBy,
    };
}
