// To parse this JSON data, do
//
//     final invoiceDetailsModal = invoiceDetailsModalFromJson(jsonString);

import 'dart:convert';


InvoiceDetailsModal invoiceDetailsModalFromJson(String str) => InvoiceDetailsModal.fromJson(json.decode(str));

String invoiceDetailsModalToJson(InvoiceDetailsModal data) => json.encode(data.toJson());

class InvoiceDetailsModal {
    dynamic inventoryStatus;
    dynamic invoiceStatus;
    dynamic cardCode;
    dynamic cardName;
    dynamic address;
    dynamic docEntry;
    dynamic invoiceNumber;
    DateTime invoiceDate;
    String invoiceTime;
    dynamic warehouseCode;
    dynamic warehouseName;
    dynamic showroomName;
    dynamic deliveryLocation;
    dynamic customerName;
    dynamic customerPhoneNo;
    dynamic customerEmail;
    double invoiceTotal;
    dynamic servedBy;
    dynamic fiscalizationNumber;
    dynamic cuSerial;
    dynamic qrCodeLink;
    dynamic cuDate;
    dynamic customerKraPin;
    dynamic invoiceVatTotal;
    dynamic invoiceAmtRecd;
    List<InvoiceItem> invoiceItems;

    InvoiceDetailsModal({
        required this.inventoryStatus,
        required this.invoiceStatus,
        required this.cardCode,
        required this.cardName,
        required this.address,
        required this.docEntry,
        required this.invoiceNumber,
        required this.invoiceDate,
        required this.invoiceTime,
        required this.warehouseCode,
        required this.warehouseName,
        required this.showroomName,
        required this.deliveryLocation,
        required this.customerName,
        required this.customerPhoneNo,
        required this.customerEmail,
        required this.invoiceTotal,
        required this.servedBy,
        required this.fiscalizationNumber,
        required this.cuSerial,
        required this.qrCodeLink,
        required this.cuDate,
        required this.customerKraPin,
        required this.invoiceVatTotal,
        required this.invoiceAmtRecd,
        required this.invoiceItems,
    });

