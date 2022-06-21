// Created by https://app.quicktype.io/

import 'dart:convert';

import 'package:rightnurse/Models/HospitalModel.dart';

class Skills {
  final List<Skill> skills;

  Skills({
    this.skills,
  });

  factory Skills.fromJson(List<dynamic> parsedJson) {
    List<Skill> positions = parsedJson.map((i) => Skill.fromJson(i)).toList();

    return Skills(
      skills: positions,
    );
  }
}

class Skill {
  Skill({
    this.id,
    this.name,
    this.order,
    this.hospital,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String name;
  int order;
  Hospital hospital;
  int createdAt;
  int updatedAt;

  factory Skill.fromRawJson(String str) => Skill.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json["id"],
        name: json["name"],
        order: json["order"],
        hospital: Hospital.fromJson(json["hospital"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "order": order,
        "hospital": hospital.toJson(),
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
