/// Created by https://app.quicktype.io/

import 'dart:convert';

class Levels {
  final List<Level> bands;

  Levels({
    this.bands,
  });

  factory Levels.fromJson(List<dynamic> parsedJson) {
    List<Level> positions = parsedJson.map((i) => Level.fromJson(i)).toList();

    return Levels(
      bands: positions,
    );
  }
}

class Level {
  Level({
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
  CountryCode countryCode;
  int createdAt;
  int updatedAt;

  factory Level.fromRawJson(String str) => Level.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Level.fromJson(Map<String, dynamic> json) => Level(
        id: json["id"],
        name: json["name"],
        value: json["value"],
        countryCode: countryCodeValues.map[json["country_code"]],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
        "country_code": countryCodeValues.reverse[countryCode],
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}



class OfferLevel {
  OfferLevel({
    this.id,
    this.name,
    this.value,
    this.country_id,
    this.createdAt,
    this.updatedAt,
    this.hospital_id,
    this.trust_id
  });

  String id;
  String name;
  int value;
  dynamic country_id;
  dynamic trust_id;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic hospital_id;

  factory OfferLevel.fromRawJson(String str) => OfferLevel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OfferLevel.fromJson(Map<String, dynamic> json) => OfferLevel(
        id: json["id"],
        name: json["name"],
        value: json["value"],
        country_id: countryCodeValues.map[json["country_code"]],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        hospital_id: json["hospital_id"]??"",
        trust_id: json["trust_id"]??""
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

enum CountryCode { GB }

final countryCodeValues = EnumValues({"GB": CountryCode.GB});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
