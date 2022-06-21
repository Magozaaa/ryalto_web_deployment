// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/io_client.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/ShiftModel.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftsUtils.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';


enum ShiftsStage { ERROR, LOADING, DONE }

const Map<int, dynamic> stagingOffersStatuses = {
  0: [ "98bf981f-edf5-4974-919b-fa1dd4ef7c7d", "Available"], // blue "primary colour of the app"
  1: [ "820ee03c-65b2-4e57-9e1a-6dc6deb1f6ea", "Accepted"], // green
  2: [ "8a53f401-6614-48b9-b51c-70f331d1eacf", "Declined"], // red
  3: [ "6f5f1e7e-d09b-4aab-b5f9-e05431fe161e", "Expired"], // red
  4: [ "652981ac-5d4a-4698-9b7d-2c2c099de616", "Cancelled"], // red
  5: [ "1c778f6b-833c-4754-90ae-ec1c59a6f00b", "Referred"], // ?? lite_blue
  6: [ "595890e0-f85c-4f3d-8d64-5cc76d59dd3f", "Cancelled and Confirmed"], // red
  7: [ "10206097-a9bf-4446-95cb-772921942b92", "Accepted and Confirmed"], // green
  8: [ "1941b4db-d127-4e58-9099-3c2d040b61a9", "Requested"], // yellow
  9: [ "e0dbde32-f8f1-4420-b00a-582f6ea4cc65", "Request Declined"], // red
};

const Map<int, dynamic> productionOffersStatuses = {
  0: ["d2f40aa5-a6b8-4495-8016-10eb99053103", "Available"], // blue "primary colour of the app"
  1: ["cd835e7e-aafa-452a-9b20-584b13d89938", "Accepted"], // green
  2: ["282198ff-e8b9-4e48-b061-3ccd3d4405c4", "Declined"], // red
  3: ["9c0d3702-a619-4456-b321-95015b10ae01", "Expired"], // red
  4: ["ffbb12ae-1769-40a7-8861-32aa86a86890", "Cancelled"], // red
  5: ["fa1cda9e-5d3c-4ec6-956d-fa8965632494", "Referred"], // ?? lite_blue
  6: ["e0766147-c49d-4472-83f9-499b864a46b6", "Cancelled and Confirmed"], // red
  7: ["d0375e05-4ef3-4251-8985-0e327b3fe31e", "Accepted and Confirmed"], // green
  8: ["fe7b36d1-4e6e-4a71-9e45-05d677cae1d5", "Requested"], // yellow
  9: ["2d96315b-9e41-4977-843a-4df3ac78ba1d", "Request Declined"], // red
  10: ["713ecbae-9bb9-493d-ba6f-74c05184c8ba", "Request Cancelled"], // red
};


const Map<int, dynamic> stagingTimeSheetStatuses = {
  0: ["455cdf9f-37c8-4d46-8041-7fbc7652801d", "Not authorised"],
  1: ["7cbcbb55-9c43-4528-a19c-86314fb81c64", "Awaiting release"],
  2: ["74696686-d1d2-47fd-9d39-8d5a8b69bd7a", "Released"],
  3: ["b2fcbbf9-1a9c-4fde-ad04-0beaced88799", "Processed for payment"],
  4: ["5e904603-904e-4c6e-b857-5369ae0fbf0f", "Queried"],
};


const Map<int, dynamic> productionTimeSheetStatuses = {
  0: ["da561f89-0666-414b-a32f-131cdd77d72f", "Not authorised"],
  1: ["c461c4c0-23d3-4b6f-9bc7-e89c347f3373", "Awaiting release"],
  2: ["2872b822-1c28-4c9b-83ef-e25a44609e6a", "Released"],
  3: ["7e82f7a4-ebaa-4f22-9754-e91c6181c918", "Processed for payment"],
  4: ["bcf15dd1-1775-4b9b-b13e-962691c2aabe", "Queried"],
};

class ShiftsProvider extends ChangeNotifier{
  ShiftsStage stage ;
  ShiftsStage timeSheetStage ;
  ShiftsStage openShiftsStage ;
  ShiftsStage upcomingShiftsStage ;
  ShiftsStage queryStage ;


