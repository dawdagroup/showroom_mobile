// To parse this JSON data, do
//
//     final productStockModal = productStockModalFromJson(jsonString);

import 'dart:convert';

ProductStockModal productStockModalFromJson(String str) => ProductStockModal.fromJson(json.decode(str));

String productStockModalToJson(ProductStockModal data) => json.encode(data.toJson());

class ProductStockModal {
    dynamic itemCode;
    dynamic itemName;
    dynamic barcode;
    dynamic modelNo;
    dynamic warehouseCode;
    double onHand;
    double onOrder;
    double isCommited;

    ProductStockModal({
        required this.itemCode,
        required this.itemName,
        required this.barcode,
        required this.modelNo,
        required this.warehouseCode,
        required this.onHand,
        required this.onOrder,
        required this.isCommited,
    });

    factory ProductStockModal.fromJson(Map<String, dynamic> json) => ProductStockModal(
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        barcode: json["barcode"],
        modelNo: json["modelNo"],
        warehouseCode: json["warehouseCode"],
        onHand: json["onHand"],
        onOrder: json["onOrder"],
        isCommited: json["isCommited"],
    );

    Map<String, dynamic> toJson() => {
        "itemCode": itemCode,
        "itemName": itemName,
        "barcode": barcode,
        "modelNo": modelNo,
        "warehouseCode": warehouseCode,
        "onHand": onHand,
        "onOrder": onOrder,
        "isCommited": isCommited,
    };
}
