// To parse this JSON data, do
//
//     final aftersaleRequestModal = aftersaleRequestModalFromJson(jsonString);

import 'dart:convert';

AftersaleRequestModal aftersaleRequestModalFromJson(String str) => AftersaleRequestModal.fromJson(json.decode(str));

String aftersaleRequestModalToJson(AftersaleRequestModal data) => json.encode(data.toJson());

class AftersaleRequestModal {
    dynamic docEntry;
    dynamic docNum;
    DateTime createDate;
    dynamic complaintNo;
    dynamic complaintNoIal;
    DateTime dateOfComplaint;
    dynamic consumerName;
    dynamic consumerPhoneNo;
    dynamic consumerEmail;
    dynamic town;
    dynamic location;
    dynamic complaintDesc;
    dynamic displayWhsCode;
    dynamic brand;
    dynamic itemGroup;
    dynamic itemModelNo;
    dynamic itemCode;
    dynamic serialNo;
    dynamic warrantyCardNo;
    dynamic dateOfPurchase;
    dynamic pkgMissing;
    dynamic damage;
    dynamic ourRemarks;
    dynamic status;
    dynamic closingDate;
    dynamic closingRemarks;
    dynamic createdBy;
    dynamic typeOfReturn;

    AftersaleRequestModal({
        required this.docEntry,
        required this.docNum,
        required this.createDate,
        required this.complaintNo,
        required this.complaintNoIal,
        required this.dateOfComplaint,
        required this.consumerName,
        required this.consumerPhoneNo,
        required this.consumerEmail,
        required this.town,
        required this.location,
        required this.complaintDesc,
        required this.displayWhsCode,
        required this.brand,
        required this.itemGroup,
        required this.itemModelNo,
        required this.itemCode,
        required this.serialNo,
        required this.warrantyCardNo,
        required this.dateOfPurchase,
        required this.pkgMissing,
        required this.damage,
        required this.ourRemarks,
        required this.status,
        required this.closingDate,
        required this.closingRemarks,
        required this.createdBy,
        required this.typeOfReturn,
    });

    factory AftersaleRequestModal.fromJson(Map<String, dynamic> json) => AftersaleRequestModal(
        docEntry: json["docEntry"],
        docNum: json["docNum"],
        createDate: DateTime.parse(json["createDate"]),
        complaintNo: json["complaintNo"],
        complaintNoIal: json["complaintNoIal"],
        dateOfComplaint: DateTime.parse(json["dateOfComplaint"]),
        consumerName: json["consumerName"],
        consumerPhoneNo: json["consumerPhoneNo"],
        consumerEmail: json["consumerEmail"],
        town: json["town"],
        location: json["location"],
        complaintDesc: json["complaintDesc"],
        displayWhsCode: json["displayWhsCode"],
        brand: json["brand"],
        itemGroup: json["itemGroup"],
        itemModelNo: json["itemModelNo"],
        itemCode: json["itemCode"],
        serialNo: json["serialNo"],
        warrantyCardNo: json["warrantyCardNo"],
        dateOfPurchase: json["dateOfPurchase"],
        pkgMissing: json["pkgMissing"],
        damage: json["damage"],
        ourRemarks: json["ourRemarks"],
        status: json["status"],
        closingDate: json["closingDate"],
        closingRemarks: json["closingRemarks"],
        createdBy: json["createdBy"],
        typeOfReturn: json["typeOfReturn"],
    );

    Map<String, dynamic> toJson() => {
        "docEntry": docEntry,
        "docNum": docNum,
        "createDate": createDate.toIso8601String(),
        "complaintNo": complaintNo,
        "complaintNoIal": complaintNoIal,
        "dateOfComplaint": dateOfComplaint.toIso8601String(),
        "consumerName": consumerName,
        "consumerPhoneNo": consumerPhoneNo,
        "consumerEmail": consumerEmail,
        "town": town,
        "location": location,
        "complaintDesc": complaintDesc,
        "displayWhsCode": displayWhsCode,
        "brand": brand,
        "itemGroup": itemGroup,
        "itemModelNo": itemModelNo,
        "itemCode": itemCode,
        "serialNo": serialNo,
        "warrantyCardNo": warrantyCardNo,
        "dateOfPurchase": dateOfPurchase,
        "pkgMissing": pkgMissing,
        "damage": damage,
        "ourRemarks": ourRemarks,
        "status": status,
        "closingDate": closingDate,
        "closingRemarks": closingRemarks,
        "createdBy": createdBy,
        "typeOfReturn": typeOfReturn,
    };
}