    factory InvoiceDetailsModal.fromJson(Map<String, dynamic> json) => InvoiceDetailsModal(
        inventoryStatus: json["inventoryStatus"],
        invoiceStatus: json["invoiceStatus"],
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        address: json["address"],
        docEntry: json["docEntry"],
        invoiceNumber: json["invoiceNumber"],
        invoiceDate: DateTime.parse(json["invoiceDate"]),
        invoiceTime: json["invoiceTime"],
        warehouseCode: json["warehouseCode"],
        warehouseName: json["warehouseName"],
        showroomName: json["showroomName"],
        deliveryLocation: json["deliveryLocation"],
        customerName: json["customerName"],
        customerPhoneNo: json["customerPhoneNo"],
        customerEmail: json["customerEmail"],
        invoiceTotal: json["invoiceTotal"]?.toDouble(),
        servedBy: json["servedBy"],
        fiscalizationNumber: json["fiscalizationNumber"],
        cuSerial: json["cuSerial"],
        qrCodeLink: json["qrCodeLink"],
        cuDate: json["cuDate"],
        customerKraPin: json["customerKraPin"],
        invoiceVatTotal: json["invoiceVatTotal"],
        invoiceAmtRecd: json["invoiceAmtRecd"],
        invoiceItems: List<InvoiceItem>.from(json["invoiceItems"].map((x) => InvoiceItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "inventoryStatus": inventoryStatus,
        "invoiceStatus": invoiceStatus,
        "cardCode": cardCode,
        "cardName": cardName,
        "address": address,
        "docEntry": docEntry,
        "invoiceNumber": invoiceNumber,
        "invoiceDate": "${invoiceDate.year.toString().padLeft(4, '0')}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}",
        "invoiceTime": invoiceTime,
        "warehouseCode": warehouseCode,
        "warehouseName": warehouseName,
        "showroomName": showroomName,
        "deliveryLocation": deliveryLocation,
        "customerName": customerName,
        "customerPhoneNo": customerPhoneNo,
        "customerEmail": customerEmail,
        "invoiceTotal": invoiceTotal,
        "servedBy": servedBy,
        "fiscalizationNumber": fiscalizationNumber,
        "cuSerial": cuSerial,
        "qrCodeLink": qrCodeLink,
        "cuDate": cuDate,
        "customerKraPin": customerKraPin,
        "invoiceVatTotal": invoiceVatTotal,
        "invoiceAmtRecd": invoiceAmtRecd,
        "invoiceItems": List<dynamic>.from(invoiceItems.map((x) => x.toJson())),
    };
}

class InvoiceItem {
    dynamic itemLineNum;
    dynamic itemBaseRef;
    dynamic itemBaseLine;
    dynamic itemBaseEntry;
    dynamic itemBaseType;
    dynamic itemCode;
    dynamic lineStatus;
    dynamic itemDescription;
    double quantity;
    dynamic itemOpenQty;
    dynamic itemWarehouseCode;
    dynamic itemPictureName;
    dynamic itemInventoryStatus;
    dynamic itemVatPerc;
    dynamic itemPrice;
    dynamic itemVatGroup;
    dynamic itemBarcode;
    dynamic itemBrand;
    dynamic itemModelNo;
    dynamic itemTreeType;
    dynamic itemImageUrl;
    dynamic itemGroup;
    dynamic itemDiscountPerc;
    double itemPriceAfVat;
    dynamic itemName;
    dynamic itemTotal;
    dynamic itemVatTotal;

    InvoiceItem({
        required this.itemLineNum,
        required this.itemBaseRef,
        required this.itemBaseLine,
        required this.itemBaseEntry,
        required this.itemBaseType,
        required this.itemCode,
        required this.lineStatus,
        required this.itemDescription,
        required this.quantity,
        required this.itemOpenQty,
        required this.itemWarehouseCode,
        required this.itemPictureName,
        required this.itemInventoryStatus,
        required this.itemVatPerc,
        required this.itemPrice,
        required this.itemVatGroup,
        required this.itemBarcode,
        required this.itemBrand,
        required this.itemModelNo,
        required this.itemTreeType,
        required this.itemImageUrl,
        required this.itemGroup,
        required this.itemDiscountPerc,
        required this.itemPriceAfVat,
        required this.itemName,
        required this.itemTotal,
        required this.itemVatTotal
    });

    factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        itemLineNum: json["itemLineNum"],
        itemBaseRef: json["itemBaseRef"],
        itemBaseLine: json["itemBaseLine"],
        itemBaseEntry: json["itemBaseEntry"],
        itemBaseType: json["itemBaseType"],
        itemCode: json["itemCode"],
        lineStatus: json["lineStatus"],
        itemDescription: json["itemDescription"],
        quantity: json["quantity"],
        itemOpenQty: json["itemOpenQty"],
        itemWarehouseCode: json["itemWarehouseCode"],
        itemPictureName: json["itemPictureName"],
        itemInventoryStatus: json["itemInventoryStatus"],
        itemVatPerc: json["itemVatPerc"],
        itemPrice: json["itemPrice"]?.toDouble(),
        itemVatGroup: json["itemVatGroup"],
        itemBarcode: json["itemBarcode"],
        itemBrand: json["itemBrand"],
        itemModelNo: json["itemModelNo"],
        itemTreeType: json["itemTreeType"],
        itemImageUrl: json["itemImageUrl"],
        itemGroup: json["itemGroup"],
        itemDiscountPerc: json["itemDiscountPerc"],
        itemPriceAfVat: json["itemPriceAfVAT"]?.toDouble(),
        itemName: json["itemName"],
        itemTotal: json["itemTotal"],
        itemVatTotal: json["itemVatTotal"]
    );

    Map<String, dynamic> toJson() => {
        "itemLineNum": itemLineNum,
        "itemBaseRef": itemBaseRef,
        "itemBaseLine": itemBaseLine,
        "itemBaseEntry": itemBaseEntry,
        "itemBaseType": itemBaseType,
        "itemCode": itemCode,
        "lineStatus": lineStatus,
        "itemDescription": itemDescription,
        "quantity": quantity,
        "itemOpenQty": itemOpenQty,
        "itemWarehouseCode": itemWarehouseCode,
        "itemPictureName": itemPictureName,
        "itemInventoryStatus": itemInventoryStatus,
        "itemVatPerc": itemVatPerc,
        "itemPrice": itemPrice,
        "itemVatGroup": itemVatGroup,
        "itemBarcode": itemBarcode,
        "itemBrand": itemBrand,
        "itemModelNo": itemModelNo,
        "itemTreeType": itemTreeType,
        "itemImageUrl": itemImageUrl,
        "itemGroup": itemGroup,
        "itemDiscountPerc": itemDiscountPerc,
        "itemPriceAfVAT": itemPriceAfVat,
        "itemName": itemName,
        "itemTotal": itemTotal,
        "itemVatTotal": itemVatTotal
    };
}
