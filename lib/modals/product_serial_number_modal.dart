// To parse this JSON data, do
//
//     final productSerialNumberModal = productSerialNumberModalFromJson(jsonString);

import 'dart:convert';

ProductSerialNumberModal productSerialNumberModalFromJson(String str) => ProductSerialNumberModal.fromJson(json.decode(str));

String productSerialNumberModalToJson(ProductSerialNumberModal data) => json.encode(data.toJson());

class ProductSerialNumberModal {
    int code;
    String serialNo;
    String itemCode;
    String modelNo;
    String warehouseCode;
    String docType;
    String asCreadtedBy;
    dynamic docNumber;
    DateTime createdDate;
    String serialStatus;

    ProductSerialNumberModal({
        required this.code,
        required this.serialNo,
        required this.itemCode,
        required this.modelNo,
        required this.warehouseCode,
        required this.docType,
        required this.asCreadtedBy,
        required this.docNumber,
        required this.createdDate,
        required this.serialStatus,
    });

    factory ProductSerialNumberModal.fromJson(Map<String, dynamic> json) => ProductSerialNumberModal(
        code: json["code"],
        serialNo: json["serialNo"],
        itemCode: json["itemCode"],
        modelNo: json["modelNo"],
        warehouseCode: json["warehouseCode"],
        docType: json["docType"],
        asCreadtedBy: json["asCreadtedBy"],
        docNumber: json["docNumber"],
        createdDate: DateTime.parse(json["createdDate"]),
        serialStatus: json["serialStatus"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "serialNo": serialNo,
        "itemCode": itemCode,
        "modelNo": modelNo,
        "warehouseCode": warehouseCode,
        "docType": docType,
        "asCreadtedBy": asCreadtedBy,
        "docNumber": docNumber,
        "createdDate": createdDate.toIso8601String(),
        "serialStatus": serialStatus,
    };
}
