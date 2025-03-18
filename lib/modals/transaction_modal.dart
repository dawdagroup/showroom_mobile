// To parse this JSON data, do
//
//     final transactionModal = transactionModalFromJson(jsonString);

import 'dart:convert';

TransactionModal transactionModalFromJson(String str) => TransactionModal.fromJson(json.decode(str));

String transactionModalToJson(TransactionModal data) => json.encode(data.toJson());

class TransactionModal {
    int id;
    int customerId;
    String invoiceNumber;
    double totalAmount;
    double pointsEarned;
    double pointsRedeemed;
    String transactionType;
    DateTime createdAt;

    TransactionModal({
        required this.customerId,
        required this.invoiceNumber,
        required this.totalAmount,
        required this.pointsEarned,
        required this.pointsRedeemed,
        required this.transactionType,
        required this.id,
        required this.createdAt,
    });

    factory TransactionModal.fromJson(Map<String, dynamic> json) => TransactionModal(
        customerId: json["customer_id"],
        invoiceNumber: json["invoice_number"],
        totalAmount: json["total_amount"]?.toDouble(),
        pointsEarned: json["points_earned"]?.toDouble(),
        pointsRedeemed: json["points_redeemed"],
        transactionType: json["transaction_type"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "invoice_number": invoiceNumber,
        "total_amount": totalAmount,
        "points_earned": pointsEarned,
        "points_redeemed": pointsRedeemed,
        "transaction_type": transactionType,
        "id": id,
        "created_at": createdAt.toIso8601String(),
    };
}
