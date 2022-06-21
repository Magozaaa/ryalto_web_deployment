
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'dart:io';
import 'dart:math';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:eraser/eraser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart' as pn;
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/ChannelModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/Subscreens/SplashScreen.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'dart:developer';
import 'package:http/io_client.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import '../main.dart';

enum ChatStage { ERROR, LOADING, DONE }

class ChatProvider extends ChangeNotifier {
  ChatStage stage;
  ChatStage crateNewAuthKeyStage;
  ChatStage findingUserStage;
  ChatStage loadingLastMsgs;
  ChatStage loadingChannelDataStage;
  ChatStage loadingChannelParticipantsStage;
  ChatStage updatingChannels;
  ChatStage creatingNewChatChannel;
  ChatStage setOpenChannelNameStage;




  final String errorMessage = "Network Error !";
  List<ChannelModel> _channels = [];
  String _channelsNames = "";
  String _userAuthKey = "";
  Map<String, dynamic> _channelUsers = {};
  String _channelGroupName = '';
  Set<String> _channelNamesSet = {};
  Map<String, dynamic> channelsHistory = {};
  Map<String, dynamic> channelsLastMessage = {};
  Map<String, dynamic> newMessages = {};
  Map<String, dynamic> newMessagesCreatedAt = {};
  pn.PubNub _pubnub;
  var _myKeyset;
  Map<String, dynamic> _doesChannelHasNewMsg = {};
  String _mediaUrl;
  ChannelModel _currentChannel;
  int _unreadChatMsgs = 0;
  String _openedChannelName = '';
  List<User> _groupChannelParticipants = [];

  // bool _shouldShowLoaderInChatTab = false;

  String get channelsNames => this._channelsNames;
  String get openedChannelName => this._openedChannelName;
  List<ChannelModel> get channels => this._channels;
  String get userAuthKey => this._userAuthKey;
  Map<String, dynamic> get channelUsers => this._channelUsers;
  String get channelGroupName => this._channelGroupName;
  Set<String> get channelNamesSet => this._channelNamesSet;
  Map<String, dynamic> get doesChannelHasNewMsg => this._doesChannelHasNewMsg;
  String get mediaUrl => this._mediaUrl;
  pn.PubNub get pubnub => this._pubnub;
  get myKeyset => this._myKeyset;
  ChannelModel get currentChannel => this._currentChannel;
  int get unreadChatMsgs => this._unreadChatMsgs;
  List<User> get groupChannelParticipants => this._groupChannelParticipants;
  // bool get shouldShowLoaderInChatTab => this._shouldShowLoaderInChatTab;
  //
  // this var is to listen on app state (background or foreground !!!
  StreamSubscription<FGBGType> appLifeCyclesubscription;

  // setShouldShowLoaderInChatTab(bool shouldShow){
  //   _shouldShowLoaderInChatTab = shouldShow;
  // }

  setChannels(List<ChannelModel> userChannels) {
    _channels = userChannels;
  }

  clearGroupChannelParticipants(){
    _groupChannelParticipants.clear();
    notifyListeners();
  }

  setOpenChannelName(String channelName){
    this.setOpenChannelNameStage = ChatStage.LOADING;
    _openedChannelName = channelName;
    this.setOpenChannelNameStage = ChatStage.DONE;



    notifyListeners();
  }

  clearChannelsLastMsgOnLogout(){
    channelsLastMessage.clear();
    notifyListeners();
  }

  clearOpenChannelName(BuildContext context, {String channelName}){
    _openedChannelName = '';
    notifyListeners();
  }

  setChannelsNames(String userChannelsNamesNames) {
    _channelsNames = userChannelsNamesNames;
  }

  clearChannels() {
    _channels.clear();
    _channelNamesSet.clear();
    notifyListeners();
  }

  clearChannelsHistory() {
    channelsHistory.clear();
    notifyListeners();
  }

  unsubscribeFromChatChannels({deviceToken = ""}) {
    pubnub.unsubscribeAll();
    if (!kIsWeb) {
      if(Platform.isIOS){
        pubnub.removeDevice(deviceToken, pn.PushGateway.apns);
        pubnub.removePushChannels(deviceToken, pn.PushGateway.apns, _channelNamesSet);
      }else{
        pubnub.removeDevice(deviceToken, pn.PushGateway.gcm);
        pubnub.removePushChannels(deviceToken, pn.PushGateway.gcm, _channelNamesSet);
      }
    }
  }

  removeChannel(channel) {
    _channels.removeAt(channel);
    notifyListeners();
  }

  sortChannels() {
    /// check this line to make sure newly created channels has the correct timeToken/created_at values
    _channels.forEach((element) {
      if (element.lastMessageTimetoken == null || element.lastMessageTimetoken == "")
        element.lastMessageTimetoken = element.lastMsgAt??element.createdAt;
      //int.parse(DateTime.now().millisecondsSinceEpoch.toString());
    });
    _channels.sort((ch1, ch2) =>
    -ch1.lastMessageTimetoken.compareTo(ch2.lastMessageTimetoken));
    // -ch1.lastMsgAt??-ch1.createdAt.compareTo(ch2.lastMsgAt??ch2.createdAt));

    debugPrint("sort channels has been called !!!!!!!!");
    notifyListeners();
  }

  clearCurrenChannel() {
    _currentChannel = null;
    notifyListeners();
  }

  setCurrentChannel(ChannelModel myChannel){
    _currentChannel = myChannel;
    notifyListeners();
  }






  getSavedLastMsgTimeForChannelsBeforeAppGoesInactive(BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();

    if(_channels.isNotEmpty && prefs.getString("whenAppWentToBackground") != null){


      _channels.forEach((channel) {

        if (channel != null && channel.lastMsgAt != null &&
            DateTime.parse(prefs.getString("whenAppWentToBackground")??DateTime.now()).millisecondsSinceEpoch < channel.lastMsgAt) {

          setNewMSGforChannelToTrue(channel.name);
          // debugPrint("hey this is the stored value ^^^^^^^^^^^^^^^^^^^^ from getting the saved data ^^^^^^^^^^^^^ ${channel.displayName}  ${channel.channelType}  ${_lastMsgTimeForEachChannelLocally[channel.name]}");
          debugPrint("when app went to background from getting the saved data ^^^^^^^^^^^^^ ${_channels.first.displayName}  ${_channels.first.channelType}  ${DateTime.parse(prefs.getString("whenAppWentToBackground")??DateTime.now()).millisecondsSinceEpoch}");
          debugPrint("this is the LAST-MSG-AT from getting the saved data ^^^^^^^^^^^^^     ${_channels.first.displayName}  ${_channels.first.channelType}  ${_channels.first.lastMsgAt}");

        }
      });
    }
    /// this code is to Flag the channels that has messages sent to current user while they weren't logged in
     if(_channels.isNotEmpty && prefs.getString("whenAppWentToBackground") == null){

      _channels.forEach((channel) {

        if (channel != null && channel.lastMsgAt != null && Provider.of<UserProvider>(context, listen: false).userData.verified &&
            Provider.of<UserProvider>(context, listen: false).userData.lastLogoutAt < channel.lastMsgAt) {
          setNewMSGforChannelToTrue(channel.name);
        }
        else if(channel.channelType == "group" && Provider.of<UserProvider>(context, listen: false).userData.verified &&
            Provider.of<UserProvider>(context, listen: false).userData.lastLogoutAt < channel.createdAt && channel.adminId != Provider.of<UserProvider>(context, listen: false).userData.id){
          setNewMSGforChannelToTrue(channel.name);
        }

      });

    }
    notifyListeners();
  }
  //
  DateTime whenAppWentToBackground = DateTime.now();
  DateTime whenAppCameToLiveFromBackground = DateTime.now();
  int differenceInMinutes = 0;

