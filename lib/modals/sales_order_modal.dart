// To parse this JSON data, do
//
//     final salesOrderModal = salesOrderModalFromJson(jsonString);

import 'dart:convert';

SalesOrderModal salesOrderModalFromJson(String str) => SalesOrderModal.fromJson(json.decode(str));

String salesOrderModalToJson(SalesOrderModal data) => json.encode(data.toJson());

class SalesOrderModal {
    dynamic docEntry;
    dynamic saleOrderNumber;
    dynamic documentStatus;
    dynamic inventoryStatus;
    DateTime documentDate;
    dynamic cardCode;
    dynamic cardName;
    dynamic address;
    dynamic docTotal;
    dynamic approvalStatus;
    dynamic customerName;
    dynamic customerPhone;
    dynamic customerEmail;
    dynamic customerIdNo;
    dynamic customerKraPin;

    SalesOrderModal({
        required this.docEntry,
        required this.saleOrderNumber,
        required this.documentStatus,
        required this.inventoryStatus,
        required this.documentDate,
        required this.cardCode,
        required this.cardName,
        required this.address,
        required this.docTotal,
        required this.approvalStatus,
        required this.customerName,
        required this.customerPhone,
        required this.customerEmail,
        required this.customerIdNo,
        required this.customerKraPin,
    });

    factory SalesOrderModal.fromJson(Map<String, dynamic> json) => SalesOrderModal(
        docEntry: json["docEntry"],
        saleOrderNumber: json["saleOrderNumber"],
        documentStatus: json["documentStatus"],
        inventoryStatus: json["inventoryStatus"],
        documentDate: DateTime.parse(json["documentDate"]),
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        address: json["address"],
        docTotal: json["docTotal"],
        approvalStatus: json["approvalStatus"],
        customerName: json["customerName"],
        customerPhone: json["customerPhone"],
        customerEmail: json["customerEmail"],
        customerIdNo: json["customerIdNo"],
        customerKraPin: json["customerKraPin"],
    );

    Map<String, dynamic> toJson() => {
        "docEntry": docEntry,
        "saleOrderNumber": saleOrderNumber,
        "documentStatus": documentStatus,
        "inventoryStatus": inventoryStatus,
        "documentDate": "${documentDate.year.toString().padLeft(4, '0')}-${documentDate.month.toString().padLeft(2, '0')}-${documentDate.day.toString().padLeft(2, '0')}",
        "cardCode": cardCode,
        "cardName": cardName,
        "address": address,
        "docTotal": docTotal,
        "approvalStatus": approvalStatus,
        "customerName": customerName,
        "customerPhone": customerPhone,
        "customerEmail": customerEmail,
        "customerIdNo": customerIdNo,
        "customerKraPin": customerKraPin,
    };
}
