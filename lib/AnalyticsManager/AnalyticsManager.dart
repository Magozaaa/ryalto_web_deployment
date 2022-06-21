import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AnalyticsManager {


  static FirebaseAnalytics analyticsProvider = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analyticsProvider);

  static String currentEventName = '';
  static Map<String,dynamic> currentEventParameters = {};

  static FirebaseOptions analyticsInitialization(){
    return const FirebaseOptions(
      appId: '1:622102173692:ios:d5e51ebefb017732',
      apiKey: 'AIzaSyDB0IUFD1lMe2P6fsCvr50rAz-Mkrc3tuQ',
      projectId: 'right-nurse',
      messagingSenderId: '622102173692',
      // iosBundleId: 'com.ryaltoapp.rightnurse',
      // iosClientId:
      // '448618578101-28tsenal97nceuij1msj7iuqinv48t02.apps.googleusercontent.com',
      // androidClientId:
      // '448618578101-a9p7bj5jlakabp22fo3cbkj7nsmag24e.apps.googleusercontent.com',
      // databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
      // storageBucket: 'react-native-firebase-testing.appspot.com',
    );
  }

  static Future identifyUserId(String userId)async{
    debugPrint("identifyUserId to analytics*********** $userId");
    analyticsProvider.setUserId(userId);
  }

  // static Future addUserToken(String userToken)async{
  //   debugPrint("identifyUserToken to analytics*********** $userToken");
  //   await analyticsProvider.add(userId);
  // }

  static void track(name, {parameters}) async {
    currentEventName = name;
    currentEventParameters = parameters;
    await analyticsProvider.logEvent(name: currentEventName, parameters: currentEventParameters).then((_){
      debugPrint("tracking sent to analytics*********** $name");
      // debugPrint("parameters sent to analytics*********** $parameters");
    });

  }


  static void clearAnalytics(){
    currentEventParameters.clear();
    currentEventName = '';
  }
}