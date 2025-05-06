// To parse this JSON data, do
//
//     final warehouseModal = warehouseModalFromJson(jsonString);

import 'dart:convert';

WarehouseModal warehouseModalFromJson(String str) => WarehouseModal.fromJson(json.decode(str));

String warehouseModalToJson(WarehouseModal data) => json.encode(data.toJson());

class WarehouseModal {
    String name;
    String code;
    dynamic isDisplay;
    dynamic isStore;
    dynamic isVirtual;
    dynamic isSellable;
    dynamic isHqStore;

    WarehouseModal({
        required this.name,
        required this.code,
        required this.isDisplay,
        required this.isStore,
        required this.isVirtual,
        required this.isSellable,
        required this.isHqStore,
    });

    factory WarehouseModal.fromJson(Map<String, dynamic> json) => WarehouseModal(
        name: json["name"],
        code: json["code"],
        isDisplay: json["is_display"],
        isStore: json["is_store"],
        isVirtual: json["is_virtual"],
        isSellable: json["is_sellable"],
        isHqStore: json["is_hq_store"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "is_display": isDisplay,
        "is_store": isStore,
        "is_virtual": isVirtual,
        "is_sellable": isSellable,
        "is_hq_store": isHqStore,
    };
    
  @override
  String toString() {
    return name;
  }
}
