// To parse this JSON data, do
//
//     final deliveryDetailsModal = deliveryDetailsModalFromJson(jsonString);

import 'dart:convert';

DeliveryDetailsModal deliveryDetailsModalFromJson(String str) => DeliveryDetailsModal.fromJson(json.decode(str));

String deliveryDetailsModalToJson(DeliveryDetailsModal data) => json.encode(data.toJson());

class DeliveryDetailsModal {
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
    dynamic createdBy;
    List<DocumentLine> documentLines;

    DeliveryDetailsModal({
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
        required this.documentLines,
        required this.createdBy,
    });

    factory DeliveryDetailsModal.fromJson(Map<String, dynamic> json) => DeliveryDetailsModal(
        docEntry: json["docEntry"],
        deliveryNumber: json["deliveryNumber"],
        inventoryStatus: json["inventoryStatus"],
        documentStatus: json["documentStatus"],
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        vatPercent: json["vatPercent"],
        vatSum: json["vatSum"]?.toDouble(),
        totalAmount: json["totalAmount"],
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
        createdBy: json["createdBy"],
        documentLines: List<DocumentLine>.from(json["documentLines"].map((x) => DocumentLine.fromJson(x))),
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
        "createdBy": createdBy,
        "documentLines": List<dynamic>.from(documentLines.map((x) => x.toJson())),
    };
}

class DocumentLine {
    dynamic itemLineNum;
    dynamic itemBaseEntry;
    dynamic itemBaseLine;
    dynamic itemBaseType;
    dynamic itemBaseRef;
    dynamic itemLineStatus;
    dynamic itemCode;
    dynamic itemName;
    dynamic itemBarCode;
    dynamic itemModelNo;
    dynamic itemBrand;
    dynamic itemOpenQty;
    dynamic itemPrice;
    dynamic itemDiscPrcnt;
    dynamic itemLineTotal;
    dynamic pictureName;
    dynamic quantity;

    DocumentLine({
        required this.itemLineNum,
        required this.itemBaseEntry,
        required this.itemBaseLine,
        required this.itemBaseType,
        required this.itemBaseRef,
        required this.itemLineStatus,
        required this.itemCode,
        required this.itemName,
        required this.itemBarCode,
        required this.itemModelNo,
        required this.itemBrand,
        required this.itemOpenQty,
        required this.itemPrice,
        required this.itemDiscPrcnt,
        required this.itemLineTotal,
        required this.pictureName,
        required this.quantity,
    });

    factory DocumentLine.fromJson(Map<String, dynamic> json) => DocumentLine(
        itemLineNum: json["itemLineNum"],
        itemBaseEntry: json["itemBaseEntry"],
        itemBaseLine: json["itemBaseLine"],
        itemBaseType: json["itemBaseType"],
        itemBaseRef: json["itemBaseRef"],
        itemLineStatus: json["itemLineStatus"],
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        itemBarCode: json["itemBarCode"],
        itemModelNo: json["itemModelNo"],
        itemBrand: json["itemBrand"],
        itemOpenQty: json["itemOpenQty"],
        itemPrice: json["itemPrice"]?.toDouble(),
        itemDiscPrcnt: json["itemDiscPrcnt"],
        itemLineTotal: json["itemLineTotal"]?.toDouble(),
        pictureName: json["pictureName"],
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "itemLineNum": itemLineNum,
        "itemBaseEntry": itemBaseEntry,
        "itemBaseLine": itemBaseLine,
        "itemBaseType": itemBaseType,
        "itemBaseRef": itemBaseRef,
        "itemLineStatus": itemLineStatus,
        "itemCode": itemCode,
        "itemName": itemName,
        "itemBarCode": itemBarCode,
        "itemModelNo": itemModelNo,
        "itemBrand": itemBrand,
        "itemOpenQty": itemOpenQty,
        "itemPrice": itemPrice,
        "itemDiscPrcnt": itemDiscPrcnt,
        "itemLineTotal": itemLineTotal,
        "pictureName": pictureName,
        "quantity": quantity,
    };
}
