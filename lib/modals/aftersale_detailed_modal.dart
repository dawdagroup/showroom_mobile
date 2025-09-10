// To parse this JSON data, do
//
//     final aftersaleDetailedModal = aftersaleDetailedModalFromJson(jsonString);

import 'dart:convert';

AftersaleDetailedModal aftersaleDetailedModalFromJson(String str) => AftersaleDetailedModal.fromJson(json.decode(str));

String aftersaleDetailedModalToJson(AftersaleDetailedModal data) => json.encode(data.toJson());

class AftersaleDetailedModal {
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
    dynamic region;
    dynamic zone;
    dynamic complaintOrigin;
    dynamic warrantyStatus;
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
    dynamic dateOfComplaintFrom;
    dynamic dateOfComplaintTo;
    List<ProgressLine> progressLines;
    List<MovementsLine> movementsLines;

    AftersaleDetailedModal({
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
        required this.region,
        required this.zone,
        required this.complaintOrigin,
        required this.warrantyStatus,
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
        required this.dateOfComplaintFrom,
        required this.dateOfComplaintTo,
        required this.progressLines,
        required this.movementsLines,
    });

    factory AftersaleDetailedModal.fromJson(Map<String, dynamic> json) => AftersaleDetailedModal(
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
        region: json["region"],
        zone: json["zone"],
        complaintOrigin: json["complaintOrigin"],
        warrantyStatus: json["warrantyStatus"],
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
        dateOfComplaintFrom: json["dateOfComplaintFrom"],
        dateOfComplaintTo: json["dateOfComplaintTo"],
        progressLines: List<ProgressLine>.from(json["progressLines"].map((x) => ProgressLine.fromJson(x))),
        movementsLines: List<MovementsLine>.from(json["movementsLines"].map((x) => MovementsLine.fromJson(x))),
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
        "region": region,
        "zone": zone,
        "complaintOrigin": complaintOrigin,
        "warrantyStatus": warrantyStatus,
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
        "dateOfComplaintFrom": dateOfComplaintFrom,
        "dateOfComplaintTo": dateOfComplaintTo,
        "progressLines": List<dynamic>.from(progressLines.map((x) => x.toJson())),
        "movementsLines": List<dynamic>.from(movementsLines.map((x) => x.toJson())),
    };
}


class MovementsLine {
    dynamic aftersalesCollectionNo;
    dynamic aftersalesMoveType;
    dynamic aftersalesCreatedBy;
    dynamic aftersalesDate;
    dynamic aftersalesPackagingType;
    dynamic aftersalesPackagingDetails;
    dynamic aftersalesDamageType;
    dynamic aftersalesDamageDetails;
    dynamic aftersalesRemarks;
    dynamic aftersalesAttachment;
    dynamic aftersalesMoveTypeDetails;
    dynamic accessoriesMissingType;
    dynamic accessoriesMissingDetails;

    MovementsLine({
        required this.aftersalesCollectionNo,
        required this.aftersalesMoveType,
        required this.aftersalesCreatedBy,
        required this.aftersalesDate,
        required this.aftersalesPackagingType,
        required this.aftersalesPackagingDetails,
        required this.aftersalesDamageType,
        required this.aftersalesDamageDetails,
        required this.aftersalesRemarks,
        required this.aftersalesAttachment,
        required this.aftersalesMoveTypeDetails,
        required this.accessoriesMissingType,
        required this.accessoriesMissingDetails,

    });

    factory MovementsLine.fromJson(Map<String, dynamic> json) => MovementsLine(
        aftersalesCollectionNo: json["aftersalesCollectionNo"],
        aftersalesMoveType: json["aftersalesMoveType"],
        aftersalesCreatedBy: json["aftersalesCreatedBy"],
        aftersalesDate: json["aftersalesDate"],
        aftersalesPackagingType: json["aftersalesPackagingType"],
        aftersalesPackagingDetails: json["aftersalesPackagingDetails"],
        aftersalesDamageType: json["aftersalesDamageType"],
        aftersalesDamageDetails: json["aftersalesDamageDetails"],
        aftersalesRemarks: json["aftersalesRemarks"],
        aftersalesAttachment: json["aftersalesAttachment"],
        aftersalesMoveTypeDetails: json["aftersalesMoveTypeDetails"],
        accessoriesMissingType: json["accessoriesMissingType"],
        accessoriesMissingDetails: json["accessoriesMissingDetails"],
    );

    Map<String, dynamic> toJson() => {
        "aftersalesCollectionNo": aftersalesCollectionNo,
        "aftersalesMoveType": aftersalesMoveType,
        "aftersalesCreatedBy": aftersalesCreatedBy,
        "aftersalesDate": aftersalesDate,
        "aftersalesPackagingType": aftersalesPackagingType,
        "aftersalesPackagingDetails": aftersalesPackagingDetails,
        "aftersalesDamageType": aftersalesDamageType,
        "aftersalesDamageDetails": aftersalesDamageDetails,
        "aftersalesRemarks": aftersalesRemarks,
        "aftersalesAttachment": aftersalesAttachment,
        "aftersalesMoveTypeDetails": aftersalesMoveTypeDetails,
        "accessoriesMissingType": accessoriesMissingType,
        "accessoriesMissingDetails": accessoriesMissingDetails,
    };
}

class ProgressLine {
    dynamic progressDate;
    dynamic progressStatus;
    dynamic progressUpdatedBy;

    ProgressLine({
        required this.progressDate,
        required this.progressStatus,
        required this.progressUpdatedBy,
    });

    factory ProgressLine.fromJson(Map<String, dynamic> json) => ProgressLine(
        progressDate: json["progressDate"],
        progressStatus: json["progressStatus"],
        progressUpdatedBy: json["progressUpdatedBy"],
    );

    Map<String, dynamic> toJson() => {
        "progressDate": progressDate,
        "progressStatus": progressStatus,
        "progressUpdatedBy": progressUpdatedBy,
    };
}

