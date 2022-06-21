import 'package:flutter/material.dart';


class CountryModel {
  String id;
  String name;
  dynamic code;


  CountryModel({
    this.id,
    this.name,
    this.code,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
    id: json["id"],
    name: json["name"],
    code: json["code"],
  );
}