// To parse this JSON data, do
//
//     final salesOrderDetailsModal = salesOrderDetailsModalFromJson(jsonString);

import 'dart:convert';

SalesOrderDetailsModal salesOrderDetailsModalFromJson(String str) => SalesOrderDetailsModal.fromJson(json.decode(str));

String salesOrderDetailsModalToJson(SalesOrderDetailsModal data) => json.encode(data.toJson());

class SalesOrderDetailsModal {
    dynamic docEntry;
    dynamic saleOrderNumber;
    dynamic documentStatus;
    dynamic inventoryStatus;
    DateTime documentDate;
    dynamic cardCode;
    dynamic cardName;
    dynamic address;
    dynamic docTotal;
    dynamic approvalStatus;
    dynamic customerName;
    dynamic customerPhone;
    dynamic customerEmail;
    dynamic customerIdNo;
    dynamic customerKraPin;
    dynamic amountReceived;
    dynamic customerChange;
    dynamic deliveryLocation;
    dynamic warehouseCode;
    dynamic servedBy;
    dynamic warehouseName;
    List<SalesOrderDetailsLineItem> lineItems;

    SalesOrderDetailsModal({
        required this.docEntry,
        required this.saleOrderNumber,
        required this.documentStatus,
        required this.inventoryStatus,
        required this.documentDate,
        required this.cardCode,
        required this.cardName,
        required this.address,
        required this.docTotal,
        required this.approvalStatus,
        required this.customerName,
        required this.customerPhone,
        required this.customerEmail,
        required this.customerIdNo,
        required this.customerKraPin,
        required this.amountReceived,
        required this.customerChange,
        required this.deliveryLocation,
        required this.warehouseCode,
        required this.servedBy,
        required this.warehouseName,
        required this.lineItems,
    });

    factory SalesOrderDetailsModal.fromJson(Map<String, dynamic> json) => SalesOrderDetailsModal(
        docEntry: json["docEntry"],
        saleOrderNumber: json["saleOrderNumber"],
        documentStatus: json["documentStatus"],
        inventoryStatus: json["inventoryStatus"],
        documentDate: DateTime.parse(json["documentDate"]),
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        address: json["address"],
        docTotal: json["docTotal"],
        approvalStatus: json["approvalStatus"],
        customerName: json["customerName"],
        customerPhone: json["customerPhone"],
        customerEmail: json["customerEmail"],
        customerIdNo: json["customerIdNo"],
        customerKraPin: json["customerKraPin"],
        amountReceived: json["amountReceived"],
        customerChange: json["customerChange"],
        deliveryLocation: json["deliveryLocation"],
        warehouseCode: json["warehouseCode"],
        servedBy: json["servedBy"],
        warehouseName: json["warehouseName"],
        lineItems: List<SalesOrderDetailsLineItem>.from(json["lineItems"].map((x) => SalesOrderDetailsLineItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "docEntry": docEntry,
        "saleOrderNumber": saleOrderNumber,
        "documentStatus": documentStatus,
        "inventoryStatus": inventoryStatus,
        "documentDate": "${documentDate.year.toString().padLeft(4, '0')}-${documentDate.month.toString().padLeft(2, '0')}-${documentDate.day.toString().padLeft(2, '0')}",
        "cardCode": cardCode,
        "cardName": cardName,
        "address": address,
        "docTotal": docTotal,
        "approvalStatus": approvalStatus,
        "customerName": customerName,
        "customerPhone": customerPhone,
        "customerEmail": customerEmail,
        "customerIdNo": customerIdNo,
        "customerKraPin": customerKraPin,
        "amountReceived": amountReceived,
        "customerChange": customerChange,
        "deliveryLocation": deliveryLocation,
        "warehouseCode": warehouseCode,
        "servedBy": servedBy,
        "warehouseName": warehouseName,
        "lineItems": List<dynamic>.from(lineItems.map((x) => x.toJson())),
    };
}

class SalesOrderDetailsLineItem {
    dynamic itemLineNumber;
    dynamic itemLineStatus;
    dynamic itemTreeType;
    dynamic itemCode;
    dynamic itemQuantity;
    dynamic itemOpenQuantity;
    dynamic itemTotal;
    dynamic itemModelNo;
    dynamic itemWarehouseCode;
    dynamic itemBarcode;
    dynamic itemName;
    dynamic itemListingCode;
    dynamic itemBrand;
    dynamic itemImageUrl;
    dynamic itemImage;
    dynamic itemPrice;
    dynamic itemVatPrcnt;
    dynamic itemVatGroup;
    dynamic itemPriceAfVat;
    dynamic itemGroup;

    SalesOrderDetailsLineItem({
        required this.itemLineNumber,
        required this.itemLineStatus,
        required this.itemTreeType,
        required this.itemCode,
        required this.itemQuantity,
        required this.itemOpenQuantity,
        required this.itemTotal,
        required this.itemModelNo,
        required this.itemWarehouseCode,
        required this.itemBarcode,
        required this.itemName,
        required this.itemListingCode,
        required this.itemBrand,
        required this.itemImageUrl,
        required this.itemImage,
        required this.itemPrice,
        required this.itemVatPrcnt,
        required this.itemVatGroup,
        required this.itemPriceAfVat,
        required this.itemGroup,
    });

    factory SalesOrderDetailsLineItem.fromJson(Map<String, dynamic> json) => SalesOrderDetailsLineItem(
        itemLineNumber: json["itemLineNumber"],
        itemLineStatus: json["itemLineStatus"],
        itemTreeType: json["itemTreeType"],
        itemCode: json["itemCode"],
        itemQuantity: json["itemQuantity"],
        itemOpenQuantity: json["itemOpenQuantity"],
        itemTotal: json["itemTotal"]?.toDouble(),
        itemModelNo: json["itemModelNo"],
        itemWarehouseCode: json["itemWarehouseCode"],
        itemBarcode: json["itemBarcode"],
        itemName: json["itemName"],
        itemListingCode: json["itemListingCode"],
        itemBrand: json["itemBrand"],
        itemImageUrl: json["itemImageUrl"],
        itemImage: json["itemImage"],
        itemPrice: json["itemPrice"]?.toDouble(),
        itemVatPrcnt: json["itemVatPrcnt"],
        itemVatGroup: json["itemVatGroup"],
        itemPriceAfVat: json["itemPriceAfVat"],
        itemGroup: json["itemGroup"],
    );

    Map<String, dynamic> toJson() => {
        "itemLineNumber": itemLineNumber,
        "itemLineStatus": itemLineStatus,
        "itemTreeType": itemTreeType,
        "itemCode": itemCode,
        "itemQuantity": itemQuantity,
        "itemOpenQuantity": itemOpenQuantity,
        "itemTotal": itemTotal,
        "itemModelNo": itemModelNo,
        "itemWarehouseCode": itemWarehouseCode,
        "itemBarcode": itemBarcode,
        "itemName": itemName,
        "itemListingCode": itemListingCode,
        "itemBrand": itemBrand,
        "itemImageUrl": itemImageUrl,
        "itemImage": itemImage,
        "itemPrice": itemPrice,
        "itemVatPrcnt": itemVatPrcnt,
        "itemVatGroup": itemVatGroup,
        "itemPriceAfVat": itemPriceAfVat,
        "itemGroup": itemGroup,
    };
}
