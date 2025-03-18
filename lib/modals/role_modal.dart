// To parse this JSON data, do
//
//     final role = roleFromJson(jsonString);

import 'dart:convert';

import 'permission_modal.dart';

Role roleFromJson(String str) => Role.fromJson(json.decode(str));

String roleToJson(Role data) => json.encode(data.toJson());

class Role {
    String name;
    List<Permission> permissions;

    Role({
        required this.name,
        required this.permissions,
    });

    factory Role.fromJson(Map<String, dynamic> json) => Role(
        name: json["roleName"],
        permissions: List<Permission>.from(json["permissions"].map((x) => Permission.fromJson( {"name" : x }))),
    );

    Map<String, dynamic> toJson() => {
        "roleName": name,
        "permissions": List<dynamic>.from(permissions.map((x) => x.toJson())),
    };
}