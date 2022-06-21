// Created by https://app.quicktype.io/

import 'dart:convert';

class Languages {
  final List<Language> languages;

  Languages({
    this.languages,
  });

  factory Languages.fromJson(List<dynamic> parsedJson) {
    List<Language> positions = parsedJson.map((i) => Language.fromJson(i)).toList();

    return Languages(
      languages: positions,
    );
  }
}

class Language {
  Language({
    this.id,
    this.name,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String name;
  int order;
  int createdAt;
  int updatedAt;

  factory Language.fromRawJson(String str) => Language.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["id"],
        name: json["name"],
        order: json["order"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "order": order,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
