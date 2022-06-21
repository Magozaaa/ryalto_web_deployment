// ignore_for_file: file_names, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/ConnectivityManager.dart';
import 'package:rightnurse/Helper/StorageManager.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Providers/changeIndexPage.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/Subscreens/LandingPage.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/WebModel/WebLandingPage.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:twilio_voice/twilio_voice.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = "/SplashScreen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver , TickerProviderStateMixin  {

  Future navigateToOtherScreen() async{

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = storedUser == null ? null : jsonDecode(storedUser)['token'];
    String userId = storedUser == null ? null : jsonDecode(storedUser)['id'];

    Provider.of<ConnectivityManager>(context,listen: false).initConnectivity().then((_) {
      Provider.of<ConnectivityManager>(context, listen: false).test();
      if (Provider.of<ConnectivityManager>(context,listen: false).connectionStatus != ConnectivityResult.none) {

        print('coonectivity');


        if (!kIsWeb) {
          Future selectNotification(String payload) async {
            if (Provider.of<CallProvider>(context, listen: false).hasPushedToCallScreen == false) {
              if (Provider.of<ChangeIndex>(context, listen: false).index != 2) {
                //Handle notification tapped logic here
                Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
              }
              Navigator.popUntil(context, ModalRoute.withName(NavigationHome.routeName));
            }
          }

          const initializationSettings = InitializationSettings(
              android: MyApp.initialzationSettingsAndroid,
              iOS: MyApp.initializationSettingsIOS);

        MyApp.flutterLocalNotificationsPlugin.initialize(
            initializationSettings, onSelectNotification: selectNotification);

        }

        Timer(const Duration(milliseconds: 1700), () async {
          if (token != null && userId != null) {
            // if(Provider.of<UserProvider>(context, listen: false).userData == null)
            Provider.of<UserProvider>(context, listen: false).getUser(context).then((value) {
              if (value == true) {
                AnalyticsManager.identifyUserId(Provider.of<UserProvider>(context, listen: false).userData.id).then((_) {
                  AnalyticsManager.track('app_open');
                });

                if (Provider.of<ChatProvider>(context, listen: false).pubnub == null)
                  Provider.of<ChatProvider>(context, listen: false).intializingPubnub(PubNub(defaultKeyset: Provider.of<ChatProvider>(context, listen: false).myKeyset));

                if (Provider.of<ChatProvider>(context, listen: false).userAuthKey == "")
                  Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) {
                    if (Provider.of<ChatProvider>(context, listen: false).channels.isEmpty) {
                      Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, isInitialLoad: true).then((_) {
                        Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                      });

                      if (!kIsWeb) {
                        Provider.of<CallProvider>(context, listen: false).registerTwilioClient(
                            context,
                            id: Provider.of<UserProvider>(context, listen: false).userData.id,
                            name: Provider.of<UserProvider>(context, listen: false).userData.name,
                            myToken: Provider.of<UserProvider>(context, listen: false).userData.token);
                      }
                    }


                    Timer.periodic(const Duration(minutes: 5), (timer) {
                      if (mounted) {
                        Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) {
                          Provider.of<ChatProvider>(context, listen: false).clearChannels();
                          Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                            Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                          });
                        });
                      }
                    });

                    /// check if actually this works and updates the TwilioAcesstoken when it gets expired or not
                    if (!kIsWeb) {
                      Timer.periodic(const Duration(minutes: 40), (timer) {
                        if (mounted) {
                          Provider.of<CallProvider>(context, listen: false)
                              .registerTwilioClient(context, id: Provider
                              .of<UserProvider>(context, listen: false)
                              .userData
                              .id,
                              name: Provider
                                  .of<UserProvider>(context, listen: false)
                                  .userData
                                  .name,
                              myToken: Provider
                                  .of<UserProvider>(context, listen: false)
                                  .userData
                                  .token);
                        }
                      });

                      FirebaseMessaging.instance.getInitialMessage().then((
                          RemoteMessage message) async {
                          if (Platform.isAndroid) {
                            if (message != null && message.notification != null &&
                                message.notification.title.contains("Chat:")) {
                              // this condition is to add the new created channel if its not in the users channels set
                              if (Provider
                                  .of<ChatProvider>(context, listen: false)
                                  .channelNamesSet
                                  .contains(message.data["channel_name"]) ==
                                  false) {
                                Provider.of<ChatProvider>(context, listen: false)
                                    .clearChannels();
                                Provider.of<ChatProvider>(context, listen: false)
                                    .fetchGroupChannels(
                                    context, isInitialLoad: true)
                                    .then((_) async {
                                  Provider.of<ChatProvider>(context, listen: false)
                                      .fetchHistoryForChannels(Provider
                                      .of<ChatProvider>(context, listen: false)
                                      .userAuthKey);


                                  Provider.of<ChangeIndex>(context, listen: false)
                                      .changeIndexFunction(2);

                                  ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);

                                  // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                                  //   "conversation_messages": null,
                                  //   "channel": null,
                                  //   "channel_name": message.data["channel_name"],
                                  //   "pn":null,
                                  //   "private_chat_user": null,
                                  //   "type": null,
                                  //   "current_user_id": null
                                  // });
                                });
                              }

                              // Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();


                            } else
                            if (message != null && message.notification != null &&
                                !message.notification.title.contains("Chat:")) {
                              Provider.of<UserProvider>(context, listen: false)
                                  .increaseBackendNotificationCount();
                            }
                            else if (message != null &&
                                message.data['notification_type'].toString() ==
                                    '100') {
                              // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                              if (message.data['title'] == 'Focused News') {
                                // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchProfessionalNews(
                                    context, pageOffset: 0, trustId: Provider
                                    .of<UserProvider>(context, listen: false)
                                    .userData
                                    .trust['id']);
                              }
                              else {
                                // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchOrganisationNews(
                                    context,
                                    pageOffset: 0,
                                    trustId: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .userData
                                        .trust['id'],
                                    hospitalsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .hospitalIds,
                                    membershipsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .membershipIds);
                              }
                            }
                          }

                          else if (Platform.isIOS) {
                            debugPrint(
                                "*************************************** 1111111 getInitialMessage");

                            // handling news notification for iOS is different as the bdy for the notification is different
                            if (await message != null &&
                                message.notification != null &&
                                await message.notification.title ==
                                    'Focused News') {
                              // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                              // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                              Provider.of<NewsProvider>(context, listen: false)
                                  .fetchProfessionalNews(
                                  context, pageOffset: 0, trustId: Provider
                                  .of<UserProvider>(context, listen: false)
                                  .userData
                                  .trust['id']);
                            }
                            else if (await message != null &&
                                message.notification != null &&
                                await message.notification.title ==
                                    'My Organisation') {
                              // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                              // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                              Provider.of<NewsProvider>(context, listen: false)
                                  .fetchOrganisationNews(
                                  context,
                                  pageOffset: 0,
                                  trustId: Provider
                                      .of<UserProvider>(context, listen: false)
                                      .userData
                                      .trust['id'],
                                  hospitalsIds: Provider
                                      .of<UserProvider>(context, listen: false)
                                      .hospitalIds,
                                  membershipsIds: Provider
                                      .of<UserProvider>(context, listen: false)
                                      .membershipIds);
                            }

                            if (await message != null &&
                                await message.category != null) {
                              if (message.category.contains("channel-")) {
                                if (Provider
                                    .of<ChatProvider>(context, listen: false)
                                    .channelNamesSet
                                    .contains(message.category) == false) {
                                  Provider.of<ChatProvider>(context, listen: false)
                                      .clearChannels();
                                  Provider.of<ChatProvider>(context, listen: false)
                                      .fetchGroupChannels(
                                      context, isInitialLoad: true)
                                      .then((_) async {
                                    Provider.of<ChatProvider>(
                                        context, listen: false)
                                        .fetchHistoryForChannels(Provider
                                        .of<ChatProvider>(context, listen: false)
                                        .userAuthKey);

                                    //.then((_) async{
                                    // Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                                    // Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                                    // });

                                    Provider.of<ChangeIndex>(context, listen: false)
                                        .changeIndexFunction(2);

                                    ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);

                                    // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                                    //   "conversation_messages": null,
                                    //   "channel": null,
                                    //   "channel_name": message.category,
                                    //   "pn":null,
                                    //   "private_chat_user": null,
                                    //   "type": null,
                                    //   "current_user_id": null,
                                    //   // "sender_name": message.notification.title
                                    // });

                                  });
                                }
                                // Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                              }
                              // Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                            } else if (await message != null &&
                                await message.category == null) {
                              Provider.of<UserProvider>(context, listen: false)
                                  .increaseBackendNotificationCount();
                            }
                          }
                      });

                      FirebaseMessaging.onMessage.listen((
                          RemoteMessage message) async {
                          if (mounted) {
                            if (Platform.isAndroid) {
                              debugPrint(
                                  "on message Android *************************************** SPLASH !!!");
                              // this check is to make sure that notification will have a title as in Twilio & announcement notifications "message.notification" gets sent with null
                              if (await message.notification != null) {
                                // (message.notification != null) is commented out as it prevents navigationHome error when announcement get sent
                                if (message !=
                                    null && /* message.notification != null  && */
                                    message.notification.title.contains("Chat:")) {
                                  if (message.data != null) {
                                    // this condition is to add the new created channel if its not in the users channels set
                                    if (Provider
                                        .of<ChatProvider>(context, listen: false)
                                        .channelNamesSet
                                        .contains(message.data["channel_name"]) ==
                                        false) {
                                      Provider.of<ChatProvider>(
                                          context, listen: false).clearChannels();
                                      Provider.of<ChatProvider>(
                                          context, listen: false)
                                          .fetchGroupChannels(context);
                                    }

                                    /// to show local Notification when chat Message comes for Android
                                    if (message != null &&
                                        message.data['is_announcement'] ==
                                            "false" &&
                                        message.data["senderId"] != Provider
                                            .of<UserProvider>(
                                            context, listen: false)
                                            .userData
                                            .id
                                        && Provider
                                            .of<ChatProvider>(
                                            context, listen: false)
                                            .openedChannelName !=
                                            message.data["channel_name"]) {
                                      MyApp.flutterLocalNotificationsPlugin.show(
                                          message.notification.hashCode,
                                          "${message.data['text']}",
                                          "",
                                          MyApp.androidNotificationDetails
                                      );
                                    }

                                    // commented this part out since there is a listen already on the only for Android iOS requires this part
                                    // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                                    //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                                    //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                                    //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                                    // }

                                  }
                                }
                                else if (message != null &&
                                    message.notification != null &&
                                    !message.notification.title.contains("Chat:") &&
                                    message.data['notification_type'].toString() !=
                                        '100') {
                                  Provider.of<UserProvider>(context, listen: false)
                                      .increaseBackendNotificationCount();
                                }
                              }

                              // handled for Android but still need to be handled for ios
                              if (message != null &&
                                  message.data['notification_type'].toString() ==
                                      '100') {
                                // // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                                // if(message.data['title'] == 'Focused News'){
                                //   // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                                // }
                                // else{
                                //   // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                                // }

                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchOrganisationNews(
                                    context,
                                    pageOffset: 0,
                                    trustId: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .userData
                                        .trust['id'],
                                    hospitalsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .hospitalIds,
                                    membershipsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .membershipIds);
                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchProfessionalNews(
                                    context, pageOffset: 0, trustId: Provider
                                    .of<UserProvider>(context, listen: false)
                                    .userData
                                    .trust['id']);
                              }

                              /// to show local Notification when an Announcement Message comes for Android
                              if (message != null &&
                                  message.data['is_announcement'] == "true" &&
                                  message.data["sender_id"] != Provider
                                      .of<UserProvider>(context, listen: false)
                                      .userData
                                      .id
                                  && Provider
                                      .of<ChatProvider>(context, listen: false)
                                      .openedChannelName !=
                                      message.data["channel_name"]) {
                                debugPrint("sender id: ${message
                                    .data}\n currentUserId: ${Provider
                                    .of<UserProvider>(context, listen: false)
                                    .userData
                                    .id}");


                                var rng = Random();
                                var code = rng.nextInt(900000) + 100000;

                                MyApp.flutterLocalNotificationsPlugin.show(
                                    code,
                                    "Announcement 📣",
                                    "${message.data['text']}",
                                    MyApp.androidNotificationDetails
                                );


                                /* this is the announcement body that gets sent to Android *******
                                    new
                                    {channel_name: channel-1627569163-d4f9bcd3867d48f889312c7abc2f48dfbd5d1b13e7d7fcebc7,
                                     payload_id: 9ce7e749-cbe3-4274-9e37-3409c270d7b6,
                                     is_system_message: false,
                                     is_announcement: true,
                                     text: test, channel_id: 4e83a2d7-1554-4852-99fb-4d3e369ec4f2,
                                     version: 1.0.0,
                                     sender_id: 2265b3b5-e649-4b4b-8c33-f50c2cb59164}
                                    */
                                // handled for Android but still need to be handled for ios
                                // showNotificationsCustomDialog(
                                //   context,
                                //   key: Key("value"),
                                //   width: double.infinity,
                                //   title: "New Announcement",
                                //   subTitle: "${message.data['text']}",
                                //   mainPhoto: Image.asset("images/AppIcon.png"),
                                // );
                              }
                            }

                            else if (Platform.isIOS) {
                              debugPrint(
                                  "on message iOS *************************************** SPLASH !!!");
                              // handling news notification for iOS is different as the bdy for the notification is different
                              if (await message != null &&
                                  message.notification != null &&
                                  await message.notification.title ==
                                      'Focused News') {
                                // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                                // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchProfessionalNews(
                                    context, pageOffset: 0, trustId: Provider
                                    .of<UserProvider>(context, listen: false)
                                    .userData
                                    .trust['id']);
                              }
                              else if (await message != null &&
                                  message.notification != null &&
                                  await message.notification.title ==
                                      'My Organisation') {
                                // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                                // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();

                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchOrganisationNews(
                                    context,
                                    pageOffset: 0,
                                    trustId: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .userData
                                        .trust['id'],
                                    hospitalsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .hospitalIds,
                                    membershipsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .membershipIds);
                              }


                              if (await message != null &&
                                  await message.category != null) {
                                if (message.category.contains("channel-")) {
                                  if (Provider
                                      .of<ChatProvider>(context, listen: false)
                                      .channelNamesSet
                                      .contains(message.category) == false) {
                                    Provider.of<ChatProvider>(
                                        context, listen: false).clearChannels();
                                    Provider.of<ChatProvider>(
                                        context, listen: false).fetchGroupChannels(
                                        context).then((_) {
                                      Provider.of<ChatProvider>(
                                          context, listen: false)
                                          .fetchHistoryForChannels(Provider
                                          .of<ChatProvider>(context, listen: false)
                                          .userAuthKey);
                                    });
                                  }

                                  // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                                  // if (message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                                  //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                                  //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                                  //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                                  // }

                                  String iOSNotificationPayload = message.messageId
                                      .toString();
                                  var startOfsenderId = "{title: ";
                                  var endOfsenderId = ",";


                                  var startIndex = iOSNotificationPayload.indexOf(
                                      startOfsenderId);
                                  var endIndex = iOSNotificationPayload.indexOf(
                                      endOfsenderId,
                                      startIndex + startOfsenderId.length);
                                  String senderName = iOSNotificationPayload
                                      .substring(
                                      startIndex + startOfsenderId.length,
                                      endIndex);


                                  /// to show local Notification when chat Message comes for iOS
                                  if (message != null &&
                                      message.notification != null &&
                                      senderName != Provider
                                          .of<UserProvider>(context, listen: false)
                                          .userData
                                          .name
                                      && Provider
                                          .of<ChatProvider>(context, listen: false)
                                          .openedChannelName != message.category) {
                                    /*
                                      * {
                                      *   messageId:
                                      *     {
                                            * senderId: e613bb99-af6c-4afb-bc63-1909a19c8b92,
                                            *  is_system_message: false, payload_id: 5dd1297f-e4ed-4b21-a0d9-ad441819af34,
                                            *  is_announcement: false, channel_id: 3fdfab40-6b66-4747-886f-b81db8ea35a7,
                                            *  channel_name: channel-1614709937-b2fb0597d40de63c66095c85af65b7e006beef924fa4975d84,
                                            *  isArticle: false, version: 1.1.0
                                      *     },
                                      *  data: {},
                                      *  mutableContent: true,
                                      *  category: channel-1614709937-b2fb0597d40de63c66095c85af65b7e006beef924fa4975d84,
                                      *  notification: {body: n, title: test one,
                                      *  apple: {}, sound: {name: notification.m4r,
                                      *  volume: 1, critical: false}}}
                                      * */

                                    var rng = Random();
                                    var code = rng.nextInt(900000) + 100000;

                                    MyApp.flutterLocalNotificationsPlugin.show(
                                        code,
                                        "${message.notification.title}",
                                        "${message.notification.body}",
                                        MyApp.iOSNotificationDetails
                                    );
                                  }
                                }
                              }
                              String isAnnouncement = '';
                              if (await message != null &&
                                  await message.messageId != null) {
                                /*
                                * {is_system_message: false,
                                *  payload_id: d41a9e31-26e1-4474-8422-034c9027b24b,
                                *  channel_id: 7eb9bfba-73cc-4ff6-8912-6e60bf2a42d9,
                                *  is_announcement: true,
                                *  channel_name: channel-1609782388-3d387982b0e974626ad17b8b8442afc0bef80d11b45a7de1e1,
                                *  version: 1.0.0,
                                *  sender_id: e613bb99-af6c-4afb-bc63-1909a19c8b92}
                                * }
                                * */

                                /// to show local Notification when an Announcement Message comes for iOS
                                String iOSNotificationPayload = message.messageId
                                    .toString();
                                var startOfsenderId = "sender_id:";
                                var endOfsenderId = "}";

                                var startIndex = iOSNotificationPayload.indexOf(
                                    startOfsenderId);
                                var endIndex = iOSNotificationPayload.indexOf(
                                    endOfsenderId,
                                    startIndex + startOfsenderId.length);
                                String senderId = iOSNotificationPayload.substring(
                                    startIndex + startOfsenderId.length, endIndex)
                                    .trim();

                                var startOfisAnnouncement = "is_announcement:";
                                var endOfsAnnouncement = ",";

                                var startIndexisAnnouncement = iOSNotificationPayload
                                    .indexOf(startOfisAnnouncement);
                                var endIndexisAnnouncement = iOSNotificationPayload
                                    .indexOf(endOfsAnnouncement,
                                    startIndexisAnnouncement +
                                        startOfisAnnouncement.length);
                                isAnnouncement = iOSNotificationPayload.substring(
                                    startIndexisAnnouncement +
                                        startOfisAnnouncement.length,
                                    endIndexisAnnouncement).trim();

                                if ((isAnnouncement == "true" ||
                                    isAnnouncement == "tru") && senderId != Provider
                                    .of<UserProvider>(context, listen: false)
                                    .userData
                                    .id) {
                                  var rng = Random();
                                  var code = rng.nextInt(900000) + 100000;

                                  MyApp.flutterLocalNotificationsPlugin.show(
                                      code,
                                      "Announcement 📣",
                                      "${message.notification.body}",
                                      MyApp.iOSNotificationDetails
                                  );
                                }
                              }
                              if (await message != null &&
                                  await message.category == null &&
                                  isAnnouncement != "true" &&
                                  isAnnouncement != "tru") {
                                Provider.of<UserProvider>(context, listen: false)
                                    .increaseBackendNotificationCount();
                              }
                            }
                          }
                      });

                      // this Method is to do what's needed when Notification is clicked if the app is in the background
                      FirebaseMessaging.onMessageOpenedApp.listen((
                          RemoteMessage message) async {
                          if (mounted) {
                            if (Platform.isAndroid) {
                              if (message != null &&
                                  message.notification.title.contains("Chat:")) {
                                Provider.of<ChatProvider>(context, listen: false)
                                    .createNewAuthKey(context)
                                    .then((_) async {
                                  // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                                  //   "conversation_messages": null,
                                  //   "channel": null,
                                  //   "channel_name": message.data["channel_name"],
                                  //   "pn":null,
                                  //   "private_chat_user": null,
                                  //   "type": null,
                                  //   "current_user_id": null
                                  // });


                                  // this condition is to add the new created channel if its not in the users channels set
                                  if (Provider
                                      .of<ChatProvider>(context, listen: false)
                                      .channelNamesSet
                                      .contains(message.data["channel_name"]) ==
                                      false) {
                                    Provider.of<ChatProvider>(
                                        context, listen: false).clearChannels();
                                    Provider.of<ChatProvider>(
                                        context, listen: false).fetchGroupChannels(
                                        context);
                                  }
                                  // this is to force the badge to show when a chat msg notification comes while the app is in the background for more than 10 mins
                                  ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                                  if (Provider
                                      .of<CallProvider>(context, listen: false)
                                      .hasPushedToCallScreen == false) {
                                    Navigator.of(context).popUntil(
                                        ModalRoute.withName(
                                            NavigationHome.routeName));
                                    Provider.of<ChangeIndex>(context, listen: false)
                                        .changeIndexFunction(2);
                                  }
                                });


                                // commented this part out since there is a listen already on the only for Android iOS requires this part
                                // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                                //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                                //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                                //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                                // }
                              } else
                              if (message != null && message.notification != null &&
                                  !message.notification.title.contains("Chat:") &&
                                  message.data['notification_type'].toString() !=
                                      '100') {
                                Provider.of<UserProvider>(context, listen: false)
                                    .increaseBackendNotificationCount();
                              }

                              // handling News notifications
                              else if (message != null &&
                                  message.data['notification_type'].toString() ==
                                      '100') {
                                // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                                // if(message.data['title'] == 'Focused News'){
                                //   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                                // }
                                // else{
                                //   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                                // }

                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchOrganisationNews(
                                    context,
                                    pageOffset: 0,
                                    trustId: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .userData
                                        .trust['id'],
                                    hospitalsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .hospitalIds,
                                    membershipsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .membershipIds);
                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchProfessionalNews(
                                    context, pageOffset: 0, trustId: Provider
                                    .of<UserProvider>(context, listen: false)
                                    .userData
                                    .trust['id']);
                              }

                              /// the code here is to flag the newly created group-channel that this user got included in when he clicks on the notification to open the app
                              /// but its suspended till work on 975 is done as Android doesn't get the Notification for it
                              /*else if(message != null && message.data != null/*&& message.data['notification_type'].toString() == '21'*/){
                              debugPrint("new Notification message to see !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ${message.data.toString()}");
                            }*/
                            }
                            else if (Platform.isIOS) {
                              debugPrint(
                                  "*************************************** 1111111 onMessageOpenedApp");

                              if (await message != null &&
                                  await message.category != null) {
                                if (message.category.contains("channel-")) {
                                  /// we might need to call this inside the Listen in chatProvider for iOS !!!!
                                  Provider.of<ChatProvider>(context, listen: false)
                                      .createNewAuthKey(context)
                                      .then((_) async {
                                    // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                                    //   "conversation_messages": null,
                                    //   "channel": null,
                                    //   "channel_name": message.category,
                                    //   "pn":null,
                                    //   "private_chat_user": null,
                                    //   "type": null,
                                    //   "current_user_id": null
                                    // });

                                    // this condition is to check if this channel is new or already included to current user's channels
                                    if (Provider
                                        .of<ChatProvider>(context, listen: false)
                                        .channelNamesSet
                                        .contains(message.category) == false) {
                                      Provider.of<ChatProvider>(
                                          context, listen: false).clearChannels();
                                      Provider.of<ChatProvider>(
                                          context, listen: false)
                                          .fetchGroupChannels(context)
                                          .then((_) {
                                        Provider.of<ChatProvider>(
                                            context, listen: false)
                                            .fetchHistoryForChannels(Provider
                                            .of<ChatProvider>(
                                            context, listen: false)
                                            .userAuthKey);
                                      });
                                    }
                                    // this is to force the badge to show when a chat msg notification comes while the app is in the background for more than 10 mins
                                    /// Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);

                                    if (Provider
                                        .of<CallProvider>(context, listen: false)
                                        .hasPushedToCallScreen == false) {
                                      await Navigator.of(context).popUntil(
                                          ModalRoute.withName(
                                              NavigationHome.routeName));
                                      Provider.of<ChangeIndex>(
                                          context, listen: false)
                                          .changeIndexFunction(2);
                                    }
                                  });


                                  // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                                  // if(message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                                  //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                                  //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                                  //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                                  // }

                                }
                              }

                              // handling news notification for iOS is different as the body for the notification is different
                              if (await message != null &&
                                  message.notification != null &&
                                  await message.notification.title ==
                                      'Focused News') {
                                // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                                // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchProfessionalNews(
                                    context, pageOffset: 0, trustId: Provider
                                    .of<UserProvider>(context, listen: false)
                                    .userData
                                    .trust['id']);
                              }
                              if (await message != null &&
                                  message.notification != null &&
                                  await message.notification.title ==
                                      'My Organisation') {
                                // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                                // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();

                                Provider.of<NewsProvider>(context, listen: false)
                                    .fetchOrganisationNews(
                                    context,
                                    pageOffset: 0,
                                    trustId: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .userData
                                        .trust['id'],
                                    hospitalsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .hospitalIds,
                                    membershipsIds: Provider
                                        .of<UserProvider>(context, listen: false)
                                        .membershipIds);
                              }


                              if (await message != null &&
                                  await message.category == null) {
                                Provider.of<UserProvider>(context, listen: false)
                                    .increaseBackendNotificationCount();
                              }
                            }
                          }
                      });
                      Navigator.pushNamed(context, NavigationHome.routeName);
                    }


                    // Provider.of<CallProvider>(context, listen: false).registerTwilioClient(context, id: Provider.of<UserProvider>(context, listen: false).userData.id,
                    //     name: Provider.of<UserProvider>(context, listen: false).userData.name,
                    //     myToken: Provider.of<UserProvider>(context, listen: false).userData.token);

                    else {
                      Navigator.pushNamed(context, WebMainScreen.routeName);
                    }
                  });


                // if(Provider.of<ChatProvider>(context, listen: false).channels.isEmpty)
                //   Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);


                //
                //         FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
                //           if (mounted) {
                //             if(Platform.isAndroid){
                //               // (message.notification != null) is commented out as it prevents navigationHome error when announcement get sent
                //               if (message != null && /* message.notification != null  && */ message.notification.title.contains("Chat:")) {
                //                 if (message.data != null) {
                //                   // this condition is to add the new created channel if its not in the users channels set
                //                   if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.data["channel_name"]) == false){
                //                     Provider.of<ChatProvider>(context, listen: false).clearChannels();
                //                     Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
                //                   }
                //                   // commented this part out since there is a listen already on the only for Android iOS requires this part
                //                   // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                //                   //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                //                   //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                //                   //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                //                   // }
                //                 }
                //
                //               }
                //               else if(message != null && message.notification!= null  && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
                //                 Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                //               }
                //
                //               // handled for Android but still need to be handled for ios
                //               if(message != null && message.data['notification_type'].toString()=='100'){
                //                 Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                //                 if(message.data['title'] == 'Focused News'){
                //                   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                //                 }
                //                 else{
                //                   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                //                 }
                //
                //                 Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                //                     context,
                //                     pageOffset: 0,
                //                     trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                //                     hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                //                     membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                //                 Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                //               }
                //
                //
                //               if(message != null && message.data['is_announcement'] == "true" && message.data["sender_id"] != Provider.of<UserProvider>(context, listen: false).userData.id){
                //
                //                 /* this is the announcement body that gets sent to Android *******
                //                 new
                //                 {channel_name: channel-1627569163-d4f9bcd3867d48f889312c7abc2f48dfbd5d1b13e7d7fcebc7,
                //                  payload_id: 9ce7e749-cbe3-4274-9e37-3409c270d7b6,
                //                  is_system_message: false,
                //                  is_announcement: true,
                //                  text: test, channel_id: 4e83a2d7-1554-4852-99fb-4d3e369ec4f2,
                //                  version: 1.0.0,
                //                  sender_id: 2265b3b5-e649-4b4b-8c33-f50c2cb59164}
                //                 */
                //                 // handled for Android but still need to be handled for ios
                //                 showNotificationsCustomDialog(
                //                   context,
                //                   key: Key("value"),
                //                   width: double.infinity,
                //                   title: "New Announcement",
                //                   subTitle: "${message.data['text']}",
                //                   mainPhoto: Image.asset("images/AppIcon.png"),
                //                 );
                //               }
                //             }
                //
                //             else if(Platform.isIOS){
                //               print("heeeeeey this is the print from onMessage.listen @@@@@@@@@@@@@@@@1111");
                //
                //               // handling news notification for iOS is different as the bdy for the notification is different
                //               if(await message != null && await message.notification.title == 'Focused News'){
                //                 Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                //                 Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                //                 Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                //               }
                //               else if (await message != null && await message.notification.title == 'My Organisation'){
                //                 Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                //                 Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                //
                //                 Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                //                     context,
                //                     pageOffset: 0,
                //                     trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                //                     hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                //                     membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                //               }
                //
                //
                //               if (await message != null && await message.category != null) {
                //                 if(message.category.contains("channel-")){
                //                   if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
                //                     Provider.of<ChatProvider>(context, listen: false).clearChannels();
                //                     Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                //                       Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                //                     });
                //                   }
                //
                //                   // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                //                   // if (message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                //                   //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                //                   //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                //                   //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                //                   // }
                //
                //                 }
                //               }else if(await message != null && await message.category == null){
                //                 Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                //               }
                //               if(await message != null && await message.messageId != null){
                //                 /*
                // * {is_system_message: false,
                // *  payload_id: d41a9e31-26e1-4474-8422-034c9027b24b,
                // *  channel_id: 7eb9bfba-73cc-4ff6-8912-6e60bf2a42d9,
                // *  is_announcement: true,
                // *  channel_name: channel-1609782388-3d387982b0e974626ad17b8b8442afc0bef80d11b45a7de1e1,
                // *  version: 1.0.0,
                // *  sender_id: e613bb99-af6c-4afb-bc63-1909a19c8b92}
                // * }
                // * */
                //                 String iOSNotificationPayload = message.messageId.toString();
                //                 var startOfsenderId = "sender_id:";
                //                 var endOfsenderId = "}";
                //
                //                 var startIndex = iOSNotificationPayload.indexOf(startOfsenderId);
                //                 var endIndex = iOSNotificationPayload.indexOf(endOfsenderId, startIndex + startOfsenderId.length);
                //                 String senderId = iOSNotificationPayload.substring(startIndex + startOfsenderId.length, endIndex).trim();
                //
                //                 var startOfisAnnouncement = "is_announcement:";
                //                 var endOfsAnnouncement = ",";
                //
                //                 var startIndexisAnnouncement = iOSNotificationPayload.indexOf(startOfisAnnouncement);
                //                 var endIndexisAnnouncement = iOSNotificationPayload.indexOf(endOfsAnnouncement, startIndexisAnnouncement + startOfisAnnouncement.length);
                //                 String isAnnouncement = iOSNotificationPayload.substring(startIndexisAnnouncement + startOfisAnnouncement.length, endIndexisAnnouncement).trim();
                //
                //                 if((isAnnouncement == "true" || isAnnouncement == "tru") && senderId != Provider.of<UserProvider>(context, listen: false).userData.id){
                //
                //                   showNotificationsCustomDialog(
                //                     context,
                //                     key: Key("value"),
                //                     width: double.infinity,
                //                     title: "New Announcement",
                //                     subTitle: "${message.notification.body}",
                //                     mainPhoto: Image.asset("images/AppIcon.png"),
                //                   );
                //                 }
                //
                //               }
                //
                //             }
                //           }
                //         });
                //
                //         // this Method is to do what's needed when Notification is clicked if the app is in the background
                //         FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
                //           if (mounted) {
                //             if(Platform.isAndroid){
                //               if (message != null && message.notification.title.contains("Chat:")) {
                //
                //                 Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_){
                //                   // this condition is to add the new created channel if its not in the users channels set
                //                   if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.data["channel_name"]) == false){
                //                     Provider.of<ChatProvider>(context, listen: false).clearChannels();
                //                     Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
                //                   }
                //                   Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));
                //                   Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                //                 });
                //
                //
                //                 // commented this part out since there is a listen already on the only for Android iOS requires this part
                //                 // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                //                 //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                //                 //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                //                 //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                //                 // }
                //               }else if(message != null && message.notification!= null && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
                //                 Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                //               }
                //
                //               // handling News notifications
                //               else if(message != null && message.data['notification_type'].toString()=='100'){
                //                 Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                //                 if(message.data['title'] == 'Focused News'){
                //                   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                //                 }
                //                 else{
                //                   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                //                 }
                //
                //                 Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                //                     context,
                //                     pageOffset: 0,
                //                     trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                //                     hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                //                     membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                //                 Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                //               }
                //             }
                //             else if(Platform.isIOS){
                //
                //               print("heeeeeey this is the print from onOpenApp @@@@@@@@@@@@@@@@");
                //               if (await message != null && await message.category != null) {
                //
                //                 if(message.category.contains("channel-")){
                //                   Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_){
                //
                //                     // Provider.of<ChatProvider>(context, listen: false).newMessages[message.category] = message.;
                //                     // Provider.of<ChatProvider>(context, listen: false).newMessagesCreatedAt[message.category] = event;
                //
                //                     // if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
                //                     Provider.of<ChatProvider>(context, listen: false).clearChannels();
                //                     Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                //                       Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                //                       // Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));
                //                       // Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                //                     });
                //                     // }
                //                     Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));
                //                     Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                //                   });
                //                   // this condition is to check if this channel is new or already included to current user's channels
                //
                //
                //                   // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                //                   // if(message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                //                   //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                //                   //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                //                   //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                //                   // }
                //
                //                 }
                //               }
                //
                //               // handling news notification for iOS is different as the body for the notification is different
                //               if(await message != null && await message.notification.title == 'Focused News'){
                //                 Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                //                 Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                //                 Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                //               }
                //               if (await message != null && await message.notification.title == 'My Organisation'){
                //                 Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                //                 Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                //
                //                 Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                //                     context,
                //                     pageOffset: 0,
                //                     trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                //                     hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                //                     membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                //               }
                //
                //
                //               if(await message != null && await message.category == null){
                //                 Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                //               }
                //
                //             }
                //           }
                //
                //         });


                // ignore: missing_return


                // this Method is to do what's needed when Notification is clicked if the app is terminated

              }
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationHome(trustId:  Provider.of<UserProvider>(context, listen: false).userTrustId,)));
            });
          }
          else {
            if (!kIsWeb) Navigator.pushNamed(context, LandingPage.routeName);
            else Navigator.pushNamed(context, WebLandingPage.routeName);
          }
        });
      }
      else{
        showGeneralDialog(
          context: context,
          barrierLabel: "Barrier",
          barrierColor: Colors.black.withOpacity(0.5),
          barrierDismissible: false,
          transitionDuration: Duration(milliseconds: 500),
          transitionBuilder: (_, anim, __, child) {
            return SlideTransition(
              position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
              child: WillPopScope(
                  onWillPop: () async => false,
                  child: child),
            );
          },
          pageBuilder: (_, __, ___) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return FailureConnectionAlertDialogContent(
                     (){
                    Navigator.pop(context);
                    navigateToOtherScreen();
                  },
                  );
                });
          },
        );
      }
    });
  }


  Animation<double> _animation;
  AnimationController _animationController;

  void _animationState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
  }

  @override
  void initState() {
    super.initState();
    _animationState();

    // FirebaseMessaging.onBackgroundMessage((message) => null)
    WidgetsBinding.instance.addObserver(this);


        navigateToOtherScreen();

        Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
        Provider.of<UserProvider>(context, listen: false).updateUnreadNotificationCount();
        // Provider.of<NewsProvider>(context, listen: false).updateUnreadNewsNotificationCount();
        // Provider.of<NewsProvider>(context, listen: false).updateUnreadMyOrganisationNewsNotificationCount();
        // Provider.of<NewsProvider>(context, listen: false).updateUnreadFocusedNewsNotificationCount();


  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
        Container(
        color: Theme.of(context).primaryColor,
        width: media.width,
        height: media.height,),
            Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(88)),child: Image.asset('${Provider.of<UserProvider>(context,listen: false).currentAppBackground}',fit: kIsWeb ? BoxFit.cover : BoxFit.fitHeight,))),
            Container(
                color: Colors.transparent,
                width: media.width,
                height: media.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: OpacityAnimatedWidget.tween(
                    opacityEnabled: 1, //define start value
                    opacityDisabled: 0, //and end value
                    enabled: true, //bind with the boolean
                    duration: const Duration(milliseconds: 1200),
                    child:  ScaleTransition(
                      scale: _animation,
                      child: Hero(
                        tag: 'img_logo',
                        child: Container(
                          width: media.width*0.5,
                          decoration: const BoxDecoration(
                              image: DecorationImage(image: AssetImage("images/img_logo.webp"))
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
          ],
        ),
        // ),
      ),
    );
  }
}