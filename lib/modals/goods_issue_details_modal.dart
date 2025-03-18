// To parse this JSON data, do
//
//     final goodsIssueDetailsModal = goodsIssueDetailsModalFromJson(jsonString);

import 'dart:convert';

GoodsIssueDetailsModal goodsIssueDetailsModalFromJson(String str) => GoodsIssueDetailsModal.fromJson(json.decode(str));

String goodsIssueDetailsModalToJson(GoodsIssueDetailsModal data) => json.encode(data.toJson());

class GoodsIssueDetailsModal {
    int docEntry;
    int documentNumber;
    dynamic cardCode;
    dynamic cardName;
    dynamic address;
    dynamic documentStatus;
    DateTime documentDate;
    dynamic warehouseCode;
    dynamic deliveryLocation;
    dynamic receiverWahouse;
    dynamic documentType;
    dynamic warehouseName;
    List<GoodsIssueDetailsLineItem> lineItems;

    GoodsIssueDetailsModal({
        required this.docEntry,
        required this.documentNumber,
        required this.cardCode,
        required this.cardName,
        required this.address,
        required this.documentStatus,
        required this.documentDate,
        required this.warehouseCode,
        required this.deliveryLocation,
        required this.receiverWahouse,
        required this.documentType,
        required this.warehouseName,
        required this.lineItems,
    });

    factory GoodsIssueDetailsModal.fromJson(Map<String, dynamic> json) => GoodsIssueDetailsModal(
        docEntry: json["docEntry"],
        documentNumber: json["documentNumber"],
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        address: json["address"],
        documentStatus: json["documentStatus"],
        documentDate: DateTime.parse(json["documentDate"]),
        warehouseCode: json["warehouseCode"],
        deliveryLocation: json["deliveryLocation"],
        receiverWahouse: json["receiverWahouse"],
        documentType: json["documentType"],
        warehouseName: json["warehouseName"],
        lineItems: List<GoodsIssueDetailsLineItem>.from(json["lineItems"].map((x) => GoodsIssueDetailsLineItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "docEntry": docEntry,
        "documentNumber": documentNumber,
        "cardCode": cardCode,
        "cardName": cardName,
        "address": address,
        "documentStatus": documentStatus,
        "documentDate": "${documentDate.year.toString().padLeft(4, '0')}-${documentDate.month.toString().padLeft(2, '0')}-${documentDate.day.toString().padLeft(2, '0')}",
        "warehouseCode": warehouseCode,
        "deliveryLocation": deliveryLocation,
        "receiverWahouse": receiverWahouse,
        "documentType": documentType,
        "warehouseName": warehouseName,
        "lineItems": List<dynamic>.from(lineItems.map((x) => x.toJson())),
    };
}

class GoodsIssueDetailsLineItem {
    dynamic itemLineNum;
    dynamic itemBaseLine;
    dynamic itemPrice;
    dynamic itemWarehouseCode;
    dynamic itemCode;
    dynamic itemModelNo;
    dynamic itemQuantity;
    dynamic itemDescription;
    dynamic itemStatus;
    dynamic itemPictureName;
    dynamic itemName;
    dynamic itemImageUrl;
    dynamic itemDocEntry;
    dynamic itemOpenQuantity;

    GoodsIssueDetailsLineItem({
        required this.itemLineNum,
        required this.itemBaseLine,
        required this.itemPrice,
        required this.itemWarehouseCode,
        required this.itemCode,
        required this.itemModelNo,
        required this.itemQuantity,
        required this.itemDescription,
        required this.itemStatus,
        required this.itemPictureName,
        required this.itemName,
        required this.itemImageUrl,
        required this.itemDocEntry,
        required this.itemOpenQuantity,
    });

    factory GoodsIssueDetailsLineItem.fromJson(Map<String, dynamic> json) => GoodsIssueDetailsLineItem(
        itemLineNum: json["itemLineNum"],
        itemBaseLine: json["itemBaseLine"],
        itemPrice: json["itemPrice"]?.toDouble(),
        itemWarehouseCode: json["itemWarehouseCode"],
        itemCode: json["itemCode"],
        itemModelNo: json["itemModelNo"],
        itemQuantity: json["itemQuantity"],
        itemDescription: json["itemDescription"],
        itemStatus: json["itemStatus"],
        itemPictureName: json["itemPictureName"],
        itemName: json["itemName"],
        itemImageUrl: json["itemImageUrl"],
        itemDocEntry: json["itemDocEntry"],
        itemOpenQuantity: json["itemOpenQuantity"],
    );

    Map<String, dynamic> toJson() => {
        "itemLineNum": itemLineNum,
        "itemBaseLine": itemBaseLine,
        "itemPrice": itemPrice,
        "itemWarehouseCode": itemWarehouseCode,
        "itemCode": itemCode,
        "itemModelNo": itemModelNo,
        "itemQuantity": itemQuantity,
        "itemDescription": itemDescription,
        "itemStatus": itemStatus,
        "itemPictureName": itemPictureName,
        "itemName": itemName,
        "itemImageUrl": itemImageUrl,
        "itemDocEntry": itemDocEntry,
        "itemOpenQuantity": itemOpenQuantity,
    };
}
