import 'package:rightnurse/Models/AvailablePositionModel.dart';
import 'package:rightnurse/Models/BandModel.dart';
import 'package:rightnurse/Models/LanguageModel.dart';
import 'package:rightnurse/Models/SkillModel.dart';
import 'package:rightnurse/Models/UserModel.dart';

class ShiftModel{
  dynamic id;
  dynamic type;
  dynamic seen;
  dynamic hospital;
  dynamic ward;
  dynamic external_system_id;
  dynamic shift_status;
  dynamic start_date;
  dynamic end_date;
  dynamic created_at;
  dynamic updated_at;
  dynamic role_type;
  dynamic promotion;
  dynamic shift_type;

  ShiftModel({
    this.id,
    this.type,
    this.seen,
    this.hospital,
    this.ward,
    this.external_system_id,
    this.shift_status,
    this.start_date,
    this.end_date,
    this.created_at,
    this.updated_at,
    this.role_type,
    this.promotion,
    this.shift_type,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) => ShiftModel(
    id: json["id"],
    type: json["type"],
    seen: json["seen"],
    hospital: json["hospital"],
    ward: json["ward"],
    external_system_id: json["external_system_id"],
    shift_status: json["shift_status"],
    start_date: json["start_date"],
    end_date: json["end_date"],
    created_at: json["created_at"],
    updated_at: json["updated_at"],
    role_type: json["role_type"],
    promotion: json["promotion"],
    shift_type: json["shift_type"],
  );

}

class ShiftStatuses {
  dynamic id;
  dynamic name;
  dynamic value;
  dynamic created_at;
  dynamic updated_at;

  ShiftStatuses({
    this.id,
    this.name,
    this.value,
    this.created_at,
    this.updated_at,
  });

  factory ShiftStatuses.fromJson(Map<String, dynamic> json) => ShiftStatuses(
    id: json["id"],
    name: json["name"],
    value: json["value"],
    created_at: json["created_at"],
    updated_at: json["updated_at"],
  );
}


// new work for shifts


class Week {
  dynamic week_start;
  dynamic week_end;
  List<Offer> offers;


  Week({
    this.week_start,
    this.week_end,
    this.offers,

  });

  factory Week.fromJson(Map<String, dynamic> json) {
    List<Offer> offers =[];
    List<dynamic> dynamicOffers = json["offers"];

    if(dynamicOffers!=null){
      dynamicOffers.forEach((element) {offers.add(Offer.fromJson(element));});
    }

    return Week(
      week_start: json["week_start"],
      week_end: json["week_end"],
      offers: offers,
    );
  }
}


class Offer {
  dynamic id;
  // User nurse;
  User bankAdmin;
  // User doctor;
  User user;
  dynamic startDate;
  dynamic endDate;
  OfferStatus offerStatus;
  dynamic type;
  dynamic seen;
  Hospital hospital;
  Ward ward;
  dynamic promotion;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic timeSheet;
  dynamic messages;
  dynamic expiresAt;
  int cancellableUntil;
  dynamic coreRate;
  dynamic enhancedRateValue;
  dynamic enhancedRateRule;
  Currency currency;
  ShiftType shiftType;
  bool newShift;
  String bookingType;
  dynamic notes;
  List<Skill> skills;
  List<Language> languages;
  List<OfferRole> roles;
  OfferLevel offerLevel;



  Offer({
    this.id,
    this.bankAdmin,
    this.user,
    this.startDate,
    this.endDate,
    this.offerStatus,
    this.type,
    this.seen,
    this.hospital,
    this.ward,
    this.promotion,
    this.createdAt,
    this.updatedAt,
    this.timeSheet,
    this.messages,
    this.expiresAt,
    this.cancellableUntil,
    this.coreRate,
    this.enhancedRateValue,
    this.enhancedRateRule,
    this.currency,
    this.shiftType,
    this.bookingType,
    this.newShift,
    this.skills,
    this.languages,
    this.notes,
    this.roles,
    this.offerLevel,

  });

