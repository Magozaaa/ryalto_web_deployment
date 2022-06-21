// Created by https://app.quicktype.io/

import 'dart:convert';

class SystemType {
  SystemType({
    this.id,
    this.name,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String name;
  int value;
  int createdAt;
  int updatedAt;

  SystemType copyWith({
    String id,
    String name,
    int value,
    int createdAt,
    int updatedAt,
  }) =>
      SystemType(
        id: id ?? this.id,
        name: name ?? this.name,
        value: value ?? this.value,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory SystemType.fromRawJson(String str) => SystemType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SystemType.fromJson(Map<String, dynamic> json) => SystemType(
        id: json["id"],
        name: json["name"],
        value: json["value"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
