// ignore_for_file: file_names, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'package:meta/meta.dart';

class User {
  String id;
  String name;
  String firstName;
  String lastName;
  String email;
  String phone;
  bool profileCompleted;
  String offerId;
  bool makeOffer;
  var connectionInCommonCount;
  String token;
  List<dynamic> commonConnection;
  String profilePic;
  var roleType;
  var availability;
  String chatPublicKey;
  String chatPrivateKey;
  bool emailVerified;
  var lengthUnitType;
  bool verified;
  bool headUser;
  bool favorite;
  bool chat_push_notifications_enabled;
  bool daily_email_notifications_enabled;
  bool offer_push_notifications_enabled;
  bool offer_email_notifications_enabled;
  bool shift_reminder_push_notifications_enabled;
  Map<String, dynamic> trust;
  Map<String, dynamic> country;
  String countryCode;
  String trust_support_user;
  String employee_number;
  String nhsp_staff_id;
  var nhsp_web_user_id;
  var points;
  var date_of_birth;
  String staff_badge;
  List<dynamic> preferred_wards;
  List<dynamic> memberships;
  List<dynamic> hospitals;
  String notifications_unseen_count;
  String pin_number;
  var contractor_type;
  Map<String, dynamic> grade;
  Map<String, dynamic> band;
  Map<String, dynamic> minAcceptedGrade;
  Map<String, dynamic> minAcceptedBand;
  bool bank_shift_approved;
  bool super_user;
  String nmc_code;
  List<dynamic> languages;
  List<dynamic> roles;
  List<dynamic> skills;
  List<dynamic>  wards;
  bool canShareDocs;
  int lastLogoutAt;


  User({
    @required this.id,
    @required this.name,
    @required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    @required this.profileCompleted,
    this.offerId,
    this.makeOffer,
    this.commonConnection,
    @required this.token,
    this.connectionInCommonCount,
    this.availability,
    this.grade,
    this.bank_shift_approved,
    this.chat_push_notifications_enabled,
    this.chatPrivateKey,
    this.chatPublicKey,
    this.contractor_type,
    this.country,
    this.countryCode,
    this.daily_email_notifications_enabled,
    this.date_of_birth,
    this.emailVerified,
    this.employee_number,
    this.favorite,
    this.headUser,
    this.hospitals,
    this.languages,
    this.lengthUnitType,
    this.memberships,
    this.minAcceptedBand,
    this.nhsp_staff_id,
    this.nhsp_web_user_id,
    this.nmc_code,
    this.notifications_unseen_count,
    this.offer_email_notifications_enabled,
    this.offer_push_notifications_enabled,
    this.pin_number,
    this.points,
    this.preferred_wards,
    this.profilePic,
    this.roles,
    this.roleType,
    this.shift_reminder_push_notifications_enabled,
    this.skills,
    this.staff_badge,
    this.super_user,
    this.trust,
    this.trust_support_user,
    this.verified,
    this.wards,
    this.band,
    this.minAcceptedGrade,
    this.canShareDocs,
    this.lastLogoutAt
  });

  factory User.fromJson(Map<String,dynamic>json){
    return User (
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileCompleted: json['profile_complete'],
      connectionInCommonCount: json['connections_in_common_count'],
      makeOffer: json['make_offer'],
      offerId: json['offer_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone_number'],
      token: json['token'],
      commonConnection: json['common_connections'],
      profilePic: json['profile_image'],
      roleType: json['role_type'],
      availability: json['availability'],
      chatPublicKey: json['chat_public_key'],
      chatPrivateKey: json['chat_private_key'],
      emailVerified: json['email_verified'],
      lengthUnitType: json['length_unit_type'],
      verified: json['verified'],
      headUser: json['head_user'],
      favorite: json['favorite'],
      chat_push_notifications_enabled: json['chat_push_notifications_enabled'],
      daily_email_notifications_enabled: json['daily_email_notifications_enabled'],
      offer_push_notifications_enabled: json['offer_push_notifications_enabled'],
      offer_email_notifications_enabled: json['offer_email_notifications_enabled'],
      shift_reminder_push_notifications_enabled: json['shift_reminder_push_notifications_enabled'],
      trust: json['trust'],
      countryCode: json['country_code'],
      country: json['country'],
      trust_support_user: json['trust_support_user'],
      employee_number: json['employee_number'],
      nhsp_staff_id: json['nhsp_staff_id'],
      nhsp_web_user_id: json['nhsp_web_user_id'],
      points: json['points'],
      date_of_birth: json['date_of_birth'],
      staff_badge: json['staff_badge'],
      preferred_wards: json['preferred_wards'],
      memberships: json['memberships'],
      hospitals: json['hospitals'],
      notifications_unseen_count: json['notifications_unseen_count'],
      pin_number: json['pin_number'],
      contractor_type: json['contractor_type'],
      grade: json['grade'],
      minAcceptedGrade: json['minimum_accepted_grade'],
      band: json['band'],
      minAcceptedBand: json['minimum_accepted_band'],
      bank_shift_approved: json['bank_shift_approved'],
      super_user: json['super_user'],
      nmc_code: json['nmc_code'],
      languages: json['languages'],
      roles: json['roles'],
      skills: json['skills'],
      wards: json['wards'],
      canShareDocs: json['document_sharing']??false,
      lastLogoutAt: json['last_logout']??DateTime.now().millisecondsSinceEpoch
    );
  }
}