  factory Offer.fromJson(Map<String, dynamic> json) {

    Ward ward;
    OfferStatus offerStatus;
    Currency currency;
    ShiftType shiftType;
    Hospital hospital;
    // will make it easy to deal with one user
    User user;
    User bankAdmin;
    List<Skill> skills=[];
    List<Language> languages=[];
    List<OfferRole> roles=[];
    OfferLevel level;

    if(json["nurse"] == null && json["doctor"] != null){
      user = User.fromJson(json["doctor"]);

    }
    else if(json["nurse"] != null && json["doctor"] == null){
      user = User.fromJson(json["nurse"]);
    }
    ////////////////////////

    if(json['bank_admin']!=null){
      bankAdmin = User.fromJson(json['bank_admin']);
    }

    if(json['ward']!=null){
      ward = Ward.fromJson(json['ward']);
    }

    if(json['offer_status']!=null){
      offerStatus = OfferStatus.fromJson(json['offer_status']);
    }

     if(json['currency']!=null){
       currency = Currency.fromJson(json['currency']);
    }

     if(json['shift_type']!=null){
       shiftType = ShiftType.fromJson(json['shift_type']);
    }

     if(json['hospital']!=null){
       hospital = Hospital.fromJson(json['hospital']);
    }

     if(json['offer_level']!=null){
       level = OfferLevel.fromJson(json['offer_level']);
    }
     else if (json['band'] != null){
       level = OfferLevel.fromJson(json['band']);
     }
     else if (json['grade'] != null){
       level = OfferLevel.fromJson(json['grade']);
     }

     if(json['languages']!=null){
       json['languages'].forEach((element)=>languages.add(Language.fromJson(element)));
    }
     if(json['skills']!=null){
       json['skills'].forEach((element)=>skills.add(Skill.fromJson(element)));
    }

     if(json['roles']!=null){
       json['roles'].forEach((element)=>roles.add(OfferRole.fromJson(element)));
    }

    return Offer(
      id: json["id"],
      bankAdmin: bankAdmin,
      user: user,
      startDate: json["start_date"],
      endDate: json["end_date"],
      offerStatus: offerStatus,
      type: json["type"],
      seen: json["seen"],
      hospital: hospital,
      ward: ward,
      promotion: json["promotion"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      timeSheet: json["timesheet"],
      messages: json["messages"],
      expiresAt: json["expires_at"],
      cancellableUntil: json["cancellable_until"],
      coreRate: json["core_rate"] ?? 0.0,
      enhancedRateValue: json["enhanced_rate_value"] ?? 0.0,
      enhancedRateRule: json["enhanced_rate_rule"],
      currency: currency,
      shiftType: shiftType,
      languages: languages,
      skills: skills,
      notes: json["notes"],
      bookingType: json["booking_type"],
      newShift: json["new_shift"]??false,
      roles: roles,
      offerLevel: level,
    );
  }
}


class Ward {
  String id;
  String name;
  dynamic order;
  Hospital hospital;
  dynamic created_at;
  dynamic updated_at;


