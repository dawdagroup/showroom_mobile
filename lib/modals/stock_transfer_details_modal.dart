// To parse this JSON data, do
//
//     final stockTransferDetailsModal = stockTransferDetailsModalFromJson(jsonString);

import 'dart:convert';

StockTransferDetailsModal stockTransferDetailsModalFromJson(String str) => StockTransferDetailsModal.fromJson(json.decode(str));

String stockTransferDetailsModalToJson(StockTransferDetailsModal data) => json.encode(data.toJson());

class StockTransferDetailsModal {
    String transferNumber;
    DateTime transferDate;
    int transferTypeId;
    String status;
    int fromLocationId;
    int toLocationId;
    dynamic approvedBy;
    dynamic approvedAt;
    dynamic approvalComment;
    String approvalStatus;
    int id;
    DateTime createdAt;
    int createdBy;
    dynamic createdByName;
    dynamic updatedAt;
    dynamic updatedBy;
    dynamic approvedByName;
    dynamic transferTypeName;
    dynamic fromWarehouseName;
    dynamic fromWarehouseCode;
    dynamic toWarehouseName;
    dynamic toWarehouseCode;
    dynamic goodsIssueNumber;
    dynamic goodsIssueDate;
    dynamic goodsReceiptNumber;
    dynamic goodsReceiptDate;
    List<StockTransferProduct> products;

    StockTransferDetailsModal({
        required this.transferNumber,
        required this.transferDate,
        required this.transferTypeId,
        required this.status,
        required this.fromLocationId,
        required this.toLocationId,
        required this.approvedBy,
        required this.approvedAt,
        required this.approvalComment,
        required this.approvalStatus,
        required this.id,
        required this.createdAt,
        required this.createdBy,
        required this.createdByName,
        required this.updatedAt,
        required this.updatedBy,
        required this.approvedByName,
        required this.transferTypeName,
        required this.fromWarehouseName,
        required this.fromWarehouseCode,
        required this.toWarehouseName,
        required this.toWarehouseCode,
        required this.goodsIssueNumber,
        required this.goodsIssueDate,
        required this.goodsReceiptNumber,
        required this.goodsReceiptDate,
        required this.products,
    });

    factory StockTransferDetailsModal.fromJson(Map<String, dynamic> json) => StockTransferDetailsModal(
        transferNumber: json["transfer_number"],
        transferDate: DateTime.parse(json["transfer_date"]),
        transferTypeId: json["transfer_type_id"],
        status: json["status"],
        fromLocationId: json["from_location_id"],
        toLocationId: json["to_location_id"],
        approvedBy: json["approved_by"],
        approvedAt: json["approved_at"],
        approvalComment: json["approval_comment"],
        approvalStatus: json["approval_status"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        createdByName: json["created_by_name"],
        updatedAt: json["updated_at"],
        updatedBy: json["updated_by"],
        approvedByName: json["approved_by_name"],
        transferTypeName: json["transfer_type_name"],
        fromWarehouseName: json["from_warehouse_name"],
        fromWarehouseCode: json["from_warehouse_code"],
        toWarehouseName: json["to_warehouse_name"],
        toWarehouseCode: json["to_warehouse_code"],
        goodsIssueNumber: json["goods_issue_number"],
        goodsIssueDate: json["goods_issue_date"],
        goodsReceiptNumber: json["goods_receipt_number"],
        goodsReceiptDate: json["goods_receipt_date"],
        products: List<StockTransferProduct>.from(json["products"].map((x) => StockTransferProduct.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "transfer_number": transferNumber,
        "transfer_date": transferDate.toIso8601String(),
        "transfer_type_id": transferTypeId,
        "status": status,
        "from_location_id": fromLocationId,
        "to_location_id": toLocationId,
        "approved_by": approvedBy,
        "approved_at": approvedAt,
        "approval_comment": approvalComment,
        "approval_status": approvalStatus,
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "created_by": createdBy,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
        "created_by_name": createdByName,
        "approved_by_name": approvedByName,
        "transfer_type_name": transferTypeName,
        "from_warehouse_name": fromWarehouseName,
        "from_warehouse_code": fromWarehouseCode,
        "to_warehouse_name": toWarehouseName,
        "to_warehouse_code": toWarehouseCode,
        "goods_issue_number": goodsIssueNumber,
        "goods_issue_date": goodsIssueDate,
        "goods_receipt_number": goodsReceiptNumber,
        "goods_receipt_date": goodsReceiptDate,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
    };
}

class StockTransferProduct {
    int id;
    int transferRequestId;
    String itemCode;
    String modelNumber;
    String barcode;
    String itemName;
    String itemGroup;
    String itemBrand;
    dynamic itemPictureName;
    int quantity;
    DateTime createdAt;

    StockTransferProduct({
        required this.id,
        required this.transferRequestId,
        required this.itemCode,
        required this.modelNumber,
        required this.barcode,
        required this.itemName,
        required this.itemGroup,
        required this.itemBrand,
        required this.quantity,
        required this.itemPictureName,
        required this.createdAt,
    });

    factory StockTransferProduct.fromJson(Map<String, dynamic> json) => StockTransferProduct(
        id: json["id"],
        transferRequestId: json["transfer_request_id"],
        itemCode: json["item_code"],
        modelNumber: json["modelNumber"],
        barcode: json["barcode"],
        itemName: json["item_name"],
        itemGroup: json["item_group"],
        itemBrand: json["item_brand"],
        quantity: json["quantity"],
        itemPictureName: json["item_picture_name"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "transfer_request_id": transferRequestId,
        "item_code": itemCode,
        "modelNumber": modelNumber,
        "barcode": barcode,
        "item_name": itemName,
        "item_group": itemGroup,
        "item_brand": itemBrand,
        "quantity": quantity,
        "item_picture_name": itemPictureName,
        "created_at": createdAt.toIso8601String(),
    };
}
