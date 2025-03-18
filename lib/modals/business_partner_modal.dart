// To parse this JSON data, do
//
//     final businessPartnerModal = businessPartnerModalFromJson(jsonString);

import 'dart:convert';

BusinessPartnerModal businessPartnerModalFromJson(String str) => BusinessPartnerModal.fromJson(json.decode(str));

String businessPartnerModalToJson(BusinessPartnerModal data) => json.encode(data.toJson());

class BusinessPartnerModal {
    String name;
    String code;
    dynamic requiresCustomerId;
    dynamic requiresFullPayment;
    dynamic autoPrintReceipt;
    dynamic status;

    BusinessPartnerModal({
        required this.name,
        required this.code,
        required this.requiresCustomerId,
        required this.requiresFullPayment,
        required this.autoPrintReceipt,
        required this.status,
    });

    factory BusinessPartnerModal.fromJson(Map<String, dynamic> json) => BusinessPartnerModal(
        name: json["name"],
        code: json["code"],
        requiresCustomerId: json["requires_customer_id"],
        requiresFullPayment: json["requires_full_payment"],
        autoPrintReceipt: json["auto_print_receipt"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "requires_customer_id": requiresCustomerId,
        "requires_full_payment": requiresFullPayment,
        "auto_print_receipt": autoPrintReceipt,
        "status": status,
    };
}
