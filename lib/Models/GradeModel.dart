/// Created by https://app.quicktype.io/

import 'dart:convert';

class Grades {
  final List<Grade> grades;

  Grades({
    this.grades,
  });

  factory Grades.fromJson(List<dynamic> parsedJson) {
    List<Grade> positions = parsedJson.map((i) => Grade.fromJson(i)).toList();

    return Grades(
      grades: positions,
    );
  }
}

class Grade {
  Grade({
    this.id,
    this.name,
    this.value,
    this.countryCode,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String name;
  int value;
  String countryCode;
  int createdAt;
  int updatedAt;

  factory Grade.fromRawJson(String str) => Grade.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
        id: json["id"],
        name: json["name"],
        value: json["value"],
        countryCode: json["country_code"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
        "country_code": countryCode,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
