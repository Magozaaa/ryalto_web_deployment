// Created by https://app.quicktype.io/

import 'dart:convert';

import 'package:rightnurse/Models/SystemTypeModel.dart';

class Trust {
  Trust({
    this.id,
    this.name,
    this.trustIcon,
    this.systemType,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String name;
  dynamic trustIcon;
  SystemType systemType;
  String timezone;
  int createdAt;
  int updatedAt;

  Trust copyWith({
    String id,
    String name,
    dynamic trustIcon,
    SystemType systemType,
    String timezone,
    int createdAt,
    int updatedAt,
  }) =>
      Trust(
        id: id ?? this.id,
        name: name ?? this.name,
        trustIcon: trustIcon ?? this.trustIcon,
        systemType: systemType ?? this.systemType,
        timezone: timezone ?? this.timezone,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Trust.fromRawJson(String str) => Trust.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Trust.fromJson(Map<String, dynamic> json) => Trust(
        id: json["id"],
        name: json["name"],
        trustIcon: json["trust_icon"],
        systemType: SystemType.fromJson(json["system_type"]),
        timezone: json["timezone"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "trust_icon": trustIcon,
        "system_type": systemType.toJson(),
        "timezone": timezone,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
