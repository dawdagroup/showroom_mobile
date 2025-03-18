// To parse this JSON data, do
//
//     final productModal = productModalFromJson(jsonString);

import 'dart:convert';

import 'tax_group_modal.dart';

ProductModal productModalFromJson(String str) => ProductModal.fromJson(json.decode(str));

String productModalToJson(ProductModal data) => json.encode(data.toJson());

class ProductModal {
    dynamic cardCode;
    dynamic itemCode;
    dynamic itemName;
    dynamic barcode;
    dynamic itemGroup;
    dynamic brand;
    dynamic modelNo;
    dynamic picturName;
    dynamic userText;
    dynamic specs; 
    List<dynamic> specList;
    dynamic supplierName;
    dynamic treeType;
    double price;
    double discount;
    dynamic installationRequired;
    dynamic productStrength;
    dynamic productStatus;
    double priceInclusiveVat;
    TaxGroupModal? selectedTaxGroup;

    ProductModal({
        required this.cardCode,
        required this.itemCode,
        required this.itemName,
        required this.barcode,
        required this.itemGroup,
        required this.brand,
        required this.modelNo,
        required this.picturName,
        required this.userText,
        required this.specs,
        required this.specList,
        required this.supplierName,
        required this.treeType,
        required this.price,
        required this.discount,
        required this.installationRequired,
        required this.productStrength,
        required this.productStatus,
        required this.priceInclusiveVat,
        this.selectedTaxGroup,
    });

    factory ProductModal.fromJson(Map<String, dynamic> json) => ProductModal(
        cardCode: json["cardCode"],
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        barcode: json["barcode"],
        itemGroup: json["itemGroup"],
        brand: json["brand"],
        modelNo: json["modelNo"],
        picturName: json["picturName"],
        userText: json["userText"],
        specs: json["specs"],
        supplierName: json["supplierName"],
        treeType: json["treeType"],
        price: json["price"],
        discount: json["discount"],
        installationRequired: json["installationRequired"],
        productStrength: json["productStrength"],
        productStatus: json["productStatus"],
        priceInclusiveVat: json["priceInclusiveVat"],
        specList: List<String>.from(json["specList"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "cardCode": cardCode,
        "itemCode": itemCode,
        "itemName": itemName,
        "barcode": barcode,
        "itemGroup": itemGroup,
        "brand": brand,
        "modelNo": modelNo,
        "picturName": picturName,
        "userText": userText,
        "specs": specs,
        "supplierName": supplierName,
        "treeType": treeType,
        "price": price,
        "discount": discount,
        "installationRequired": installationRequired,
        "productStrength": productStrength,
        "productStatus": productStatus,
        "priceInclusiveVat": priceInclusiveVat,
        "specList": List<dynamic>.from(specList.map((x) => x)),
    };
  
  @override
  String toString() {
    return modelNo;
  }
}