  setTimeWhenAppWentToBackground() async{
    final prefs = await SharedPreferences.getInstance();
    whenAppWentToBackground = DateTime.now();
    prefs.setString("whenAppWentToBackground", whenAppWentToBackground.toString());
    notifyListeners();
  }

  getTimeWhenAppCameToLiveFromBackground(BuildContext context) async{

    whenAppCameToLiveFromBackground = DateTime.now();

    final prefs = await SharedPreferences.getInstance();

    if(prefs.getString("whenAppWentToBackground") != null){
      whenAppWentToBackground = DateTime.parse(prefs.getString("whenAppWentToBackground"));
      debugPrint("here is when the app went to background -----------------========> $whenAppWentToBackground");
      differenceInMinutes = whenAppCameToLiveFromBackground.difference(whenAppWentToBackground).inMinutes;
    }
    /// this code is to restart the app after 5 mins to Flag the channels that has messages sent to current user while they weren't logged in
    else{
      whenAppWentToBackground = DateTime.fromMillisecondsSinceEpoch(Provider.of<UserProvider>(context, listen: false).userData.lastLogoutAt);
      debugPrint("here is when the app went to background after first Login/SignUp -----------------========> $whenAppWentToBackground");
      differenceInMinutes = whenAppCameToLiveFromBackground.difference(whenAppWentToBackground).inMinutes;
    }
    notifyListeners();
  }

  updateUnreadMsgsCount() async{
    // this method is to get the last updated unread chat msgs count before app gets terminated
    final prefs = await SharedPreferences.getInstance();
    final storedUnreadMsgsCount = prefs.getInt("unSeen_Msgs");
    Map<String, dynamic> chatChannelsState = {};
    if(storedUnreadMsgsCount != null)
      chatChannelsState = jsonDecode(prefs.getString("chatChannelsState"));

    _unreadChatMsgs = storedUnreadMsgsCount;
    if(_unreadChatMsgs == null){
      _unreadChatMsgs = 0;
    }
    debugPrint("stored unseen msgs is $storedUnreadMsgsCount");
    if(chatChannelsState != null){
      _doesChannelHasNewMsg = chatChannelsState;
    }
    notifyListeners();
  }

