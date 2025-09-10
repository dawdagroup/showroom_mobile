// To parse this JSON data, do
//
//     final salesOrderDeliveryNotesModal = salesOrderDeliveryNotesModalFromJson(jsonString);

import 'dart:convert';

SalesOrderDeliveryNotesModal salesOrderDeliveryNotesModalFromJson(String str) => SalesOrderDeliveryNotesModal.fromJson(json.decode(str));

String salesOrderDeliveryNotesModalToJson(SalesOrderDeliveryNotesModal data) => json.encode(data.toJson());

class SalesOrderDeliveryNotesModal {
    dynamic deliveryDocEntry;
    dynamic deliveryNumber;
    dynamic salesOrderDocEntry;
    dynamic salesOrderNumber;
    DateTime deliveryDate;
    dynamic createdBy;

    SalesOrderDeliveryNotesModal({
        required this.deliveryDocEntry,
        required this.deliveryNumber,
        required this.salesOrderDocEntry,
        required this.salesOrderNumber,
        required this.deliveryDate,
        required this.createdBy,
    });

    factory SalesOrderDeliveryNotesModal.fromJson(Map<String, dynamic> json) => SalesOrderDeliveryNotesModal(
        deliveryDocEntry: json["deliveryDocEntry"],
        deliveryNumber: json["deliveryNumber"],
        salesOrderDocEntry: json["salesOrderDocEntry"],
        salesOrderNumber: json["salesOrderNumber"],
        deliveryDate: DateTime.parse(json["deliveryDate"]),
        createdBy: json["createdBy"],
    );

    Map<String, dynamic> toJson() => {
        "deliveryDocEntry": deliveryDocEntry,
        "deliveryNumber": deliveryNumber,
        "salesOrderDocEntry": salesOrderDocEntry,
        "salesOrderNumber": salesOrderNumber,
        "deliveryDate": deliveryDate.toIso8601String(),
        "createdBy": createdBy,
    };
}
