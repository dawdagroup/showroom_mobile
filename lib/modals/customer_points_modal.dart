// To parse this JSON data, do
//
//     final customerPointsModal = customerPointsModalFromJson(jsonString);

import 'dart:convert';

CustomerPointsModal customerPointsModalFromJson(String str) => CustomerPointsModal.fromJson(json.decode(str));

String customerPointsModalToJson(CustomerPointsModal data) => json.encode(data.toJson());

class CustomerPointsModal {
    int id;
    int customerId;
    double pointsEarned;
    double pointsRedeemed;
    double balancePoints;
    int transactionId;
    DateTime createdAt;

    CustomerPointsModal({
        required this.customerId,
        required this.pointsEarned,
        required this.pointsRedeemed,
        required this.balancePoints,
        required this.transactionId,
        required this.id,
        required this.createdAt,
    });

    factory CustomerPointsModal.fromJson(Map<String, dynamic> json) => CustomerPointsModal(
        customerId: json["customer_id"],
        pointsEarned: json["points_earned"],
        pointsRedeemed: json["points_redeemed"],
        balancePoints: json["balance_points"],
        transactionId: json["transaction_id"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "points_earned": pointsEarned,
        "points_redeemed": pointsRedeemed,
        "balance_points": balancePoints,
        "transaction_id": transactionId,
        "id": id,
        "created_at": createdAt.toIso8601String(),
    };
}