  setNewMSGforChannelToTrue(channelName,) async{
    _doesChannelHasNewMsg[channelName] = true;
    _unreadChatMsgs = 0;
    _doesChannelHasNewMsg.values.toList().forEach((element) {
      if(element == true){
        _unreadChatMsgs += 1;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("unSeen_Msgs", _unreadChatMsgs);
    prefs.setString("chatChannelsState", jsonEncode(_doesChannelHasNewMsg));
    debugPrint("the value of chat flag is $_unreadChatMsgs");
    // debugPrint("the map to tell if the user has new message $doesChannelHasNewMsg");
    // debugPrint("@@@@@@@@@@@@ sender is $senderIdForiOS  current user is $currentUserId  $calledFrom");

    notifyListeners();
  }

  setNewMSGforChannelToNull(channelName) async{
    _doesChannelHasNewMsg[channelName] = null;

    // _channels.firstWhere((ch) => ch.name == channelName).lastMsgAt = null;

    _unreadChatMsgs = 0;
    _doesChannelHasNewMsg.values.toList().forEach((element) {
      if(element == true){
        _unreadChatMsgs += 1;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("unSeen_Msgs", _unreadChatMsgs);
    if(_doesChannelHasNewMsg.isNotEmpty){
      prefs.setString("chatChannelsState", jsonEncode(_doesChannelHasNewMsg));
    }
    /// new to prevent showing flags for read messages if the app got terminated very fast after reading messages
    whenAppWentToBackground = DateTime.now();
    prefs.setString("whenAppWentToBackground", whenAppWentToBackground.toString());

    debugPrint("the value of chat flag is $_unreadChatMsgs");
    notifyListeners();
  }



  clearChatUnreadMessagesOnLogout() async{
    _doesChannelHasNewMsg.clear();
    _unreadChatMsgs = 0;
    // FlutterAppBadger.removeBadge();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("unSeen_Msgs", _unreadChatMsgs);
    prefs.setString("chatChannelsState", jsonEncode(_doesChannelHasNewMsg));
    debugPrint("the value of chat flag is $_unreadChatMsgs");
    notifyListeners();
  }


  intializingPubnub(pn.PubNub pubnub) {
    _pubnub = pubnub;
    print('intializingPubnub $_pubnub');
    notifyListeners();
  }

  intializingKeyset(var keyset) {
    _myKeyset = keyset;
    notifyListeners();
  }

  /// this method is from pubnub to list all channels for a given channel-group
  // Future listSortedChannels(authKey) async{
  //   try{
  //     var request = http.Request('GET', Uri.parse(
  //          "https://ps.pndsn.com/v1/channel-registration/sub-key/$pnSubscribeKey/channel-group/$_channelGroupName?auth=$authKey"
  //        ));
  //     var responseString;
  //
  //     http.StreamedResponse response = await request.send();
  //     responseString = await response.stream.bytesToString();
  //     var responseList = json.decode(responseString);
  //
  //
  //     if (response.statusCode == 200) {
  //       var lastch = responseList["payload"]["channels"];
  //       debugPrint("MY SORTED channels ${responseList}");
  //       debugPrint("MY SORTED channels ${lastch}");
  //     }
  //     else {
  //       debugPrint(response.reasonPhrase);
  //     }
  //   }catch(e){
  //     debugPrint(e.toString());
  //   }
  // }

  registerForChatPushNotifications(String deviceToken) async {

    //  pubnub.listPushChannels(deviceToken,
    //   /*Platform.isAndroid ? pn.PushGateway.gcm : */ pn.PushGateway.fcm,
    // ).then((pn.ListPushChannelsResult value) => debugPrint("sdsdsdsds22 ${value.channels.length}"));

    try {
      pubnub.addPushChannels(deviceToken,
        Platform.isIOS ? pn.PushGateway.apns :
        pn.PushGateway.gcm,
        _channelNamesSet,
      ).then((value) => debugPrint("status for chat channel notifications subscription ${value.status}"));
    } catch (e) {
      debugPrint("Error $e");
    }


  }


  Future fetchGroupChannels(BuildContext context,{int offset = 0, bool isInitialLoad = false, bool isFromNewChatTab = false}) async {
    this.stage = ChatStage.LOADING;


    debugPrint("fetchGroupChannels has been called !!!!!!!!!!!!!!");

    if (isFromNewChatTab) {
      debugPrint("fetchGroupChannels has been called !!!!!!!!!!!!!! from NewChatScreen in chat Tab !!!!!!!!");
    }


    if (offset == null)
      offset = 0;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");

    if (storedUser != null) {

    String token = jsonDecode(storedUser)['token'];
    String userId = jsonDecode(storedUser)['id'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };
    var responseString;

    try {
      var request =
      http.Request('GET', Uri.parse(
          '$appDomain/chat/channel_groups?limit=25&offset=${offset ?? 0}'));
      request.headers.addAll(headers);

      debugPrint("fetchGroupChannelssssssssssssss ${'$appDomain/chat/channel_groups?limit=25&offset=${offset ?? 0}'}");


      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      String userChannelsNames = "";

      if (response.statusCode == 200) {
        print('fetch group chanelllllllls ${responseString}');
        if (offset == 0) {
          if (_myKeyset == null)
            intializingKeyset(pn.Keyset(
                subscribeKey: pnSubscribeKey,
                publishKey: pnPublishKey,
                authKey: _userAuthKey,
                uuid: pn.UUID(Provider
                    .of<UserProvider>(context, listen: false)
                    .userData
                    .id)));

          _pubnub = pn.PubNub(defaultKeyset: _myKeyset);

          // if (_channels.isNotEmpty && _pubnub != null) {
          //   await _pubnub.unsubscribeAll();
          // }

          _channels.clear();
          _channelsNames = "";
          _channelNamesSet.clear();
        }


        Map<String, dynamic> responseList = json.decode(responseString);
        _channelGroupName = responseList["name"];
        responseList["channels"].forEach((element) {
          final ChannelModel channel = ChannelModel.fromJson(element);
          _channels.add(channel);
          _channelNamesSet.add(channel.name);
          _channelsNames = _channelsNames + "${channel.name},";
          userChannelsNames = userChannelsNames + "${channel.name},";

          /// moved this line here and commented out the other forEach !!
          if (channel.channelType == "private") {
            fetchUserById(context, userIds: channel.participantIds,
                channelName: channel.name);
          }
        });

        // _channels.forEach((channel) {
        //   /// has to be in a forEach on its own otherwise it hide all private channels when a notification comes from private chat !!!
        //   if (channel.channelType == "private") {
        //     fetchUserById(context, userIds: channel.participantIds, channelName: channel.name);
        //   }
        // });


        /// this code is to get the flags when the app starts after being terminated only
        /// ---- if we are going to call the following func regardless isInitialLoad or not
        /// we have to save the last time every channel got read !!!! -----


        if (isInitialLoad ||
            isFromNewChatTab /*& _isInit*/ /*&& appLifeCyclesubscription == null*/ /*|| appLifeCyclesubscription == null || appLifeCyclesubscription.isPaused*/) {
          getSavedLastMsgTimeForChannelsBeforeAppGoesInactive(context);
          //_isInit = false;
        }


        if (offset == 0 /*&& isInitialLoad*/) {
          if (!kIsWeb) {
            if (appLifeCyclesubscription == null) {
              appLifeCyclesubscription = FGBGEvents.stream.listen((appLifeCycleEvent) {
                    if (appLifeCycleEvent == FGBGType.background) { // FGBGType.foreground or FGBGType.background

                      setTimeWhenAppWentToBackground();

                      debugPrint("^^^^^^^^^^^^^^^^^^^^^^^^^^^ $appLifeCycleEvent");
                    }
                    else if (appLifeCycleEvent == FGBGType.foreground) {
                      getTimeWhenAppCameToLiveFromBackground(context).then((_) async {
                        debugPrint("********************************* difference in minutes $differenceInMinutes");
                        if (differenceInMinutes != null &&
                            differenceInMinutes > 4 && await TwilioVoice.instance.call.isOnCall() == false) {

                          RestartWidget.restartApp(context);
                          // Phoenix.rebirth(context);
                        }
                        else {
                          // createNewAuthKey(context).then((_) {
                          //   _shouldShowLoaderInChatTab = true;
                          // clearChannels();
                          // clearChannelsLastMsgOnLogout();

                          fetchGroupChannels(context, offset: 0).then((_) {

                            /// ----- if Flagging channels are enabled in the _pubnub listen we can comment this out
                            /// and it will work as listen is still working for few mins while app is in background ------
                            getSavedLastMsgTimeForChannelsBeforeAppGoesInactive(
                                context).then((_) {

                              /// see if we can alter the sortChannels function and sort according to last_message_at that comes from fetchGroupChannels
                              // fetchHistoryForChannels(_userAuthKey);

                              // _shouldShowLoaderInChatTab = false;

                              // to Erase the badge on the App Icon for Android
                                if (Platform.isAndroid) {
                                  Eraser.clearAllAppNotifications();
                                }
                            });

                            Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                                context,
                                pageOffset: 0,
                                trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                                hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                                membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);

                            Provider.of<NewsProvider>(context, listen: false).fetchProfessionalNews(
                                context,
                                pageOffset: 0,
                                trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);


                            // });

                          });
                        }
                      });

                      debugPrint("^^^^^^^^^^^^^^^^^^^^^^^^^^^ should be ACTIVE !! $appLifeCycleEvent");
                    }
                  });
            }
          }

          _pubnub.subscribe(channelGroups: {_channelGroupName} /*_channelNamesSet*/).asStream().forEach((sub) {
            sub.messages.listen((event) {
              newMessages[event.channel] = event.payload;
              newMessagesCreatedAt[event.channel] = event;


              if (channelNamesSet.contains(event.channel) == false) {
                clearChannels();
                fetchGroupChannels(context).then((_) {
                  fetchHistoryForChannels(_userAuthKey);
                  if(_channels.firstWhere((channel) => channel.name == event.channel).adminId != userId){
                    setNewMSGforChannelToTrue(event.channel);
                  }
                });
              }

              // var rng = Random();
              // var code = rng.nextInt(900000) + 100000;

              if (_channels.isNotEmpty &&
                  (_channelNamesSet.contains(event.channel) &&
                      event.payload["pn_apns"]["chat_message"]["is_announcement"] == false &&
                      event.payload["pn_gcm"]["data"]["is_announcement"] == false)) {
                if (
                //event.payload["pn_gcm"]["data"].toString().contains("senderId") && event.payload["pn_gcm"]["data"]["senderId"].toString()
                event.uuid.toString() != userId && _openedChannelName != event.channel) {

                  /// commented just to test what flags it when app is in background
                  setNewMSGforChannelToTrue(event.channel);

                  // MyApp.flutterLocalNotificationsPlugin.show(
                  //     code,
                  //     "${event.payload["pn_gcm"]["data"]['text']}",
                  //     "",
                  //     Platform.isIOS ? MyApp.iOSNotificationDetails : MyApp.androidNotificationDetails
                  // );

                }
              }

              // this means that this channel is an announcement
              else if (_channels.isNotEmpty &&
               (_channelNamesSet.contains(event.channel) && event.payload["pn_apns"]["chat_message"]["is_announcement"] == true &&
                      event.payload["pn_gcm"]["data"]["is_announcement"] == true)) {
                    Map<String, dynamic> announcementSenderInfo = {};
                    String gettingFullLongBase64String(String text) {
                      String res = "";
                      final pattern =
                      RegExp('.{1,800}'); // 800 is the size of each chunk
                      pattern.allMatches(text).forEach((match) =>
                      res += match.group(0));
                      return res;
                  }

                List<int> listOfInts = base64Decode(gettingFullLongBase64String("${event.payload["content"]}"));
                announcementSenderInfo = json.decode(utf8.decode(listOfInts))["entity"]["sender"];

                if (announcementSenderInfo["id"] != userId && _openedChannelName != event.channel) {

                  debugPrint("hey flagging the announcement channel ============> announce sender id ${announcementSenderInfo["id"]} current user id ${userId}");
                  setNewMSGforChannelToTrue(event.channel);

                  // MyApp.flutterLocalNotificationsPlugin.show(
                  //     code,
                  //     "Announcement 📣",
                  //     "${event.payload["pn_gcm"]["data"]['text']}",
                  //     Platform.isIOS ? MyApp.iOSNotificationDetails : MyApp.androidNotificationDetails
                  // );
                }
              }


              if (_channels.isNotEmpty &&
                  _channelNamesSet.contains(event.channel)) {
                _channels
                    .firstWhere((ch) => ch.name == event.channel)
                    .lastMessageTimetoken =
                    int.parse(event.timetoken.toString().substring(0, 13));
              }

              sortChannels();
            });
          }
          );
        }
      } else {
        this.stage = ChatStage.ERROR;
        debugPrint(response.reasonPhrase);
      }
      this.stage = ChatStage.DONE;

    } catch (e) {
      this.stage = ChatStage.ERROR;
      debugPrint("$e");
    }
    notifyListeners();
    }
  }


// Fetch Group Channels only to use it in Contacts Screen in case the user is sharing an article

  List<ChannelModel> _groupChannelsInContactsScreen=[];
  List<ChannelModel> get groupChannelsInContactsScreen=>this._groupChannelsInContactsScreen;


  setGroupChannelsInContactsScreen(List<ChannelModel> groupChannels){
    _groupChannelsInContactsScreen = groupChannels;
  }

  Future fetchGroupChannelsOnly(BuildContext context) async {
    this.stage = ChatStage.LOADING;

    String url = "$appDomain/chat/channels?group_channels=true";
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    String userId = jsonDecode(storedUser)['id'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };
    var responseString;

    try {
      var request =
      http.Request('GET', Uri.parse(url));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      List<dynamic> responseMap = json.decode(responseString);
      List<ChannelModel> channels =[];
      if (response.statusCode == 200) {
        if(responseMap!=null){
          responseMap.forEach((element) {
            channels.add(ChannelModel.fromJson(element));
          });
          setGroupChannelsInContactsScreen(channels);

        }
      }
      this.stage = ChatStage.DONE;

    }
    catch(e){
      debugPrint(e.toString());
      this.stage = ChatStage.ERROR;

    }
    notifyListeners();
  }

  fetchUserById(BuildContext context,
      {List userIds, channelName, bool isAnnoucnement = false}) async {

    this.findingUserStage = ChatStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    String userId = jsonDecode(storedUser)['id'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };

    var responseString;
    List<String> castingList = [];
    List<User> userListForChannel = [];
    try{
      userIds.forEach((element) {
        if (element != null) {
          if ((element != userId ??
              Provider.of<UserProvider>(context, listen: false).userData.id) && isAnnoucnement == false) {
            // if(element != (Provider.of<UserProvider>(context, listen: false).userData == null ? userId : Provider.of<UserProvider>(context, listen: false).userData.id) && isAnnoucnement == false){
            castingList.add('"$element"');
          } else if (isAnnoucnement == true) {
            castingList.add('"$element"');
          }
        }
      });

      var request = http.Request('POST', Uri.parse('$appDomain/chat/users'));
      request.body = '''{\n  "ids": $castingList\n}''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      List<dynamic> newsResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        newsResponse.forEach((element) {
          var user = User.fromJson(element);
          //if(!_channelUsers.containsKey(channelName)){
          userListForChannel.add(user);
          _channelUsers[channelName] = userListForChannel;

          // adding this line to register users for Twilio in order not to have Ryalto user as name when they call
          if (!kIsWeb) {
            TwilioVoice.instance.registerClient(user.id, user.name);
          }
          //}
        });
        //debugPrint(_channelUsers.toString());
      }
      notifyListeners();
      this.findingUserStage = ChatStage.DONE;
    }catch(e){
      this.findingUserStage = ChatStage.ERROR;
    }


  }

  fetchChatUserByName({name, channelName}) {
    var user;
    if (_channelUsers[channelName] != null){
      if (_channelUsers[channelName].any((element) => element.name == name)) {
        user =
            _channelUsers[channelName].firstWhere((element) => element.name ==
                name);
      }
    }
    return user ?? null;
  }

  clearChannelUsers() {
    _channelUsers.clear();
    notifyListeners();
  }

  settingMediaUrlNull() {
    _mediaUrl = null;
    notifyListeners();
  }


  Future fetchHistoryForChannels(authKey) async {
    this.loadingLastMsgs = ChatStage.LOADING;
    channelsLastMessage.clear();
    newMessages.clear();

    try {
      var request = http.Request(
          'GET',
          Uri.parse(
            // MyApp.flavor == "staging" ?
            // "https://ps.pndsn.com/v3/history/sub-key/$pnSubscribeKey/channel/channel-1627373776-fa204a95c449898b66a376dc7350d2aceee312eae60667ed02,channel-1627942655-2cce746db2faa939078750eb9c2b89779d7bc77e662b18ff5b,channel-1628158917-7498e5e83abb943338d699d48f984786dae80117c797b8c610,channel-1629110121-1655fde5f25f8b950e2209156003ac685771a484432bd7a87c,channel-1629985767-c345b647cb597fdddeb4d29ab7c76369a193454dd0ae5b333f,channel-1635866602-0ab021189562e773c5064d0691cfbe13225a324a12068fa10f,channel-1635868687-60e8fff01dfdc34bd6ef1ac8a37b1c73120df608c4ac36adaf,channel-1635868832-e828ca37bcef5a05ffc6a8e0d715c20b25318a0e486afdeb72,channel-1636988728-4e5bf6627c4f0522222d0f5ccc54a98d9aeeb6f63940651187,channel-1637253799-c1813e863b786743bba0d01bea5f2d81a1fd8d9d912392eb82,channel-1637587105-a32fbe888db86b30b351ea643e035952c194c315a80b715744,channel-1637670726-8a62b6cbcc2a6bae2ae8ba5d7d7cf7af82b0032ab9ef99ae76,channel-1638267417-ffdf06b296338d70a5fb5d3ae1f6fccaaf2b045f6c5cdf3029,channel-1638267520-1540d215526af71fd6b414e62f783955a0fc8aec03e9dd1a56,channel-1638274045-ceb986a125d0a4d8a25957d2ce4bac56428ee788a44737de87,channel-1638274223-dbe0be5a3240de91adb3b0122490e3fee3a67ed3936053717e,channel-1638274510-492caf60b49390ba50468e8316e6a75d69c9b2da1a2006caa4,channel-1638469928-aa678acc433b2ff8cef6de76b679d09cec9ce63afa3bc104e1,channel-1638635056-78c65d66f07d39f419a5d2df8118f7d392691e2ef6b24f11b3,channel-1638635109-e20b128fd3d484d19ae81562a34ed05e1848559b33fe6aa29a,channel-1638641886-9c0b71c06d93908b24ee818a087eb4d66e41857dc803b4649c,channel-1638817149-59672bbb0ea9581c64a9a8ec86621b974d54f0b90494803cb1,channel-1638872132-aa8e73093673be7557a7e1fa5aec333a6c4f10c1b6ecb4e0c2,channel-1638872423-59ff012a5bab68b4c6d2efada587b0e923eb6e0cf189fa3260,channel-1638872927-eda79d7c93f002feeec14988c6935343295b5b1995bbad6917,channel-1638873237-dd7f1c530fbdd2f9fb66a71d8f06a683a354979d5f8e5d7a08,channel-1638888172-278c41e4d7cd36044d1931b7dd84da03e12cb9dbf35283ed19,channel-1639397088-d34e17f527e63a0a5586285189c9f0f4e70b45e4dfaf8d0773,channel-1639655035-1bc61356786a84b49855fd93d055671c9a02d010272789ad27?pnsdk=PubNub-Java-Unified%2F4.21.0&auth=af152bef-8208-4da3-8046-c67c33322b9f-f6745097ad8577a8479bdafdca455851d7f95876763fea9a8e&max=1&requestid=6820cb03-3924-40d1-b02f-1cb62b51200f&l_pres=0.069&uuid=pn-2ca1ad1b-8580-40bd-bc96-d2069a473d0a"
            // :
              'https://ps.pndsn.com/v3/history/sub-key/$pnSubscribeKey/channel/$_channelsNames?pnsdk=PubNub-Java-Unified%2F4.21.0&auth=$authKey&max=1&requestid=a2a57811-7069-46d5-8298-488b9c069624&uuid=pn-2623a176-a8f6-45f2-93fc-dfb6218985f4'
          ));

      var responseString;

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var responseList = json.decode(responseString);
        channelsLastMessage = responseList["channels"];

        // var logger = Logger(
        //   filter: null, // Use the default LogFilter (-> only log in debug mode)
        //   printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
        //   output: null, // Use the default LogOutput (-> send everything to console)
        // );
        // logger.i("tFetch HitoryForChannels endpoint response  ${channelsLastMessage.values.toList().first}");

        for (int i = 0; i < channelsLastMessage.length; i++) {
          if(_channels.isNotEmpty){
            if (channelsLastMessage.values.toList()[i].toString().contains("createdAt")) {
              _channels.firstWhere((ch) => ch.name == channelsLastMessage.keys.toList()[i]).lastMessageTimetoken =
              channelsLastMessage.values.toList()[i][0]["message"]["createdAt"] == null || channelsLastMessage.values.toList()[i][0]["message"]["createdAt"].toString() == ""
                  ? int.parse(DateTime.now().millisecondsSinceEpoch.toString())
                  : channelsLastMessage.values.toList()[i][0]["message"]["createdAt"];

            } else {
              _channels.firstWhere((ch) => ch.name == channelsLastMessage.keys.toList()[i])
                  .lastMessageTimetoken = channelsLastMessage.values.toList()[i][0]["timetoken"] == null ||
                  channelsLastMessage.values.toList()[i][0]["timetoken"].toString() == ""
                  ? int.parse(DateTime.now().millisecondsSinceEpoch.toString())
                  : int.parse(channelsLastMessage.values.toList()[i][0]["timetoken"].toString().substring(0, 13));

            }
          }
        }


        // this line is to hide the 1-to-1 channels if it doesn't have any messages
        _channels.removeWhere((ch) => (ch.channelType == "private" || ch.channelType == "person") && ch.lastMessageTimetoken == null);

        sortChannels();

        this.loadingLastMsgs = ChatStage.DONE;
        // notifyListeners();
      }
      else {
        this.loadingLastMsgs = ChatStage.ERROR;
      }
    } catch (e) {
      this.loadingLastMsgs = ChatStage.ERROR;
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future createNewChannel(BuildContext context,
      {@required List<String> usersIds, @required String channelType,
        String channelDisplayName, groupImg,articleThumbnail,articleUrl,
        User privateChatUser,
        articleTitle,isArticleFavourite,articleCommentsCount,articleId}) async {

    this.creatingNewChatChannel = ChatStage.LOADING;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'UserAgent': 'RightNurse/1.2.3 (iPhone; iOS 10.3.1; Scale/3.00)',
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };

    var responseString;

    try {
      var request =
      http.Request('POST', Uri.parse('$appDomain/chat/channels/new'));
      request.body = json.encode({
        "channel_type": "$channelType",
        "user_ids": usersIds,
        "display_name": channelDisplayName,
        "image": groupImg ?? null
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      Map responseMap = json.decode(responseString);
      // var logger = Logger(
      //   filter: null, // Use the default LogFilter (-> only log in debug mode)
      //   printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
      //   output: null, // Use the default LogOutput (-> send everything to console)
      // );
      // logger.i("tesing old create group !! $responseString");

      print('njnjnjnjnjnjnjnjnjnjnjnjnj1111');
      if (response.statusCode == 200) {
        print('njnjnjnjnjnjnjnjnjnjnjnjnj2222 ${responseMap}');

        final ChannelModel channel = ChannelModel.fromJson(responseMap);
        channel.lastMessageTimetoken = channel.lastMsgAt??channel.createdAt;//int.parse(DateTime.now().millisecondsSinceEpoch.toString());

        pn.PaginatedChannelHistory history = _pubnub.channel('${responseMap["name"]}').history(chunkSize: 70);

        if(history.messages.isEmpty){
          channelsLastMessage[channel.name] = channel.lastMsgAt??channel.createdAt;
        }
        // else{
        //   await history.more();
        // }
        // if(history.messages != null){
        setCurrentChannel(channel);
        if (articleUrl != null) {
          clearChannels();
          fetchGroupChannels(context).then((_) {

            if (!kIsWeb) {
              Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(NavigationHome.routeName),
                  // Navigator.pushReplacementNamed(context, MessagingScreen.routeName,
                  // await Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(NavigationHome.routName),
                  arguments: {
                    "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                    history,
                    "channel": channel,
                    "channel_name": responseMap["name"],
                    "pn": _pubnub,
                    "private_chat_user": privateChatUser, //channelType == "private" ? //await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: usersIds[0]) : null,
                    "chat_title": channelDisplayName,
                    "type": channelType == "private" ? 'person': "group",
                    "current_user_id": jsonDecode(storedUser)['id'],
                    "articleUrl" : articleUrl,
                    "articleThumbnail" : articleThumbnail,
                    "articleTitle" : articleTitle,
                    "isArticleFavourite" : isArticleFavourite,
                    "articleCommentsCount" : articleCommentsCount,
                    "articleId" : articleId
                  });
            }
            else{
              _passedChannelData.clear();
              setPassedData({
                "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                history,
                "channel": channel,
                "channel_name": responseMap["name"],
                "pn": _pubnub,
                "private_chat_user": privateChatUser, //channelType == "private" ? //await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: usersIds[0]) : null,
                "chat_title": channelDisplayName,
                "type": channelType == "private" ? 'person': "group",
                "current_user_id": jsonDecode(storedUser)['id'],
                "articleUrl" : articleUrl,
                "articleThumbnail" : articleThumbnail,
                "articleTitle" : articleTitle,
                "isArticleFavourite" : isArticleFavourite,
                "articleCommentsCount" : articleCommentsCount,
                "articleId" : articleId
              });
              Navigator.pushReplacementNamed(context, WebMainScreen.routeName);
              // Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(WebMainScreen.routeName),
              //     // Navigator.pushReplacementNamed(context, MessagingScreen.routeName,
              //     // await Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(NavigationHome.routName),
              //     arguments: {
              //       "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
              //       history,
              //       "channel": channel,
              //       "channel_name": responseMap["name"],
              //       "pn": _pubnub,
              //       "private_chat_user": privateChatUser, //channelType == "private" ? //await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: usersIds[0]) : null,
              //       "chat_title": channelDisplayName,
              //       "type": channelType == "private" ? 'person': "group",
              //       "current_user_id": jsonDecode(storedUser)['id'],
              //       "articleUrl" : articleUrl,
              //       "articleThumbnail" : articleThumbnail,
              //       "articleTitle" : articleTitle,
              //       "isArticleFavourite" : isArticleFavourite,
              //       "articleCommentsCount" : articleCommentsCount,
              //       "articleId" : articleId
              //     });
            }
          });

        }
        else{
          // await Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(NavigationHome.routName),
          clearChannels();
          fetchGroupChannels(context).then((_) {
            _passedChannelData.clear();
            setPassedData({
              "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
              history,
              "channel": channel,
              "channel_name": responseMap["name"],
              "pn": _pubnub,
              "private_chat_user": privateChatUser,//channelType == "private" ? await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: usersIds[0]) : null,
              "chat_title": channelDisplayName,
              "type": channelType == "private" ? 'person': "group",
              "current_user_id": jsonDecode(storedUser)['id'],
              "articleUrl" : null,
              "articleThumbnail" : null,
              "articleTitle" : null,
              "isArticleFavourite" : null,
              "articleCommentsCount" : null,
              "articleId" : null
            });
            Navigator.pushReplacementNamed(context, WebMainScreen.routeName);
            // Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(NavigationHome.routeName),
            //
            //     // Navigator.pushReplacementNamed(context, MessagingScreen.routeName,
            //     arguments: {
            //       "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
            //       history,
            //       "channel": channel,
            //       "channel_name": responseMap["name"],
            //       "pn": _pubnub,
            //       "private_chat_user": privateChatUser,//channelType == "private" ? await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: usersIds[0]) : null,
            //       "chat_title": channelDisplayName,
            //       "type": channelType == "private" ? 'person': "group",
            //       "current_user_id": jsonDecode(storedUser)['id'],
            //       "articleUrl" : null,
            //       "articleThumbnail" : null,
            //       "articleTitle" : null,
            //       "isArticleFavourite" : null,
            //       "articleCommentsCount" : null,
            //       "articleId" : null
            //     });
          });

        }
        // }
        // clearChannels();
        // fetchGroupChannels(context);
        // fetchHistoryForChannels(userAuthKey);
        this.creatingNewChatChannel = ChatStage.DONE;
      }
      else {
        debugPrint(response.reasonPhrase);
        this.creatingNewChatChannel = ChatStage.ERROR;
      }
    }catch(e){
      debugPrint(e.toString());
      this.creatingNewChatChannel = ChatStage.ERROR;
    }
    notifyListeners();

  }

  Future createNewAuthKey(BuildContext context) async {
    this.crateNewAuthKeyStage = ChatStage.LOADING;
    _userAuthKey = "";
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
      'Content-Length': '0'
    };
    var responseString;
    try {
      var request = http.Request('POST', Uri.parse('$appDomain/chat/auth/new'));
      request.body = '''''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      Map responseMap = json.decode(responseString);

      if (response.statusCode == 200) {
        _userAuthKey = responseMap["user_auth_key"];
        _myKeyset = pn.Keyset(
            subscribeKey: pnSubscribeKey,
            publishKey: pnPublishKey,
            authKey: _userAuthKey,
            uuid: pn.UUID(
                Provider.of<UserProvider>(context, listen: false).userData.id));
        _pubnub = pn.PubNub(defaultKeyset: _myKeyset);
        debugPrint("createNewAuthKey response ${responseMap}");

        notifyListeners();
      } else {
        debugPrint(response.reasonPhrase);
      }
      this.crateNewAuthKeyStage = ChatStage.DONE;
    } catch (e) {
      this.crateNewAuthKeyStage = ChatStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future fetchParticipantsForChannel({@required String channelId, offset}) async {
    // if(_currentChannel == null || _currentChannel.id != channelId){
    this.loadingChannelParticipantsStage = ChatStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };
    var responseString;
    try {
      var request = http.Request(
          'GET', Uri.parse('$appDomain/chat/channels/$channelId/participants?limit=10&offset=$offset'));
      debugPrint('$appDomain/chat/channels/$channelId/participants?limit=10&offset=$offset');

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      List<dynamic> participantsList = json.decode(responseString);

      if (response.statusCode == 200) {
        if(offset == 0){
          _groupChannelParticipants.clear();
        }
        participantsList.forEach((element) {
          final User user = User.fromJson(element);
          _groupChannelParticipants.add(user);

        });
      } else {
        _groupChannelParticipants.clear();
        debugPrint(response.reasonPhrase);
      }
      this.loadingChannelParticipantsStage = ChatStage.DONE;
    } catch (e) {
      debugPrint("$e");
      this.loadingChannelParticipantsStage = ChatStage.ERROR;
    }
    notifyListeners();
    // }
  }

  Future fetchChannelByName({@required String channelName}) async {
    if(_currentChannel == null || _currentChannel.name != channelName || currentChannel.memberCount == null){
      this.loadingChannelDataStage = ChatStage.LOADING;

      final prefs = await SharedPreferences.getInstance();
      final storedUser = prefs.getString("user");
      String token = jsonDecode(storedUser)['token'];

      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=2',
        'Content-Type': 'application/json',
        'Authorization': 'Token token=$token',
      };
      var responseString;
      try {
        var request = http.Request(
            'GET', Uri.parse('$appDomain/chat/channels/name/$channelName'));
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        responseString = await response.stream.bytesToString();
        Map responseMap = json.decode(responseString);

        if (response.statusCode == 200) {
          debugPrint("hey this is the channle name that we will get its data ---> $responseMap");

          final ChannelModel channel = ChannelModel.fromJson(responseMap);
          _currentChannel = channel;
        } else {
          debugPrint(response.reasonPhrase);
        }
        this.loadingChannelDataStage = ChatStage.DONE;

      } catch (e) {
        debugPrint(e.toString());
        this.loadingChannelDataStage = ChatStage.ERROR;
      }
      notifyListeners();
    }
  }

  Future updateChatChannel(BuildContext context,
      {String channelId,
        List<String> usersIdsToRemove,
        List<String> userIdsToAdd,
        String groupImage,
        String groupDisplayName,
        String channelName}) async {
    this.stage = ChatStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };

    var body = {
      'notifications_enabled': true,
      'add_user_ids': userIdsToAdd, //String[]
      'remove_user_ids': usersIdsToRemove, //String[]
      //'image': groupImage,//String Base64 channel image
      //'display_name': groupDisplayName
    };


    if (groupImage != null) {
      body['image'] = groupImage;
    }

    if (groupDisplayName != null) {
      body['display_name'] = groupDisplayName;
    }
    var responseString;
    try {
      var request =
      http.Request('PUT', Uri.parse('$appDomain/chat/channels/$channelId'));

      request.body = json.encode(body);

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      // Map responseMap = json.decode(responseString);

      if (response.statusCode == 200) {
        _currentChannel = null;
        fetchChannelByName(channelName: channelName);
        fetchParticipantsForChannel(channelId: channelId, offset: 0);
        // clearChannels();
        // fetchGroupChannels(context);

        clearChannels();
        await fetchGroupChannels(context);
        (_userAuthKey);

      }
      else {
        debugPrint(response.reasonPhrase);
      }
      this.stage = ChatStage.DONE;
    } catch (e) {
      this.stage = ChatStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future chatAttachment(context, {String channelId, filePath, fileName, isUploadingDocument = false, var file,imageBytes}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    // print('fileNamefileName $fileName');
    // print('filePathfilePath $filePath');

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'UserAgent': 'RightNurse/1.2.3 (iPhone; iOS 14.6; Scale/3.00)',
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Token token=$token',
    };

    var responseString;
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('$appDomain/chat/attachments?channel_id=$channelId'));


      if(isUploadingDocument && (!fileName.toString().toLowerCase().contains(".jpg") &&
                                !fileName.toString().toLowerCase().contains(".jpeg") &&
                                !fileName.toString().toLowerCase().contains(".png") &&
                                !fileName.toString().toLowerCase().contains(".webp") &&
                                !fileName.toString().toLowerCase().contains(".svg"))){

        if (!kIsWeb) {
          var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
          var length = await file.length();

          var multipartFile = await http.MultipartFile('attachment', stream, length,
              filename: fileName);

          request.files.add(multipartFile);
        }
        else{
          request.files.add(http.MultipartFile.fromBytes('attachment',file.bytes,filename: fileName));

        }



      }
      else{
        if(imageBytes == null){
          request.files.add(await http.MultipartFile.fromPath(
              'attachment', '${filePath}',
              filename: "$fileName", contentType: MediaType("image", "*")));
        }
        else{
          request.files.add(http.MultipartFile.fromBytes('attachment',imageBytes,filename: fileName,contentType: MediaType("image", "*")));
        }
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      Map responseMap = json.decode(responseString);
      print(response.statusCode);

      if (response.statusCode == 200) {
        _mediaUrl = responseMap["url"];
        debugPrint("attachment uploaded successfully !!! with url ---> ${responseMap["url"]}");
        notifyListeners();
      } else {

        debugPrint(responseString);
        showAnimatedCustomDialog(context,
            title: "Error", message: responseMap["message"]);
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  Future leaveChat(context, {String channelId}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };
    var responseString;
    try {
      var request = http.Request(
          'POST', Uri.parse('$appDomain/chat/channels/$channelId/leave'));
      request.body = json.encode({"leave_channel": true});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      Map responseMap = json.decode(responseString);

      if (response.statusCode == 200) {
        debugPrint(responseMap.toString());
      } else {
        debugPrint(response.reasonPhrase);
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future chatAnnouncement(BuildContext context,
      {discoveryProvider, userData, String announcementText}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Content-Type': 'application/json',
      'Accept': 'application/vnd.right_nurse; version=2',
      'Authorization': 'Token token=$token',
    };
    var responseString;

    var body = {
      "wards":
      discoveryProvider.activeFilteringParameters.areasOfWorkIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.areasOfWorkIds
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", ""),
      "skills": discoveryProvider.activeFilteringParameters.skillsIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.skillsIds
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", ""),
      "languages":
      discoveryProvider.activeFilteringParameters.languageIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.languageIds
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", ""),
      "memberships":
      discoveryProvider.activeFilteringParameters.membershipIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.membershipIds
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", ""),
      "roles": discoveryProvider.activeFilteringParameters.roleIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.roleIds
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", ""),
      "country_code": userData.userData.countryCode.toString() ?? "GB",
      //"name": userData.userData.name.toString() ?? "User",
      "role_type": discoveryProvider.activeFilteringParameters.roleType == 0 ? null :
      discoveryProvider.activeFilteringParameters.roleType != null ?
      int.parse(discoveryProvider.activeFilteringParameters.roleType.toString()):int.parse(userData.userData.roleType.toString()),

      "message": announcementText ?? "announcement message",
    };

    if (userData.userData.roleType.toString() == "2") {
      body["grades"] =
      discoveryProvider.activeFilteringParameters.gradeIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.gradeIds
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "");
    } else if (userData.userData.roleType.toString() == "1") {
      body["bands"] =
      discoveryProvider.activeFilteringParameters.bandIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.bandIds
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "");
    }

    try {
      var request =
      http.Request('POST', Uri.parse('$appDomain/pubnub_announcements'));
      request.body = json.encode(body);
      request.headers.addAll(headers);
      
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      //Map responseMap = json.decode(responseString);

      if (response.reasonPhrase == "Accepted") {
        showAnimatedCustomDialog(context, message: "Announcement sent.",
            onClicked: () {
              // clearChannels();
              // fetchGroupChannels(context).then((_) {
              //   fetchHistoryForChannels(_userAuthKey);
              if (!kIsWeb) {
                Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
              }
              else{
                Navigator.pushReplacementNamed(context, WebMainScreen.routeName);
              }

              /// we replaced this with the above as this code prevents the app from restart as we change the context passed to "RestartWidget"
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NavigationHome()),
                //         (route) => false);
              // });
            });
        AnalyticsManager.track('announcement_sent');

      } else {
        showAnimatedCustomDialog(context,
            title: "Error", message: response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future createNewGroupChatWithSelectAll(BuildContext context,
      {discoveryProvider, userData, @required String channelType,
        String channelDisplayName, groupImg, articleThumbnail,articleUrl,
        articleTitle,isArticleFavourite,articleCommentsCount,articleId}) async {

    this.creatingNewChatChannel = ChatStage.LOADING;
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Content-Type': 'application/json',
      'Accept': 'application/vnd.right_nurse; version=2',
      'Authorization': 'Token token=$token',
    };
    var responseString;

    var body = {
      "wards":
      discoveryProvider.activeFilteringParameters.areasOfWorkIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.areasOfWorkIds,
      // .toString()
      // .replaceAll("[", "")
      // .replaceAll("]", ""),
      "skills": discoveryProvider.activeFilteringParameters.skillsIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.skillsIds,
      // .toString()
      // .replaceAll("[", "")
      // .replaceAll("]", ""),
      "languages":
      discoveryProvider.activeFilteringParameters.languageIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.languageIds,
      // .toString()
      // .replaceAll("[", "")
      // .replaceAll("]", ""),
      "memberships":
      discoveryProvider.activeFilteringParameters.membershipIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.membershipIds,
      // .toString()
      // .replaceAll("[", "")
      // .replaceAll("]", ""),
      "roles": discoveryProvider.activeFilteringParameters.roleIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.roleIds,
      // .toString()
      // .replaceAll("[", "")
      // .replaceAll("]", ""),
      "country_code": userData.userData.countryCode.toString() ?? "GB",
      "channel_type": "$channelType",
      "display_name": channelDisplayName,
      "channel_image": groupImg ?? null,
      // "image": ,
      // "role_type": int.parse(discoveryProvider.activeFilteringParameters.roleType.toString()) ?? int.parse(userData.userData.roleType.toString()),
    };

    if(discoveryProvider.activeFilteringParameters.roleType != null && discoveryProvider.activeFilteringParameters.roleType.toString() != "0"){
      body["role_type"] = int.parse(discoveryProvider.activeFilteringParameters.roleType.toString()) ?? int.parse(userData.userData.roleType.toString());
    }

    if (userData.userData.roleType.toString() == "2") {
      body["grades"] =
      discoveryProvider.activeFilteringParameters.gradeIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.gradeIds;
      // .toString()
      // .replaceAll("[", "")
      // .replaceAll("]", "");
    } else if (userData.userData.roleType.toString() == "1") {
      body["bands"] =
      discoveryProvider.activeFilteringParameters.bandIds.isEmpty
          ? null
          : discoveryProvider.activeFilteringParameters.bandIds;
      // .toString()
      // .replaceAll("[", "")
      // .replaceAll("]", "");
    }

    try {
      var request =
      http.Request('POST', Uri.parse('$appDomain/chat/channels/new'));
      request.body = json.encode(body);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      debugPrint("filtering parameters are  $body");
      debugPrint("response of creating channel with select all $responseString");
      Map responseMap = json.decode(responseString);

      if (response.statusCode == 200) {

        final ChannelModel channel = ChannelModel.fromJson(responseMap);
        channel.lastMessageTimetoken = channel.lastMsgAt??channel.createdAt;//int.parse(DateTime.now().millisecondsSinceEpoch.toString());

        pn.PaginatedChannelHistory history = _pubnub.channel('${responseMap["name"]}').history(chunkSize: 70);

        if(history.messages.isEmpty){
          channelsLastMessage[channel.name] = channel.lastMsgAt??channel.createdAt;
        }else{
          await history.more();
        }

        if(history.messages != null){
          /// an alternative way to Navigate to chat tab instead of opening the newly created channel
          // clearChannels();
          // fetchGroupChannels(context).then((_){
          //   // fetchHistoryForChannels(userAuthKey);
          //   Navigator.pushNamedAndRemoveUntil(context, NavigationHome.routName, (route) => false);
          //   // Navigator.pushReplacementNamed(context, NavigationHome.routName);
          // });

          clearChannels();
          fetchGroupChannels(context).then((_){
            if(articleUrl == null){
              _passedChannelData.clear();
              setPassedData({
                "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                history,
                "channel": channel,
                "channel_name": responseMap["name"],
                "pn": _pubnub,
                "private_chat_user": null,
                "chat_title": channelDisplayName,
                "type": "group",
                "current_user_id": jsonDecode(storedUser)['id']
              });
              // Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(NavigationHome.routeName),
              //     arguments: {
              //       "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
              //       history,
              //       "channel": channel,
              //       "channel_name": responseMap["name"],
              //       "pn": _pubnub,
              //       "private_chat_user": null,
              //       "chat_title": channelDisplayName,
              //       "type": "group",
              //       "current_user_id": jsonDecode(storedUser)['id']
              //     });
            }else{
              _passedChannelData.clear();
              setPassedData({
                "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                history,
                "channel": channel,
                "channel_name": responseMap["name"],
                "pn": _pubnub,
                "private_chat_user": null,
                "chat_title": channelDisplayName,
                "type": "group",
                "current_user_id": jsonDecode(storedUser)['id'],
                "articleUrl" : articleUrl,
                "articleThumbnail" : articleThumbnail,
                "articleTitle" : articleTitle,
                "isArticleFavourite" : isArticleFavourite,
                "articleCommentsCount" : articleCommentsCount,
                "articleId" : articleId
              });
              // Navigator.pushNamedAndRemoveUntil(context, MessagingScreen.routeName, ModalRoute.withName(NavigationHome.routeName),
              //     arguments: {
              //       "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
              //       history,
              //       "channel": channel,
              //       "channel_name": responseMap["name"],
              //       "pn": _pubnub,
              //       "private_chat_user": null,
              //       "chat_title": channelDisplayName,
              //       "type": "group",
              //       "current_user_id": jsonDecode(storedUser)['id'],
              //       "articleUrl" : articleUrl,
              //       "articleThumbnail" : articleThumbnail,
              //       "articleTitle" : articleTitle,
              //       "isArticleFavourite" : isArticleFavourite,
              //       "articleCommentsCount" : articleCommentsCount,
              //       "articleId" : articleId
              //     });
            }
          });

        }
        AnalyticsManager.track('messaging_group_created');
        this.creatingNewChatChannel = ChatStage.DONE;

      }
      else {
        debugPrint(response.reasonPhrase);
        this.creatingNewChatChannel = ChatStage.ERROR;
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      this.creatingNewChatChannel = ChatStage.ERROR;
    }
  }



  List<User> _groupChannelParticipantsForSearch = [];
  List<User> get groupChannelParticipantsForSearch => this._groupChannelParticipantsForSearch;

  clearGroupChannelParticipantsForSearch(){
    _groupChannelParticipantsForSearch.clear();
    notifyListeners();
  }

  Future searchForParticipantByNameInGroupChannel({@required String channelId, offset, searchKey})async{
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    String userId = jsonDecode(storedUser)['id'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token',
    };
    var responseString;
    try {
      var request = http.Request(
          'GET', Uri.parse('$appDomain/chat/channels/$channelId/participants?participant_name=$searchKey&limit=10&offset=$offset'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      List<dynamic> participantsList = json.decode(responseString);

      if (response.statusCode == 200) {
        if(offset == 0){
          _groupChannelParticipantsForSearch.clear();
        }
        participantsList.forEach((element) {
          final User user = User.fromJson(element);
          _groupChannelParticipantsForSearch.add(user);

        });
        debugPrint(_groupChannelParticipantsForSearch.toString());
      } else {
        _groupChannelParticipantsForSearch.clear();
        debugPrint(response.reasonPhrase);
      }
      this.loadingChannelParticipantsStage = ChatStage.DONE;
    } catch (e) {
      debugPrint(e.toString());
      this.loadingChannelParticipantsStage = ChatStage.ERROR;
    }
    notifyListeners();

  }



  /// Data for web
  ///
  ///
  ///

  final PageController pageController = PageController();

  pn.PaginatedChannelHistory _conversation_messages;
  pn.PaginatedChannelHistory get conversation_messages =>this._conversation_messages;
  setConversationChannelHistory(
      {pn.PaginatedChannelHistory conversation_messages}){
    _conversation_messages = conversation_messages;
    notifyListeners();
  }

  ChannelModel _channel;
  ChannelModel get channel => this._channel;

  setChannel(
  {channel}){
  _channel = channel;
  notifyListeners();
  }

  pn.PubNub _pnb;
  pn.PubNub get pnb => this._pnb;
  setPnb(
      {pnb}){
    _pnb = pnb;
    notifyListeners();
  }

  var _private_chat_user;
  get private_chat_user =>this._private_chat_user;
  setPrivateChatUser(
      {chatUser}){
    _private_chat_user = chatUser;
    notifyListeners();
  }

  String _type;
  String get type => this._type;

  setChannelType(
      {type}){
    _type = type;
    notifyListeners();
  }

  String _channel_name;
  String get channel_name => this._channel_name;

  setChannelName(
      {name}){
    _channel_name = name;
    notifyListeners();
  }

  String _current_user_id;
  String get current_user_id => this._current_user_id;
  setCurrentUserId(
      {current_user_id}){
    _current_user_id = current_user_id;
    notifyListeners();
  }

  String _channel_id;
  String get channel_id => this._channel_id;

  setCurrentId(
      {current_id}){
    _channel_id = current_id;
    notifyListeners();
  }

  setChannelsData(
      {pn.PaginatedChannelHistory conversation_messages,
        channel,
        pnb,
        private_chat_user,
        type,
        current_user_id,
        channel_id}){
    _conversation_messages = conversation_messages;
    _channel = channel;
    _pnb = pnb;
    _private_chat_user = private_chat_user;
    _type = type;
    _current_user_id = current_user_id;
    _channel_id = channel_id;
    _openedChannelName = channel.name;
    notifyListeners();
  }




  /// Web

  pn.PaginatedChannelHistory _chatChannelHistory;
  pn.PaginatedChannelHistory get chatChannelHistory => this._chatChannelHistory;


  setChatChannelHistory(chatHistory){
    _chatChannelHistory = chatHistory;
    // notifyListeners();
  }
  resetChatChannelHistory(){
    if (_chatChannelHistory != null) {
      _chatChannelHistory.reset();
      // notifyListeners();
    }
  }

  Future<void> loadMoreChatChannelHistory()async{
    if (_chatChannelHistory != null
    ) {
      await _chatChannelHistory.more();
    }
    notifyListeners();
  }


  Map _passedChannelData = {};
  Map get passedChannelData =>this._passedChannelData;

  setPassedData(Map passedChannelData){
    _passedChannelData = passedChannelData;
    notifyListeners();
  }
  clearPassedData(){
    _passedChannelData.clear();
    notifyListeners();
  }



}