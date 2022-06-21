import 'package:flutter/material.dart';


class UserTypeModel {
  String id;
  String name;
  dynamic role_type;


  UserTypeModel({
    this.id,
    this.name,
    this.role_type,
});

  factory UserTypeModel.fromJson(Map<String, dynamic> json) => UserTypeModel(
    id: json["id"],
    name: json["name"],
    role_type: json["role_type"],
  );
}