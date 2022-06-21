// Created by https://app.quicktype.io/

import 'dart:convert';

class Memberships {
  final List<Membership> memberships;

  Memberships({
    this.memberships,
  });

  factory Memberships.fromJson(List<dynamic> parsedJson) {
    List<Membership> positions = parsedJson.map((i) => Membership.fromJson(i)).toList();

    return Memberships(
      memberships: positions,
    );
  }
}

class Membership {
  Membership({
    this.id,
    this.name,
  });

  String id;
  String name;

  factory Membership.fromRawJson(String str) => Membership.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