  // Check Accept TimeSheet Declaration
  bool _acceptedTimeSheetDeclaration = false;
  bool get acceptedTimeSheetDeclaration=>this._acceptedTimeSheetDeclaration;

  setAcceptedTimeSheetDeclaration(bool value) async {
    _acceptedTimeSheetDeclaration = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("acceptedTimeSheetDeclaration", value);
    notifyListeners();
  }

  // set to true to handle calendar UI wed 2nd Feb 2022
  bool _isCalendarView = false;
  bool get isCalendarView => this._isCalendarView;

  changeShiftsView(){
    _isCalendarView = !_isCalendarView;
    notifyListeners();
  }

  // selected attributes for filtering shifts

  List<String> selectedAreasOfWorkIds = [];

  Map<int,dynamic> shiftTypes = {
    0 : false,  // Early
    1 : false,  // Late
    2 : false   // Night
  };

  String startTime = '';
  String endTime='';
  bool isNewActive = false;
  bool isResetFilterShown = false;
  bool _shouldUpDateCalendarData = false;
  bool get shouldUpDateCalendarData => this._shouldUpDateCalendarData;


  setShouldUpdateCalendarData(bool shouldUpdate){
    _shouldUpDateCalendarData = shouldUpdate;
    notifyListeners();
  }

  setIsResetFilterShown({@required bool show}){
    if (!show) {
      startTime = '';
      endTime='';
      isNewActive = false;
      isResetFilterShown = false;
      shiftTypes = {
        0 : false,  // Early
        1 : false,  // Late
        2 : false   // Night
      };
      selectedAreasOfWorkIds = [];
    }
    else{
      isResetFilterShown = true;
    }

    notifyListeners();
  }


  List<ShiftModel> _shifts =[];
  List<ShiftModel> get shifts=>this._shifts;

  setShifts(List<ShiftModel> shifts){
    _shifts = shifts;
  }

  List<ShiftStatuses> _shiftStatuses =[];
  List<ShiftStatuses> get shiftStatuses=>this._shiftStatuses;

  setShiftStatuses(List<ShiftStatuses> shifts){
    _shiftStatuses = shifts;
  }

  List<CancellationReason> _cancellationReasons = [];
  List<CancellationReason> get cancellationReasons =>this._cancellationReasons;

  setCancellationReason(List<CancellationReason> reasons){
    _cancellationReasons = reasons;
  }


  List<Week> _openWeeks = [];
  List<Week> get openWeeks =>this._openWeeks;


  clearOpenWeeksWithOffers(){
    _openWeeks.clear();
    notifyListeners();
  }

  // Future fetchShifts(BuildContext context,{history_type,start_date,pageOffset}) async{
  //   this.stage = ShiftsStage.LOADING;
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final storedUser = prefs.getString("user");
  //   String token = jsonDecode(storedUser)['token'];
  //
  //   DateTime now = DateTime.now();
  //   int currentDay = now.weekday;
  //   DateTime firstDayOfWeek = now.subtract(Duration(days: currentDay - 1 - 7));
  //
  //   // DateTime currentPhoneDate = DateTime.now(); //DateTime
  //
  //   // Timestamp myTimeStamp = Timestamp.fromDate(firstDayOfWeek);
  //   // debugPrint('timeStampppppp ${myTimeStamp.seconds}');//To TimeStamp
  //   //
  //   // DateTime myDateTime = myTimeStamp.toDate();
  //
  //   var headers = {
  //     'Platform': MyApp.platformIndex,
  //     'Right-Nurse-Version': Domain.appVersion,
  //     'Accept': 'application/vnd.right_nurse; version=1',
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Token token=$token'
  //   };
  //
  //   var responseString;
  //
  //   try{
  //      var request = http.Request('GET', Uri.parse('$appDomain/shifts?start_day=$firstDayOfWeek'));
  //
  //     request.headers.addAll(headers);
  //
  //     http.StreamedResponse response = await request.send();
  //     responseString = await response.stream.bytesToString();
  //     List<dynamic> responseList = json.decode(responseString);
  //
  //
  //     List<ShiftModel> shifts = [];
  //
  //     if(responseList != null ){
  //       responseList.forEach((element) {
  //         final ShiftModel shiftModel = ShiftModel.fromJson(element);
  //         shifts.add(shiftModel);
  //       });
  //       setShifts(shifts);
  //       shifts.forEach((element) {
  //         if(element.start_date == firstDayOfWeek){
  //         }
  //       });
  //     }
  //
  //     this.stage = ShiftsStage.DONE;
  //   }catch(e){
  //     this.stage = ShiftsStage.ERROR;
  //     debugPrint(e.toString());
  //   }
  //   notifyListeners();
  // }

