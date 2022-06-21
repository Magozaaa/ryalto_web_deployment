

import 'package:flutter/material.dart';
import 'package:rightnurse/Models/ReactionsModel.dart';

class News {
  String id;
  String title;
  String thumbnail;
  String largeThumbnail;
  String url;
  String description;
  String published;
  List<dynamic> tags;
  String category;
  Map<String, dynamic> author;
  bool favorite;
  bool isNewArticle;
  var commentCount;
  List<Reaction> reactions;
  bool restricted_sharing;
  String documentUrl;

  News({
  @required this.id,
  @required this.title,
  this.author,
  this.favorite,
  this.category,
  this.commentCount,
  this.description,
  this.largeThumbnail,
  this.published,
  this.tags,
  this.thumbnail,
  this.url,
  this.restricted_sharing,
  this.reactions,
  this.isNewArticle,
  this.documentUrl
  });


  factory News.fromJson(Map<String,dynamic>json){
    List<Reaction> reactions =[];
    if (json['reactions'] != null) {
      json['reactions'].forEach((element)=>reactions.add(Reaction.fromJson(element)));
    }

    return News (
      id: json['id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      largeThumbnail: json['thumbnail_large'],
      description: json['description'],
      url: json['url'],
      published: json['published'],
      tags: json['tags'],
      category: json['category'],
      author: json['author'],
      favorite: json['favorite'],
      isNewArticle: json['new_article']??false,
      restricted_sharing: json['restricted_sharing'],
      documentUrl: json['document'],
      commentCount: json['comments_count'],
        reactions: reactions
    );
  }
}