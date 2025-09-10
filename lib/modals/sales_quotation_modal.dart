// To parse this JSON data, do
//
//     final salesQuotationModal = salesQuotationModalFromJson(jsonString);

import 'dart:convert';

SalesQuotationModal salesQuotationModalFromJson(String str) => SalesQuotationModal.fromJson(json.decode(str));

String salesQuotationModalToJson(SalesQuotationModal data) => json.encode(data.toJson());

class SalesQuotationModal {
    dynamic salesOrderId;
    dynamic salesOrderRef;
    DateTime salesOrderDate;
    dynamic cardCode;
    dynamic cardName;
    dynamic warehouseName;
    dynamic driverName;
    dynamic driverContact;
    dynamic warehouseCode;
    dynamic uTruckNo;
    dynamic transapoterName;
    dynamic customerName;
    dynamic customerPhoneNo;
    dynamic customerEmail;
    dynamic customerIdNo;
    dynamic amountReceved;
    dynamic docTotal;
    dynamic change;
    dynamic deliveryLocation;
    dynamic customerKraPin;
    dynamic createdBy;

    SalesQuotationModal({
        required this.salesOrderId,
        required this.salesOrderRef,
        required this.salesOrderDate,
        required this.cardCode,
        required this.cardName,
        required this.warehouseName,
        required this.driverName,
        required this.driverContact,
        required this.warehouseCode,
        required this.uTruckNo,
        required this.transapoterName,
        required this.customerName,
        required this.customerPhoneNo,
        required this.customerEmail,
        required this.customerIdNo,
        required this.amountReceved,
        required this.docTotal,
        required this.change,
        required this.deliveryLocation,
        required this.customerKraPin,
        required this.createdBy,
    });

    factory SalesQuotationModal.fromJson(Map<String, dynamic> json) => SalesQuotationModal(
        salesOrderId: json["salesOrderId"],
        salesOrderRef: json["salesOrderRef"],
        salesOrderDate: DateTime.parse(json["salesOrderDate"]),
        cardCode: json["CardCode"],
        cardName: json["CardName"],
        warehouseName: json["warehouseName"],
        driverName: json["driverName"],
        driverContact: json["driverContact"],
        warehouseCode: json["warehouseCode"],
        uTruckNo: json["U_TruckNo"],
        transapoterName: json["transapoterName"],
        customerName: json["customerName"],
        customerPhoneNo: json["customerPhoneNo"],
        customerEmail: json["customerEmail"],
        customerIdNo: json["customerIdNo"],
        amountReceved: json["amountReceved"],
        docTotal: json["docTotal"],
        change: json["change"],
        deliveryLocation: json["deliveryLocation"],
        customerKraPin: json["customerKraPin"],
        createdBy: json["createdBy"],
    );

    Map<String, dynamic> toJson() => {
        "salesOrderId": salesOrderId,
        "salesOrderRef": salesOrderRef,
        "salesOrderDate": salesOrderDate.toIso8601String(),
        "CardCode": cardCode,
        "CardName": cardName,
        "warehouseName": warehouseName,
        "driverName": driverName,
        "driverContact": driverContact,
        "warehouseCode": warehouseCode,
        "U_TruckNo": uTruckNo,
        "transapoterName": transapoterName,
        "customerName": customerName,
        "customerPhoneNo": customerPhoneNo,
        "customerEmail": customerEmail,
        "customerIdNo": customerIdNo,
        "amountReceved": amountReceved,
        "docTotal": docTotal,
        "change": change,
        "deliveryLocation": deliveryLocation,
        "customerKraPin": customerKraPin,
        "createdBy": createdBy,
    };
}
