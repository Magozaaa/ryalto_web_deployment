// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:rightnurse/Models/UserModel.dart';
// import 'package:rightnurse/Providers/NewsProvider.dart';
// import 'package:rightnurse/Providers/UserProvider.dart';
// import 'package:rightnurse/Screens/TwilioCallScreen.dart';
// import 'package:rightnurse/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:twilio_voice/twilio_voice.dart';
// import 'package:http/io_client.dart';
// import 'package:device_info/device_info.dart';
//
//
// class CallProvider extends ChangeNotifier with WidgetsBindingObserver {
//   final kTwilioTokenExpiryInterval = 60 * 60;
//   DateTime lastTwilioTokenUpdateTime = DateTime(2000); // initially very old, so will need a new one
//   String _twilioCallToken;
//   bool _hasPushedToCallScreen = false;
//   AppLifecycleState _state = AppLifecycleState.resumed;
//   User _currentCallFromUser;
//   User _currentCallToUser;
//   // bool _fetchingCallingUser = false;
//   ActiveCall _activeCall;
//   final TwilioVoice twilio = TwilioVoice.instance;
//
//   bool _speaker = false;
//   bool get speaker => this._speaker;
//   bool _mute = false;
//   bool get mute => this._mute;
//
//   void toggleMute(bool mute){
//     _mute = mute;
//     notifyListeners();
//   }
//
//   void toggleSpeaker(bool speaker){
//     _speaker = speaker;
//     notifyListeners();
//   }
//
//   // CallProvider() {
//   //   // start listening for state changes (only stop when app terminated)
//   //   // if(Platform.isIOS){
//   //   WidgetsBinding.instance.addObserver(this);
//   //   init();
//   //   // TwilioVoice.instance.setOnDeviceTokenChanged((token) {
//   //   //   _lastTwilioTokenUpdateTime = DateTime(2000);
//   //   //   debugPrint("TWILIO: token changed");
//   //   //   registerTwilioClient();
//   //   // });
//   //   //
//   //   // // on startup, must start waiting for a call (which checks if already on a call)
//   //   _waitForTwilioCall();
//   //
//   //   // }
//   // }
//   //
//   // void init() async {
//   //   await registerTwilioClient();
//   //   await registerAllUserNamesWithTwilio();
//   // }
//
//
//   User get currentCallFromUser => _currentCallFromUser;
//   User get currentCallToUser => _currentCallToUser;
//   ActiveCall get activeCall => _activeCall;
//
//
//   bool _isRingingNow = false;
//   bool get isRingingNow => this._isRingingNow;
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     this._state = state;
//     // if on an active call, go to call screen
//     if (state == AppLifecycleState.resumed) {
//       _checkActiveTwilioCall();
//     }
//   }
//
//
//   resetTwilioTokenUpdateTime(){
//     lastTwilioTokenUpdateTime = DateTime(2000);
//     notifyListeners();
//   }
//   // if user not logged-in on startup
//   // this must be called when logged-in (user id and name known)
//   Future<void> registerTwilioClient(BuildContext context,{id, name, myToken}) async {
//     WidgetsBinding.instance.addObserver(this);
//
//     final prefs = await SharedPreferences.getInstance();
//     var storedTwilioToken = prefs.getString("twilio_access_token");
//
//     print("the value for twilio token from sharedPrefs $storedTwilioToken");
//     TwilioVoice.instance.setDefaultCallerName('Ryalto User');
//     TwilioVoice.instance.registerClient(id, name);
//     // if(storedTwilioToken == null){
//       loadTwilioTokenIfRequired(token: myToken);
//       debugPrint('TWILIO: registered Twilio client');
//       // registerAllUserNamesWithTwilio();
//       waitForTwilioCall(context);
//
//     // }
//     // }
//   }
//
//   unRegisterFromTwilioCalls({userId}) async{
//     await TwilioVoice.instance.unregister(accessToken: _twilioCallToken);
//     notifyListeners();
//     // _twilioCallToken = null ;
//     // _lastTwilioTokenUpdateTime = DateTime(2000);
//     // _twilioCallToken = null;
//     //  _hasPushedToCallScreen = false;
//     //  _currentCallFromUser = null;
//     //  _currentCallToUser = null;
//     //  _fetchingCallingUser = false;
//     //  _activeCall = null;
//     // notifyListeners();
//   }
//
//    Future waitForTwilioCall(BuildContext context) async{
//     _checkActiveTwilioCall();
//
//     final twilioInstaince = TwilioVoice.instance.callEventsListener;
//     twilioInstaince
//       ..listen((event) async {
//
//         switch (event) {
//           case CallEvent.ringing:
//             // if (TwilioVoice.instance.call.activeCall != null) {
//           /// for some reason the call direction is always outgoing here !!!!!
//               print("ring ring ring ring !!!! ${TwilioVoice.instance.call.activeCall.callDirection} ");
//               clearCallCounter();
//               setInACallValue(true);
//
//               this._isRingingNow = true;
//               _activeCall = TwilioVoice.instance.call.activeCall;
//
//                 await getCallerFromId(context,callerId: TwilioVoice.instance.call.activeCall.from);
//                 debugPrint("from id should have a value of ${TwilioVoice.instance.call.activeCall.from} ");
//             break;
//
//           case CallEvent.connected:
//             if (Platform.isAndroid && TwilioVoice.instance.call.activeCall.callDirection == CallDirection.incoming) {
//               if (_state != AppLifecycleState.resumed) {
//                 TwilioVoice.instance.showBackgroundCallUI();
//                 notifyListeners();
//               }
//               else if (_state == null || _state == AppLifecycleState.resumed) {
//                 initialiseActiveCallCounter();
//                 setInACallValue(true);
//                 pushToTwilioCallScreen();
//               }
//             }
//             notifyListeners();
//             break;
//
//           case CallEvent.answer:
//           // at this point android is still paused
//             if (Platform.isIOS && _state == null || _state == AppLifecycleState.resumed) {
//               initialiseActiveCallCounter();
//               setInACallValue(true);
//               pushToTwilioCallScreen();
//             }
//
//             break;
//
//
//
//           case CallEvent.callEnded:
//             _activeCall = null;
//             _currentCallToUser = null;
//             _currentCallFromUser = null;
//             _hasPushedToCallScreen = false;
//             toggleSpeaker(false);
//             toggleMute(false);
//             setInACallValue(false);
//             this._isInACall = false;
//             clearCallCounter();
//             Navigator.of(context).pop();
//             notifyListeners();
//             print("call stateeeeee $_state");
//             // below code is added to handle call when screen is locked for not floating on the lock screen
//             // after making a call Twillio Call screen floats on the lock screen
//             //  if (Platform.isAndroid){
//             //    SystemNavigator.pop();
//             //  }
//             break;
//           // case CallEvent.returningCall:
//           //   _pushToTwilioCallScreen();
//           //   break;
//           case CallEvent.mute:
//             toggleMute(true);
//             break;
//           case CallEvent.unmute:
//             toggleMute(false);
//             break;
//           case CallEvent.speakerOn:
//             toggleSpeaker(true);
//             break;
//           case CallEvent.speakerOff:
//             toggleSpeaker(false);
//
//             break;
//           default:
//             break;
//         }
//       });
//   }
//
//   Future<void> registerAllUserNamesWithTwilio() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedUser = prefs.getString("user");
//     // TODO: NOTE: this must be called after a use has signed in
//     // no user has yet signed in, so this function MUST be call when the user has signed in (ie the token is known)
//     if (storedUser != null) {
//       final String token = jsonDecode(storedUser)['token'];
//
//       var headers = {
//         'Platform': MyApp.platformIndex,
//         'Right-Nurse-Version': Domain.appVersion,
//         'Accept': 'application/vnd.right_nurse; version=1',
//         'Content-Type': 'application/json',
//         'Authorization': 'Token token=$token'
//       };
//
//       try {
//         final String url = '$appDomain/doctor?limit=1000&offset=0';
//
//         debugPrint('api call $url');
//         final ioc = new HttpClient();
//         ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//         final httpp = new IOClient(ioc);
//
//         http.Response response = await httpp.get(url, headers: headers);
//
//         if (response.statusCode == 200) {
//           final responseString = response.body;
//           final responseJson = jsonDecode(responseString);
//           print(responseJson);
//         }
//       } catch (e) {
//         print(e);
//       }
//     }
//   }
//
//   Future<void> loadTwilioTokenIfRequired({@required String token}) async {
//     // check if older that 1 hour...
//     final dateNow = DateTime.now();
//     final difference = dateNow.difference(lastTwilioTokenUpdateTime);
//     print(difference);
//
//     final tokenExpired = (difference.inSeconds > kTwilioTokenExpiryInterval);
//     final prefs = await SharedPreferences.getInstance();
//     String savedTwilioToken = prefs.getString("twilio_access_token");
//     // const eventStream = const EventChannel('ryalto.com/streamApnsTokenChange');
//     // StreamSubscription<dynamic> tokenChangedStream;
//     final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//
//     // if (savedTwilioToken == null || savedTwilioToken.isEmpty || tokenExpired) {
//       // if yes, make new request to get a token
//       var headers = {
//         'Platform': MyApp.platformIndex,
//         'Right-Nurse-Version': Domain.appVersion,
//         'Accept': 'application/vnd.right_nurse; version=1',
//         'Content-Type': 'application/json',
//         'Authorization': 'Token token=$token'
//       };
//
//       try {
//         final String url = '$appDomain/twilio/generate_access_token';
//
//         debugPrint('api call $url');
//         final ioc = new HttpClient();
//         ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//         final httpp = new IOClient(ioc);
//         http.Response response = await httpp.post(url, headers: headers);
//
//         if (response.statusCode == 200) {
//           final responseString = response.body;
//           final responseJson = jsonDecode(responseString);
//           _twilioCallToken = responseJson['token'];
//           debugPrint('TWILIO: twilioCallToken: $responseString');
//
//           debugPrint("Twilio access token has been updated successfully !!!!");
//
//           prefs.setString('twilio_access_token', responseJson['token']);
//           // prefs.getString("twilio_access_token");
//
//           if (Platform.isIOS) {
//             String deviceToken = '';
//             final platform = const MethodChannel('ryalto.com/getApnsToken');
//             String result = await platform.invokeMethod('getApnsTokenValue');
//             deviceToken = result;
//
//             TwilioVoice.instance.setTokens(accessToken: _twilioCallToken, deviceToken: deviceToken);
//             lastTwilioTokenUpdateTime = DateTime.now();
//           }
//           if(Platform.isAndroid){
//             _firebaseMessaging.getToken().then((String token) {
//               print('call token ${_twilioCallToken}');
//               TwilioVoice.instance.setTokens(accessToken: _twilioCallToken, deviceToken: token);
//               lastTwilioTokenUpdateTime = DateTime.now();
//             });
//           }
//
//         }
//
//       } catch (e) {
//         print(e);
//       }
//
//     // }
//     debugPrint("Load twilio access token called");
//     notifyListeners();
//
//   }
//
//   String _activeCallCounter = '00:00:00';
//   String get activeCallCounter =>this._activeCallCounter;
//   Timer showConnectionTime;
//
//   bool _isInACall = false;
//   bool get isInACall => this._isInACall;
//
//   setInACallValue(bool isInACall){
//     _isInACall = isInACall;
//     notifyListeners();
//   }
//
//
//   String getDurationAsHoursMinsSec(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }
//
//   clearCallCounter(){
//     _activeCallCounter = '00:00:00';
//     if (showConnectionTime!=null) {
//       showConnectionTime.cancel();
//       showConnectionTime = null;
//
//     }
//     notifyListeners();
//   }
//
//
//
//   void initialiseActiveCallCounter() {
//     Timer(Duration(milliseconds: 500), () {
//         DateTime callStartTime = DateTime.now();
//         showConnectionTime = Timer.periodic(Duration(milliseconds: 500), (timer) {
//             final timeDiff = DateTime.now().difference(callStartTime);
//             _activeCallCounter = getDurationAsHoursMinsSec(timeDiff);
//         });
//     });
//     notifyListeners();
//   }
//
//
//   void pushToTwilioCallScreen() {
//     if (!_hasPushedToCallScreen) {
//       _hasPushedToCallScreen = true;
//       kGlobalNavigatorKey.currentState.push(MaterialPageRoute(builder: (context)=>TwilioCallScreen()));
//     }
//     notifyListeners();
//   }
//
//
//
//
//   // this method need to be checked for Android
//   void _checkActiveTwilioCall() async {
//     final isOnCall = await TwilioVoice.instance.call.isOnCall();
//     debugPrint("_checkActiveTwilioCall $isOnCall");
//     if (isOnCall && !_hasPushedToCallScreen &&
//         TwilioVoice.instance.call.activeCall.callDirection == CallDirection.incoming) {
//       print("user is on call");
//       pushToTwilioCallScreen();
//       _hasPushedToCallScreen = true;
//     }
//     notifyListeners();
//   }
//
//   Future<void> initiateTwilioCall({@required User callToUser}) async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedUser = prefs.getString("user");
//     final name = jsonDecode(storedUser)['name'];
//     final String id = jsonDecode(storedUser)['id'];
//
//     _currentCallToUser = callToUser;
//     print("calling user ${_currentCallToUser.name} caller is $name");
//     // if(Platform.isAndroid){
//     //   TwilioVoice.instance.call.place(to: _currentCallToUser.id, from: id).then((value) {
//     //     print('call value $value');
//     //   });
//     //   _pushToTwilioCallScreen();
//     // }else{
//       // check have mic access
//     // clearCallCounter();
//     // initialiseActiveCallCounter();
//     setInACallValue(true);
//
//     if (!await (TwilioVoice.instance.hasMicAccess())) {
//         debugPrint("requesting mic access");
//         await TwilioVoice.instance.requestMicAccess().then((value) {
//           debugPrint('TWILIO: starting call to \"${_currentCallToUser.name}\", id ${_currentCallToUser.id}, from \"$name\", id $id');
//           TwilioVoice.instance.call.place(to: _currentCallToUser.id.replaceAll("_", "-"), from: id.replaceAll("_", "-")).then((value) {
//             debugPrint('call value $value');
//           });
//           pushToTwilioCallScreen();
//         });
//       }
//       else{
//         debugPrint("already have mic access");
//         await TwilioVoice.instance.requestMicAccess().then((value) {
//           debugPrint('TWILIO: starting call to \"${_currentCallToUser.name}\", id ${_currentCallToUser.id}, from \"$name\", id $id');
//           TwilioVoice.instance.call.place(to: _currentCallToUser.id.replaceAll("_", "-"), from: id.replaceAll("_", "-")).then((value) {
//             debugPrint('call value $value');
//           });
//           pushToTwilioCallScreen();
//         });
//       }
//
//     // }
//
//   }
//
//   Future<void> getCallerFromId(BuildContext context,{@required String callerId}) async {
//
//     // if(_fetchingCallingUser){
//     //   return;
//     // }
//     // _fetchingCallingUser = true;
//     String callerIdWithRightFormat = callerId.replaceAll("_", "-");
//
//     try {
//     if(callerId != null){
//       await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: callerIdWithRightFormat).then((user){
//         if(user != null){
//           _currentCallFromUser = user as User;
//           TwilioVoice.instance.registerClient(user.id, user.name);
//           debugPrint("hey ${user.name} is calling you !!!");
//           // TwilioVoice.instance.setDefaultCallerName(user.name);
//         }else{
//           debugPrint("current user is null");
//         }
//         // _fetchingCallingUser = false;
//         notifyListeners();
//       });
//     }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//
//   }
// }

