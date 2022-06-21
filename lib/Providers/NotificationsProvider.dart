import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rightnurse/Models/Notification.dart';
import 'package:rightnurse/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';




enum NotificationsStage {ERROR,LOADING,DONE}

class NotificationsProvider extends ChangeNotifier{

  NotificationsStage stage ;




  List<NotificationModel> _notifications=[];
  List<NotificationModel> get notifications =>this._notifications;

  setNotifications(List<NotificationModel> notifications){
    _notifications = notifications;
  }

  List<NotificationModel> notificationsList=[];


  clearOrgNotifications(){
    _notifications.clear();
    notifyListeners();
  }
  List<NotificationModel> notificationss=[];


// Get All Notifications
   Future getAllNotifications({pageOffset=0}) async {
     // this.stage = NotificationsStage.LOADING;
     final prefs = await SharedPreferences.getInstance();
     final storedUser = prefs.getString("user");
     String token = jsonDecode(storedUser)['token'];

     String url ='$appDomain/notifications?limit=15&offset=$pageOffset';

     var headers = {
       'Platform': MyApp.platformIndex,
       'Right-Nurse-Version': Domain.appVersion,
       'Accept': 'application/vnd.right_nurse; version=1',
       'Content-Type': 'application/json',
       'Authorization': 'Token token=$token'

     };
     // final ioc = new HttpClient();
     // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
     // final httpp = new IOClient(ioc);
     //
     // http.Response response = await httpp.get(Uri.parse(url), headers: headers);
     //
     // var responseString;

     String responseString;
     var request = http.MultipartRequest('GET', Uri.parse(url));
     request.headers.addAll(headers);
     http.StreamedResponse response = await request.send();
     responseString = await response.stream.bytesToString();
     // Map responseMap = json.decode(responseString);

     try {
       if (response.statusCode == 200) {
         // debugPrint('${response.body}');
         if (pageOffset==0){
           _notifications.clear();
         }
         // responseString =  response.body;
         List<dynamic> responseList = json.decode(responseString);
         // this.stage = NotificationsStage.DONE;
         // debugPrint(responseList.toString());

         responseList.forEach((element) {

           NotificationModel notification = NotificationModel.fromJson(element);

           notificationss.add(notification);
         });
         setNotifications(notificationss);

       }
       else {
         // this.stage = NotificationsStage.ERROR;
         debugPrint(response.reasonPhrase);
       }
     } on Exception catch (e) {
       // TODO
     }
     notifyListeners();
   }


 // Update notifications

  Future updateNotifications(BuildContext context, {notificationId, status = 204}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    String url = '$appDomain/notifications/$notificationId';

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
   //  final ioc = new HttpClient();
   //  ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
   //  final httpp = new IOClient(ioc);
   //
   var body = {"status":204};
   // http.Response response = await httpp.put(Uri.parse('$appDomain/notifications/$notificationId'), headers: headers, body: body);
   //  String responseString = response.body;
   //
   //  dynamic responseMap = json.decode(responseString);

    var request = http.Request('PUT', Uri.parse('$appDomain/notifications/$notificationId'));

    request.body = json.encode(body);

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();
    Map responseMap = json.decode(responseString);
   try {
     if(response.statusCode == 200 ){
       debugPrint(responseMap['successful'].toString());
       if(responseMap['successful'] == true){
         _notifications.firstWhere((element) => element.id == notificationId).status = 204;
       }
     }
   }catch (e) {
     debugPrint(e);
   }

   notifyListeners();
  }

}