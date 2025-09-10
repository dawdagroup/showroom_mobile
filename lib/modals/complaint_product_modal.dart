// To parse this JSON data, do
//
//     final complaintProductModal = complaintProductModalFromJson(jsonString);

import 'dart:convert';

ComplaintProductModal complaintProductModalFromJson(String str) => ComplaintProductModal.fromJson(json.decode(str));

String complaintProductModalToJson(ComplaintProductModal data) => json.encode(data.toJson());

class ComplaintProductModal {
    String? cardCode;
    String? cardName;
    String? itemCode;
    String? itemName;
    String? barcode;
    String? itemGroup;
    String? brand;
    String? modelNo;
    String? picturName;
    String? userText;
    String? specList;
    String? supplierName;
    String? treeType;
    String? price;
    String? priceList;
    String? discount;
    String? installationRequired;
    String? itemPictureName;
    String? productStrength;
    String? productStatus;
    String? priceInclusiveVat;

    ComplaintProductModal({
        this.cardCode,
        this.cardName,
        this.itemCode,
        this.itemName,
        this.barcode,
        this.itemGroup,
        this.brand,
        this.modelNo,
        this.picturName,
        this.userText,
        this.specList,
        this.supplierName,
        this.treeType,
        this.price,
        this.priceList,
        this.discount,
        this.installationRequired,
        this.itemPictureName,
        this.productStrength,
        this.productStatus,
        this.priceInclusiveVat,
    });

    factory ComplaintProductModal.fromJson(Map<String, dynamic> json) => ComplaintProductModal(
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        barcode: json["barcode"],
        itemGroup: json["itemGroup"],
        brand: json["brand"],
        modelNo: json["modelNo"],
        picturName: json["picturName"],
        userText: json["userText"],
        specList: json["specList"],
        supplierName: json["supplierName"],
        treeType: json["treeType"],
        price: json["price"],
        priceList: json["priceList"],
        discount: json["discount"],
        installationRequired: json["installationRequired"],
        itemPictureName: json["itemPictureName"],
        productStrength: json["productStrength"],
        productStatus: json["productStatus"],
        priceInclusiveVat: json["priceInclusiveVat"],
    );

    Map<String, dynamic> toJson() => {
        "cardCode": cardCode,
        "cardName": cardName,
        "itemCode": itemCode,
        "itemName": itemName,
        "barcode": barcode,
        "itemGroup": itemGroup,
        "brand": brand,
        "modelNo": modelNo,
        "picturName": picturName,
        "userText": userText,
        "specList": specList,
        "supplierName": supplierName,
        "treeType": treeType,
        "price": price,
        "priceList": priceList,
        "discount": discount,
        "installationRequired": installationRequired,
        "itemPictureName": itemPictureName,
        "productStrength": productStrength,
        "productStatus": productStatus,
        "priceInclusiveVat": priceInclusiveVat,
    };

    // Helper methods for safe access to potentially null values
    String get safeBrand => brand ?? '';
    String get safeModelNo => modelNo ?? '';
    String get safeItemName => itemName ?? '';
    String get safeItemCode => itemCode ?? '';
    String get safeBarcode => barcode ?? '';
    String get safeItemGroup => itemGroup ?? '';

    // Display name for dropdowns - combines brand and model with fallback
    String get displayName {
        final brandText = safeBrand;
        final modelText = safeModelNo;
        
        if (brandText.isNotEmpty && modelText.isNotEmpty) {
            return '$brandText - $modelText';
        } else if (brandText.isNotEmpty) {
            return brandText;
        } else if (modelText.isNotEmpty) {
            return modelText;
        } else if (safeItemName.isNotEmpty) {
            return safeItemName;
        } else {
            return safeItemCode.isNotEmpty ? safeItemCode : 'Unknown Product';
        }
    }

    @override
    String toString() {
        return displayName;
    }
}
