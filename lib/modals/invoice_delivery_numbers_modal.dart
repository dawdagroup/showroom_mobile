// To parse this JSON data, do
//
//     final invoiceDeliveryNotesModal = invoiceDeliveryNotesModalFromJson(jsonString);

import 'dart:convert';

InvoiceDeliveryNotesModal invoiceDeliveryNotesModalFromJson(String str) => InvoiceDeliveryNotesModal.fromJson(json.decode(str));

String invoiceDeliveryNotesModalToJson(InvoiceDeliveryNotesModal data) => json.encode(data.toJson());

class InvoiceDeliveryNotesModal {
    dynamic deliveryDocEntry;
    dynamic deliveryNumber;
    dynamic invoiceNumber;
    DateTime deliveryDate;
    String createdBy;

    InvoiceDeliveryNotesModal({
        required this.deliveryDocEntry,
        required this.deliveryNumber,
        required this.invoiceNumber,
        required this.deliveryDate,
        required this.createdBy,
    });

    factory InvoiceDeliveryNotesModal.fromJson(Map<String, dynamic> json) => InvoiceDeliveryNotesModal(
        deliveryDocEntry: json["deliveryDocEntry"],
        deliveryNumber: json["deliveryNumber"],
        invoiceNumber: json["invoiceNumber"],
        deliveryDate: DateTime.parse(json["deliveryDate"]),
        createdBy: json["createdBy"],
    );

    Map<String, dynamic> toJson() => {
        "deliveryDocEntry": deliveryDocEntry,
        "deliveryNumber": deliveryNumber,
        "invoiceNumber": invoiceNumber,
        "deliveryDate": deliveryDate.toIso8601String(),
        "createdBy": createdBy,
    };
}
