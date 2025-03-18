// To parse this JSON data, do
//
//     final permission = permissionFromJson(jsonString);

import 'dart:convert';

Permission permissionFromJson(String str) => Permission.fromJson(json.decode(str));

String permissionToJson(Permission data) => json.encode(data.toJson());

class Permission {
    String name;

    Permission({
        required this.name,
    });

    factory Permission.fromJson(Map<String, dynamic> json) => Permission(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}