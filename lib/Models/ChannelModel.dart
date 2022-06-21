

// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class ChannelModel {
  String id;
  String name;
  String displayName;
  String channelType;
  var channelImage;
  String adminId;
  List<dynamic> participantIds;
  var notificationsEnabled;
  int lastMessageTimetoken;
  List<dynamic> participant;
  int memberCount;
  int createdAt;
  int updatedAt;
  int lastMsgAt;
  // dynamic lastMessageSent;

  ChannelModel({
    @required this.id,
    this.name,
    this.displayName,
    this.adminId,
    this.channelImage,
    this.channelType,
    this.notificationsEnabled,
    this.participantIds,
    this.lastMessageTimetoken,
    this.participant,
    this.memberCount,
    this.updatedAt,
    this.createdAt,
    this.lastMsgAt
    // this.lastMessageSent
  });


  factory ChannelModel.fromJson(Map<String,dynamic>json){
    return ChannelModel (
        id: json['id'],
        name: json['name'],
        displayName: json['display_name'],
        channelType: json['channel_type'],
        channelImage: json['channel_image'],
        adminId: json['admin_id'],
        participantIds: json['participant_ids'],
        notificationsEnabled: json['notifications_enabled'],
        participant: json['participants'],
        memberCount: json['member_count'],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        lastMsgAt: json["last_message_at"]
        // lastMessageSent: json["last_message_sent"]
    );
  }
}