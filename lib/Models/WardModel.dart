import 'package:flutter/material.dart';


class WardModel {
  String id;
  String name;
  dynamic trust_id;
  dynamic created_at;
  dynamic updated_at;
  dynamic shift_booking_type;
  dynamic wards;


  WardModel({
    this.id,
    this.name,
    this.trust_id,
    this.created_at,
    this.updated_at,
    this.shift_booking_type,
    this.wards,
  });

  factory WardModel.fromJson(Map<String, dynamic> json) => WardModel(
    id: json["id"],
    name: json["name"],
    trust_id: json["trust_id"],
    created_at: json["created_at"],
    updated_at: json["updated_at"],
    shift_booking_type: json["shift_booking_type"],
    wards: json["wards"],
  );
}