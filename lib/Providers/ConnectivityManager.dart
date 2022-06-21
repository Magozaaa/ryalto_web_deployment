import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class ConnectivityManager extends ChangeNotifier {


  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  ConnectivityResult get connectionStatus => this._connectionStatus;

  final Connectivity _connectivity = Connectivity();

   StreamSubscription<ConnectivityResult> _connectivitySubscription;
   StreamSubscription<ConnectivityResult> get connectivitySubscription => this._connectivitySubscription;


  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      debugPrint("result.index $result");
      subscribeConnectivityChanges();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    return _updateConnectionStatus(result);
  }

  cancelConnectivitySub(){
    _connectivitySubscription.cancel();
    debugPrint("Connectivity Sub is now cancelled !!");
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
      _connectionStatus = result;
      notifyListeners();
  }

  subscribeConnectivityChanges(){
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    print("_connectivitySubscription ${_connectivitySubscription.isPaused}");

  }

  test()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      debugPrint('I am connected to a mobile network.');
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      debugPrint('I am connected to a wifi network.');
      // I am connected to a wifi network.
    }
  }


}