  Ward({
    this.id,
    this.name,
    this.order,
    this.hospital,
    this.created_at,
    this.updated_at,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {

    Hospital hospital;
    if(json["hospital"] != null ){
      hospital = Hospital.fromJson(json["hospital"]);
    }

    return Ward(
      id: json["id"],
      name: json["name"],
      order: json["order"],
      hospital: hospital,
      created_at: json["created_at"],
      updated_at: json["updated_at"],
    );
  }
}



class Hospital {
  String id;
  String name;


  Hospital({
    this.id,
    this.name,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
    id: json["id"],
    name: json["name"],
  );
}



class OfferStatus {
  String id;
  String name;
  dynamic value;
  dynamic created_at;
  dynamic updated_at;

  OfferStatus({
    this.id,
    this.name,
    this.value,
    this.created_at,
    this.updated_at,
  });

  factory OfferStatus.fromJson(Map<String, dynamic> json){
    return OfferStatus(
      id: json["id"],
      name: json["name"],
      value: json["value"],
      created_at: json["created_at"],
      updated_at: json["updated_at"],
    );
  }
}


class Currency {
  String id;
  String name;
  dynamic iso_code;
  dynamic logo;
  dynamic symbol;
  dynamic created_at;
  dynamic updated_at;

  Currency({
    this.id,
    this.name,
    this.iso_code,
    this.logo,
    this.symbol,
    this.created_at,
    this.updated_at,
  });

  factory Currency.fromJson(Map<String, dynamic> json){
    return Currency(
      id: json["id"],
      name: json["name"],
      iso_code: json["iso_code"],
      logo: json["logo"],
      symbol: json["symbol"],
      created_at: json["created_at"],
      updated_at: json["updated_at"],
    );
  }
}


class ShiftType {
  String id;
  String name;
  dynamic value;
  dynamic trust_id;

  ShiftType({
    this.id,
    this.name,
    this.value,
    this.trust_id,
  });

  factory ShiftType.fromJson(Map<String, dynamic> json){
    return ShiftType(
      id: json["id"],
      name: json["name"],
      value: json["value"],
      trust_id: json["trust_id"],
    );
  }
}


class CancellationReason {
  String id;
  String name;
  dynamic hospital;
  dynamic role_type;
  dynamic created_at;
  dynamic updated_at;

  CancellationReason({
    this.id,
    this.name,
    this.hospital,
    this.role_type,
    this.created_at,
    this.updated_at,
  });

  factory CancellationReason.fromJson(Map<String, dynamic> json){
    return CancellationReason(
      id: json["id"],
      name: json["name"],
      hospital: json["hospital"],
      role_type: json["role_type"],
      created_at: json["created_at"],
      updated_at: json["updated_at"],
    );
  }
}



class CalendarDay {
  dynamic date;
  List<Offer> offers;
  bool accepted_offers;

  CalendarDay({
    this.date,
    this.offers,
    this.accepted_offers,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json){
    List<Offer> offers=[];
    if(json["offers"] != null ){
      json["offers"].forEach((element) { offers.add(Offer.fromJson(element));});
    }
    return CalendarDay(
      date: json["date"],
      offers: offers,
      accepted_offers: json["accepted_offers"],
    );
  }
}


class TimeSheetDay {
  dynamic id;
  dynamic timesheet_status;
  dynamic start_date;
  dynamic trust;
  dynamic ward;
  dynamic hospital;
  dynamic provider;


  TimeSheetDay({
    this.id,
    this.timesheet_status,
    this.start_date,
    this.trust,
    this.ward,
    this.hospital,
    this.provider,

  });

  factory TimeSheetDay.fromJson(Map<String, dynamic> json) {


    return TimeSheetDay(
      id: json["id"],
      timesheet_status: json["timesheet_status"],
      start_date: json["start_date"],
      trust: json["trust"],
      ward: json["ward"],
      hospital: json["hospital"],
      provider: json["provider"],
    );
  }
}

class TimeSheetTrust {
  dynamic id;
  dynamic name;
  dynamic trust_icon;
  dynamic system_type;
  dynamic timezone;
  dynamic created_at;
  dynamic updated_at;


  TimeSheetTrust({
    this.id,
    this.name,
    this.trust_icon,
    this.system_type,
    this.timezone,
    this.created_at,
    this.updated_at,

  });

  factory TimeSheetTrust.fromJson(Map<String, dynamic> json) {


    return TimeSheetTrust(
      id: json["id"],
      name: json["name"],
      trust_icon: json["trust_icon"],
      system_type: json["system_type"],
      timezone: json["timezone"],
      created_at: json["created_at"],
      updated_at: json["updated_at"],
    );
  }
}

class TimeSheetHospital {
  String id;
  String name;
  TimeSheetTrust trust;


  TimeSheetHospital({
    this.id,
    this.name,
    this.trust,
  });

  factory TimeSheetHospital.fromJson(Map<String, dynamic> json) {
    TimeSheetTrust trust;
    if(json["trust"] != null){
      trust = TimeSheetTrust.fromJson(json["trust"]);
    }
    return TimeSheetHospital(
      id: json["id"],
      name: json["name"],
      trust: trust,
    );
  }
}


class TimeSheetStatus {
  String id;
  String name;
  dynamic value;
  dynamic system_type;


  TimeSheetStatus({
    this.id,
    this.name,
    this.value,
    this.system_type,
  });

  factory TimeSheetStatus.fromJson(Map<String, dynamic> json) {

    return TimeSheetStatus(
      id: json["id"],
      name: json["name"],
      value: json["value"],
      system_type: json["system_type"],
    );
  }
}
