// To parse this JSON data, do
//
//     final showroomSalesSummaryModal = showroomSalesSummaryModalFromJson(jsonString);

import 'dart:convert';

ShowroomSalesSummaryModal showroomSalesSummaryModalFromJson(String str) => ShowroomSalesSummaryModal.fromJson(json.decode(str));

String showroomSalesSummaryModalToJson(ShowroomSalesSummaryModal data) => json.encode(data.toJson());

class ShowroomSalesSummaryModal {
    dynamic showroomName;
    dynamic showroomId;
    dynamic salesAgentFullName;
    dynamic showroomSalesToDate;
    dynamic showroomSalesToday;
    dynamic salesAgentsSalesToday;

    ShowroomSalesSummaryModal({
        required this.showroomName,
        required this.showroomId,
        required this.salesAgentFullName,
        required this.showroomSalesToDate,
        required this.showroomSalesToday,
        required this.salesAgentsSalesToday,
    });

    factory ShowroomSalesSummaryModal.fromJson(Map<String, dynamic> json) => ShowroomSalesSummaryModal(
        showroomName: json["showroom_name"],
        showroomId: json["showroom_id"],
        salesAgentFullName: json["sales_agent_full_name"],
        showroomSalesToDate: json["showroom_sales_to_date"],
        showroomSalesToday: json["showroom_sales_today"],
        salesAgentsSalesToday: json["sales_agents_sales_today"],
    );

    Map<String, dynamic> toJson() => {
        "showroom_name": showroomName,
        "showroom_id": showroomId,
        "sales_agent_full_name": salesAgentFullName,
        "showroom_sales_to_date": showroomSalesToDate,
        "showroom_sales_today": showroomSalesToday,
        "sales_agents_sales_today": salesAgentsSalesToday,
    };
}
