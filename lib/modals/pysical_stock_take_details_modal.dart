// To parse this JSON data, do
//
//     final physicalStockTakeDetailsModal = physicalStockTakeDetailsModalFromJson(jsonString);

import 'dart:convert';

PhysicalStockTakeDetailsModal physicalStockTakeDetailsModalFromJson(String str) => PhysicalStockTakeDetailsModal.fromJson(json.decode(str));

String physicalStockTakeDetailsModalToJson(PhysicalStockTakeDetailsModal data) => json.encode(data.toJson());

class PhysicalStockTakeDetailsModal {
    int showroomId;
    int warehouseId;
    int physicalStockCountTypeId;
    DateTime stockCountDate;
    String status;
    int id;
    String stockCountNumber;
    DateTime createdAt;
    int createdBy;
    dynamic createdByName;
    dynamic showroomName;
    dynamic warehouseName;
    dynamic warehouseCode;
    dynamic physicalStockCountTypeName;
    List<StockCountProduct> stockCountProducts;

    PhysicalStockTakeDetailsModal({
        required this.showroomId,
        required this.warehouseId,
        required this.physicalStockCountTypeId,
        required this.stockCountDate,
        required this.status,
        required this.id,
        required this.stockCountNumber,
        required this.createdAt,
        required this.createdBy,
        required this.createdByName,
        required this.showroomName,
        required this.warehouseName,
        required this.warehouseCode,
        required this.physicalStockCountTypeName,
        required this.stockCountProducts,
    });

    factory PhysicalStockTakeDetailsModal.fromJson(Map<String, dynamic> json) => PhysicalStockTakeDetailsModal(
        showroomId: json["showroom_id"],
        warehouseId: json["warehouse_id"],
        physicalStockCountTypeId: json["physical_stock_count_type_id"],
        stockCountDate: DateTime.parse(json["stock_count_date"]),
        status: json["status"],
        id: json["id"],
        stockCountNumber: json["stock_count_number"],
        createdAt: DateTime.parse(json["created_at"]),
        createdByName: json["created_by_name"],
        createdBy: json["created_by"],
        showroomName: json["showroom_name"],
        warehouseName: json["warehouse_name"],
        warehouseCode: json["warehouse_code"],
        physicalStockCountTypeName: json["physical_stock_count_type_name"],
        stockCountProducts: List<StockCountProduct>.from(json["stock_count_products"].map((x) => StockCountProduct.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "showroom_id": showroomId,
        "warehouse_id": warehouseId,
        "physical_stock_count_type_id": physicalStockCountTypeId,
        "stock_count_date": stockCountDate.toIso8601String(),
        "status": status,
        "id": id,
        "stock_count_number": stockCountNumber,
        "created_at": createdAt.toIso8601String(),
        "created_by": createdBy,
        "created_by_name": createdByName,
        "showroom_name": showroomName,
        "warehouse_name": warehouseName,
        "warehouse_code": warehouseCode,
        "physical_stock_count_type_name": physicalStockCountTypeName,
        "stock_count_products": List<dynamic>.from(stockCountProducts.map((x) => x.toJson())),
    };
}

class StockCountProduct {
    int id;
    int physicalStockCountId;
    DateTime createdAt;
    dynamic barcode;
    dynamic itemName;
    dynamic itemGroup;
    dynamic itemBrand;
    dynamic itemPictureName;
    dynamic modelNumber;

    StockCountProduct({
        required this.id,
        required this.physicalStockCountId,
        required this.createdAt,
        required this.barcode,
        required this.itemName,
        required this.itemGroup,
        required this.itemBrand,
        required this.itemPictureName,
        required this.modelNumber,
    });

    factory StockCountProduct.fromJson(Map<String, dynamic> json) => StockCountProduct(
        id: json["id"],
        physicalStockCountId: json["physical_stock_count_id"],
        createdAt: DateTime.parse(json["created_at"]),
        barcode: json["barcode"],
        itemName: json["item_name"],
        itemGroup: json["item_group"],
        itemBrand: json["item_brand"],
        itemPictureName: json["item_picture_name"],
        modelNumber: json["modelNumber"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "physical_stock_count_id": physicalStockCountId,
        "created_at": createdAt.toIso8601String(),
        "barcode": barcode,
        "item_name": itemName,
        "item_group": itemGroup,
        "item_brand": itemBrand,
        "item_picture_name": itemPictureName,
        "modelNumber": modelNumber,
    };
}
