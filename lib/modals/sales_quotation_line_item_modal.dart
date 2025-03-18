
class SalesQuotationLineItemModal {
    int itemLineNum;
    dynamic itemCode;
    dynamic itemDescription;
    dynamic quantity;
    dynamic itemOpenQty;
    dynamic itemPrice;
    dynamic itemWarehouseCode;
    dynamic itemBarcode;
    dynamic itemVatPerc;
    dynamic itemVatGroup;
    dynamic brand;
    dynamic itemModelNo;
    dynamic itemGroupOne;
    dynamic itemGroupTwo;
    dynamic itemGroupThree;
    dynamic itemGroupFour;
    dynamic itemPictureName;
    dynamic itemImageUrl;
    dynamic itemDiscountPerc;

    SalesQuotationLineItemModal({
        required this.itemLineNum,
        required this.itemCode,
        required this.itemDescription,
        required this.quantity,
        required this.itemOpenQty,
        required this.itemPrice,
        required this.itemWarehouseCode,
        required this.itemBarcode,
        required this.itemVatPerc,
        required this.itemVatGroup,
        required this.brand,
        required this.itemModelNo,
        required this.itemGroupOne,
        required this.itemGroupTwo,
        required this.itemGroupThree,
        required this.itemGroupFour,
        required this.itemPictureName,
        required this.itemImageUrl,
        required this.itemDiscountPerc,
    });

    factory SalesQuotationLineItemModal.fromJson(Map<String, dynamic> json) => SalesQuotationLineItemModal(
        itemLineNum: json["itemLineNum"],
        itemCode: json["itemCode"],
        itemDescription: json["itemDescription"],
        quantity: json["quantity"],
        itemOpenQty: json["itemOpenQty"],
        itemPrice: json["itemPrice"],
        itemWarehouseCode: json["itemWarehouseCode"],
        itemBarcode: json["itemBarcode"],
        itemVatPerc: json["itemVatPerc"],
        itemVatGroup: json["itemVatGroup"],
        brand: json["brand"],
        itemModelNo: json["itemModelNo"],
        itemGroupOne: json["itemGroupOne"],
        itemGroupTwo: json["itemGroupTwo"],
        itemGroupThree: json["itemGroupThree"],
        itemGroupFour: json["itemGroupFour"],
        itemPictureName: json["itemPictureName"],
        itemImageUrl: json["itemImageUrl"],
        itemDiscountPerc: json["itemDiscountPerc"],
    );

    Map<String, dynamic> toJson() => {
        "itemLineNum": itemLineNum,
        "itemCode": itemCode,
        "itemDescription": itemDescription,
        "quantity": quantity,
        "itemOpenQty": itemOpenQty,
        "itemPrice": itemPrice,
        "itemWarehouseCode": itemWarehouseCode,
        "itemBarcode": itemBarcode,
        "itemVatPerc": itemVatPerc,
        "itemVatGroup": itemVatGroup,
        "brand": brand,
        "itemModelNo": itemModelNo,
        "itemGroupOne": itemGroupOne,
        "itemGroupTwo": itemGroupTwo,
        "itemGroupThree": itemGroupThree,
        "itemGroupFour": itemGroupFour,
        "itemPictureName": itemPictureName,
        "itemImageUrl": itemImageUrl,
        "itemDiscountPerc": itemDiscountPerc,
    };
}
