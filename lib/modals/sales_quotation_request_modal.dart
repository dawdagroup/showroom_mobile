// To parse this JSON data, do
//
//     final salesQuotationRequestModal = salesQuotationRequestModalFromJson(jsonString);

import 'dart:convert';

SalesQuotationRequestModal salesQuotationRequestModalFromJson(String str) => SalesQuotationRequestModal.fromJson(json.decode(str));

String salesQuotationRequestModalToJson(SalesQuotationRequestModal data) => json.encode(data.toJson());

class SalesQuotationRequestModal {
    int approvalTypeId;
    int documentId;
    int showroomId;
    String documentType;
    int createdBy;
    String status;
    String approvalStatus;
    dynamic approvalComment;
    dynamic approvalBy;
    dynamic approvalDate;
    int id;
    DateTime createdAt;

    SalesQuotationRequestModal({
        required this.approvalTypeId,
        required this.documentId,
        required this.showroomId,
        required this.documentType,
        required this.createdBy,
        required this.status,
        required this.approvalStatus,
        required this.approvalComment,
        required this.approvalBy,
        required this.approvalDate,
        required this.id,
        required this.createdAt,
    });

    factory SalesQuotationRequestModal.fromJson(Map<String, dynamic> json) => SalesQuotationRequestModal(
        approvalTypeId: json["approval_type_id"],
        documentId: json["document_id"],
        showroomId: json["showroom_id"],
        documentType: json["document_type"],
        createdBy: json["created_by"],
        status: json["status"],
        approvalStatus: json["approval_status"],
        approvalComment: json["approval_comment"],
        approvalBy: json["approval_by"],
        approvalDate: json["approval_date"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "approval_type_id": approvalTypeId,
        "document_id": documentId,
        "showroom_id": showroomId,
        "document_type": documentType,
        "created_by": createdBy,
        "status": status,
        "approval_status": approvalStatus,
        "approval_comment": approvalComment,
        "approval_by": approvalBy,
        "approval_date": approvalDate,
        "id": id,
        "created_at": createdAt.toIso8601String(),
    };
}
