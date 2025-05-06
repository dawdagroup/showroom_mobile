// To parse this JSON data, do
//
//     final paymentDetailsModal = paymentDetailsModalFromJson(jsonString);

import 'dart:convert';

PaymentDetailsModal paymentDetailsModalFromJson(String str) => PaymentDetailsModal.fromJson(json.decode(str));

String paymentDetailsModalToJson(PaymentDetailsModal data) => json.encode(data.toJson());

class PaymentDetailsModal {
    dynamic invoiceNumber;
    dynamic mpesaAmount;
    dynamic creditCardAmount;
    dynamic cashAmount;
    dynamic checkAmount;

    PaymentDetailsModal({
        required this.invoiceNumber,
        required this.mpesaAmount,
        required this.creditCardAmount,
        required this.cashAmount,
        required this.checkAmount,
    });

    factory PaymentDetailsModal.fromJson(Map<String, dynamic> json) => PaymentDetailsModal(
        invoiceNumber: json["invoiceNumber"],
        mpesaAmount: json["mpesaAmount"],
        creditCardAmount: json["creditCardAmount"],
        cashAmount: json["cashAmount"],
        checkAmount: json["checkAmount"],
    );

    Map<String, dynamic> toJson() => {
        "invoiceNumber": invoiceNumber,
        "mpesaAmount": mpesaAmount,
        "creditCardAmount": creditCardAmount,
        "cashAmount": cashAmount,
        "checkAmount": checkAmount,
    };
}
