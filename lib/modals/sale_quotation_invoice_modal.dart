// To parse this JSON data, do
//
//     final saleQuotationInvoiceModal = saleQuotationInvoiceModalFromJson(jsonString);

import 'dart:convert';

SaleQuotationInvoiceModal saleQuotationInvoiceModalFromJson(String str) => SaleQuotationInvoiceModal.fromJson(json.decode(str));

String saleQuotationInvoiceModalToJson(SaleQuotationInvoiceModal data) => json.encode(data.toJson());

class SaleQuotationInvoiceModal {
    dynamic quotationDocEntry;
    dynamic quotationNumber;
    dynamic invoiceDocEntry;
    dynamic invoiceNumber;

    SaleQuotationInvoiceModal({
        required this.quotationDocEntry,
        required this.quotationNumber,
        required this.invoiceDocEntry,
        required this.invoiceNumber,
    });

    factory SaleQuotationInvoiceModal.fromJson(Map<String, dynamic> json) => SaleQuotationInvoiceModal(
        quotationDocEntry: json["quotationDocEntry"],
        quotationNumber: json["quotationNumber"],
        invoiceDocEntry: json["invoiceDocEntry"],
        invoiceNumber: json["invoiceNumber"],
    );

    Map<String, dynamic> toJson() => {
        "quotationDocEntry": quotationDocEntry,
        "quotationNumber": quotationNumber,
        "invoiceDocEntry": invoiceDocEntry,
        "invoiceNumber": invoiceNumber,
    };
}
