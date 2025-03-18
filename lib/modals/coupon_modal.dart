// To parse this JSON data, do
//
//     final couponModal = couponModalFromJson(jsonString);

import 'dart:convert';

CouponModal couponModalFromJson(String str) => CouponModal.fromJson(json.decode(str));

String couponModalToJson(CouponModal data) => json.encode(data.toJson());

class CouponModal {
    String code;
    dynamic description;
    double discountPercentage;
    bool isActive;
    dynamic expiryDate;
    int id;

    CouponModal({
        required this.code,
        required this.description,
        required this.discountPercentage,
        required this.isActive,
        required this.expiryDate,
        required this.id,
    });

    factory CouponModal.fromJson(Map<String, dynamic> json) => CouponModal(
        code: json["code"],
        description: json["description"],
        discountPercentage: json["discount_percentage"],
        isActive: json["is_active"],
        expiryDate: json["expiry_date"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "description": description,
        "discount_percentage": discountPercentage,
        "is_active": isActive,
        "expiry_date": expiryDate,
        "id": id,
    };
}
