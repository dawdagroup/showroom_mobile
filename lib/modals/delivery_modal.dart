// To parse this JSON data, do
//
//     final deliveryModal = deliveryModalFromJson(jsonString);

import 'dart:convert';

DeliveryModal deliveryModalFromJson(String str) => DeliveryModal.fromJson(json.decode(str));

String deliveryModalToJson(DeliveryModal data) => json.encode(data.toJson());

class DeliveryModal {
    dynamic docEntry;
    dynamic deliveryNumber;
    dynamic inventoryStatus;
    dynamic documentStatus;
    dynamic cardCode;
    dynamic cardName;
    dynamic vatPercent;
    dynamic vatSum;
    dynamic totalAmount;
    DateTime docDate;
    dynamic warehouseCode;
    dynamic warehouseName;
    dynamic driverName;
    dynamic driverContact;
    dynamic truckNumber;
    dynamic tripName;
    dynamic customerName;
    dynamic customerPhoneNo;
    dynamic customerEmail;
    dynamic customerIdNo;
    dynamic deliveryLocation;

    DeliveryModal({
        required this.docEntry,
        required this.deliveryNumber,
        required this.inventoryStatus,
        required this.documentStatus,
        required this.cardCode,
        required this.cardName,
        required this.vatPercent,
        required this.vatSum,
        required this.totalAmount,
        required this.docDate,
        required this.warehouseCode,
        required this.warehouseName,
        required this.driverName,
        required this.driverContact,
        required this.truckNumber,
        required this.tripName,
        required this.customerName,
        required this.customerPhoneNo,
        required this.customerEmail,
        required this.customerIdNo,
        required this.deliveryLocation,
    });

    factory DeliveryModal.fromJson(Map<String, dynamic> json) => DeliveryModal(
        docEntry: json["docEntry"],
        deliveryNumber: json["deliveryNumber"],
        inventoryStatus: json["inventoryStatus"],
        documentStatus: json["documentStatus"],
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        vatPercent: json["vatPercent"],
        vatSum: json["vatSum"]?.toDouble(),
        totalAmount: json["totalAmount"]?.toDouble(),
        docDate: DateTime.parse(json["docDate"]),
        warehouseCode: json["warehouseCode"],
        warehouseName: json["warehouseName"],
        driverName: json["driverName"],
        driverContact: json["driverContact"],
        truckNumber: json["truckNumber"],
        tripName: json["tripName"],
        customerName: json["customerName"],
        customerPhoneNo: json["customerPhoneNo"],
        customerEmail: json["customerEmail"],
        customerIdNo: json["customerIdNo"],
        deliveryLocation: json["deliveryLocation"],
    );

    Map<String, dynamic> toJson() => {
        "docEntry": docEntry,
        "deliveryNumber": deliveryNumber,
        "inventoryStatus": inventoryStatus,
        "documentStatus": documentStatus,
        "cardCode": cardCode,
        "cardName": cardName,
        "vatPercent": vatPercent,
        "vatSum": vatSum,
        "totalAmount": totalAmount,
        "docDate": "${docDate.year.toString().padLeft(4, '0')}-${docDate.month.toString().padLeft(2, '0')}-${docDate.day.toString().padLeft(2, '0')}",
        "warehouseCode": warehouseCode,
        "warehouseName": warehouseName,
        "driverName": driverName,
        "driverContact": driverContact,
        "truckNumber": truckNumber,
        "tripName": tripName,
        "customerName": customerName,
        "customerPhoneNo": customerPhoneNo,
        "customerEmail": customerEmail,
        "customerIdNo": customerIdNo,
        "deliveryLocation": deliveryLocation,
    };
}
