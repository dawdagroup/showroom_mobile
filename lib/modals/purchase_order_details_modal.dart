// To parse this JSON data, do
//
//     final purchaseOrderDetailsModal = purchaseOrderDetailsModalFromJson(jsonString);

import 'dart:convert';

PurchaseOrderDetailsModal purchaseOrderDetailsModalFromJson(String str) => PurchaseOrderDetailsModal.fromJson(json.decode(str));

String purchaseOrderDetailsModalToJson(PurchaseOrderDetailsModal data) => json.encode(data.toJson());

class PurchaseOrderDetailsModal {
    dynamic docEntry;
    dynamic documentNumber;
    dynamic cardCode;
    dynamic cardName;
    dynamic address;
    dynamic documentStatus;
    dynamic documentDate;
    List<PurchaseOrderLineItem> lineItems;

    PurchaseOrderDetailsModal({
      required this.docEntry,
      required this.documentNumber,
      required this.cardCode,
      required this.cardName,
      required this.address,
      required this.documentStatus,
      required this.documentDate,
      required this.lineItems,
    });

    factory PurchaseOrderDetailsModal.fromJson(Map<String, dynamic> json) => PurchaseOrderDetailsModal(
      docEntry: json["docEntry"],
      documentNumber: json["documentNumber"],
      cardCode: json["cardCode"],
      cardName: json["cardName"],
      address: json["address"],
      documentStatus: json["documentStatus"],
      documentDate: DateTime.parse(json["documentDate"]),
      lineItems: List<PurchaseOrderLineItem>.from(json["lineItems"].map((x) => PurchaseOrderLineItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
      "docEntry": docEntry,
      "documentNumber": documentNumber,
      "cardCode": cardCode,
      "cardName": cardName,
      "address": address,
      "documentStatus": documentStatus,
      "documentDate": "${documentDate.year.toString().padLeft(4, '0')}-${documentDate.month.toString().padLeft(2, '0')}-${documentDate.day.toString().padLeft(2, '0')}",
      "lineItems": List<dynamic>.from(lineItems.map((x) => x.toJson())),
    };
}

class PurchaseOrderLineItem {
    int itemLineNumber;
    dynamic itemBaseLine;
    dynamic itemPrice;
    dynamic itemWarehouseCode;
    dynamic itemModelNumber;
    dynamic itemQuantity;
    dynamic itemCode;
    dynamic itemDescription;
    dynamic itemLineStatus;
    dynamic itemPictureName;
    dynamic itemName;
    dynamic itemImageUrl;
    dynamic itemOpenQuantity;

    PurchaseOrderLineItem({
      required this.itemLineNumber,
      required this.itemBaseLine,
      required this.itemPrice,
      required this.itemWarehouseCode,
      required this.itemModelNumber,
      required this.itemQuantity,
      required this.itemCode,
      required this.itemDescription,
      required this.itemLineStatus,
      required this.itemPictureName,
      required this.itemName,
      required this.itemImageUrl,
      required this.itemOpenQuantity,
    });

    factory PurchaseOrderLineItem.fromJson(Map<String, dynamic> json) => PurchaseOrderLineItem(
      itemLineNumber: json["itemLineNumber"],
      itemBaseLine: json["itemBaseLine"],
      itemPrice: json["itemPrice"]?.toDouble(),
      itemWarehouseCode: json["itemWarehouseCode"],
      itemModelNumber: json["itemModelNumber"],
      itemQuantity: json["itemQuantity"],
      itemCode: json["itemCode"],
      itemDescription: json["itemDescription"],
      itemLineStatus: json["itemLineStatus"],
      itemPictureName: json["itemPictureName"],
      itemName: json["itemName"],
      itemImageUrl: json["itemImageUrl"],
      itemOpenQuantity: json["itemOpenQuantity"],
    );

    Map<String, dynamic> toJson() => {
      "itemLineNumber": itemLineNumber,
      "itemBaseLine": itemBaseLine,
      "itemPrice": itemPrice,
      "itemWarehouseCode": itemWarehouseCode,
      "itemModelNumber": itemModelNumber,
      "itemQuantity": itemQuantity,
      "itemCode": itemCode,
      "itemDescription": itemDescription,
      "itemLineStatus": itemLineStatus,
      "itemPictureName": itemPictureName,
      "itemName": itemName,
      "itemImageUrl": itemImageUrl,
      "itemOpenQuantity": itemOpenQuantity,
    };
}
