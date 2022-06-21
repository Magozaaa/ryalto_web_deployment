

import 'package:flutter/material.dart';
import 'package:rightnurse/Models/ReactionsModel.dart';

class Comment {
  String id;
  dynamic parent_id;
  List<Reply> replies;
  List<Reaction> reactions;
  var body;
  var postId;
  String userId;
  dynamic user;
  String updatedAt;
  bool editing =false;
  bool canReply =true;

  Comment({
    @required this.id,
    this.parent_id,
    this.replies,
    this.reactions,
    this.body,
    this.postId,
    this.updatedAt,
    this.user,
    this.userId,
    this.editing = false,
    this.canReply = true
  });

  factory Comment.fromJson(Map<String,dynamic>json){
    List<Reply> replies =[];
    List<Reaction> reactions =[];

    if (json['replies'] != null) {
      json['replies'].forEach((element)=>replies.add(Reply.fromJson(element)));
    }
    if (json['reactions'] != null) {
      json['reactions'].forEach((element)=>reactions.add(Reaction.fromJson(element)));
    }


    return Comment (
        id: json['id'],
      parent_id: json['parent_id'],
      replies: replies ,
      reactions: reactions ,
        body: json['body'],
        postId: json['post_id'],
        userId: json['user_id'],
        updatedAt: json['updated_at'],
      user: json['user'],
    );
  }
}

class Reply {
  String id;
  dynamic parent_id;
  var body;
  var postId;
  String userId;
  dynamic user;
  List<Reaction> reactions;
  String updatedAt;
  bool editing =false;

  Reply({
    @required this.id,
    this.parent_id,
    this.body,
    this.postId,
    this.updatedAt,
    this.reactions,
    this.user,
    this.userId,
    this.editing = false
  });

  factory Reply.fromJson(Map<String,dynamic>json){
    List<Reaction> reactions =[];
    if (json['reactions'] != null) {
      json['reactions'].forEach((element)=>reactions.add(Reaction.fromJson(element)));
    }
    return Reply (
      id: json['id'],
      parent_id: json['parent_id'],
      body: json['body'],
      postId: json['post_id'],
      userId: json['user_id'],
      reactions: reactions,
      updatedAt: json['updated_at'],
      user: json['user'],
    );
  }
}