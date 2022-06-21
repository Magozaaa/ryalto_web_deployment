// Created by https://app.quicktype.io/

import 'dart:convert';

import 'package:rightnurse/Models/TrustModel.dart';

class Hospital {
  Hospital({
    this.id,
    this.name,
    this.trust,
    this.createdAt,
    this.updatedAt,
    this.shiftBookingType,

  });

  String id;
  String name;
  Trust trust;
  int createdAt;
  int updatedAt;
  String shiftBookingType;

  factory Hospital.fromRawJson(String str) => Hospital.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
        id: json["id"],
        name: json["name"],
        trust: Trust.fromJson(json["trust"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        shiftBookingType: json["shift_booking_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "trust": trust.toJson(),
        "created_at": createdAt,
        "updated_at": updatedAt,
        "shift_booking_type": shiftBookingType,
      };
}


class HospitalForUserAttributes {
  HospitalForUserAttributes({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.shiftBookingType,
    this.wards,
    this.positions,
    this.skills,
  });

  String id;
  String name;
  int createdAt;
  int updatedAt;
  String shiftBookingType;
  List<dynamic> wards;
  List<dynamic> positions;
  List<dynamic> skills;

  factory HospitalForUserAttributes.fromRawJson(String str) => HospitalForUserAttributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HospitalForUserAttributes.fromJson(Map<String, dynamic> json) => HospitalForUserAttributes(
    id: json["id"],
    name: json["name"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    shiftBookingType: json["shift_booking_type"],
    wards: json["wards"],
    positions: json["positions"],
    skills: json["skills"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "shift_booking_type": shiftBookingType,
    "wards": wards,
    "positions": positions,
    "skills": skills,
  };
}
