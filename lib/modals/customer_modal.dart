// To parse this JSON data, do
//
//     final customerModal = customerModalFromJson(jsonString);

import 'dart:convert';

CustomerModal customerModalFromJson(String str) => CustomerModal.fromJson(json.decode(str));

String customerModalToJson(CustomerModal data) => json.encode(data.toJson());

class CustomerModal {
    dynamic firstName;
    dynamic middleName;
    dynamic lastName;
    dynamic email;
    dynamic phoneNumber;
    dynamic address;
    dynamic longitude;
    dynamic latitude;
    dynamic id;
    dynamic status;
    DateTime createdAt;
    dynamic registeredBy;

    CustomerModal({
        required this.firstName,
        required this.middleName,
        required this.lastName,
        required this.email,
        required this.phoneNumber,
        required this.address,
        required this.longitude,
        required this.latitude,
        required this.id,
        required this.status,
        required this.createdAt,
        required this.registeredBy,
    });

    factory CustomerModal.fromJson(Map<String, dynamic> json) => CustomerModal(
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        email: json["email"],
        phoneNumber: json["phone_number"],
        address: json["address"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        id: json["id"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        registeredBy: json["registered_by"],
    );

    Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "email": email,
        "phone_number": phoneNumber,
        "address": address,
        "longitude": longitude,
        "latitude": latitude,
        "id": id,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "registered_by": registeredBy,
    };
}
