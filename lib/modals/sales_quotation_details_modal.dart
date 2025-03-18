// To parse this JSON data, do
//
//     final salesQuotationDetailsModal = salesQuotationDetailsModalFromJson(jsonString);

import 'dart:convert';

import 'sales_quotation_line_item_modal.dart';

SalesQuotationDetailsModal salesQuotationDetailsModalFromJson(String str) => SalesQuotationDetailsModal.fromJson(json.decode(str));

String salesQuotationDetailsModalToJson(SalesQuotationDetailsModal data) => json.encode(data.toJson());

class SalesQuotationDetailsModal {
    dynamic salesOrderId;
    dynamic salesOrderRef;
    dynamic salesOrderStatus;
    dynamic salesOrderTotal;
    DateTime salesOrderDate;
    String cardCode;
    String cardName;
    dynamic warehouseName;
    dynamic driverName;
    dynamic driverContact;
    dynamic warehouseCode;
    dynamic truckNo;
    dynamic customerName;
    dynamic customerPhoneNumber;
    dynamic customerEmail;
    dynamic customerIdNo;
    dynamic amountReceived;
    dynamic change;
    dynamic deliveryLocation;
    dynamic docType;
    dynamic customerKraPin;
    dynamic fiscalizationNumber;
    dynamic cuSerial;
    dynamic kraQrCode;
    dynamic fiscalizationStatus;
    dynamic fiscalizationDate;
    dynamic createdBy;
    List<SalesQuotationLineItemModal> lineItems;

    SalesQuotationDetailsModal({
        required this.salesOrderId,
        required this.salesOrderRef,
        required this.salesOrderDate,
        required this.salesOrderStatus,
        required this.salesOrderTotal,
        required this.cardCode,
        required this.cardName,
        required this.warehouseName,
        required this.driverName,
        required this.driverContact,
        required this.warehouseCode,
        required this.truckNo,
        required this.customerName,
        required this.customerPhoneNumber,
        required this.customerEmail,
        required this.customerIdNo,
        required this.amountReceived,
        required this.change,
        required this.deliveryLocation,
        required this.docType,
        required this.customerKraPin,
        required this.fiscalizationNumber,
        required this.cuSerial,
        required this.kraQrCode,
        required this.fiscalizationStatus,
        required this.fiscalizationDate,
        required this.createdBy,
        required this.lineItems,
    });

    factory SalesQuotationDetailsModal.fromJson(Map<String, dynamic> json) => SalesQuotationDetailsModal(
        salesOrderId: json["salesOrderId"],
        salesOrderRef: json["salesOrderRef"],
        salesOrderDate: DateTime.parse(json["salesOrderDate"]),
        salesOrderStatus: json["salesOrderStatus"],
        salesOrderTotal: json["salesOrderTotal"],
        cardCode: json["CardCode"],
        cardName: json["CardName"],
        warehouseName: json["warehouseName"],
        driverName: json["driverName"],
        driverContact: json["driverContact"],
        warehouseCode: json["warehouseCode"],
        truckNo: json["truckNo"],
        customerName: json["customerName"],
        customerPhoneNumber: json["customerPhoneNumber"],
        customerEmail: json["customerEmail"],
        customerIdNo: json["customerIdNo"],
        amountReceived: json["amountReceived"],
        change: json["change"],
        deliveryLocation: json["deliveryLocation"],
        docType: json["docType"],
        customerKraPin: json["customerKraPin"],
        fiscalizationNumber: json["fiscalizationNumber"],
        cuSerial: json["cuSerial"],
        kraQrCode: json["kraQrCode"],
        fiscalizationStatus: json["fiscalizationStatus"],
        fiscalizationDate: json["fiscalizationDate"],
        createdBy: json["createdBy"],
        lineItems: List<SalesQuotationLineItemModal>.from(json["lineItems"].map((x) => SalesQuotationLineItemModal.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "salesOrderId": salesOrderId,
        "salesOrderRef": salesOrderRef,
        "salesOrderDate": salesOrderDate.toIso8601String(),
        "salesOrderStatus": salesOrderStatus,
        "salesOrderTotal": salesOrderTotal,
        "CardCode": cardCode,
        "CardName": cardName,
        "warehouseName": warehouseName,
        "driverName": driverName,
        "driverContact": driverContact,
        "warehouseCode": warehouseCode,
        "truckNo": truckNo,
        "customerName": customerName,
        "customerPhoneNumber": customerPhoneNumber,
        "customerEmail": customerEmail,
        "customerIdNo": customerIdNo,
        "amountReceived": amountReceived,
        "change": change,
        "deliveryLocation": deliveryLocation,
        "docType": docType,
        "customerKraPin": customerKraPin,
        "fiscalizationNumber": fiscalizationNumber,
        "cuSerial": cuSerial,
        "kraQrCode": kraQrCode,
        "fiscalizationStatus": fiscalizationStatus,
        "fiscalizationDate": fiscalizationDate,
        "createdBy": createdBy,
        "lineItems": List<dynamic>.from(lineItems.map((x) => x.toJson())),
    };
}
