// Created by https://app.quicktype.io/

import 'dart:convert';

class AreasOfWork {
  final List<AreaOfWork> areasOfWork;

  AreasOfWork({
    this.areasOfWork,
  });

  factory AreasOfWork.fromJson(List<dynamic> parsedJson) {
    List<AreaOfWork> positions = parsedJson.map((i) => AreaOfWork.fromJson(i)).toList();

    return AreasOfWork(
      areasOfWork: positions,
    );
  }
}

class AreaOfWork {
  AreaOfWork({
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
  AreaOfWorkHospital hospital;
  int createdAt;
  int updatedAt;

  factory AreaOfWork.fromRawJson(String str) => AreaOfWork.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AreaOfWork.fromJson(Map<String, dynamic> json) => AreaOfWork(
        id: json["id"],
        name: json["name"],
        order: json["order"],
        hospital: AreaOfWorkHospital.fromJson(json["hospital"]),
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

class AreaOfWorkHospital {
  AreaOfWorkHospital({
    this.id,
    this.name,
  });

  String id;
  String name;

  factory AreaOfWorkHospital.fromRawJson(String str) => AreaOfWorkHospital.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AreaOfWorkHospital.fromJson(Map<String, dynamic> json) => AreaOfWorkHospital(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
