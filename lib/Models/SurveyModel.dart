import 'package:flutter/material.dart';
import 'package:rightnurse/Models/ReactionsModel.dart';

class SurveyModel {
  dynamic id;
  dynamic question;
  SurveyTrust trust;
  dynamic type;
  List<AnswerModel> user_survey_answers;


  SurveyModel({
    @required this.id,
    @required this.question,
    this.trust,
    this.user_survey_answers,
  });


  factory SurveyModel.fromJson(Map<String,dynamic>json){
    List<AnswerModel> answers =[];
    SurveyTrust trust;

    if (json['user_survey_answers'] != null) {
      json['user_survey_answers'].forEach((element)=>answers.add(AnswerModel.fromJson(element)));
    }
    if(json['trust']!=null){
      trust = SurveyTrust.fromJson(json['trust']);
    }

    return SurveyModel (
        id: json['id'],
        question: json['question'],
        trust: trust,
        user_survey_answers: answers,

    );
  }
}



class AnswerModel {
  dynamic id;
  dynamic name;
  dynamic value;

  AnswerModel({
    @required this.id,
    @required this.name,
    @required this.value,

  });


  factory AnswerModel.fromJson(Map<String,dynamic>json){

    return AnswerModel (
        id: json['id'],
        name: json['name'],
        value: json['value'],
    );
  }
}


class SurveyTrust {
  dynamic id;
  dynamic name;
  dynamic trust_icon;
  dynamic system_type;
  dynamic timezone;
  dynamic created_at;
  dynamic updated_at;

  SurveyTrust({
    @required this.id,
    @required this.name,
    @required this.trust_icon,
    @required this.system_type,
    @required this.timezone,
    @required this.created_at,
    @required this.updated_at,

  });


  factory SurveyTrust.fromJson(Map<String,dynamic>json){

    return SurveyTrust (
        id: json['id'],
        name: json['name'],
        trust_icon: json['trust_icon'],
        system_type: json['system_type'],
        timezone: json['timezone'],
        created_at: json['created_at'],
        updated_at: json['updated_at'],
    );
  }
}