  // Future fetchShiftStatuses(BuildContext context,{pageOffset}) async{
  //   this.stage = ShiftsStage.LOADING;
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final storedUser = prefs.getString("user");
  //   String token = jsonDecode(storedUser)['token'];
  //
  //   var headers = {
  //     'Platform': MyApp.platformIndex,
  //     'Right-Nurse-Version': Domain.appVersion,
  //     'Accept': 'application/vnd.right_nurse; version=1',
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Token token=$token'
  //   };
  //
  //   var responseString;
  //
  //   try{
  //      var request = http.Request('GET', Uri.parse('$appDomain/offer_statuses'));
  //
  //     request.headers.addAll(headers);
  //
  //     http.StreamedResponse response = await request.send();
  //     responseString = await response.stream.bytesToString();
  //     List<dynamic> responseList = json.decode(responseString);
  //
  //     debugPrint('shiftStatuses ${responseList}');
  //
  //     List<ShiftStatuses> shiftStatuses = [];
  //
  //     if(responseList != null ){
  //       responseList.forEach((element) {
  //         final ShiftStatuses shiftStatus = ShiftStatuses.fromJson(element);
  //         shiftStatuses.add(shiftStatus);
  //       });
  //       setShiftStatuses(shiftStatuses);
  //     }
  //
  //     this.stage = ShiftsStage.DONE;
  //   }catch(e){
  //     this.stage = ShiftsStage.ERROR;
  //     debugPrint(e.toString());
  //   }
  //   notifyListeners();
  // }


  Offer _currentOffer;
  Offer get currentOffer => this._currentOffer;

  setCurrentOffer(Offer offer){
    _currentOffer = offer;
    notifyListeners();
  }

  clearCurrentOffer(){
    _currentOfferId = null;
    _currentOffer = null;
    notifyListeners();
  }

  List<Week> _upComingWeeks = [];
  List<Week> get upComingWeeks => this._upComingWeeks;
  