// ignore_for_file: file_names, avoid_single_cascade_in_expression_statements

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/TwilioCallScreen.dart';
import 'package:rightnurse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:http/io_client.dart';
import 'package:device_info/device_info.dart';
import 'package:wakelock/wakelock.dart';
// import 'package:get/get.dart';


class CallProvider extends ChangeNotifier with WidgetsBindingObserver {
  final kTwilioTokenExpiryInterval = 60 * 60;
  DateTime lastTwilioTokenUpdateTime = DateTime(2000); // initially very old, so will need a new one
  String _twilioCallToken;
  bool hasPushedToCallScreen = false;
  AppLifecycleState _state = AppLifecycleState.resumed;
  User _currentCallFromUser;
  User _currentCallToUser;
  // bool _fetchingCallingUser = false;
  ActiveCall _activeCall;
  String _callerId;
  final TwilioVoice twilio = TwilioVoice.instance;


  setAppState(state){
    this._state = state;
    notifyListeners();
  }

  String get callerId => _callerId;

  setCallerId(String id){
     _callerId = id.replaceAll("_", "-");
    notifyListeners();
  }
  // CallProvider() {
  //   // start listening for state changes (only stop when app terminated)
  //   // if(Platform.isIOS){
  //   WidgetsBinding.instance.addObserver(this);
  //   init();
  //   // TwilioVoice.instance.setOnDeviceTokenChanged((token) {
  //   //   _lastTwilioTokenUpdateTime = DateTime(2000);
  //   //   debugPrint("TWILIO: token changed");
  //   //   registerTwilioClient();
  //   // });
  //   //
  //   // // on startup, must start waiting for a call (which checks if already on a call)
  //   _waitForTwilioCall();
  //
  //   // }
  // }
  //
  // void init() async {
  //   await registerTwilioClient();
  //   await registerAllUserNamesWithTwilio();
  // }

