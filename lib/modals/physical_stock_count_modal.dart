// To parse this JSON data, do
//
//     final physicalStockCountModal = physicalStockCountModalFromJson(jsonString);

import 'dart:convert';

PhysicalStockCountModal physicalStockCountModalFromJson(String str) => PhysicalStockCountModal.fromJson(json.decode(str));

String physicalStockCountModalToJson(PhysicalStockCountModal data) => json.encode(data.toJson());

class PhysicalStockCountModal {
    int showroomId;
    int warehouseId;
    int physicalStockCountTypeId;
    DateTime stockCountDate;
    String status;
    int id;
    String stockCountNumber;
    DateTime createdAt;
    int createdBy;
    String showroomName;
    String warehouseName;
    String warehouseCode;
    String physicalStockCountTypeName;

    PhysicalStockCountModal({
        required this.showroomId,
        required this.warehouseId,
        required this.physicalStockCountTypeId,
        required this.stockCountDate,
        required this.status,
        required this.id,
        required this.stockCountNumber,
        required this.createdAt,
        required this.createdBy,
        required this.showroomName,
        required this.warehouseName,
        required this.warehouseCode,
        required this.physicalStockCountTypeName,
    });

    factory PhysicalStockCountModal.fromJson(Map<String, dynamic> json) => PhysicalStockCountModal(
        showroomId: json["showroom_id"],
        warehouseId: json["warehouse_id"],
        physicalStockCountTypeId: json["physical_stock_count_type_id"],
        stockCountDate: DateTime.parse(json["stock_count_date"]),
        status: json["status"],
        id: json["id"],
        stockCountNumber: json["stock_count_number"],
        createdAt: DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        showroomName: json["showroom_name"],
        warehouseName: json["warehouse_name"],
        warehouseCode: json["warehouse_code"],
        physicalStockCountTypeName: json["physical_stock_count_type_name"],
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
        "showroom_name": showroomName,
        "warehouse_name": warehouseName,
        "warehouse_code": warehouseCode,
        "physical_stock_count_type_name": physicalStockCountTypeName,
    };
}
