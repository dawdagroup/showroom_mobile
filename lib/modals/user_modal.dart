// To parse this JSON data, do
//
//     final userModal = userModalFromJson(jsonString);

import 'dart:convert';

UserModal userModalFromJson(String str) => UserModal.fromJson(json.decode(str));

String userModalToJson(UserModal data) => json.encode(data.toJson());

class UserModal {
    String email;
    String username;
    String firstName;
    String middleName;
    String lastName;
    bool isActive;
    String phoneNumber;
    String status;
    int id;

    UserModal({
        required this.email,
        required this.username,
        required this.firstName,
        required this.middleName,
        required this.lastName,
        required this.isActive,
        required this.phoneNumber,
        required this.status,
        required this.id,
    });

    factory UserModal.fromJson(Map<String, dynamic> json) => UserModal(
        email: json["email"],
        username: json["username"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        isActive: json["is_active"],
        phoneNumber: json["phone_number"],
        status: json["status"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "username": username,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "is_active": isActive,
        "phone_number": phoneNumber,
        "status": status,
        "id": id,
    };
  
    String get fullName => "$firstName $middleName $lastName";
}
