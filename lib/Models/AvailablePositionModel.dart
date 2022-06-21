// Created by https://app.quicktype.io/

import 'dart:convert';

import 'package:rightnurse/Models/HospitalModel.dart';

class AvailablePositions {
  final List<AvailablePosition> positions;

  AvailablePositions({
    this.positions,
  });

  factory AvailablePositions.fromJson(List<dynamic> parsedJson) {
    List<AvailablePosition> listOfPositionsHaveHospital =[];
    List<AvailablePosition> positions = parsedJson.map((i) => AvailablePosition.fromJson(i)).toList();

    parsedJson.forEach((element) {
      if(element['hospital'] != null){
        listOfPositionsHaveHospital.add(AvailablePosition.fromJson(element));
      }
    });

    return AvailablePositions(positions: listOfPositionsHaveHospital);
    //   AvailablePositions(
    //   positions: positions,
    // );
  }
}

class AvailablePosition {
  AvailablePosition({
    this.id,
    this.name,
    this.roleType,
    this.country,
    this.hospital,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String name;
  int roleType;
  Country country;
  Hospital hospital;
  int createdAt;
  int updatedAt;

  AvailablePosition copyWith({
    String id,
    String name,
    int roleType,
    Country country,
    Hospital hospital,
    int createdAt,
    int updatedAt,
  }) =>
      AvailablePosition(
        id: id ?? this.id,
        name: name ?? this.name,
        roleType: roleType ?? this.roleType,
        country: country ?? this.country,
        hospital: hospital ?? this.hospital,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory AvailablePosition.fromRawJson(String str) => AvailablePosition.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AvailablePosition.fromJson(Map<String, dynamic> json) => AvailablePosition(
        id: json["id"],
        name: json["name"],
        roleType: json["role_type"],
        country: Country.fromJson(json["country"]),
        hospital: json["hospital"] == null ? null : Hospital.fromJson(json["hospital"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "role_type": roleType,
        "country": country.toJson(),
        "hospital": hospital.toJson(),
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Country {
  Country({
    this.id,
    this.name,
    this.code,
  });

  String id;
  String name;
  String code;

  Country copyWith({
    String id,
    String name,
    String code,
  }) =>
      Country(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
      );

  factory Country.fromRawJson(String str) => Country.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        name: json["name"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
      };
}


class OfferRole {
  OfferRole({
    this.id,
    this.name,
    this.role_id,
    this.created_at,
    this.updated_at,
    this.hospital_id,
    this.role_type,
    this.country_id,
    this.trust_id,
  });

  String id;
  String name;
  dynamic role_id;
  dynamic created_at;
  dynamic updated_at;
  dynamic hospital_id;
  dynamic role_type;
  dynamic country_id;
  dynamic trust_id;

  OfferRole copyWith({
    String id,
    String name,
    dynamic role_id,
    dynamic created_at,
    dynamic updated_at,
    dynamic hospital_id,
    dynamic role_type,
    dynamic country_id,
    dynamic trust_id,
  }) =>
      OfferRole(
        id: id ?? this.id,
        name: name ?? this.name,
        role_id: role_id ?? this.role_id,
        created_at: created_at ?? this.created_at,
        updated_at: updated_at ?? this.updated_at,
        hospital_id: hospital_id ?? this.hospital_id,
        role_type: role_type ?? this.role_type,
        country_id: country_id ?? this.country_id,
        trust_id: trust_id ?? this.trust_id,
      );

  factory OfferRole.fromRawJson(String str) => OfferRole.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OfferRole.fromJson(Map<String, dynamic> json) => OfferRole(
        id: json["id"],
        name: json["name"],
        role_id: json["role_id"],
        created_at: json["created_at"],
        updated_at: json["updated_at"],
        hospital_id: json["hospital_id"],
        role_type: json["role_type"],
        country_id: json["country_id"],
        trust_id: json["trust_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "role_id": role_id,
        "created_at" : created_at,
        "updated_at" : updated_at
      };
}