  clearUpComingWeeksWithOffers(){
    _upComingWeeks.clear();
    notifyListeners();
  }


// Accept, request or cancel  offer
  Future updateOfferStatus(BuildContext context, {String offerId, String offerStatusId, String message = "", String cancellationOptionId = ""}) async{
    this.stage = ShiftsStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;

    try{

      var body = json.encode({
        "offer_id": "$offerId",
        "offer_status_id": "$offerStatusId",
        // these two keys only get a value for the cancel update
        "cancellation_option_id": "$cancellationOptionId",
        "message": "$message"
      });
      http.Response request = await http.put('$appDomain/shift/offer',
          headers: headers, body: body);

      responseString = request.body;
      Map responseMap = json.decode(responseString);
      if (request.statusCode == 200) {
        // var logger = Logger(
        //   filter: null, // Use the default LogFilter (-> only log in debug mode)
        //   printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
        //   output: null, // Use the default LogOutput (-> send everything to console)
        // );
        // logger.i("tesing old create group !! $responseMap");
        // debugPrint("offer status after the update is: ${responseMap}");
        if(Provider.of<UserProvider>(context,listen: false).userData.trust['system_type']['name'] == "nhsp_api"){
          _currentOffer.offerStatus.value = responseMap['shift_status']['value'];
          _currentOffer.offerStatus.name = responseMap['shift_status']['name'];
        }else{
          _currentOffer.offerStatus.value = responseMap['user_offer_status']['value'];
          _currentOffer.offerStatus.name = responseMap['user_offer_status']['name'];
        }
        if( MyApp.flavor == "staging" && offerStatusId == stagingOffersStatuses[1][0]){
          AnalyticsManager.track('shift_offer_submitted');
        }
        if( MyApp.flavor == "production" && offerStatusId == productionOffersStatuses[1][0]){
          AnalyticsManager.track('shift_offer_submitted');
        }
        if(cancellationOptionId!=null && cancellationOptionId != ''){
          AnalyticsManager.track('shift_cancelled');
        }

      } else {
        showAnimatedCustomDialog(context,
            title: "Failed!", message: responseMap["message"]);
      }
      this.stage = ShiftsStage.DONE;
    }catch(e){
      this.stage = ShiftsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }


  Future fetchOffers(BuildContext context,{int historyType,pageOffset=0,startTime = '',endTime = '',createdSince = '',List<String> wardIds}) async{
    if (historyType == 0) {
      this.openShiftsStage = ShiftsStage.LOADING;
    }
    else{
      this.upcomingShiftsStage = ShiftsStage.LOADING;
    }
    // this.stage = ShiftsStage.LOADING;
    String url = '$appDomain/offers?history_type=$historyType&limit=7&offset=$pageOffset&created_since=$createdSince&end_time=$endTime&start_time=$startTime';

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    debugPrint("the url of offer for list request is ---> $url");

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    String areasOfWordParams = '';
    if (wardIds != null && wardIds.isNotEmpty) {
      wardIds.forEach((element) {
        areasOfWordParams += '&ward_ids%5B%5D=$element';
      });
      debugPrint('$areasOfWordParams');
      url += areasOfWordParams;
    }

    var responseString;
    try{
      http.Response request = await http.get(url, headers: headers);
      responseString = request.body;

      debugPrint("the urlll of offer for list request is ---> $url");


      List<dynamic> responseList = json.decode(responseString);
      // var logger = Logger(
      //   filter: null, // Use the default LogFilter (-> only log in debug mode)
      //   printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
      //   output: null, // Use the default LogOutput (-> send everything to console)
      // );
      // logger.i("the response of offer for list request is ${responseList.first}");
      // debugPrint("the response of offer for list request is: ${responseList.first}");

      if(request.statusCode == 200 && responseList != null) {

          if (pageOffset == 0 && historyType == 0) {
          _openWeeks.clear();
          } else if (pageOffset == 0 && historyType == 1) {
            _upComingWeeks.clear();
          }

        if (historyType == 1) {
          responseList.forEach((element) {
            final Week shiftModel = Week.fromJson(element);
            _upComingWeeks.add(shiftModel);
          });
        } else {
          responseList.forEach((element) {
            final Week shiftModel = Week.fromJson(element);
            _openWeeks.add(shiftModel);
          });
        }

          if (historyType == 0) {
            this.openShiftsStage = ShiftsStage.DONE;
          }
          else{
            this.upcomingShiftsStage = ShiftsStage.DONE;
          }
          // this.stage = ShiftsStage.DONE;

      }else{
        if (historyType == 0) {
          this.openShiftsStage = ShiftsStage.ERROR;
        }
        else{
          this.upcomingShiftsStage = ShiftsStage.ERROR;
        }
        // this.stage = ShiftsStage.ERROR;
      }

    }catch(e){
      if (historyType == 0) {
        this.openShiftsStage = ShiftsStage.ERROR;
      }
      else{
        this.upcomingShiftsStage = ShiftsStage.ERROR;
      }
      // this.stage = ShiftsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  String _currentOfferId;
  // String get currentOfferId => this._currentOfferId;

  setCurrentOfferId(String offerId){
    _currentOfferId = offerId;
    notifyListeners();
  }

  Future fetchOfferById(BuildContext context) async {
    this.stage = ShiftsStage.LOADING;

    String url = '$appDomain/offers/$_currentOfferId';

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    debugPrint("the url of fetchOfferById request is ---> $url");

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1', // version = 1 until version 2 is ready to use
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;
    try {
      var request = http.Request('GET', Uri.parse(url));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      dynamic offerObject = json.decode(responseString);
      print('offerObject ${offerObject}');

      if (response.statusCode == 200) {

        _currentOffer = Offer.fromJson(offerObject);
        if(responseString.contains("offer_level") == false){
          if(Provider.of<UserProvider>(context,listen: false).userData.roleType == 2){
            // _currentOffer.offerLevel =
          }
        }
        this.stage = ShiftsStage.DONE;
      }
      else {
        // print(response.reasonPhrase);
        this.stage = ShiftsStage.ERROR;
        showAnimatedCustomDialog(context,message: response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
      this.stage = ShiftsStage.ERROR;
    }
  notifyListeners();
  }


  Future fetchCancellationReasons(BuildContext context,{String hospitalId = ""}) async{
    this.stage = ShiftsStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];


    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    if(Provider.of<UserProvider>(context,listen: false).userData.trust['system_type']['name'] == "nhsp_api"){
      headers['Accept'] = 'application/vnd.right_nurse; version=1';
    }else{
      headers['Accept'] = 'application/vnd.right_nurse; version=2';
    }

    var responseString;

    try{
      var request = http.Request('GET', Uri.parse('$appDomain/cancellation_options?hospital_id=$hospitalId'));

      request.headers.addAll(headers);
      debugPrint("here's the fetchCancellationReasons url --> $appDomain/cancellation_options?hospital_id=$hospitalId");
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      List<dynamic> responseList = json.decode(responseString);


      List<CancellationReason> reasons = [];

      if(responseList != null){
        responseList.forEach((element) {
          final CancellationReason reason = CancellationReason.fromJson(element);
          reasons.add(reason);
        });
        setCancellationReason(reasons);
      }

      this.stage = ShiftsStage.DONE;
    }catch(e){
      this.stage = ShiftsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }


  List<TimeSheetDay> _timesheetdays = [];
  List<TimeSheetDay> get timesheetdays => this._timesheetdays;


  clearTimesheetWeeksWithOffers(){
    _timesheetdays.clear();
    notifyListeners();
  }

  TimeSheetDay _currentTimeSheetShit;
  TimeSheetDay get currentTimeSheetShit => this._currentTimeSheetShit;

  setCurrentTimeSheetShift(TimeSheetDay timeSheetShift){
    _currentTimeSheetShit = timeSheetShift;
    notifyListeners();
  }

  Future fetchTimeSheets(BuildContext context,{pageOffset=0,startDate,endDate}) async{
    this.timeSheetStage = ShiftsStage.LOADING;
    String url = '$appDomain/timesheets?start_date=$startDate&end_date=$endDate';

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    debugPrint("the url of offer for list request is ---> $url");

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };


    var responseString;
    try{
      http.Response request = await http.get(url, headers: headers);
      responseString = request.body;

      debugPrint("the response of TimeSheets for list request is ---> $responseString");

      List<dynamic> responseList = json.decode(responseString);

      if(request.statusCode == 200 && responseList != null) {

        if (pageOffset == 0) {
          _timesheetdays.clear();
        }
          responseList.forEach((element) {
            final TimeSheetDay shiftModel = TimeSheetDay.fromJson(element);
            _timesheetdays.add(shiftModel);
          });

        this.timeSheetStage = ShiftsStage.DONE;

      }else{
        this.timeSheetStage = ShiftsStage.ERROR;
      }

    }catch(e){
      this.timeSheetStage = ShiftsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }


  // Future fetchTimeSheetDetails(BuildContext context,{timeSheetShiftId}) async{
  //   this.timeSheetStage = ShiftsStage.LOADING;
  //   String url = '$appDomain/timesheets/$timeSheetShiftId';
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final storedUser = prefs.getString("user");
  //   String token = jsonDecode(storedUser)['token'];
  //
  //   debugPrint("the url of offer for list request is ---> $url");
  //
  //   var headers = {
  //     'Platform': MyApp.platformIndex,
  //     'Right-Nurse-Version': Domain.appVersion,
  //     'Accept': 'application/vnd.right_nurse; version=1',
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Token token=$token'
  //   };
  //
  //
  //   var responseString;
  //   try{
  //     http.Response request = await http.get(url, headers: headers);
  //     responseString = request.body;
  //
  //     debugPrint("the response of TimeSheet Shift Details for list request is ---> $responseString");
  //
  //     dynamic responseTimeSheetShift = json.decode(responseString);
  //
  //     if(request.statusCode == 200 && responseTimeSheetShift != null) {
  //       final TimeSheetDay shiftModel = TimeSheetDay.fromJson(responseTimeSheetShift);
  //       setCurrentTimeSheetShift(shiftModel);
  //       this.timeSheetStage = ShiftsStage.DONE;
  //
  //     }else{
  //       this.timeSheetStage = ShiftsStage.ERROR;
  //     }
  //
  //   }catch(e){
  //     this.timeSheetStage = ShiftsStage.ERROR;
  //     debugPrint(e.toString());
  //   }
  //   notifyListeners();
  // }


  List<CalendarDay> _calendarDays = [];
  List<CalendarDay> get calendarDays =>this._calendarDays;

  setCalendarDayOffers(List<CalendarDay> days){
    _calendarDays = days;
  }


  CalendarDay _currentCalendarDay;
  CalendarDay get currentCalendarDay => this._currentCalendarDay;

  setCurrentCalendarDay({@required selectedDay}){
    calendarDays.forEach((day) {
      if (selectedDay == DateTime.utc(DateFormat("yyyy-MM-dd").parse(day.date).year,DateFormat("yyyy-MM-dd").parse(day.date).month,DateFormat("yyyy-MM-dd").parse(day.date).day)) {
        _currentCalendarDay = day;
      }
    });
    notifyListeners();
  }
  setNextCalendarDay(){
    DateTime currentDay = DateFormat("yyyy-MM-dd").parse(_currentCalendarDay.date);
    calendarDays.forEach((day) {

      if (DateTime.utc(DateFormat("yyyy-MM-dd").parse(day.date).year,DateFormat("yyyy-MM-dd").parse(day.date).month,DateFormat("yyyy-MM-dd").parse(day.date).day-1) == DateTime.utc(currentDay.year,currentDay.month,currentDay.day)) {
        _currentCalendarDay = day;
      }

    });

    notifyListeners();
  }

  setPreviousCalendarDay(){
    DateTime currentDay = DateFormat("yyyy-MM-dd").parse(_currentCalendarDay.date);

    calendarDays.forEach((day) {
      if (DateTime.utc(DateFormat("yyyy-MM-dd").parse(day.date).year,DateFormat("yyyy-MM-dd").parse(day.date).month,DateFormat("yyyy-MM-dd").parse(day.date).day) == DateTime.utc(currentDay.year,currentDay.month,currentDay.day-1)) {
        _currentCalendarDay = day;
      }
    });
    notifyListeners();
  }

  int _currentShiftType = 0;
  int get currentShiftType => this._currentShiftType;

  setCurrentShiftType(int shiftType){
    _currentShiftType = shiftType;
    notifyListeners();
  }

  Map<DateTime,List<Offer>> dayOffers = {} ;
  List<CalendarDay> days = [];

  void clearDayOffers(){
    dayOffers.clear();
    notifyListeners();
  }

  int _startDay = dateToTimeStamp(date: DateTime(kToday.year, kToday.month, kToday.day)).seconds;
  int get startDay => this._startDay;

  void setStartDay(int startDay){
    _startDay = startDay;
    notifyListeners();
  }

  int _endDay = dateToTimeStamp(date: DateTime(kToday.year, kToday.month + 1, 0)).seconds;
  int get endDay => this._endDay;

  void setEndDay(int endDay){
    _endDay = endDay;
    notifyListeners();
  }

  bool _isRetrtyFetchingOffersForCalendar = true;
  bool get isRetrtyFetchingOffersForCalendar => this._isRetrtyFetchingOffersForCalendar;


  Future fetchCalendarDaysWithOffers(BuildContext context,
      {@required startDate, @required endDate,int historyType,bool sendFromCalendar = false,startTime='',endTime='',createdSince='',List<String> wardIds,bool shouldUpdate = false})async{
    // this.stage = ShiftsStage.LOADING;

    String url = '$appDomain/offers_calendar?search_start_date_from=$startDate&search_start_date_to=$endDate&history_type=$historyType&created_since=$createdSince&end_time=$endTime&start_time=$startTime';
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;
    try{
      // lastDayInDayOffers is used for getting last day in the dayOffers keys to get current month and compare it with next month
      // so the request is sent only if Calendar view is changed to a new month

      debugPrint("here's the url for get offers for Calendar form ---> $url");

      DateTime lastDayInDayOffers;
      if (dayOffers.isNotEmpty) {
        lastDayInDayOffers  = dayOffers.keys.last;
      }

      String areasOfWordParams = '';
      if (wardIds != null && wardIds.isNotEmpty) {
        wardIds.forEach((element) {
          areasOfWordParams += '&ward_ids%5B%5D=$element';
        });
        debugPrint('$areasOfWordParams');
        url += areasOfWordParams;
      }

      // this condition is prevent loading offers for months that we have already loaded before
      if (dayOffers.isEmpty || timeStampToDateTime(startDate).month > lastDayInDayOffers.month || sendFromCalendar == false || shouldUpdate) {

        this.stage = ShiftsStage.LOADING;

        var request = http.Request('GET', Uri.parse(url));

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        responseString = await response.stream.bytesToString();

        debugPrint("the response of offer for Calendar request is ---> $responseString");

        if((responseString.toString().contains("We're sorry, but something went wrong (500)") ||
            responseString.toString().contains("The NHSP server is unreachable at the moment. Please try again later."))
            && Provider.of<UserProvider>(context, listen: false).userData.trust['system_type']['name'] == 'nhsp_api'){
          showAnimatedCustomDialog(context,
              buttonText: "Retry now",
              onClicked: (){
                _isRetrtyFetchingOffersForCalendar = true;
              Navigator.pop(context);
              fetchCalendarDaysWithOffers(
                  context,
                  startDate: startDate,
                  endDate: endDate,
                  historyType: currentShiftType,
                  wardIds: wardIds,
                  endTime: endTime,
                  startTime: startTime,
                  createdSince: createdSince,
                  sendFromCalendar: true,
                  shouldUpdate: shouldUpdate
              );
              },
              cancelButtonTitle: "Cancel",
              onCancelClicked: (){
                _isRetrtyFetchingOffersForCalendar = false;
                Navigator.pop(context);
              },
              title: "Server Error!", message: "The NHSP server is unreachable at the moment. Please try again later.");
        }


        if(response.statusCode == 200){
          // the reason we moved this line to be under the check "response.statusCode == 200" is because when the request fails
          // it sometimes gives this response ===> {"code":59,"status":504,"message":"The NHSP server is unreachable at the moment. Please try again later."}
          // which not a list so it will give error ---> '_InternalLinkedHashMap<String, dynamic>' is not a subtype of type 'List<dynamic>'
          List<dynamic> responseList = json.decode(responseString);

          if(responseList != null){
            responseList.forEach((calendarDay) {
              final CalendarDay day = CalendarDay.fromJson(calendarDay);
              days.add(day);
              dayOffers[DateTime.utc(DateFormat("yyyy-MM-dd").parse(calendarDay["date"]).year,DateFormat("yyyy-MM-dd").parse(calendarDay["date"]).month,DateFormat("yyyy-MM-dd").parse(calendarDay["date"]).day)] = day.offers;

            });

            setCalendarDayOffers(days);
            _shouldUpDateCalendarData = false;
            _isRetrtyFetchingOffersForCalendar = false;
          }
          this.stage = ShiftsStage.DONE;
        }
      }

    }catch(e){
      this.stage = ShiftsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }


  Future updateTimeSheet(BuildContext context, { String message, String timeSheetStatusId}) async{
    this.stage = ShiftsStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;

    try{

      var body = {
        "timesheet_status_id": "$timeSheetStatusId",
      };

      if(message != null && message.isNotEmpty){
        body['message'] = "$message";
      }

      http.Response request = await http.put('$appDomain/timesheets/${_currentTimeSheetShit.id}',
          headers: headers,
          body: json.encode(body));

      responseString = request.body;

      if(request.statusCode == 200){
        Map responseMap = json.decode(responseString);
        showAnimatedCustomDialog(context,message: responseMap['message']);
        if(message != null && message.isNotEmpty){
          _currentTimeSheetShit.timesheet_status["name"] = "Queried";
        }
        else{
          _currentTimeSheetShit.timesheet_status["name"] = "Released";
        }
        AnalyticsManager.track('timesheet_accepted');
      }
      else{
        showAnimatedCustomDialog(context,title: Text("Something went wrong!"),message: "NHSP server error!");
      }


      this.stage = ShiftsStage.DONE;
    }catch(e){
      this.stage = ShiftsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }


}