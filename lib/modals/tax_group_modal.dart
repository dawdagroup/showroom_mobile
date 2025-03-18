// To parse this JSON data, do
//
//     final taxGroupModal = taxGroupModalFromJson(jsonString);

import 'dart:convert';

TaxGroupModal taxGroupModalFromJson(String str) => TaxGroupModal.fromJson(json.decode(str));

String taxGroupModalToJson(TaxGroupModal data) => json.encode(data.toJson());

class TaxGroupModal {
    dynamic code;
    dynamic name;
    DateTime effectDate;
    dynamic rate;
    dynamic category;
    dynamic accountCode;
    dynamic status;

    TaxGroupModal({
        required this.code,
        required this.name,
        required this.effectDate,
        required this.rate,
        required this.category,
        required this.accountCode,
        required this.status,
    });

    factory TaxGroupModal.fromJson(Map<String, dynamic> json) => TaxGroupModal(
        code: json["code"],
        name: json["name"],
        effectDate: DateTime.parse(json["effectDate"]),
        rate: json["rate"],
        category: json["category"],
        accountCode: json["accountCode"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "effectDate": effectDate.toIso8601String(),
        "rate": rate,
        "category": category,
        "accountCode": accountCode,
        "status": status,
    };
}
