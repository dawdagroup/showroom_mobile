// To parse this JSON data, do
//
//     final invoiceModal = invoiceModalFromJson(jsonString);

import 'dart:convert';

InvoiceModal invoiceModalFromJson(String str) => InvoiceModal.fromJson(json.decode(str));

String invoiceModalToJson(InvoiceModal data) => json.encode(data.toJson());

class InvoiceModal {
    dynamic invoiceStatus;
    dynamic cardCode;
    dynamic cardName;
    dynamic address;
    dynamic docEntry;
    dynamic invoiceNumber;
    DateTime invoiceDate;
    dynamic warehouseCode;
    dynamic warehouseName;
    dynamic deliveryLocation;
    dynamic customerName;
    dynamic customerPhoneNo;
    dynamic customerEmail;
    double invoiceTotal;
    dynamic servedBy;
    dynamic fiscalizationNumber;
    dynamic cuSerial;
    dynamic qrCodeLink;
    dynamic cuDate;
    dynamic customerKraPin;

    InvoiceModal({
        required this.invoiceStatus,
        required this.cardCode,
        required this.cardName,
        required this.address,
        required this.docEntry,
        required this.invoiceNumber,
        required this.invoiceDate,
        required this.warehouseCode,
        required this.warehouseName,
        required this.deliveryLocation,
        required this.customerName,
        required this.customerPhoneNo,
        required this.customerEmail,
        required this.invoiceTotal,
        required this.servedBy,
        required this.fiscalizationNumber,
        required this.cuSerial,
        required this.qrCodeLink,
        required this.cuDate,
        required this.customerKraPin,
    });

    factory InvoiceModal.fromJson(Map<String, dynamic> json) => InvoiceModal(
        invoiceStatus: json["invoiceStatus"],
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        address: json["address"],
        docEntry: json["docEntry"],
        invoiceNumber: json["invoiceNumber"],
        invoiceDate: DateTime.parse(json["invoiceDate"]),
        warehouseCode: json["warehouseCode"],
        warehouseName: json["warehouseName"],
        deliveryLocation: json["deliveryLocation"],
        customerName: json["customerName"],
        customerPhoneNo: json["customerPhoneNo"],
        customerEmail: json["customerEmail"],
        invoiceTotal: json["invoiceTotal"]?.toDouble(),
        servedBy: json["servedBy"],
        fiscalizationNumber: json["fiscalizationNumber"],
        cuSerial: json["cuSerial"],
        qrCodeLink: json["qrCodeLink"],
        cuDate: json["cuDate"],
        customerKraPin: json["customerKraPin"],
    );

    Map<String, dynamic> toJson() => {
        "invoiceStatus": invoiceStatus,
        "cardCode": cardCode,
        "cardName": cardName,
        "address": address,
        "docEntry": docEntry,
        "invoiceNumber": invoiceNumber,
        "invoiceDate": "${invoiceDate.year.toString().padLeft(4, '0')}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}",
        "warehouseCode": warehouseCode,
        "warehouseName": warehouseName,
        "deliveryLocation": deliveryLocation,
        "customerName": customerName,
        "customerPhoneNo": customerPhoneNo,
        "customerEmail": customerEmail,
        "invoiceTotal": invoiceTotal,
        "servedBy": servedBy,
        "fiscalizationNumber": fiscalizationNumber,
        "cuSerial": cuSerial,
        "qrCodeLink": qrCodeLink,
        "cuDate": cuDate,
        "customerKraPin": customerKraPin,
    };
}
