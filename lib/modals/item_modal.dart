// To parse this JSON data, do
//
//     final itemModal = itemModalFromJson(jsonString);

import 'dart:convert';

ItemModal itemModalFromJson(String str) => ItemModal.fromJson(json.decode(str));

String itemModalToJson(ItemModal data) => json.encode(data.toJson());

class ItemModal {
    String cardCode;
    String itemCode;
    String itemName;
    String barcode;
    String itemGroup;
    String brand;
    String modelNo;

    ItemModal({
        required this.cardCode,
        required this.itemCode,
        required this.itemName,
        required this.barcode,
        required this.itemGroup,
        required this.brand,
        required this.modelNo,
    });

    factory ItemModal.fromJson(Map<String, dynamic> json) => ItemModal(
        cardCode: json["cardCode"],
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        barcode: json["barcode"],
        itemGroup: json["itemGroup"],
        brand: json["brand"],
        modelNo: json["modelNo"],
    );

    Map<String, dynamic> toJson() => {
        "cardCode": cardCode,
        "itemCode": itemCode,
        "itemName": itemName,
        "barcode": barcode,
        "itemGroup": itemGroup,
        "brand": brand,
        "modelNo": modelNo,
    };

    @override
    String toString() {
      return modelNo;
    }
}