  /// new code for handling TwilioCallScreen ** moving all functionality from Screen **
  bool _mute = false;
  bool get mute => this._mute;

  toggleMute(bool status){
    _mute = status;
    notifyListeners();
  }

  bool _speaker = false;
  bool get speaker => this._speaker;

  toggleSpeaker(bool status){
    _speaker = status;
    notifyListeners();
  }

  bool _isInCall = false;
  bool get isInCall => this._isInCall;

  callStatus(bool status){
    _isInCall = status;
    notifyListeners();
  }

  StreamSubscription<CallEvent> callStateListener;



  void cancelListeningToCall(){
    if (callStateListener != null) {
      callStateListener.cancel();
    }
    // notifyListeners();
  }


  Timer showConnectionTime;
  DateTime callStartTime;
  String _connectedTimeString = '00:00:00';
  String get connectedTimeString => this._connectedTimeString;

  String getDurationAsHoursMinsSec(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void initialiseTimer() {
    Timer(const Duration(milliseconds: 500), () {
        callStartTime = DateTime.now();
        showConnectionTime = Timer.periodic(const Duration(milliseconds: 500), (timer) {
            final timeDiff = DateTime.now().difference(callStartTime);
            _connectedTimeString = getDurationAsHoursMinsSec(timeDiff);
            print("$_connectedTimeString");
            notifyListeners();
        });
    });
    notifyListeners();
  }

  void cancelTimer(){
    showConnectionTime?.cancel();
  }


  User get currentCallFromUser => _currentCallFromUser;
  User get currentCallToUser => _currentCallToUser;
  ActiveCall get activeCall => _activeCall;


  bool _isRingingNow = false;
  bool get isRingingNow => this._isRingingNow;

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   this._state = state;
  //   // if on an active call, go to call screen
  //   if (state == AppLifecycleState.resumed) {
  //     checkActiveTwilioCall();
  //   }
  // }


  resetTwilioTokenUpdateTime(){
    lastTwilioTokenUpdateTime = DateTime(2000);
    notifyListeners();
  }
  // if user not logged-in on startup
  // this must be called when logged-in (user id and name known)
  Future<void> registerTwilioClient(BuildContext context,{id, name, myToken}) async {
    WidgetsBinding.instance.addObserver(this);

    final prefs = await SharedPreferences.getInstance();
    var storedTwilioToken = prefs.getString("twilio_access_token");

    debugPrint("the value for twilio token from sharedPrefs $storedTwilioToken");
    TwilioVoice.instance.setDefaultCallerName('Ryalto User');
    TwilioVoice.instance.registerClient(id, name);
    if (!kIsWeb) {
      if(Platform.isAndroid){
        TwilioVoice.instance.requestBackgroundPermissions();
      }
      loadTwilioTokenIfRequired(token: myToken);
      debugPrint('TWILIO: registered Twilio client');
      // registerAllUserNamesWithTwilio();
      _waitForTwilioCall(context);
    }
    // if(storedTwilioToken == null){
    // loadTwilioTokenIfRequired(token: myToken);
    // debugPrint('TWILIO: registered Twilio client');
    // // registerAllUserNamesWithTwilio();
    // _waitForTwilioCall(context);

    // }
    // }
  }

  unRegisterFromTwilioCalls({userId}) async{
   await TwilioVoice.instance.unregisterClient(userId);
    await TwilioVoice.instance.unregister(accessToken: _twilioCallToken);
    notifyListeners();
    // _twilioCallToken = null ;
    // _lastTwilioTokenUpdateTime = DateTime(2000);
    // _twilioCallToken = null;
    //  _hasPushedToCallScreen = false;
    //  _currentCallFromUser = null;
    //  _currentCallToUser = null;
    //  _fetchingCallingUser = false;
    //  _activeCall = null;
    // notifyListeners();
  }


  void listenCall(context) {
    callStateListener = TwilioVoice.instance.callEventsListener.listen((event) {

      switch (event) {
        case CallEvent.callEnded:
          callStatus(false);
          _speaker = false;
          _mute = false;
          _connectedTimeString = '00:00:00';
          Wakelock.disable();
          cancelTimer();
          notifyListeners();
          Navigator.of(context).pop();
          break;
        case CallEvent.mute:
          toggleMute(true);
          break;

        case CallEvent.unmute:
          toggleMute(false);
          break;

        case CallEvent.speakerOn:
          toggleSpeaker(true);
          break;
        case CallEvent.connected:
        // initialiseTimer();
        // this code is to enable speaker for iOS as it doesn't get turned on if user
        // has enabled it as soon as they made the call
          callStatus(true);
          if(!kIsWeb){
            if(Platform.isIOS){
              // toggleSpeaker(true);
              TwilioVoice.instance.call.toggleSpeaker(speaker);
            }
          }
          break;
        case CallEvent.speakerOff:
          toggleSpeaker(false);
          // setState(() {
          //   speaker = false;
          // });
          break;
        case CallEvent.ringing:
        // this code is to enable speaker for iOS as it doesn't get turned on if user
        // has enabled it as soon as they made the call
          if(!kIsWeb){
            if (Platform.isIOS) {
              TwilioVoice.instance.call.toggleSpeaker(speaker);
            }
          }
          break;

        case CallEvent.answer:
          callStatus(true);
          Wakelock.enable();
          // setState(() {});
          break;

        case CallEvent.log:
          break;
        case CallEvent.hold:
        case CallEvent.unhold:
          break;
        default:
          break;
      }
    });
    // notifyListeners();
  }



  _waitForTwilioCall(BuildContext context) async{
    // checkActiveTwilioCall();

    final twilioInstaince = TwilioVoice.instance.callEventsListener;
    twilioInstaince
      ..listen((event) async {

        switch (event) {
          case CallEvent.ringing:
          // if (TwilioVoice.instance.call.activeCall != null) {
          /// for some reason the call direction is always outgoing here !!!!!
            debugPrint("ring ring ring ring !!!! ${TwilioVoice.instance.call.activeCall.callDirection} ");

            this._isRingingNow = true;
            _activeCall = TwilioVoice.instance.call.activeCall;

            await getCallerFromId(context,callerId: TwilioVoice.instance.call.activeCall.from);
            debugPrint("from id should have a value of ${TwilioVoice.instance.call.activeCall.from} ");
            _callerId = TwilioVoice.instance.call.activeCall.from.replaceAll("_", "-");
            notifyListeners();
            break;

          case CallEvent.connected:
            initialiseTimer();
            _callerId = TwilioVoice.instance.call.activeCall.from.replaceAll("_", "-");
            Wakelock.enable();
            if(!kIsWeb){
              if (Platform.isAndroid) {
                if (_state != AppLifecycleState.resumed) {
                  // TwilioVoice.instance.showBackgroundCallUI();
                  _pushToTwilioCallScreen(context);
                  notifyListeners();
                }
                else
                if (_state == null || _state == AppLifecycleState.resumed) {
                  _pushToTwilioCallScreen(context);
                }
              }
            }
            callStatus(true);
            notifyListeners();
            break;

          case CallEvent.answer:
            // initialiseTimer();
            _callerId = TwilioVoice.instance.call.activeCall.from.replaceAll("_", "-");
            Wakelock.enable();
          // at this point android is still paused
            if(!kIsWeb){
              if (Platform.isIOS && (_state == null || _state == AppLifecycleState.resumed)) {
                _pushToTwilioCallScreen(context);
              }
            }
            callStatus(true);
            notifyListeners();
            break;



          case CallEvent.callEnded:
            _activeCall = null;
            _currentCallToUser = null;
            _currentCallFromUser = null;
            hasPushedToCallScreen = false;
            _isRingingNow = false;
            TwilioVoice.instance.call.toggleMute(false);
            TwilioVoice.instance.call.toggleSpeaker(false);
            _mute = false;
            _speaker = false;
            Wakelock.disable();
            callStatus(false);
            _connectedTimeString = '00:00:00';
            cancelTimer();
            notifyListeners();
            debugPrint("call stateeeeee $_state");
            // below code is added to handle call when screen is locked for not floating on the lock screen
            // after making a call Twillio Call screen floats on the lock screen
            //  if (Platform.isAndroid){
            //    SystemNavigator.pop();
            //  }
            break;
        // case CallEvent.returningCall:
        //   _pushToTwilioCallScreen();
        //   break;
          default:
            break;
        }
      });
  }

  Future<void> registerAllUserNamesWithTwilio() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    // TODO: NOTE: this must be called after a use has signed in
    // no user has yet signed in, so this function MUST be call when the user has signed in (ie the token is known)
    if (storedUser != null) {
      final String token = jsonDecode(storedUser)['token'];

      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=1',
        'Content-Type': 'application/json',
        'Authorization': 'Token token=$token'
      };

      try {
        final String url = '$appDomain/doctor?limit=1000&offset=0';

        debugPrint('api call $url');
        final ioc = new HttpClient();
        ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        final httpp = new IOClient(ioc);

        http.Response response = await httpp.get(url, headers: headers);

        if (response.statusCode == 200) {
          final responseString = response.body;
          final responseJson = jsonDecode(responseString);
          print(responseJson);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> loadTwilioTokenIfRequired({@required String token}) async {
    // check if older that 1 hour...
    final dateNow = DateTime.now();
    final difference = dateNow.difference(lastTwilioTokenUpdateTime);
    print(difference);

    final tokenExpired = (difference.inSeconds > kTwilioTokenExpiryInterval);
    final prefs = await SharedPreferences.getInstance();
    String savedTwilioToken = prefs.getString("twilio_access_token");
    // const eventStream = const EventChannel('ryalto.com/streamApnsTokenChange');
    // StreamSubscription<dynamic> tokenChangedStream;
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


    // if (savedTwilioToken == null || savedTwilioToken.isEmpty || tokenExpired) {
    // if yes, make new request to get a token
    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    try {
      final String url = '$appDomain/twilio/generate_access_token';

      debugPrint('api call $url');
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      // http.Response response = await httpp.post(url, headers: headers);
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint('api call $responseString');

      if (response.statusCode == 200) {
        // final responseString = response.body;
        final responseJson = jsonDecode(responseString);
        _twilioCallToken = responseJson['token'];
        debugPrint('TWILIO: twilioCallToken: $responseString');

        debugPrint("Twilio access token has been updated successfully !!!!");

        prefs.setString('twilio_access_token', responseJson['token']);
        // prefs.getString("twilio_access_token");

        if (!kIsWeb) {
          if (Platform.isIOS) {
            String deviceToken = '';
            final platform = const MethodChannel('ryalto.com/getApnsToken');
            String result = await platform.invokeMethod('getApnsTokenValue');
            deviceToken = result;

            TwilioVoice.instance.setTokens(accessToken: _twilioCallToken, deviceToken: deviceToken);
            lastTwilioTokenUpdateTime = DateTime.now();
          }
          if(Platform.isAndroid){
            _firebaseMessaging.getToken().then((String token) {
              print('call token ${_twilioCallToken}');
              TwilioVoice.instance.setTokens(accessToken: _twilioCallToken, deviceToken: token);
              lastTwilioTokenUpdateTime = DateTime.now();
            });
          }
        }

      }

    } catch (e) {
      debugPrint("$e");
    }

    // }
    debugPrint("Load twilio access token called");
    notifyListeners();

  }

  void _pushToTwilioCallScreen(BuildContext context) {
    if (!hasPushedToCallScreen) {
      hasPushedToCallScreen = true;
      // _callerId =  TwilioVoice.instance.call.activeCall.from.replaceAll("_", "-");
      // Get.key
      // Get.to(TwilioCallScreen());
      Navigator.pushNamed(context, TwilioCallScreen.routeName);
      // MyApp.kGlobalNavigatorKey.currentState.push(MaterialPageRoute(builder: (context)=>TwilioCallScreen()));
    }
    notifyListeners();
  }


  // this method need to be checked for Android
  void checkActiveTwilioCall(BuildContext context) async {
    final isOnCall = await TwilioVoice.instance.call.isOnCall();
    debugPrint("_checkActiveTwilioCall $isOnCall");
    if (isOnCall && !hasPushedToCallScreen) {
      _pushToTwilioCallScreen(context);
      hasPushedToCallScreen = true;
    }
    notifyListeners();
  }

  Future<void> initiateTwilioCall(BuildContext context, {@required User callToUser}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final name = jsonDecode(storedUser)['name'];
    final String id = jsonDecode(storedUser)['id'];

    _currentCallToUser = callToUser;
    // if(Platform.isAndroid){
    //   TwilioVoice.instance.call.place(to: _currentCallToUser.id, from: id).then((value) {
    //     print('call value $value');
    //   });
    //   _pushToTwilioCallScreen();
    // }else{
    // check have mic access
    if (!await (TwilioVoice.instance.hasMicAccess())) {
      debugPrint("requesting mic access");
      await TwilioVoice.instance.requestMicAccess().then((value) {
        debugPrint('TWILIO: starting call to \"${_currentCallToUser.name}\", id ${_currentCallToUser.id}, from \"$name\", id $id');
        TwilioVoice.instance.call.place(to: _currentCallToUser.id.replaceAll("_", "-"), from: id.replaceAll("_", "-")).then((value) {
          debugPrint('call value $value');
        });
        _pushToTwilioCallScreen(context);
      });
    }
    else{
      debugPrint("already have mic access");
      await TwilioVoice.instance.requestMicAccess().then((value) {
        debugPrint('TWILIO: starting call to \"${_currentCallToUser.name}\", id ${_currentCallToUser.id}, from \"$name\", id $id');
        TwilioVoice.instance.call.place(to: _currentCallToUser.id.replaceAll("_", "-"), from: id.replaceAll("_", "-")).then((value) {
          debugPrint('call value $value');
        });
        _pushToTwilioCallScreen(context);
      });
    }
    // }

  }

  Future<void> getCallerFromId(BuildContext context,{@required String callerId,}) async {

    // if(_fetchingCallingUser){
    //   return;
    // }
    // _fetchingCallingUser = true;
    String callerIdWithRightFormat = callerId.replaceAll("_", "-");

    try {
      if(callerId != null){
         Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: callerIdWithRightFormat).then((user){
          if(user != null){
            _currentCallFromUser = user as User;
            TwilioVoice.instance.registerClient(user.id, user.name);
            debugPrint("hey ${user.name} is calling you !!!");
            // TwilioVoice.instance.setDefaultCallerName(user.name);
          }
          // else{
          //   debugPrint("current user is null");
          //   _currentCallFromUser = Provider.of<UserProvider>(context, listen: false).userData;
          // }
          // _fetchingCallingUser = false;

        });
      }
        // else{
      //   _currentCallFromUser = Provider.of<UserProvider>(context, listen: false).userData;
      // }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }
}