// To parse this JSON data, do
//
//     final warehouseStockModal = warehouseStockModalFromJson(jsonString);

import 'dart:convert';

WarehouseStockModal warehouseStockModalFromJson(String str) => WarehouseStockModal.fromJson(json.decode(str));

String warehouseStockModalToJson(WarehouseStockModal data) => json.encode(data.toJson());

class WarehouseStockModal {
  dynamic warehouseName;
  dynamic warehouseCode;
  dynamic stockOnHand;
  dynamic warehouseType;
  dynamic warehouseShortName;

  WarehouseStockModal({
    required this.warehouseName,
    required this.warehouseCode,
    required this.stockOnHand,
    required this.warehouseType,
    required this.warehouseShortName,
  });

  factory WarehouseStockModal.fromJson(Map<String, dynamic> json) => WarehouseStockModal(
    warehouseName: json["warehouseName"],
    warehouseCode: json["warehouseCode"],
    stockOnHand: json["stockOnHand"],
    warehouseType: json["warehouseType"],
    warehouseShortName: json["warehouseShortName"],
  );

  Map<String, dynamic> toJson() => {
    "warehouseName": warehouseName,
    "warehouseCode": warehouseCode,
    "stockOnHand": stockOnHand,
    "warehouseType": warehouseType,
    "warehouseShortName": warehouseShortName,
  };
}
