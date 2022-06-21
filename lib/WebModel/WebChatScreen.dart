// ignore: unused_import
// ignore_for_file: file_names, curly_braces_in_flow_control_structures, prefer_if_null_operators, prefer_final_fields, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, unnecessary_brace_in_string_interps, prefer_generic_function_type_aliases, unnecessary_cast

import 'dart:math';
import 'dart:ui';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Chat/ChatDetails.dart';
import 'package:rightnurse/Subscreens/Chat/GroupDetails.dart';
import 'package:rightnurse/Subscreens/Directory/DirectoryFilter.dart';
import 'package:rightnurse/Subscreens/NewsFeed/NewsDetails.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:transparent_image/transparent_image.dart';
// import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_image/flutter_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:isolate';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:flutter_pubnub/pubnub.dart' as otherPNConfig;

class WebChatScreen extends StatefulWidget {
  static const routeName = '/WebMessagingScreen';

  @override
  _WebChatScreenState createState() => _WebChatScreenState();
}

class _WebChatScreenState extends State<WebChatScreen> {

  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  PubNub pubnub;
  List<ChatMessage> _chatMessages = [];

  ScrollController scScrollController = ScrollController(initialScrollOffset: 0);
  FocusNode messageFieldNode = FocusNode();
  bool _isInit = true;
  Map passedData = {};
  TextEditingController _messageController = TextEditingController();
  var channel;
  List<Message> _messages = [];
  var history = null;
  var channelName;
  var msgsToMe = [];
  var msgsFromMe = [];
  var systemMsgs = [];
  String _viewChatImage;
  bool _replyToMsg = false;
  ChatMessage msgToReplyTo;
  String chatTitle = "";
  bool isInputDisabled = false;
  // PickedFile pickedFile;
  String imageText = "Image";
  String sendingMessageStateResult;
  String lastMsgPayloadId;
  bool _isloadingMsgs = false;
  ScrollController _controller = ScrollController(initialScrollOffset: 0, keepScrollOffset: true);
  int waitToScrollInMillieSec = 1100;
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  User privateChatUser = null;

