// To parse this JSON data, do
//
//     final printerAddressModal = printerAddressModalFromJson(jsonString);

import 'dart:convert';

PrinterAddressModal printerAddressModalFromJson(String str) => PrinterAddressModal.fromJson(json.decode(str));

String printerAddressModalToJson(PrinterAddressModal data) => json.encode(data.toJson());

class PrinterAddressModal {
    int id;
    int showroomId;
    int printerTypeId;
    String address;
    String status;
    DateTime createdAt;
    String printerTypeName;
    String showroomName;

    PrinterAddressModal({
        required this.id,
        required this.showroomId,
        required this.printerTypeId,
        required this.address,
        required this.status,
        required this.createdAt,
        required this.printerTypeName,
        required this.showroomName,
    });

    factory PrinterAddressModal.fromJson(Map<String, dynamic> json) => PrinterAddressModal(
        showroomId: json["showroom_id"],
        printerTypeId: json["printer_type_id"],
        address: json["address"],
        status: json["status"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        printerTypeName: json["printer_type_name"],
        showroomName: json["showroom_name"],
    );

    Map<String, dynamic> toJson() => {
        "showroom_id": showroomId,
        "printer_type_id": printerTypeId,
        "address": address,
        "status": status,
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "printer_type_name": printerTypeName,
        "showroom_name": showroomName,
    };
}
