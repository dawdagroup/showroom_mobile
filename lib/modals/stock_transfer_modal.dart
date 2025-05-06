// To parse this JSON data, do
//
//     final stockTransferModal = stockTransferModalFromJson(jsonString);

import 'dart:convert';

StockTransferModal stockTransferModalFromJson(String str) => StockTransferModal.fromJson(json.decode(str));

String stockTransferModalToJson(StockTransferModal data) => json.encode(data.toJson());

class StockTransferModal {
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

    StockTransferModal({
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
        required this.approvedByName,
        required this.updatedAt,
        required this.updatedBy,
        required this.transferTypeName,
        required this.fromWarehouseName,
        required this.fromWarehouseCode,
        required this.toWarehouseName,
        required this.toWarehouseCode,
        required this.goodsIssueNumber,
        required this.goodsIssueDate,
        required this.goodsReceiptNumber,
        required this.goodsReceiptDate,
    });

    factory StockTransferModal.fromJson(Map<String, dynamic> json) => StockTransferModal(
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
        approvedByName: json["approved_by_name"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        createdByName: json["created_by_name"],
        updatedAt: json["updated_at"],
        updatedBy: json["updated_by"],
        transferTypeName: json["transfer_type_name"],
        fromWarehouseName: json["from_warehouse_name"],
        fromWarehouseCode: json["from_warehouse_code"],
        toWarehouseName: json["to_warehouse_name"],
        toWarehouseCode: json["to_warehouse_code"],
        goodsIssueNumber: json["goods_issue_number"],
        goodsIssueDate: json["goods_issue_date"],
        goodsReceiptNumber: json["goods_receipt_number"],
        goodsReceiptDate: json["goods_receipt_date"],
    );

    Map<String, dynamic> toJson() => {
        "transfer_number": transferNumber,
        "transfer_date": transferDate.toIso8601String(),
        "transfer_type_id": transferTypeId,
        "status": status,
        "from_location_id": fromLocationId,
        "to_location_id": toLocationId,
        "approved_by": approvedBy,
        "approved_by_name": approvedByName,
        "approved_at": approvedAt,
        "approval_comment": approvalComment,
        "approval_status": approvalStatus,
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "created_by": createdBy,
        "created_by_name": createdByName,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
        "transfer_type_name": transferTypeName,
        "from_warehouse_name": fromWarehouseName,
        "from_warehouse_code": fromWarehouseCode,
        "to_warehouse_name": toWarehouseName,
        "to_warehouse_code": toWarehouseCode,
        "goods_issue_number": goodsIssueNumber,
        "goods_issue_date": goodsIssueDate,
        "goods_receipt_number": goodsReceiptNumber,
        "goods_receipt_date": goodsReceiptDate,
    };
}