  String _localPath;
  bool _permissionReady = false;
  String fileName = "";

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }


  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }


  Future<bool> _checkPermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid && androidInfo.version.sdkInt <= 28) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          _permissionReady = true;
          return true;
        }
      } else {
        _permissionReady = true;
        return true;
      }
    } else {
      _permissionReady = true;
      return true;
    }
    return false;
  }


  void _downloadFile(url, {String fileName}) async {
    showSnack(
        millSeconds: 1200,
        context: context,
        bottomMargin: 15,
        // backgroundColor: Colors.white,
        content: SizedBox(
          height: 55.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  const <Widget>[
              SpinKitCircle(
                color: Colors.white,
                size: 20.0,
              ),

              const SizedBox(width: 8.0,),

              Flexible(child: Text("Downloading to your device’s Files app", maxLines: 2,)),
            ],
          ),
        ),
        fullHeight: 55.0,
        isFloating: true,
        scaffKey: _scaffoldKey
    );

    if(Platform.isIOS){
      final status = await Permission.storage.request();
      if(status.isGranted){
        setState(() {
          _permissionReady = true;
        });
      }
    }
    if (_permissionReady) {
      _prepareSaveDir().then((_){
        debugPrint("hey this is the Dir to save the file $_localPath");
        FlutterDownloader.enqueue(
            url: '$url',
            savedDir: _localPath,
            showNotification: true,
            openFileFromNotification: true,
            saveInPublicStorage: true,//baseStorage.path,
            // saveInPublicStorage: false,
            requiresStorageNotLow: true,
            fileName: "${fileName}"
        ).then((value){
          debugPrint('value for download is !  ${value}');
        });
      });
    } else {
      debugPrint('no permission');
    }
  }

  int progress = 0;
  ReceivePort receiverPort = ReceivePort();

  toAndFromMessages(){

    _messages.forEach((msg) {
      // adding  system messages
      if(mounted && msg.contents.toString().contains("pn_gcm") == false && msg.contents.toString().contains("pn_apns") == false && msg.contents.toString().contains("createdAt") == false){
        systemMsgs.add(msg);
      }


      // this check to see if the msg is sent from Flutter app
      if(mounted && msg.contents.toString().contains("createdAt") && msg.contents.toString().contains("pn_gcm")){
        if(msg.contents["user"]["uid"].toString() == Provider.of<UserProvider>(context, listen: false).userData.id){
          msgsFromMe.add(msg);
        }else{
          msgsToMe.add(msg);
        }
      }

      // message sent from Native Swift or Kotlin
      if(mounted && msg.contents.toString().contains("createdAt") == false && msg.contents.toString().contains("pn_gcm")){
        Map<String, dynamic> senderInfo = {};

        List<int> listOfInts = base64Decode(gettingFullLongBase64String("${msg.contents["content"]}"));
        senderInfo = json.decode(utf8.decode(listOfInts));//["entity"]["sender"];
        if (passedData["type"] == "announcement") {
          if(senderInfo["entity"]["sender"]["id"] == Provider.of<UserProvider>(context, listen: false).userData.id){
            msgsFromMe.add(msg);
          }else{
            msgsToMe.add(msg);
          }
        }else{

          if(senderInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id){
            msgsFromMe.add(msg);
          }else{
            msgsToMe.add(msg);
          }
        }
      }

    });

  }

  // DefaultCacheManager manager = new DefaultCacheManager();
  @override
  initState() {
    print('kokkokokokokokokokokoko');

    // Timer.periodic(const Duration(seconds: 5), (timer) async {
    //  // _checkMemory();
    //  // manager.emptyCache();
    //  PaintingBinding.instance.imageCache.clear();
    //  PaintingBinding.instance.imageCache.clearLiveImages();
    // });

    super.initState();
    // _controller =  ScrollController(initialScrollOffset: 0, keepScrollOffset: true);
    // scScrollController = ScrollController(initialScrollOffset: 0);

    if (!kIsWeb) {
      if(Platform.isAndroid){
        _checkPermission();
      }
      IsolateNameServer.registerPortWithName(
          receiverPort.sendPort, 'DownloadingFile');

      receiverPort.listen((message) {
        if (mounted) {
          setState(() {
            progress = message;
          });
        }
      });
      FlutterDownloader.registerCallback(downloadCallBack);
      FToast().init(context);


      // IsolateNameServer.registerPortWithName(receiverPort.sendPort, 'DownloadingFile');
      // receiverPort.listen((dynamic data) {
      //   String id = data[0];
      //   DownloadTaskStatus status = data[1];
      //   int progress = data[2];
      //   if (status.toString() == "DownloadTaskStatus(3)" && progress == 100 && id != null) {
      //     String query = "SELECT * FROM task WHERE task_id='" + id + "'";
      //     var tasks = FlutterDownloader.loadTasksWithRawQuery(query: query);
      //     //if the task exists, open it
      //     if (tasks != null) FlutterDownloader.open(taskId: id);
      //   }
      // });
      // FlutterDownloader.registerCallback(downloadCallBack);
      messageNode.addListener(() {

      });
    }
    // scrollToTop();
  }


  static downloadCallBack(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName("DownloadingFile");
    sendPort.send(progress);
  }

  // static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  //   final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send.send([id, status, progress]);
  // }

  // this method is used to decode native or system messages
  String gettingFullLongBase64String(String text) {
    String res = "";
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) =>
    res += match.group(0));
    return res;
  }


  Future getHistory() async {
    // if(history.messages == null){
    //   history.reset();  And could we set up weekly data for Basingstoke from Monday pls?
    setState(() {
      _isloadingMsgs = true;
    });
    history.more().then((_){
      toAndFromMessages();
      if (mounted)
        setState(() {

          // adding system messages
          // ignore: missing_return
          _chatMessages.addAll(systemMsgs.map((msg) {

            Map<String, dynamic> systemMsgInfo = {};
            String systemMsgText = "";
            List<int> listOfInts = base64Decode(gettingFullLongBase64String("${msg.contents["content"]}"));
            systemMsgInfo = json.decode(utf8.decode(listOfInts));

            // we will ignore any system msg fpr Anndouncement channels as there will be non anyway
            if(passedData["type"] != "announcement"){
              if (systemMsgInfo["type"] == "participants_removed") {
                systemMsgText = "${systemMsgInfo["sender_id"] ==
                    Provider.of<UserProvider>(context, listen: false).userData.id ?
                "You" : "Admin"} removed ${systemMsgInfo["entity"]["participant_names"]
                    .toString().replaceAll("[", "").replaceAll("]", "")}";
              }

              // participants_added system message
              if (systemMsgInfo["type"] == "participants_added") {
                systemMsgText = "${systemMsgInfo["sender_id"] ==
                    Provider.of<UserProvider>(context, listen: false).userData.id ?
                "You" : "Admin"} added ${systemMsgInfo["entity"]["participant_names"]
                    .toString().replaceAll("[", "").replaceAll("]", "")}";
              }

              // group_created system message
              if (systemMsgInfo["type"] == "group_created") {
                systemMsgText = "${systemMsgInfo["sender_id"] ==
                    Provider.of<UserProvider>(context, listen: false).userData.id ?
                "You" : systemMsgInfo["entity"]["sender_name"]} created group";
              }

              // left_group system message
              if (systemMsgInfo["type"] == "left_group") {
                systemMsgText = "${systemMsgInfo["entity"]["sender_name"]} left chat";
              }

              return ChatMessage(
                  image: null,
                  customProperties: null,
                  text: systemMsgText,
                  user: ChatUser(
                    uid: "SYSTEM",
                  ),
                  createdAt: msg.timetoken.toDateTime());
            }
          }));

          /// *******************************************************************************************************************


          // adding Messages sent from Current user !!!!! ***************************************************************
          _chatMessages.addAll(msgsFromMe.map((msg) {

            // check to see if the message is sent from Native
            if (msg.contents.toString().contains("createdAt") == false && passedData["type"] != "announcement") {


              Map<String, dynamic> nativeMsgContents = {};
              List<int> listOfInts = base64Decode(gettingFullLongBase64String("${msg.contents["content"]}"));
              nativeMsgContents = json.decode(utf8.decode(listOfInts));

              return ChatMessage(
                  image: nativeMsgContents["entity"]["image_url"] != null ?
                  nativeMsgContents["entity"]["image_url"] : msg.contents["image"],

                  customProperties: msg.contents["customProperties"],

                  text: msg.contents["pn_gcm"] == null || msg.contents["pn_gcm"]["data"]["body"] == "Added a photo" ?
                  "" : msg.contents["pn_gcm"]["data"]["body"].toString(),

                  user: _user,

                  createdAt: msg.timetoken.toDateTime());
            }

            // if the current user was the sender and it was an announcement channel *****
            else {
              return ChatMessage(
                  image: msg.contents["image"],
                  customProperties: msg.contents["customProperties"],
                  text: msg.contents["pn_gcm"] == null ? "" :
                  passedData["type"] == "announcement" ? msg.contents["pn_gcm"]["data"]["text"] :
                  msg.contents["pn_gcm"]["data"]["body"].toString(),
                  user: _user,
                  createdAt: msg.timetoken.toDateTime());
            }
          }));

          /// *******************************************************************************************************************

          // if msgs were from other users *****
          // ignore: missing_return
          _chatMessages.addAll(msgsToMe.map((msg) {


            // if the channel is an Announcement
            if(passedData["type"] == "announcement" && msg != null){

              Map<String, dynamic> announcementSenderInfo = {};
              List<int> listOfInts = base64Decode(gettingFullLongBase64String("${msg.contents["content"]}"));
              announcementSenderInfo = json.decode(utf8.decode(listOfInts))["entity"]["sender"];

              return ChatMessage(
                  text:  msg.contents["pn_gcm"]["data"]["text"].toString(),
                  customProperties: msg.contents["customProperties"],
                  user: ChatUser(
                      name:  announcementSenderInfo["name"],
                      avatar: announcementSenderInfo["profile_image"],
                      uid: announcementSenderInfo["id"] ),
                  createdAt: msg.timetoken.toDateTime());
            }

            // if the channel is NOT an Announcement
            if(passedData["type"] != "announcement" && msg != null){
              // if the msg is sent from Flutter
              if(msg.contents.toString().contains("createdAt") && msg.contents.toString().contains("uid")){

                return  ChatMessage(text: msg.contents["text"], image: msg.contents["image"],
                    createdAt: msg.timetoken.toDateTime()
                    /*DateTime.fromMillisecondsSinceEpoch(msg.contents["createdAt"])*/,
                    customProperties: msg.contents["customProperties"],
                    id: msg.contents["id"],
                    user: ChatUser(
                      // the msg.contents.toString().contains("uid") condition is to see if the msg is from Flutter or from Native
                      // so later on we will remove this legacy check and put the values directly from ---> msg.contents["user"][KEY_NAME]
                        name: msg.contents.toString().contains("uid") ? msg.contents["user"]["name"]:
                        passedData["type"] == "person" ? msg.contents["pn_gcm"]["data"]["title"]:
                        msg.contents["pn_gcm"]["data"]["subtitle"],

                        avatar: msg.contents.toString().contains("uid") ? msg.contents["user"]["avatar"] :
                        passedData["type"] == "person" ? null :
                        passedData["type"] == "group" && Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName) != null ?
                        Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName).profilePic : null,

                        uid: msg.contents.toString().contains("uid") ? msg.contents["user"]["uid"].toString() :
                        passedData["type"] == "person" ? Provider.of<ChatProvider>(context,listen: false).channelUsers[channelName] == null ? msg.contents["user"]["uid"].toString() : Provider.of<ChatProvider>(context,listen: false).channelUsers[channelName][0].id :
                        passedData["type"] == "group" && Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName) != null ?
                        Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName).id : "UUID"

                    ));
              }

              // message sent from Native !!!!!
              if(msg.contents.toString().contains("pn_gcm") && msg.contents.toString().contains("createdAt") == false && msg.contents.toString().contains("uid") == false){
                Map<String, dynamic> nativeMsgContents = {};
                List<int> listOfInts = base64Decode(gettingFullLongBase64String("${msg.contents["content"]}"));

                nativeMsgContents = json.decode(utf8.decode(listOfInts));

                return ChatMessage(
                    image: nativeMsgContents["entity"]["image_url"] != null ? nativeMsgContents["entity"]["image_url"] : msg.contents["image"],

                    customProperties: msg.contents["customProperties"],

                    text: msg.contents["pn_gcm"] == null || msg.contents["pn_gcm"]["data"]["body"] == "Added a photo"  ? "":
                    msg.contents["pn_gcm"]["data"]["body"].toString(),

                    user: ChatUser(
                      // the msg.contents.toString().contains("uid") condition is to see if the msg is from Flutter or from Native
                      // so later on we will remove this legacy check and put the values directly from ---> msg.contents["user"][KEY_NAME]

                      name: //nativeMsgContents["entity"]["sender_name"],
                      /*msg.contents.toString().contains("uid") ? msg.contents["user"]["name"]:*/
                      passedData["type"] == "person" ? msg.contents["pn_gcm"]["data"]["title"]:
                      msg.contents["pn_gcm"]["data"]["subtitle"],

                      avatar:
                      // passedData["type"] == "person" ? null :
                      passedData["type"] == "group" && Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName) != null ?
                      Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName).profilePic : null,

                      uid: nativeMsgContents["sender_id"],
                      /*msg.contents.toString().contains("uid") ? msg.contents["user"]["uid"].toString() :*/
                      // passedData["type"] == "person" ? Provider.of<ChatProvider>(context,listen: false).channelUsers[channelName] == null ? msg.contents["user"]["uid"].toString() : Provider.of<ChatProvider>(context,listen: false).channelUsers[channelName][0].id :
                      // passedData["type"] == "group" && Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName) != null ?
                      // Provider.of<ChatProvider>(context,listen: false).fetchChatUserByName(name: msg.contents["pn_gcm"]["data"]["subtitle"], channelName: channelName).id : "UUID"
                    ),

                    createdAt: msg.timetoken.toDateTime());
              }

            }

          }
          ));
          _chatMessages.removeWhere((element) => element == null);
          _chatMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
        });
      if(mounted){
        setState(() {
          _isloadingMsgs = false;
        });
      }
    });
    // }


    // scrollToTop();
    // var logger = Logger();
    // logger.d("${history.messages.last.contents}");
  }

  Future<void> sendMessage(ChatMessage msg) async {
    setState(() {
      isInputDisabled = true;
      waitToScrollInMillieSec = 300;
    });

    msg.pnGcm = {
      "notification":{
        "title":"Chat: ${
        //     Provider.of<ChatProvider>(context, listen: false).currentChannel.channelType == "group" &&
        //   Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName.isNotEmpty &&
        //   Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName != null
        //     ?
        // "${msg.user.name} on ${Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName}" :
            msg.user.name}, ${Provider.of<UserProvider>(context, listen: false).userData.trust["name"].length > 15 ?
        Provider.of<UserProvider>(context, listen: false).userData.trust["name"].toString().substring(0,15)+"..." :
        Provider.of<UserProvider>(context, listen: false).userData.trust["name"]}",
        "sound": "alert.mp3",
        "priority": "high",
        "android_channel_id": "CHAT_MESSAGES",
        "body":"${msg.text}"},
      "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
      "data": {
        "body": "${msg.text}",
        "payload_id":  "${msg.id}",
        "channel_name": "$channelName",
        "text": "${msg.user.name}: ${msg.text}",
        "title": "${msg.user.name}",
        "is_system_message": false,
        "is_announcement": false,
        "channel_id": "${channel.id}",
        "version": "1.1.0",
        "senderId" : _user.uid, // added to handle new message badge in navigation bar and chat tab
        "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"]
      },
      "isArticle" : passedData['articleUrl'] != null ? true : false,
    };

    msg.pnApns = {
      "notification":{
        "title":"Chat: ${msg.user.name}",
        "body":"${msg.text}",
        "content_available": true,
        "mutable-content": true,
        "sound": "notification.m4r",
      },
      "priority" : "high",
      "aps": {
        // ignore: file_names
        "mutable-content": true,
        "content_available" : true,
        "category" : "$channelName",
        "senderId" : _user.uid,
        "sound": "notification.m4r",
        "data": {
          "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
        },
        "alert": {"body": "${msg.text}", "title": "${
        //     Provider.of<ChatProvider>(context, listen: false).currentChannel.channelType == "group" &&
        //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName.isNotEmpty &&
        //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName != null
        //     ?
        // "${msg.user.name} on ${Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName}" :
            msg.user.name}, ${Provider.of<UserProvider>(context, listen: false).userData.trust["name"].length > 15 ?
        Provider.of<UserProvider>(context, listen: false).userData.trust["name"].toString().substring(0,15)+"..."  :
        Provider.of<UserProvider>(context, listen: false).userData.trust["name"]}"
        },
        "subtitle" : "Chat"},
      "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
      "chat_message": {"payload_id": "${msg.id}",
        "channel_name": "$channelName",
        "version": "1.1.0",
        "is_system_message": false,
        "is_announcement": false,
        "channel_id": "${channel.id}",
        "senderId" : _user.uid, // added to handle new message badge in navigation bar and chat tab
        "isArticle" : passedData['articleUrl'] != null ? true : false,
        "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"]
      }};


    Map<String, dynamic> msgCustomProperties;
    if(_replyToMsg){
      msgCustomProperties = {
        "sender_id": msgToReplyTo.user.uid == _user.uid ? _user.uid : msgToReplyTo.user.uid,
        "sender": msgToReplyTo.user.name,
        "msgToReplyImg": msgToReplyTo.image == null ? null : msgToReplyTo.image,
        "msgToReplyContent": msgToReplyTo.text == null ? "Image" : msgToReplyTo.text,
        "document_url": null,
        "document_name": null
      };
      msg.customProperties = msgCustomProperties;
    }
    if(passedData['articleUrl'] != null && passedData['articleThumbnail'] != null){
      msgCustomProperties = {
        "sender_id": _user.uid,
        "url" : passedData['articleUrl'],
        "isArticle" : true,
        "thumbnail" : "${passedData['articleThumbnail']}",
        "articleTitle" : "${passedData['articleTitle']}",
        "isFavourite" : passedData['isArticleFavourite'],
        "commentsCount" : passedData['articleCommentsCount'],
        "id" : passedData['articleId'],
      };
      msg.customProperties = msgCustomProperties;
    }


    setState(() {
      sendingMessageStateResult= "Failed";
      lastMsgPayloadId = msg.id;
      _chatMessages.add(msg);
      _chatMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
      passedData['articleUrl'] = null;
    });



    pubnub.publish("$channelName", msg,storeMessage: true, meta: msgCustomProperties).then((PublishResult value) async {
      setState(() {
        sendingMessageStateResult = value.description;


        _replyToMsg = false;
        msgToReplyTo = null;
        msgCustomProperties = null;
        isInputDisabled = false;
        imageText = "Image";
      });
      debugPrint("message sending result is $msgCustomProperties");
    });

    // setState(() {
    //   // _chatMessages.add(msg);
    //   // _chatMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
    //
    // });

    // /// updateChatChannel to set lastMessageSent to set badge on channels that has new msgs in NewChatScreen
    // Provider.of<ChatProvider>(context,listen: false).updateChatChannel(
    //   context,
    //   channelId: passedData['channel_id'],
    //   lastMessageSent: "${DateTime.now().millisecondsSinceEpoch}"
    // );

    if (passedData['type'] == 'group') {
      AnalyticsManager.track('messaging_group_sent');
    }
    else if (passedData['type'] == "private" || passedData['type'] == "person"){
      AnalyticsManager.track('messaging_individual_sent');
    }

  }

  Future<void> sendImageMessage(ChatMessage msg) async{

    setState(() {
      isInputDisabled = true;
      waitToScrollInMillieSec = 300;
      imageText = _messageController.text.isEmpty || _messageController.text == null ? "Image" : _messageController.text;//"${msg.text}";
    });


    Map<String, dynamic> msgCustomProperties;
    if(_replyToMsg){
      msgCustomProperties = {
        "sender_id": msgToReplyTo.user.uid == _user.uid ? _user.uid : msgToReplyTo.user.uid,
        "sender": msgToReplyTo.user.name,
        "msgToReplyImg": msgToReplyTo.image == null ? null : msgToReplyTo.image,
        "msgToReplyContent": msgToReplyTo.text == null ? "Image" : msgToReplyTo.text,
        "document_url": null,
        "document_name": null
      };
      msg.customProperties = msgCustomProperties;
    }

    msg.text = "$imageText";

    if(_imageFile != null){
      Provider.of<ChatProvider>(context,listen: false).chatAttachment(context,
          channelId: channel.id, filePath: _imageFile.path, fileName: imgName).then((_){

        if(Provider.of<ChatProvider>(context,listen: false).mediaUrl != null) {
          msg.image = Provider.of<ChatProvider>(context, listen: false).mediaUrl;
        }

        msg.pnGcm = {
          "notification":{
            "title":"Chat: ${
            // Provider.of<ChatProvider>(context, listen: false).currentChannel.channelType == "group" &&
            //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName.isNotEmpty &&
            //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName != null
            //     ?
            // "${msg.user.name} on ${Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName}" :
                msg.user.name}, ${Provider.of<UserProvider>(context, listen: false).userData.trust["name"].length > 15 ?
            Provider.of<UserProvider>(context, listen: false).userData.trust["name"].toString().substring(0,15)+"..." :
            Provider.of<UserProvider>(context, listen: false).userData.trust["name"]}",
            "sound": "alert.mp3",
            "body": "${imageText == null || imageText.isEmpty ? "Image" : imageText}",
            "priority" : "high",
            "android_channel_id": "CHAT_MESSAGES",
            "image": "${msg.image}"
          },
          "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
          "data": {
            "body": "${imageText == null || imageText.isEmpty ? "Image" : imageText}",
            "payload_id": "${msg.id}",
            "channel_name": "$channelName",
            "text": "${msg.user.name}: $imageText",
            "title": "${msg.user.name}",
            "is_system_message": false,
            "is_announcement": false,
            "channel_id": "${channel.id}",
            "version": "1.1.0",
            "senderId" : _user.uid, // added to handle new message badge in navigation bar and chat tab
            "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
          },
          "isArticle" : passedData['articleUrl'] != null ? true : false
        };

        msg.pnApns = {
          "notification":{
            "title":"Chat: ${msg.user.name}",
            "body": "${msg.text}",
            "image": "${msg.image}",
            "sound": "notification.m4r",
            "content_available": true,
            "mutable-content": true,
          },
          "priority" : "high",
          "aps": {"mutable-content": true, "content_available" : true, "category" : "$channelName",
            "sound": "notification.m4r",
            "data": {
              "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
            },
            "senderId" : _user.uid,
            "alert": {"body": "${msg.text}", "title": "${
            // Provider.of<ChatProvider>(context, listen: false).currentChannel.channelType == "group" &&
            //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName.isNotEmpty &&
            //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName != null
            //     ?
            // "${msg.user.name} on ${Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName}" :
                msg.user.name}, ${Provider.of<UserProvider>(context, listen: false).userData.trust["name"].length > 15 ?
            Provider.of<UserProvider>(context, listen: false).userData.trust["name"].toString().substring(0,15)+"..."  :
            Provider.of<UserProvider>(context, listen: false).userData.trust["name"]}"},
            "subtitle" : "Chat"},
          "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
          //"urlImageString": "${msg.image}",
          "chat_message": {"payload_id": "${msg.id}",
            "channel_name": "$channelName",
            "version": "1.1.0", "is_system_message": false,
            "is_announcement": false,
            "channel_id": "${channel.id}",
            "senderId" : _user.uid, // added to handle new message badge in navigation bar and chat tab
          }};

        /*
        * {messageId:
        *   {
        *   mutable-content: true,
        *   content_available: true,
        *   alert: {title: test two, body: hi},
        *   subtitle: Chat,
        *   category: channel-1614709937-b2fb0597d40de63c66095c85af65b7e006beef924fa4975d84,
        *   sound: notification.m4r
        *   },
        *  data: {},
        *  mutableContent: true,
        *  category: channel-1614709937-b2fb0597d40de63c66095c85af65b7e006beef924fa4975d84,
        *  notification:
        *   {
        *     body: hi,
        *      title: test two,
        *      apple: {},
        *      sound: { name: notification.m4r, volume: 1, critical: false}
        *   }
        *
        * }*/

        setState(() {
          sendingMessageStateResult= "Failed";
          lastMsgPayloadId = msg.id;
          _chatMessages.add(msg);
          _chatMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
        });



        pubnub.publish("$channelName", msg,storeMessage: true, meta: msgCustomProperties).then((PublishResult value){
          setState(() {
            sendingMessageStateResult = value.description;
            _replyToMsg = false;
            msgToReplyTo = null;
            isInputDisabled = false;
            msgCustomProperties = null;
            imageText = "Image";
            Provider.of<ChatProvider>(context,listen: false).settingMediaUrlNull();
          });
          debugPrint("message sending result is $sendingMessageStateResult");
        });
      });

    }


    setState(() {
      // _chatMessages.add(msg);
      // _chatMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
      _imageFile = null;
    });

  }

  Future<void> sendDocumentMessage() async{

    setState(() {
      isSendingDocument = true;
    });

    ChatMessage msg;
    Map<String, dynamic> msgCustomProperties;

    if(docFile != null){

      Provider.of<ChatProvider>(context,listen: false).chatAttachment(context,
          channelId: channel.id, filePath: docFile.path, fileName: docFileName, isUploadingDocument: true, file: docFile).then((_){

        if(Provider.of<ChatProvider>(context,listen: false).mediaUrl != null) {

          msgCustomProperties = {
            "sender_id": _user.uid,
            "sender": null,
            "msgToReplyImg": null,
            "msgToReplyContent": null,
            "document_url": Provider.of<ChatProvider>(context,listen: false).mediaUrl,
            "document_name": docFileName
          };

          msg = ChatMessage(id:"${_user.uid}$docFileName", text: "$docFileName", user: _user, customProperties: msgCustomProperties,
            documentUrl: Provider.of<ChatProvider>(context, listen: false).mediaUrl,
          );

          msg.pnGcm = {
            "notification":{
              "title":"Chat: ${
              // Provider.of<ChatProvider>(context, listen: false).currentChannel.channelType == "group" &&
              //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName.isNotEmpty &&
              //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName != null
              //     ?
              // "${msg.user.name} on ${Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName}" :
                  msg.user.name}, ${Provider.of<UserProvider>(context, listen: false).userData.trust["name"].length > 15 ?
              Provider.of<UserProvider>(context, listen: false).userData.trust["name"].toString().substring(0,15)+"..." :
              Provider.of<UserProvider>(context, listen: false).userData.trust["name"]}",
              "sound": "alert.mp3",
              "body": "sent a document",
              "priority" : "high",
              "android_channel_id": "CHAT_MESSAGES",
            },
            "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
            "data": {
              "body": "sent a document",
              "payload_id": "${msg.id}",
              "channel_name": "$channelName",
              "text": "${_user.name}: sent a document",
              "title": "${_user.name}",
              "is_system_message": false,
              "is_announcement": false,
              "channel_id": "${channel.id}",
              "version": "1.1.0",
              "senderId" : _user.uid, // added to handle new message badge in navigation bar and chat tab
              "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
            },
            "isArticle" : false
          };

          msg.pnApns = {
            "notification":{
              "title":"Chat: ${_user.name}",
              "body": "sent a document",
              "sound": "notification.m4r",
              "content_available": true,
              "mutable-content": true,
            },
            "priority" : "high",
            "aps": {"mutable-content": true, "content_available" : true, "category" : "$channelName",
              "sound": "notification.m4r",
              "data": {
                "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
              },
              "senderId" : _user.uid,
              "alert": {"body": "sent a document", "title": "${
              // Provider.of<ChatProvider>(context, listen: false).currentChannel.channelType == "group" &&
              //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName.isNotEmpty &&
              //     Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName != null
              //     ?
              // "${msg.user.name} on ${Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName}" :
                  msg.user.name}, ${Provider.of<UserProvider>(context, listen: false).userData.trust["name"].length > 15 ?
              Provider.of<UserProvider>(context, listen: false).userData.trust["name"].toString().substring(0,15)+"..."  :
              Provider.of<UserProvider>(context, listen: false).userData.trust["name"]}"},
              "subtitle" : "Chat"},
            "trust_id": Provider.of<UserProvider>(context, listen: false).userData.trust["id"],
            "chat_message": {"payload_id": "${msg.id}",
              "channel_name": "$channelName",
              "version": "1.1.0", "is_system_message": false,
              "is_announcement": false,
              "channel_id": "${channel.id}",
              "senderId" : _user.uid, // added to handle new message badge in navigation bar and chat tab
            }};
          // msg.documentUrl = Provider.of<ChatProvider>(context, listen: false).mediaUrl;

          setState(() {
            sendingMessageStateResult= "Failed";
            lastMsgPayloadId = "${_user.uid}$docFileName";
            _chatMessages.add(msg);
            _chatMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
          });


          pubnub.publish("$channelName", msg,storeMessage: true,).then((PublishResult value){
            setState(() {
              sendingMessageStateResult = value.description;
              isSendingDocument = false;
              docFile = null;
              docFileName = null;
              _replyToMsg = false;
              msgToReplyTo = null;
              isInputDisabled = false;
              imageText = "Image";
              Provider.of<ChatProvider>(context,listen: false).settingMediaUrlNull();
            });
            debugPrint("message sending result is $sendingMessageStateResult");
          });

        }else{
          setState(() {
            isSendingDocument = false;
            docFile = null;
            docFileName = null;
            _replyToMsg = false;
            msgToReplyTo = null;
            isInputDisabled = false;
            imageText = "Image";
            Provider.of<ChatProvider>(context,listen: false).settingMediaUrlNull();
          });
        }


      });

    }

  }

  // Widget _avatarBuilder(ChatUser user) {
  //   return CircleAvatar(
  //       radius: 17,
  //       backgroundImage: AssetImage("images/person.png")//Image.asset("images/person.png", fit: BoxFit.contain, color: Colors.grey[400],),
  //       );
  // }


  ChatUser get _user => ChatUser(
    avatar:Provider.of<UserProvider>(context,listen: false).userData == null ? null : Provider.of<UserProvider>(context,listen: false).userData.profilePic,
    uid: Provider.of<UserProvider>(context,listen: false).userData.id,
    name: Provider.of<UserProvider>(context,listen: false).userData.name,
  );


  void scrollToTop(){
    Future.delayed(Duration(milliseconds: waitToScrollInMillieSec)).then((_){
      if(_controller != null && _controller.hasClients && mounted && !_isloadingMsgs){
        _controller.animateTo(_controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150), curve: const ElasticInOutCurve()
        );
      }
    });
  }


  @override
  void dispose() /*async*/{
    messageFieldNode.dispose();
    // manager.emptyCache();
    // PaintingBinding.instance.imageCache.clear();
    pubnub.channel(channelName).subscription().unsubscribe();
    _controller.dispose();
    scScrollController.dispose();
    messageNode.dispose();
    // ********************* IMG PICKER ********************
    // _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    IsolateNameServer.removePortNameMapping('DownloadingFile');
    receiverPort.close();
    channelName = null;
    channel = null;
    _messages = [];
    history = null;
    super.dispose();
    // *****************************************************
    // Provider.of<ChatProvider>(context, listen: false).clearChannels();
    // await Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
    // await Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);

    // super.dispose();
  }

  settingCurrentChannel()async{
    final channelDetails = Provider.of<ChatProvider>(context, listen: false);
    await channelDetails.setCurrentChannel(channelDetails.channels.firstWhere((ch) => ch.name == channelName));
  }

  @override
  void didChangeDependencies() {
    // PaintingBinding.instance.imageCache.clear();

    if(_isInit){
      final channelDetails = Provider.of<ChatProvider>(context, listen: false);

      if(mounted){
        setState(() {
          passedData = ModalRoute.of(context).settings.arguments;

          // the only required field that has to be passed to this screen
          channelName = passedData["channel_name"];


          pubnub = passedData["pn"];
          if(passedData["pn"] == null && mounted){
            setState(() {
              pubnub = channelDetails.pubnub;
            });
          }

          channel = passedData["channel"]??channelDetails.channels.firstWhere((ch) => ch.name == channelName);
          // if(passedData["channel"] == null){
          //   if(mounted){
          //     setState(() {
          //       channel = channelDetails.currentChannel;//channels.firstWhere((ch) => ch.name == channelName);
          //     });
          //   }
          // }
          if(channelDetails.currentChannel == null && channelDetails.channelNamesSet.contains(channelName)){
            // if (mounted) {
            //   channelDetails.setCurrentChannel(channelDetails.channels.firstWhere((ch) => ch.name == channelName));
            // }
            settingCurrentChannel();
          }



          history = passedData["conversation_messages"];
          _messages = history == null ? [] : history.messages;

          if(passedData["conversation_messages"] == null && mounted){
          setState(() {
          channelName = passedData["channel_name"];
          history = channelDetails.pubnub.channel('$channelName').history(chunkSize: 60);
          _messages = history.messages;
          });
          }


          if(passedData['type'] == null && mounted){
          setState(() {
          passedData['type'] = channelDetails.currentChannel.channelType == "group" ? "group":
          channelDetails.currentChannel.channelType == "inbox" ? "announcement": "person";
          });
          }

          if(passedData["current_user_id"] == null && mounted){
          setState(() {
          passedData["current_user_id"] = Provider.of<UserProvider>(context, listen: false).userData.id;
          });
          }

          if(channelDetails.currentChannel.channelType == "inbox"){
          channelDetails.fetchChannelByName(channelName: channelName);
          }

          privateChatUser = passedData['private_chat_user'];

          // if((passedData['type'] == "private" || passedData['type'] == "person") && passedData['private_chat_user'] == null){
          //   if(channelDetails.channelUsers.isNotEmpty && channelDetails.channelUsers[channelName] != null){
          //     privateChatUser = channelDetails.channelUsers[channelName][0];
          //     // passedData['private_chat_user'] = channelDetails.channelUsers[channelName][0];
          //     chatTitle = channelDetails.channelUsers[channelName][0].name??"private chat";
          //   }else{
          //     channelDetails.fetchUserById(context, userIds: channel.participantIds, channelName: channelName).then((_){
          //       privateChatUser = channelDetails.channelUsers[channelName][0];
          //       // passedData['private_chat_user'] = channelDetails.channelUsers[channelName][0];
          //       chatTitle = channelDetails.channelUsers[channelName][0].name??"private chat";
          //     });
          //   }
          //   // if(Platform.isIOS && passedData["sender_name"] != null){
          //   //   chatTitle = passedData["sender_name"];
          //   // }
          //
          // }

          if(channelDetails.currentChannel.channelType == "group" && (channel.displayName == null || channel.displayName == "")){
          // channelDetails.fetchUserById(context, userIds: channel.participantIds, channelName: channelName).then((_){
          channelDetails.fetchUserById(context, userIds: channel.participantIds, channelName: channelName).then((_){
          chatTitle = channelDetails.channelUsers[channelName] == null ? "Conversation with 0 users" : "Group channel";
          });
          }

          if((passedData['type'] == "private" || passedData['type'] == "person") && passedData['private_chat_user'] == null){
          if(channelDetails.channelUsers.isNotEmpty && channelDetails.channelUsers[channelName] != null){
          privateChatUser = channelDetails.channelUsers[channelName][0];
          // passedData['private_chat_user'] = channelDetails.channelUsers[channelName][0];
          chatTitle = channelDetails.channelUsers[channelName][0].name??"private chat";
          }else{
          // debugPrint("testing private chat user name is: ${channelDetails.channelUsers[channelName].firstWhere((user) => user.id != Provider.of<UserProvider>(context, listen: false).userData.id).name}");
          channelDetails.fetchUserById(context, userIds: channel.participantIds, channelName: channelName).then((_){
          privateChatUser = channelDetails.channelUsers[channelName][0];
          // passedData['private_chat_user'] = channelDetails.channelUsers[channelName][0];
          chatTitle = channelDetails.channelUsers[channelName][0].name??"private chat";
          });
          }
          // if(Platform.isIOS && passedData["sender_name"] != null){
          //   chatTitle = passedData["sender_name"];
          // }

          }
          // if((channelDetails.currentChannel.channelType == "private" || channelDetails.currentChannel.channelType == "person") ){
          //   // debugPrint("testing private chat user name is: ${channelDetails.channelUsers[channelName].firstWhere((user) => user.id != Provider.of<UserProvider>(context, listen: false).userData.id).name}");
          //   chatTitle = channelDetails.channelUsers[channelName] != null ? channelDetails.channelUsers[channelName][0].name??"private chat":
          // }
          if(channelDetails.currentChannel.channelType == "inbox"){
          chatTitle = "Announcement";
          }
          else{
          chatTitle = channel.displayName??"";
          }

        });

      }


      if (passedData['articleUrl'] != null) {
        _messageController.text = passedData['articleUrl'];
      }




      pubnub.subscribe(channels: {channelName}).asStream().forEach((sub) {
        sub.messages.listen((env) {

          // this is for adding system messages
          if(env.payload.toString().contains("pn_gcm") == false && env.payload.toString().contains("pn_apns") == false && env.payload.toString().contains("createdAt") == false
              && passedData["type"] != "announcement"){
            Map<String, dynamic> systemMsgInfo = {};
            String gettingFullLongBase64String(String text) {
              String res = "";
              final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
              pattern.allMatches(text).forEach((match) => res += match.group(0));
              return res;
            }
            String systemMsgText = "";
            List<int> listOfInts = base64Decode(
                gettingFullLongBase64String("${env.payload['content']}"));
            systemMsgInfo = json.decode(utf8.decode(listOfInts));

            if(systemMsgInfo["type"] == "participants_removed"){
              systemMsgText = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : "Admin"} removed ${systemMsgInfo["entity"]["participant_names"].toString().replaceAll("[", "").replaceAll("]", "")}";}
            // participants_added system message
            if(systemMsgInfo["type"] == "participants_added"){
              systemMsgText = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : "Admin"} added ${systemMsgInfo["entity"]["participant_names"].toString().replaceAll("[", "").replaceAll("]", "")}";
            }

            // group_created system message
            // if(systemMsgInfo["type"] == "group_created"){
            //   systemMsgText = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : systemMsgInfo["entity"]["sender_name"]} created group";
            // }

            // left_group system message
            if(systemMsgInfo["type"] == "left_group"){
              systemMsgText = "${systemMsgInfo["entity"]["sender_name"]} left chat";
            }
            if(mounted && systemMsgText != ""){
              setState(() {
                _chatMessages.add(ChatMessage(
                    image: null,
                    customProperties: null,
                    text: systemMsgText,
                    user: ChatUser(
                      uid: "SYSTEM",
                    ),
                    createdAt: env.timetoken.toDateTime()
                ));
              });
            }
          }

          // if the message is sent from Flutter app by another user
          /// note that all messages now contain pn_gcm even the messages sent from Flutter
          if(env.payload.toString().contains("uid") && passedData["type"] != "announcement" && env.payload["id"] != _chatMessages.last.id){
            if (env.payload["user"]["uid"].toString() != passedData["current_user_id"]/*Provider.of<UserProvider>(context, listen: false).userData.id*/) {

              if(mounted && env.payload["id"] != _chatMessages.last.id){
                // var logger = Logger(
                //   filter: null, // Use the default LogFilter (-> only log in debug mode)
                //   printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
                //   output: null, // Use the default LogOutput (-> send everything to console)
                // );
                // logger.i("tesing old create group !! ${env.payload["id"]}   ${env.payload["text"]}   last msg before new one !! ${_chatMessages.last.id}  ${_chatMessages.last.text}");

                // if(passedData["type"] == "person"){
                setState(() {
                  waitToScrollInMillieSec = 300;
                  _chatMessages.add(
                      ChatMessage(
                        id: env.payload["id"],
                        text: env.payload["text"],
                        image: env.payload["image"],
                        customProperties: env.payload["customProperties"],
                        createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(env.timetoken.toString().substring(0, 13))),
                        user: ChatUser(
                            name: env.payload["user"]["name"],
                            avatar: env.payload["user"]["avatar"],/*??Provider.of<ChatProvider>(context, listen: false).channelUsers[channelName][0].profilePic,*/
                            uid: env.payload["user"]["uid"].toString() ?? "UUID"
                        ),
                      ));
                  _chatMessages.sort((m1, m2) =>
                      m1.createdAt.compareTo(m2.createdAt));
                });

              }
            }
          }
          else if(passedData["type"] == "announcement"){

            Map<String, dynamic> announcementSenderInfo = {};
            String gettingFullLongBase64String(String text) {
              String res = "";
              final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
              pattern.allMatches(text).forEach((match) => res += match.group(0));
              return res;
            }
            List<int> listOfInts = base64Decode(gettingFullLongBase64String("${env.payload["content"]}"));
            announcementSenderInfo = json.decode(utf8.decode(listOfInts))["entity"]["sender"];


            if(announcementSenderInfo["id"] == passedData["current_user_id"]/*Provider.of<UserProvider>(context, listen: false).userData.id*/){
              if(mounted){
                setState(() {
                  waitToScrollInMillieSec = 300;
                  _chatMessages.add(
                      ChatMessage(text: env.payload["pn_gcm"] == null ? "" :
                      passedData["type"] == "announcement" ? env
                          .payload["pn_gcm"]["data"]["text"] : env
                          .payload["pn_gcm"]["data"]["body"].toString(),
                          createdAt: env.timetoken.toDateTime(),
                          user: _user
                      ));
                  _chatMessages.sort((m1, m2) =>
                      m1.createdAt.compareTo(m2.createdAt));
                });
              }
            }else {
              if(mounted){
                setState(() {
                  _chatMessages.add(
                      ChatMessage(
                        text: env.payload["pn_gcm"] == null ? "" :
                        passedData["type"] == "announcement" ? env
                            .payload["pn_gcm"]["data"]["text"] : env
                            .payload["pn_gcm"]["data"]["body"].toString(),
                        createdAt: env.timetoken.toDateTime(),
                        user: ChatUser(
                            name: announcementSenderInfo["name"],

                            avatar: announcementSenderInfo["profile_image"],

                            uid: announcementSenderInfo["id"]
                        ),
                      ));
                  _chatMessages.sort((m1, m2) =>
                      m1.createdAt.compareTo(m2.createdAt));
                });
              }
            }
          }

          if(mounted){
            Provider.of<ChatProvider>(context, listen: false).sortChannels();
          }
          scrollToTop();
        });
      });

      getHistory().then((_) {
        channelDetails.setOpenChannelName(channelName);
        scrollToTop();
      });

      channelDetails.setNewMSGforChannelToNull(channelName);

      _isInit = false;
    }

    // pubnub.signal(channelName, "Typing");
    super.didChangeDependencies();

  }

  // ********************************************* Image picker code *****************************************************

  PickedFile _imageFile;
  File docFile;
  String docFileName;
  String imgName ;
  String imgPath ;
  dynamic _pickImageError;
  bool isVideo = false;
  // VideoPlayerController _videoPlayerController;
  // VideoPlayerController _toBeDisposed;
  String _retrieveDataError;
  FocusNode messageNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  /// TODO attach Videos to chat
  /*
  Future<void> _playVideo(PickedFile file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
       VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      _videoPlayerController = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
      final double volume = kIsWeb ? 0.0 : 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }
  */


  // @override
  // void deactivate() {
  //   if (_videoPlayerController != null) {
  //     _videoPlayerController.setVolume(0.0);
  //     _videoPlayerController.pause();
  //   }
  //   super.deactivate();
  // }

  // Future<void> _disposeVideoController() async {
  //   if (_toBeDisposed != null) {
  //     await _toBeDisposed.dispose();
  //   }
  //   _toBeDisposed = _videoPlayerController;
  //   _videoPlayerController = null;
  // }

  // Widget _previewVideo() {
  //   final Text retrieveError = _getRetrieveErrorWidget();
  //   if (retrieveError != null) {
  //     return retrieveError;
  //   }
  //   if (_videoPlayerController == null) {
  //     return const Text(
  //       'You have not yet picked a video',
  //       textAlign: TextAlign.center,
  //     );
  //   }
  //   return Padding(
  //     padding: const EdgeInsets.all(10.0),
  //     child: AspectRatioVideo(_videoPlayerController),
  //   );
  // }

  bool isSendingDocument = false;

  Widget _previewDocument({media, ChatMessage msg}){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isSendingDocument ? Container(
          height:5,
          margin: const EdgeInsets.all(0),
          child: LinearProgressIndicator(
            backgroundColor: const Color(0xFFebf5fe),
            color: Theme.of(context).primaryColor,
            minHeight: 2,
          ),
        ) : const SizedBox(),
        Container(
          width: media.width,
          height: 165.0,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset:
                  const Offset(0, 3), // changes position of shadow
                ),
              ], color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 35.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap:(){
                            setState(() {
                              docFile = null;
                              docFileName = null;
                            });
                          },
                          child: Text("Cancel", style: styleBlue,),
                        ),

                        InkWell(
                          onTap: isSendingDocument ? null :(){
                            sendDocumentMessage();
                          },
                          child: Text("Send", style: styleBlue,),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                  child: SizedBox(
                    height: 115,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_drive_file_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 55.0,
                        ),
                        const SizedBox(height: 2.0,),
                        SizedBox(
                          width: 115.0,
                          child: Text("$docFileName", maxLines: 2, overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14.0, color: Colors.black),),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewImage({width, height}) {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null /*|| docFile != null*/) {
      if (kIsWeb) {
        // Why network?
        // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
        return _imageFile == null ? const SizedBox() : Image.network(_imageFile.path,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SpinKitCubeGrid(color: Theme.of(context).primaryColor,size: 40,),
            );
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
            return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],height: 200,);
          },
        );
      } else {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(color: Colors.white,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //_imageFile == null ? const SizedBox() :
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                child: Container(
                    width:MediaQuery.of(context).size.width*0.25,
                    height: height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                    Semantics(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_imageFile.path),
                            width:100,
                            height: 70,
                            // scale: 1.0,
                            // fit: BoxFit.cover,
                          ),
                        ),
                        label: 'image_picker_example_picked_image')
                ),
              ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 12,top: 7),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      _imageFile = null;
                      docFile = null;
                      docFileName = null;
                    });
                  },
                  child:
                  Container(decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white),child: const Icon(Icons.cancel,color: Colors.black54,size: 18,)),
                ),
              )
            ],
          ),
        );
      }
    } else if (_pickImageError != null) {
      return Text(
        'error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    }
    else {
      return const SizedBox();
    }
  }

  //
  // Future<void> retrieveLostData() async {
  //   final LostData response = await _picker.getLostData();
  //   if (response.isEmpty) {
  //     return;
  //   }
  //   if (response.file != null) {
  //     if (response.type == RetrieveType.video) {
  //       isVideo = true;
  //       /// TODO
  //       // await _playVideo(response.file);
  //     } else {
  //       isVideo = false;
  //       setState(() {
  //         _imageFile = response.file;
  //       });
  //     }
  //   } else {
  //     _retrieveDataError = response.exception.code;
  //   }
  // }

  // ********************************************* Image picker code ends *****************************************************

  // _checkMemory(){
  //   imageCache.maximumSize = 50;
  //   imageCache.clear();
  //   imageCache.clearLiveImages();
  //   ImageCache _imageCache = PaintingBinding.instance.imageCache;
  //   if(_imageCache.currentSizeBytes >= 50 << 20 || _imageCache.currentSize >= 5){
  //     _imageCache.clear();
  //     _imageCache.clearLiveImages();
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);
    final channelDetails = Provider.of<ChatProvider>(context);
    // imageCache.maximumSize = 50;

    return WillPopScope(
      onWillPop: () {
        channelDetails.clearOpenChannelName(context, channelName: channelName);
        channelDetails.clearCurrenChannel();
        pubnub.channel(channelName).subscription().unsubscribe();
        // PaintingBinding.instance.imageCache.clear();

        // Provider.of<ChangeIndex>(context,listen: false).changeIndexFunction(2);
        if (!kIsWeb) {
          Navigator.pushReplacementNamed(context, NavigationHome.routeName);
        }
        else{
          Navigator.pushReplacementNamed(context, WebMainScreen.routeName);
        }
        channelName = null;
        // channel = null;
        _messages = [];
        history = null;

        // Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));

        // Navigator.pop(context);
        return Future.value(false);
      },
      /// putting the background image in the stack may cause an error !!!
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (Platform.isIOS && _viewChatImage == null) {
            if (details.primaryVelocity.compareTo(0) == 1) {
              channelDetails.clearOpenChannelName(context,channelName: channelName);
              channelDetails.clearCurrenChannel();
              pubnub.channel(channelName).subscription().unsubscribe();
              // PaintingBinding.instance.imageCache.clear();

              // Provider.of<ChangeIndex>(context,listen: false).changeIndexFunction(2);
              if (!kIsWeb) {
                Navigator.pushReplacementNamed(context, NavigationHome.routeName);
              }
              else{
                Navigator.pushReplacementNamed(context, WebMainScreen.routeName);
              }
              channelName = null;
              // channel = null;
              _messages = [];
              history = null;
            }
          }
        },
        child: Stack(
          children: [
            // the blew colors for blue chat BG
            // 0xFFebf5fe
            // 0xFF9FB6CD
            Container(height: media.height,width: media.width,color: Colors.white,),
            Positioned.fill(child: Image.asset('${Provider.of<UserProvider>(context,listen: false).currentAppBackground}',fit: kIsWeb ? BoxFit.cover : BoxFit.fitHeight,)),
            Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.transparent,
                appBar: screenAppBar(context, media, centerTitle: false,
                    appbarTitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        passedData["type"] == "person" ?
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                              radius: 18.0,
                              backgroundColor: Theme.of(context).primaryColor,
                              backgroundImage: privateChatUser != null && privateChatUser.profilePic != null
                                  ?
                              NetworkImage(privateChatUser.profilePic):
                              const AssetImage("images/person.png")
                          ),
                        ):const SizedBox(),
                        Flexible(child: (passedData["type"] == "group" && channelDetails.findingUserStage == ChatStage.LOADING) ?
                        const Center(
                            child: SpinKitThreeBounce(
                              color: Colors.white,
                              size: 25.0,
                            )):
                        Text(
                          passedData["type"] == "announcement" ? "Announcement" :
                          channelDetails.currentChannel != null ?
                          passedData["type"] == "person" || passedData["type"] == "person" ? "${privateChatUser != null ? privateChatUser.name : chatTitle == null ? "" : chatTitle}" : channelDetails.currentChannel.displayName??chatTitle : "${chatTitle == null ? "" : chatTitle}" ,
                          overflow: TextOverflow.ellipsis,)),
                      ],
                    ),
                    callAction: passedData["type"] == "person" || passedData["type"] == "private" ?
                        ()async {
                      User user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: privateChatUser.id);
                      if(await Permission.microphone.isGranted == true){
                        final callProvider = Provider.of<CallProvider>(context, listen: false);
                        callProvider.initiateTwilioCall(context, callToUser: user);
                      }
                      else{
                        await Permission.microphone.request().then((value) {
                          final callProvider = Provider.of<CallProvider>(context, listen: false);
                          callProvider.initiateTwilioCall(context, callToUser: user);
                        });
                      }
                    }:null,
                    addAction: passedData["type"] == "announcement" && userData.userData.headUser ?
                        ()=> showModalFilterSheet(context, scScrollController, "", isAnnouncement: true, defaultUserType: userData.userData.roleType): null,
                    infoAction: passedData["type"] == "person" || passedData["type"] == "private"? ()=> Navigator.pushNamed(context, ChatDetails.routeName,
                        arguments: {
                          "type": passedData["type"],
                          "name": privateChatUser != null ? privateChatUser.name : chatTitle,
                          "userId": channelDetails.channelUsers[channelName][0].id,
                          "profile_pic": privateChatUser == null ? null : channelDetails.channelUsers[channelName][0].profilePic
                        }): passedData["type"] == "group" ? (){
                      // await channelDetails.fetchChannelByName(channelName: channelName);
                      Navigator.pushNamed(context, GroupDetails.routeName,
                          arguments: {
                            "type": passedData["type"],
                            "name": chatTitle,
                            "channel_name":channelName,
                            "channel_id": channel.id
                            //"channel": channelDetails.currentChannel
                          });
                    } : null,
                    onBackPressed: () {
                      channelDetails.clearOpenChannelName(context,channelName: channelName);
                      channelDetails.clearCurrenChannel();

                      // PaintingBinding.instance.imageCache.clear();
                      pubnub.channel(channelName).subscription().unsubscribe();

                      // Provider.of<ChangeIndex>(context,listen: false).changeIndexFunction(2);
                      if (!kIsWeb) {
                        Navigator.pushReplacementNamed(context, NavigationHome.routeName);
                      }else{
                        Navigator.pushReplacementNamed(context, WebMainScreen.routeName);
                      }
                      channelName = null;
                      // channel = null;
                      _messages = [];
                      history = null;
                    },
                    hideProfilePic: true,
                    showLeadingPop: true),
                body:
                // channelDetails.findingUserStage == ChatStage.LOADING ?
                // Center(child: SpinKitCircle(color: Theme.of(context).primaryColor,size: 30,)):
                Stack(
                  children: [
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: _isloadingMsgs ?
                      Center(
                        child: SpinKitCircle(
                          color: Theme.of(context).primaryColor,
                          size: 45.0,
                        ),
                      ):
                      DashChat(
                        key: _chatViewKey,
                        textCapitalization: TextCapitalization.sentences,
                        // messagePadding: const EdgeInsets.all(0),
                        // onLoadEarlier: () async{
                        // },
                        // shouldShowLoadEarlier: true,
                        showTraillingBeforeSend: true,
                        avatarBuilder: (ChatUser chatUser){
                          return passedData["type"] == "person" || chatUser.uid == "SYSTEM" ?  const SizedBox():
                          Align(
                            alignment: Alignment.topLeft,
                            child: Tooltip(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(7.0)
                              ),
                              message: "${chatUser.name}",
                              child: Material(
                                elevation: 8.0,
                                borderRadius: BorderRadius.circular(20.0),
                                child: CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  backgroundImage: chatUser.avatar == null ? const AssetImage("images/person.png"): NetworkImage(chatUser.avatar),
                                ),
                              ),
                            ),
                          );
                        },
                        // onLongPressMessage: (ChatMessage msg){
                        //   messageNode.unfocus();
                        //   if(msg.image != null){
                        //     setState(() {
                        //       _viewChatImage = msg.image;
                        //     });
                        //   }
                        // },

                        // check this code with messages that contain pics
                        messageBuilder: (ChatMessage msg){
                          if(passedData["type"] != "announcement" && msg.user.uid == "SYSTEM"){
                            // system messages widget in Messaging screen need to be handled
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
                              child: Center(
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[500],
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                      child: Text(msg.text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12.0),
                                      )
                                  )
                              ),
                            );
                          }
                          else{
                            return Padding(
                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, right: msg.user.uid == _user.uid ? 0 : 25.0, left: msg.user.uid == _user.uid ? 25.0 : 0),
                              child: SwipeTo(
                                  onRightSwipe:
                                  passedData["type"] != "announcement" && docFile == null ?
                                      (){
                                    messageNode.requestFocus();
                                    setState(() {
                                      msgToReplyTo = msg;
                                      _replyToMsg = true;
                                    });
                                  } :
                                  null,
                                  child:
                                  InkWell(
                                    onTap: (){
                                      messageNode.unfocus();
                                      if(msg.image != null){
                                        setState(() {
                                          _viewChatImage = msg.image;
                                        });
                                      }
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: msg.user.uid == _user.uid ? Alignment.centerRight : Alignment.bottomLeft,
                                          child: Flex(
                                            mainAxisAlignment: msg.user.uid == _user.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            direction: Axis.horizontal,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                    decoration:
                                                    msg.user.uid == _user.uid ?
                                                    BoxDecoration(
                                                      gradient: const LinearGradient(
                                                          colors:[Color(0xff2799F0), Color(0xff79C0F6)]
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.8),
                                                          spreadRadius: 2,
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 3), // changes position of shadow
                                                        ),
                                                      ],
                                                      borderRadius: const BorderRadius.only(
                                                        bottomLeft: Radius.circular(10.0),
                                                        topLeft: Radius.circular(10.0),
                                                        topRight: Radius.circular(10.0),
                                                      ),):
                                                    BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.5),
                                                          spreadRadius: 5,
                                                          blurRadius: 7,
                                                          offset: const Offset(0, 3), // changes position of shadow
                                                        ),
                                                      ],
                                                      borderRadius: const BorderRadius.only(
                                                        bottomRight: Radius.circular(10.0),
                                                        topLeft: Radius.circular(10.0),
                                                        topRight: Radius.circular(10.0),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                      child: msg.customProperties != null && msg.customProperties.containsKey("document_url") && msg.customProperties["document_url"] != null ?
                                                      Stack(
                                                        children: [
                                                          InkWell(
                                                            onTap:(){
                                                              if (!kIsWeb) {
                                                                _downloadFile(msg.customProperties["document_url"], fileName: msg.customProperties["document_name"]);
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 5.0, bottom: 23.0),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  msg.user.uid != _user.uid && passedData["type"] != "person" ?
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                                                    child: Text("${msg.user.name}", maxLines: 1, style: TextStyle(color:
                                                                    Color(int.parse("0xff${msg.user.uid.substring(0,7).replaceAll("-", "")}")).withOpacity(1.0),
                                                                        fontWeight: FontWeight.bold, fontSize: 14.0),),
                                                                  ): const SizedBox(),

                                                                  Container(
                                                                    height: 52.0,
                                                                    constraints: BoxConstraints(
                                                                        maxWidth: media.width * 0.5
                                                                    ),
                                                                    // width: media.width * 0.5,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.black12,
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Icon(Icons.file_present, color: msg.user.uid == _user.uid ?
                                                                        Colors.white : Theme.of(context).primaryColor, size: 30.0,),
                                                                        const SizedBox(width: 3.0),
                                                                        Flexible(
                                                                          child: Text("${msg.customProperties["document_name"]}",
                                                                            style: TextStyle(color: msg.user.uid == _user.uid ? Colors.white : Colors.black, fontSize: 14.0, overflow: TextOverflow.ellipsis),),
                                                                        ),
                                                                        const SizedBox(width: 6.0,)
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 4,
                                                            right: msg.user.uid == _user.uid ? 5 : null,
                                                            left: msg.user.uid == _user.uid ? null : 5,
                                                            child: FittedBox(
                                                              fit: BoxFit.fitWidth,
                                                              child: Align(
                                                                alignment: msg.user.uid == _user.uid ? Alignment.bottomRight : Alignment.bottomLeft,
                                                                child: Text(formatStringTime(stringTime: msg.createdAt.toString()),
                                                                  style: TextStyle(fontSize: 12.0, color: Colors.grey[800]),),
                                                              ),
                                                            ),)
                                                        ],
                                                      ):
                                                      msg.customProperties != null && msg.customProperties['isArticle'] != null
                                                          ?
                                                      InkWell(
                                                        onTap: (){
                                                          Navigator.pushNamed(context, NewsDetails.routeName,
                                                              arguments: {
                                                                "url": msg.customProperties['url'],
                                                                " isArticleFavourite": msg.customProperties['isFavourite'],
                                                                "id": msg.customProperties['id'],
                                                                'commentsCount':msg.customProperties['commentsCount'],
                                                                "articleThumbnail" : msg.customProperties['thumbnail'],
                                                                "articleTitle" : msg.customProperties['articleTitle'],
                                                                "isArticleFavourite" : msg.customProperties['isFavourite'],
                                                                "articleCommentsCount" : msg.customProperties['commentsCount'],
                                                                "articleId" : msg.customProperties['id']
                                                              });
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                msg.customProperties["sender_id"] == _user.uid ?
                                                                SizedBox(
                                                                    height: 100,
                                                                    width: 160,
                                                                    child : FadeInImage.memoryNetwork(
                                                                      imageCacheHeight: 400,
                                                                      imageCacheWidth: 400,
                                                                      width: 400,
                                                                      height: 400,
                                                                      placeholder: kTransparentImage,// This should be an image, so you can't use progressbar,
                                                                      key: ValueKey('${msg.customProperties['thumbnail']}'),
                                                                      image: '${msg.customProperties['thumbnail']}',
                                                                      fit: BoxFit.cover,
                                                                      imageErrorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                                        return InkWell(
                                                                            onTap: (){
                                                                              setState(() {
                                                                                msg.customProperties['thumbnail'] = msg.customProperties['thumbnail'].split('?r')[0] + '?r=' + DateTime.now().millisecondsSinceEpoch.toString();
                                                                              });
                                                                            },
                                                                            child: Image.asset('images/errorImage.png',height: 200,)
                                                                        );
                                                                      },
                                                                    )
                                                                ) : Expanded(child: Text('${msg.customProperties['articleTitle']}',style: TextStyle(color: msg.customProperties["sender_id"] == _user.uid ? Colors.white : Colors.black),overflow: TextOverflow.ellipsis,)),
                                                                const SizedBox(width: 10,),

                                                                msg.customProperties["sender_id"] == _user.uid ?
                                                                Expanded(child: Text('${msg.customProperties['articleTitle']}',style: TextStyle(color: msg.customProperties["sender_id"] == _user.uid ? Colors.white : Colors.black),overflow: TextOverflow.ellipsis,)) :
                                                                SizedBox(
                                                                    height: 100,
                                                                    width: 160,
                                                                    child : FadeInImage.memoryNetwork(
                                                                      imageCacheHeight: 400,
                                                                      imageCacheWidth: 400,
                                                                      width: 400,
                                                                      height: 400,
                                                                      placeholder: kTransparentImage,// This should be an image, so you can't use progressbar,
                                                                      key: ValueKey('${msg.customProperties['thumbnail']}'),
                                                                      image: '${msg.customProperties['thumbnail']}',
                                                                      fit: BoxFit.cover,
                                                                      imageErrorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                                        return InkWell(
                                                                            onTap: (){
                                                                              setState(() {
                                                                                msg.customProperties['thumbnail'] = msg.customProperties['thumbnail'].split('?r')[0] + '?r=' + DateTime.now().millisecondsSinceEpoch.toString();
                                                                              });
                                                                            },
                                                                            child: Image.asset('images/errorImage.png',height: 200,)
                                                                        );
                                                                      },
                                                                    )
                                                                ),
                                                              ],
                                                            ),
                                                            Positioned(
                                                              bottom: 5,
                                                              right: msg.user.uid == _user.uid ? 5 : null,
                                                              left: msg.user.uid == _user.uid ? null : 5,
                                                              child: FittedBox(
                                                                fit: BoxFit.fitWidth,
                                                                child: Align(
                                                                  alignment: msg.user.uid == _user.uid ? Alignment.bottomRight : Alignment.bottomLeft,
                                                                  child: Text(formatStringTime(stringTime: msg.createdAt.toString()),
                                                                    style: TextStyle(fontSize: 12.0, color: Colors.grey[800]),),
                                                                ),
                                                              ),)
                                                          ],
                                                        ),
                                                      )
                                                          :
                                                      // if the MSG is not an Article or contain one !!!
                                                      Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment:
                                                        // CrossAxisAlignment.start,
                                                        msg.user.uid != _user.uid ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                                        children: [

                                                          // this is the code for Colored user name that will appear in evey msg for channel type != "person" channels
                                                          /*
                                                            me 0371b4
                                                          Gary Drew Color(0xff446453) 64da01
                                                          Emma Rowe Color(0xff605534)
                                                          Gary Drew Color(0xff446453)
                                                          Koto Uchida Color(0xff768152)
                                                          John Bacon Color(0xff989526)
                                                          Jon Bennett Color(0xff152239)
                                                          Gemma Bullock Color(0xff339651)
                                                          Jonathon Graham Color(0xff389007)
                                                          */
                                                          msg.user.uid != _user.uid && passedData["type"] != "person" ?
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 8.0),
                                                            child: Text("${msg.user.name}", maxLines: 1, style: TextStyle(color:
                                                            Color(int.parse("0xff${msg.user.uid.substring(0,7).replaceAll("-", "")}")).withOpacity(1.0),
                                                                fontWeight: FontWeight.bold, fontSize: 14.0),),
                                                          ): const SizedBox(),

                                                          msg.customProperties != null && msg.customProperties['isArticle'] == null
                                                              ?
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 4.0),
                                                            child: Container(
                                                              height: 75.0,
                                                              decoration: BoxDecoration(
                                                                color: Colors.transparent,//grey.withOpacity(0.5),
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: Container(
                                                                  // width: media.width,
                                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.black12,
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      border: Border(
                                                                          left: BorderSide(color: msg.user.uid != _user.uid ? Colors.indigoAccent : const Color(0xFFff9c01),width: 2.5)
                                                                      )
                                                                  ),
                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: SizedBox(
                                                                          width: msg.customProperties["msgToReplyImg"] != null ? media.width - 65 : media.width,
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(msg.customProperties["sender_id"] == _user.uid ? "You" : msg.customProperties["sender"], overflow: TextOverflow.ellipsis, maxLines: 1,
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: msg.user.uid != _user.uid ? Colors.indigoAccent : const Color(0xFFff9c01)),),
                                                                              const SizedBox(height: 1.5,),
                                                                              Linkify(
                                                                                onOpen: (link) async {
                                                                                  if (await canLaunch(link.url)) {
                                                                                    await launch(link.url,
                                                                                        forceSafariVC: true,
                                                                                        forceWebView: true,
                                                                                        enableJavaScript: true);
                                                                                  }else{
                                                                                    debugPrint("Couldn't launch url");
                                                                                  }
                                                                                },
                                                                                linkStyle: msg.user.uid == _user.uid ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w600):null,
                                                                                text: msg.customProperties["msgToReplyContent"] == "" ? "Image" :
                                                                                msg.customProperties["msgToReplyContent"], maxLines: 2, overflow: TextOverflow.ellipsis,),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // msgToReplyTo.image != null ? Spacer():Container(),
                                                                      msg.customProperties["msgToReplyImg"] != null ? Padding(
                                                                        padding: const EdgeInsets.only(left: 4.0),
                                                                        child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(12.0),
                                                                            child:
                                                                            SizedBox(
                                                                              width: 60.0,
                                                                              height: 60.0,
                                                                              child: FadeInImage.memoryNetwork(
                                                                                fit: BoxFit.cover,
                                                                                // imageCacheHeight: 100,
                                                                                // imageCacheWidth: 100,
                                                                                // width: 60,
                                                                                // height: 60,
                                                                                placeholder: kTransparentImage,
                                                                                key: ValueKey('${msg.customProperties['msgToReplyImg']}'),
                                                                                image: '${msg.customProperties["msgToReplyImg"]}',
                                                                                imageErrorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                                                  return InkWell(
                                                                                      onTap: (){
                                                                                        setState(() {
                                                                                          msg.customProperties['msgToReplyImg'] = msg.customProperties['msgToReplyImg'].split('?r')[0] + '?r=' + DateTime.now().millisecondsSinceEpoch.toString();
                                                                                        });
                                                                                      },
                                                                                      child: Image.asset('images/errorImage.png',height: 200,)
                                                                                  );
                                                                                },
                                                                              ),
                                                                            )
                                                                          // Image.network(msg.customProperties["msgToReplyImg"], height: 60, fit: BoxFit.contain,errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                                          //   return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                                                          // },)
                                                                        ),
                                                                      ):const SizedBox(width: 1.0,)
                                                                      // Spacer(),
                                                                      // Flexible(
                                                                      //   child: Align(
                                                                      //     alignment: Alignment.topRight,
                                                                      //     child: IconButton(icon: Icon(Icons.clear), onPressed: (){
                                                                      //       setState(() {
                                                                      //         _replyToMsg = false;
                                                                      //       });
                                                                      //     }),
                                                                      //   ),
                                                                      // )
                                                                    ],
                                                                  ),

                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                              : const SizedBox(width: 1,),

                                                          msg.image == null
                                                              ?
                                                          Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Linkify(
                                                                  onOpen: (link) async {
                                                                    if (await canLaunch(link.url)) {
                                                                      await launch(link.url,
                                                                          forceSafariVC: true,
                                                                          forceWebView: true,
                                                                          enableJavaScript: true);
                                                                    }else{
                                                                      debugPrint("Couldn't launch url");
                                                                    }
                                                                  },
                                                                  linkStyle: msg.user.uid == _user.uid ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w600):null,
                                                                  text:"${msg.text}", maxLines: null, style: TextStyle(fontSize: 16.0, color: msg.user.uid == _user.uid ? Colors.white : Colors.black))
                                                          )
                                                              :
                                                          Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: msg.user.uid == _user.uid ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                            children: [
                                                              Flexible(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                                                                  child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(12.0),
                                                                      child: SizedBox(
                                                                        height: 200,
                                                                        width: 200,
                                                                        child: FadeInImage.memoryNetwork(
                                                                          fit: BoxFit.cover,
                                                                          // height: 200,
                                                                          // width: 200,
                                                                          // imageCacheHeight: 400,
                                                                          // imageCacheWidth: 400,
                                                                          key: ValueKey('${msg.image}'),
                                                                          placeholder: kTransparentImage,// This should be an image, so you can't use progressbar,
                                                                          image: '${msg.image}',
                                                                          imageErrorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                                            return InkWell(
                                                                                onTap: (){
                                                                                  setState(() {
                                                                                    msg.image = msg.image.split('?r')[0] + '?r=' + DateTime.now().millisecondsSinceEpoch.toString();
                                                                                  });
                                                                                },
                                                                                child: Image.asset('images/errorImage.png',height: 200,)
                                                                            );
                                                                          },
                                                                        ),
                                                                      )
                                                                  ),
                                                                ),
                                                              ),
                                                              msg.text == "Image" ? const SizedBox():
                                                              Flexible(child: Padding(
                                                                padding: const EdgeInsets.only(bottom:5.0),
                                                                child: Linkify(
                                                                    onOpen: (link) async {
                                                                      if (await canLaunch(link.url)) {
                                                                        await launch(link.url,
                                                                            forceSafariVC: true,
                                                                            forceWebView: true,
                                                                            enableJavaScript: true);
                                                                      }else{
                                                                        debugPrint("Couldn't launch url");
                                                                      }
                                                                    },
                                                                    linkStyle: msg.user.uid == _user.uid ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w600):null,
                                                                    text:"${msg.text}", maxLines: null, style: TextStyle(fontSize: 16.0, color: msg.user.uid == _user.uid ? Colors.white : Colors.black)),
                                                              ))
                                                            ],
                                                          ),
                                                          Text(formatStringTime(stringTime: msg.createdAt.toString()),
                                                            style: TextStyle(fontSize: 12.0, color: Colors.grey[800]),),
                                                          const SizedBox(height: 5.0,)
                                                        ],
                                                      ),
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // this is the message status Widget for the current user messages only !!!
                                        msg.user.uid == _user.uid && msg.id == lastMsgPayloadId ?
                                        Padding(
                                          padding: const EdgeInsets.only(top:1.0),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                sendingMessageStateResult == "Sent" ?
                                                const Text("Sent ", style: TextStyle(color: Color(0xff808080), fontSize: 15.0),):
                                                sendingMessageStateResult == "Failed" ?
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Text("Sending", style: TextStyle(color: Color(0xff808080), fontSize: 15.0,),),
                                                    AnimatedTextKit(
                                                      animatedTexts: [
                                                        TyperAnimatedText(
                                                          "....",
                                                          textStyle: const TextStyle(
                                                              fontSize: 15.0,
                                                              color: Color(0xff808080)
                                                          ),
                                                          speed: const Duration(milliseconds: 800),
                                                        ),
                                                      ],
                                                      totalRepeatCount: 1000,
                                                      pause: const Duration(milliseconds: 300),
                                                      displayFullTextOnTap: true,
                                                      stopPauseOnTap: true,
                                                    ),
                                                  ],
                                                )
                                                    :
                                                const SizedBox(),

                                                sendingMessageStateResult == "Sent" ?
                                                const Icon(Icons.check_circle_outline_rounded, color: Color(0xff808080),size: 15.0,)
                                                    :
                                                const SizedBox()

                                              ],
                                            ),
                                          ),
                                        )
                                            :
                                        const SizedBox()
                                      ],
                                    ),
                                  )
                              ),
                            );
                          }
                        },

                        trailing: <Widget>[
                          // IconButton(icon: Icon(Icons.attach_file),
                          //   onPressed: () async{
                          //     FilePickerResult result = await FilePicker.platform.pickFiles(
                          //       // allowCompression: true,
                          //       // type: FileType.custom,
                          //       // allowedExtensions: ['jpg', 'png', 'heic'],
                          //     );
                          //     if(result != null) {
                          //       File file = File(result.files.single.path);
                          //       // if(file != null){
                          //       //    pubnub.files.sendFile(channelName, file, result.files.single.name, storeFileMessage: true);
                          //       // }
                          //     } else {
                          //       // User canceled the picker
                          //     }},),

                          IconButton(
                              icon: const Icon(Icons.attach_file_outlined),
                              onPressed:(){
                                // manager.emptyCache();
                                // _checkMemory();
                                FocusManager.instance.primaryFocus?.unfocus();
                                showAnimatedCustomDialog(context,
                                    title: "Error", message: "responseMap",
                                    statefulBuilder: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                      return Scaffold(
                                        backgroundColor: Colors.transparent,
                                        body: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Material(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(15.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Provider.of<UserProvider>(context, listen: false).userData.canShareDocs ?
                                                      InkWell(
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          messageNode.unfocus();
                                                          try{
                                                            FilePickerResult result = await FilePicker.platform.pickFiles();
                                                            if(result != null) {
                                                              if (await File(result.files.single.path).length() > 20000000) {
                                                                showToast("File size must be less than 20MB",icon: const Icon(Icons.clear,color: Colors.white,));
                                                              }
                                                              else{
                                                                setState(() {
                                                                  docFile = File(result.files.single.path);
                                                                  docFileName = result.names[0];
                                                                });
                                                                debugPrint("hey this is the file name ************ ${await docFile.length()}");
                                                              }
                                                            }
                                                          }catch (e) {
                                                            setState(() {
                                                              _pickImageError = e;
                                                            });
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.insert_drive_file, color: Theme.of(context).primaryColor,),
                                                              const SizedBox(width: 10.0,),
                                                              Text(
                                                                "Send a document",
                                                                style: TextStyle(
                                                                  color: Theme.of(context).primaryColor,
                                                                  fontSize: 19.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ) : const SizedBox(),

                                                      Provider.of<UserProvider>(context, listen: false).userData.canShareDocs ?
                                                      const Divider() : const SizedBox(),

                                                      InkWell(
                                                        onTap: ()async{
                                                          print('common widgets gallery');
                                                          Navigator.pop(context);
                                                          print("onGalleryImg");
                                                          try {
                                                            final pickedFile = await _picker.getImage(source: ImageSource.gallery,
                                                              // maxWidth: 800,
                                                              // maxHeight: 600,
                                                              imageQuality: 100,
                                                            );
                                                            if (pickedFile != null) {
                                                              setState(() {
                                                                _imageFile = pickedFile;
                                                                imgName = p.basename(pickedFile.path);
                                                                imgPath = pickedFile.path as String;
                                                              });
                                                            }
                                                          } catch (e) {
                                                            setState(() {
                                                              _pickImageError = e;
                                                            });
                                                          }

                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.photo, color: Theme.of(context).primaryColor,),
                                                              const SizedBox(width: 10.0,),
                                                              Text(
                                                                "Send a photo",
                                                                style: TextStyle(
                                                                  color: Theme.of(context).primaryColor,
                                                                  fontSize: 19.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      kIsWeb ? const SizedBox() : const Divider(),
                                                      kIsWeb ? const SizedBox() : InkWell(
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          messageNode.unfocus();
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                          try {
                                                            final pickedFile = await _picker.getImage(source: ImageSource.camera,
                                                              imageQuality: 100,
                                                              // maxHeight: 600,
                                                              // maxWidth: 800,
                                                            );
                                                            if (pickedFile != null) {
                                                              setState(() {
                                                                _imageFile = pickedFile;
                                                                imgName = p.basename(pickedFile.path);
                                                                imgPath = pickedFile.path as String;
                                                              });
                                                            }
                                                          } catch (e) {
                                                            setState(() {
                                                              _pickImageError = e;
                                                            });
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.camera_alt_rounded, color: Theme.of(context).primaryColor,),
                                                              const SizedBox(width: 10.0,),
                                                              Text(
                                                                "Take a photo",
                                                                style: TextStyle(
                                                                  color: Theme.of(context).primaryColor,
                                                                  fontSize: 19.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                InkWell(
                                                  onTap: () => Navigator.pop(context),
                                                  child: Material(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text("Cancel",
                                                              style: TextStyle(
                                                                color: Theme.of(context).primaryColor,
                                                                fontSize: 23.0,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                );
                                // FocusManager.instance.primaryFocus?.unfocus();
                                // showAttachImgBottomSheet(context: context,
                                //     isFromMessagingScreen: true,
                                //     onDocument: ()async{
                                //       messageNode.unfocus();
                                //       try{
                                //         FilePickerResult result = await FilePicker.platform.pickFiles();
                                //         if(result != null) {
                                //           if (await File(result.files.single.path).length() > 20000000) {
                                //             showToast("File size must be less than 20MB",icon: const Icon(Icons.clear,color: Colors.white,));
                                //           }
                                //           else{
                                //             setState(() {
                                //               docFile = File(result.files.single.path);
                                //               docFileName = result.names[0];
                                //             });
                                //             debugPrint("hey this is the file name ************ ${await docFile.length()}");
                                //           }
                                //         }
                                //       }catch (e) {
                                //         setState(() {
                                //           _pickImageError = e;
                                //         });
                                //       }
                                //     },
                                //     onCameraImg: ()async{
                                //       messageNode.unfocus();
                                //       FocusManager.instance.primaryFocus?.unfocus();
                                //       try {
                                //         final pickedFile = await _picker.getImage(source: ImageSource.camera,
                                //           imageQuality: 100,
                                //           // maxHeight: 600,
                                //           // maxWidth: 800,
                                //         );
                                //         if (pickedFile != null) {
                                //           setState(() {
                                //             _imageFile = pickedFile;
                                //             imgName = p.basename(pickedFile.path);
                                //             imgPath = pickedFile.path as String;
                                //           });
                                //         }
                                //       } catch (e) {
                                //         setState(() {
                                //           _pickImageError = e;
                                //         });
                                //       }
                                //     },
                                //     onGalleryImg: ()async{
                                //       try {
                                //         final pickedFile = await _picker.getImage(source: ImageSource.gallery,
                                //           // maxWidth: 800,
                                //           // maxHeight: 600,
                                //           imageQuality: 100,
                                //         );
                                //         if (pickedFile != null) {
                                //           setState(() {
                                //             _imageFile = pickedFile;
                                //             imgName = p.basename(pickedFile.path);
                                //             imgPath = pickedFile.path as String;
                                //           });
                                //         }
                                //       } catch (e) {
                                //         setState(() {
                                //           _pickImageError = e;
                                //         });
                                //       }
                                //     }
                                // );
                              }
                          )
                        ],

                        textBeforeImage: false,
                        dateFormat: DateFormat('yyyy-MMM-dd'),
                        timeFormat: DateFormat('HH:mm'),
                        showUserAvatar: false,
                        showAvatarForEveryMessage: false,
                        onPressAvatar: (ChatUser user) async{
                          if(user.avatar != null && user.uid != "UUID")
                            Navigator.pushNamed(context, OtherUserProfile.routName,
                                arguments: {
                                  "user_id": user.uid
                                  //channelDetails.channelUsers[channelName].firstWhere((myUser) => myUser.id == user.uid)
                                });
                        },
                        onLongPressAvatar: (ChatUser user) {
                          if(passedData["type"] != "announcement")
                            debugPrint("OnLongPressAvatar: ${user.name}");
                        },

                        inputDecoration: const InputDecoration.collapsed(hintText: "Add message here...",),
                        textController: _messageController,
                        inverted: false,
                        inputMaxLines: 3,
                        focusNode: messageNode,
                        // onTextChange: _imageFile == null ? null : (val){
                        //   if(_imageFile != null){
                        //     setState(() {
                        //       imageText = val;
                        //     });
                        //   }
                        // },
                        text: _imageFile != null && (_messageController.text == null || _messageController.text.isEmpty) ? imageText : passedData["articleUrl"]??null,
                        //_imageFile == null ? (_messageController.text == null || _messageController.text.isEmpty) ? null : _messageController.text : imageText,
                        width: media.width,
                        inputFooterBuilder: (){
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              _imageFile == null ? const SizedBox(): const Divider(thickness: 1.5,),
                              _imageFile == null ? const SizedBox():
                              _previewImage(width: media.width, height: 70.0),

                              _replyToMsg ? const Divider(thickness: 1.5,): const SizedBox(),
                              _replyToMsg ?
                              Stack(
                                children: [
                                  Container(
                                    height: 80.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      // border:  _imageFile == null ? null : Border(top: BorderSide(width: 1.1, color: Colors.grey)),
                                      // borderRadius:  _imageFile != null ? null : const BorderRadius.only(
                                      //   topRight: Radius.circular(10),
                                      //   topLeft: Radius.circular(10),
                                      // ),
                                      // boxShadow: _imageFile != null ? null :
                                      // [
                                      //   BoxShadow(
                                      //     color: Colors.grey.withOpacity(0.5),
                                      //     spreadRadius: 2,
                                      //     blurRadius: 2,
                                      //     offset: Offset(0, -4,), // changes position of shadow
                                      //   ),
                                      // ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: media.width,
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 1.0),
                                          decoration: BoxDecoration(
                                              color: Colors.black12,
                                              // borderRadius: BorderRadius.circular(10),
                                              border: Border(
                                                  left: BorderSide(color: msgToReplyTo.user.uid == _user.uid ? Colors.indigoAccent : Color(0xFFff9c01),width: 2.5)
                                              )
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 80.0,
                                                  width: msgToReplyTo.image != null ? media.width : media.width - 86,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(msgToReplyTo.user.uid == _user.uid ? "You" : msgToReplyTo.user.name.toString(),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(fontWeight: FontWeight.bold, color: msgToReplyTo.user.uid == _user.uid ? Colors.indigoAccent : const Color(0xFFff9c01), fontSize: 14.0),),
                                                      const SizedBox(height: 1.0,),
                                                      Linkify(
                                                        onOpen: (link) async {
                                                          if (await canLaunch(link.url)) {
                                                            await launch(link.url,
                                                                forceSafariVC: true,
                                                                forceWebView: true,
                                                                enableJavaScript: true);
                                                          }else{
                                                            debugPrint("Couldn't launch url");
                                                          }
                                                        },
                                                        linkStyle: msgToReplyTo.user.uid == _user.uid ? const TextStyle(color: Colors.white):null,
                                                        text:(msgToReplyTo.text == "" && msgToReplyTo.image != null) ?
                                                        "image" : msgToReplyTo.text, maxLines: 3, overflow: TextOverflow.ellipsis,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // msgToReplyTo.image != null ? Spacer():Container(),
                                              msgToReplyTo.image != null ? Padding(
                                                padding: const EdgeInsets.only(right:20.0, left: 5.0, top:5.0, bottom: 5.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  child: SizedBox(
                                                    height: 70.0,
                                                    width: 70.0,
                                                    child: FadeInImage.memoryNetwork(
                                                      fit: BoxFit.cover,
                                                      // imageCacheHeight: 200,
                                                      // imageCacheWidth: 200,
                                                      // width: 80,
                                                      // height: 80,
                                                      placeholder: kTransparentImage,
                                                      key: ValueKey('${msgToReplyTo.image}'),
                                                      image: '${msgToReplyTo.image}',
                                                      imageErrorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                        return InkWell(
                                                            onTap: (){
                                                              setState(() {
                                                                msgToReplyTo.image = msgToReplyTo.image.split('?r')[0] + '?r=' + DateTime.now().millisecondsSinceEpoch.toString();
                                                              });
                                                            },
                                                            child: Image.asset('images/error_reload.png',fit: BoxFit.cover, height: 120,)
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ):const SizedBox()
                                              // Spacer(),
                                              // Flexible(
                                              //   child: Align(
                                              //     alignment: Alignment.topRight,
                                              //     child: IconButton(icon: Icon(Icons.clear), onPressed: (){
                                              //       setState(() {
                                              //         _replyToMsg = false;
                                              //       });
                                              //     }),
                                              //   ),
                                              // )
                                            ],
                                          ),

                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 7,
                                    right: 12,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            _replyToMsg = false;
                                          });
                                          print("heeey testing if replying to msg $_replyToMsg %%%%%%%%%%%");
                                        },
                                        child: Container(decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white),child: Icon(Icons.cancel,color: Colors.black54,size: 18,)),),
                                    ),
                                  )
                                ],
                              ): const SizedBox(),

                            ],
                          );
                        },
                        inputToolbarPadding: const EdgeInsets.only(bottom: 5.0),
                        inputContainerStyle: const BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey)),
                        ),
                        // messageContainerPadding: const EdgeInsets.only(left: 0.0, right: 5.0),
                        inputTextStyle: const TextStyle(fontSize: 16.0),
                        user: _user,
                        readOnly: passedData["type"] == "announcement" /*|| docFile != null*/ ? true : false,
                        onSend: isInputDisabled ? null : _imageFile != null ? sendImageMessage : sendMessage,
                        messages: _chatMessages,
                        scrollToBottom: true,
                        scrollToBottomStyle: ScrollToBottomStyle(bottom: 78.0),
                        scrollController: _controller,
                      ),
                    ),


                    _viewChatImage == null ? Positioned(
                        bottom:0, child: Container(height: 0,)) :
                    Positioned(
                      top: 0.0,
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        height: media.height,
                        color: Colors.black87,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 7.0,),
                                  child: IconButton(icon: const Icon(Icons.clear, color: Colors.white, size: 30.0,),
                                      onPressed: (){
                                        setState(() {
                                          _viewChatImage = null;
                                        });
                                      }),
                                ),
                              ),
                              const SizedBox(height: 3.5,),
                              Container(
                                constraints: BoxConstraints(
                                    maxHeight: media.height * 0.65
                                ),
                                child: InteractiveViewer(
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12.0),
                                            child: Image.network(
                                              _viewChatImage,
                                              key: ValueKey('${_viewChatImage}'),
                                              loadingBuilder: (BuildContext context, Widget child,
                                                  ImageChunkEvent loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: SpinKitCubeGrid(color: Theme.of(context).primaryColor,size: 55,),
                                                );
                                              },
                                              errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                return InkWell(
                                                    onTap: (){
                                                      setState(() {
                                                        _viewChatImage = _viewChatImage.split('?r')[0] + '?r=' + DateTime.now().millisecondsSinceEpoch.toString();
                                                      });
                                                    },
                                                    child: Image.asset('images/errorImage.png', height: 200,)
                                                );
                                              },)),
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    docFile == null ? Positioned(
                        bottom:0, child: Container(height: 0,)) :
                    Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        left: 0.0,
                        child: _previewDocument(media: media)),
                  ],
                )),
          ],
        ),
      ),
    );
  }

}


// *************************************************** IMG picker related *********************************************************

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

/*class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  /*void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.isInitialized) {
      initialized = controller.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}*/

// *************************************************** IMG picker related *********************************************************