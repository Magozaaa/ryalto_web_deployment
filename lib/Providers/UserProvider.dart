// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Helper/StorageManager.dart';
import 'package:rightnurse/Models/AvailablePositionModel.dart';
import 'package:rightnurse/Models/BandModel.dart';
import 'package:rightnurse/Models/HospitalModel.dart';
import 'package:rightnurse/Models/LanguageModel.dart';
import 'package:rightnurse/Models/MembershipModel.dart';
import 'package:rightnurse/Models/SkillModel.dart';
import 'package:rightnurse/Models/SurveyModel.dart';
import 'package:rightnurse/Models/TrustModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Models/UserTypeModel.dart';
import 'package:rightnurse/Models/countryModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/NotificationsProvider.dart';
import 'package:rightnurse/Providers/changeIndexPage.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/Subscreens/CompleteProfileCongrates.dart';
import 'package:rightnurse/Subscreens/LandingPage.dart';
import 'package:rightnurse/Subscreens/LoginScreen.dart';
import 'package:rightnurse/Subscreens/Profile/EditProfile.dart';
import 'package:http/io_client.dart';
import 'package:rightnurse/Subscreens/Profile/MyAccountScreen.dart';
import 'package:rightnurse/Subscreens/SettingsScreen.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'DiscoveryProvider.dart';
import 'package:universal_io/io.dart' as universal;

enum UsersStage { ERROR, LOADING, DONE, NONE }

class UserProvider extends ChangeNotifier {
  String errorMessage = 'Network Error !';

  UsersStage stage = UsersStage.NONE;
  UsersStage trustsStage;
  UsersStage hospitalsStage;
  UsersStage userTypesStage;
  UsersStage countriesStage;
  UsersStage specialitiesStage;
  UsersStage membershipsStage;
  UsersStage competenciesStage;
  UsersStage wardsStage;

  // ********************************************************_ User UI Code _*************************************************************

  String _currentAppBackground = 'images/chatBackground.png';
  String get currentAppBackground => this._currentAppBackground;

  bool _isCurrentAppBackgroundSetToDefault;
  bool get isCurrentAppBackgroundSetToDefault => this._isCurrentAppBackgroundSetToDefault;


  setCurrentAppBackground(String appBackground)async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("appBackground" , appBackground);

    _currentAppBackground = appBackground;
    _isCurrentAppBackgroundSetToDefault = !_isCurrentAppBackgroundSetToDefault;
    notifyListeners();
  }

  checkIfCurrentUserIsFromKarma()async{
    final prefs = await SharedPreferences.getInstance();
    final String storedAppBackground = prefs.getString("appBackground");

    if(storedAppBackground != null){
      setCurrentAppBackground(storedAppBackground);
      if(storedAppBackground == "images/karmaSanctum.png"){
        _isCurrentAppBackgroundSetToDefault = false;
      }
      else{
        _isCurrentAppBackgroundSetToDefault = true;
      }
    }
    if (storedAppBackground == null && userData != null) {
      if(userData.trust['id'].toString() == "055eb500-09c7-4574-b957-e7dbc278d993"){
        setCurrentAppBackground("images/karmaSanctum.png");
        _isCurrentAppBackgroundSetToDefault = false;
      }else{
        setCurrentAppBackground("images/chatBackground.png");
        _isCurrentAppBackgroundSetToDefault = true;
      }
    }
    notifyListeners();
  }

  bool _copyDeviceFontSize = false;
  bool get copyDeviceFontSize => this._copyDeviceFontSize;

  changeFontSize(bool isCopyFontSizeFromDevice) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isCopyFontSizeFromDevice", isCopyFontSizeFromDevice);
    _copyDeviceFontSize = isCopyFontSizeFromDevice;
    notifyListeners();
  }

  checkDeviceFontSize() async{
    final prefs = await SharedPreferences.getInstance();
    bool storedFontSize = prefs.getBool("isCopyFontSizeFromDevice");
    if(storedFontSize != null){
      changeFontSize(storedFontSize);
    }
  }

  // *************************************************************************************************************************************

  List<String> _skillsIdsForCompletingProfile = [];
  List<String> get skillsIdsForCompletingProfile =>
      this._skillsIdsForCompletingProfile;

  setSkillsForCompletingProfile(List<String> skillsIds) {
    _skillsIdsForCompletingProfile = skillsIds;
    notifyListeners();
  }

  clearSkillsForCompletingProfile() {
    _skillsIdsForCompletingProfile.clear();
    notifyListeners();
  }

  List<String> _languagesIdsForCompletingProfile = [];
  List<String> get languagesIdsForCompletingProfile =>
      this._languagesIdsForCompletingProfile;

  setLanguagesForCompletingProfile(List<String> languagesIds) {
    _languagesIdsForCompletingProfile = languagesIds;
    notifyListeners();
  }

  clearLanguagesForCompletingProfile() {
    _languagesIdsForCompletingProfile.clear();
    notifyListeners();
  }

  List<String> _rolesIdsForCompletingProfile = [];
  List<String> get rolesIdsForCompletingProfile =>
      this._rolesIdsForCompletingProfile;

  setRolesForCompletingProfile(List<String> rolesIds) {
    _rolesIdsForCompletingProfile = rolesIds;
    notifyListeners();
  }

  Level _levelForCompletingProfile;
  Level get levelForCompletingProfile => this._levelForCompletingProfile;

  setLevelForCompletingProfile(Level level) {
    _levelForCompletingProfile = level;
    notifyListeners();
  }

  Level _minAcceptedLevelForCompletingProfile;
  Level get minAcceptedLevelForCompletingProfile =>
      this._minAcceptedLevelForCompletingProfile;

  setMinAcceptedLevelForCompletingProfile(Level minLevel) {
    _minAcceptedLevelForCompletingProfile = minLevel;
    notifyListeners();
  }

  clearRolesForCompletingProfile() {
    _rolesIdsForCompletingProfile.clear();
    notifyListeners();
  }

  List<String> _areaOfWorkIdsForCompletingProfile = [];
  List<String> get areaOfWorkIdsForCompletingProfile =>
      this._areaOfWorkIdsForCompletingProfile;

  setAreaOfWorkForCompletingProfile(List<String> areaOfWorkIds) {
    _areaOfWorkIdsForCompletingProfile = areaOfWorkIds;
    notifyListeners();
  }

  clearAreaOfWorkForCompletingProfile() {
    _areaOfWorkIdsForCompletingProfile.clear();
    notifyListeners();
  }

  String fcmToken;
  User _userInfo = null;
  String _hosptialIds = "";
  String _userTrustId = "";
  String _membershipIds = "";
  String _countryId = "";
  String _deviceToken;
  String _userSurveyLink;
  List<Trust> _trusts = [];
  List<Hospital> _hospitals = [];
  bool _hasDeviceToken = false;
  int _backendNotificartionCount = 0;
  int _numOfTimesToSkipAppUpdate;
  DateTime _whenAppUpdateDialogLastShowed;
  
  User get userData => this._userInfo;
  String get hospitalIds => this._hosptialIds;
  String get userTrustId => this._userTrustId;
  String get membershipIds => this._membershipIds;
  String get countryId => this._countryId;
  String get deviceToken => this._deviceToken;
  String get userSurveyLink => this._userSurveyLink;
  List<Trust> get trusts => this._trusts;
  List<Hospital> get hospitals => this._hospitals;
  bool get hasDevicetoken => this._hasDeviceToken;
  int get backendNotificationCount => this._backendNotificartionCount;
  int get numOfTimesToSkipAppUpdate => this._numOfTimesToSkipAppUpdate;
  DateTime get whenAppUpdateDialogLastShowed => this._whenAppUpdateDialogLastShowed;

  setTrustsList(List trusts) {
    _trusts = trusts;
  }

  setHospitalsList(List<Hospital> hospitals) {
    _hospitals = hospitals;
  }

  setDeviceToken(value) {
    _deviceToken = value;
    notifyListeners();
  }

  void setUserData(User user) {
    _userInfo = user;
  }

  void setHospitalIds(String hospIds) {
    _hosptialIds = hospIds;
  }

  void setMembershipsIds(String membershipsIds) {
    _membershipIds = membershipsIds;
  }

  void setUserTrustId(String trustId) {
    _userTrustId = trustId;
  }

  clearUserData() {
    _userInfo = null;
    notifyListeners();
  }

  updateUnreadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUnreadNotificationsCount = prefs.getInt("unSeen_Notifications");
    if (storedUnreadNotificationsCount == null) {
      _backendNotificartionCount = 0;
    } else {
      _backendNotificartionCount = storedUnreadNotificationsCount;
    }
    notifyListeners();
  }

  increaseBackendNotificationCount() async {
    _backendNotificartionCount += 1;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("unSeen_Notifications", _backendNotificartionCount);
    notifyListeners();
  }

  setNumOfTimesToSkipAppUpdate(int numOfTimesToSkipAppUpdateLeft) async{
    _numOfTimesToSkipAppUpdate = numOfTimesToSkipAppUpdateLeft;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("numOfTimesToSkipAppUpdate", numOfTimesToSkipAppUpdateLeft);
    notifyListeners();
  }

  setTimeWhenAppAppUpdateDialogLastShowed() async{
    final prefs = await SharedPreferences.getInstance();
    _whenAppUpdateDialogLastShowed = DateTime.now();
    prefs.setString("whenAppUpdateDialogLastShowed", _whenAppUpdateDialogLastShowed.toString());
    notifyListeners();
  }

  getTimeWhenAppAppUpdateDialogLastShowed(BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();
    _whenAppUpdateDialogLastShowed = prefs.getString("whenAppUpdateDialogLastShowed") == null ? null : DateTime.parse(prefs.getString("whenAppUpdateDialogLastShowed"));
    if (_whenAppUpdateDialogLastShowed == null || DateTime.now().difference(_whenAppUpdateDialogLastShowed).inMinutes > 14) {
      NewVersion(
          context: context,
          androidId: "com.ryaltoapp.rightnurse",
          dismissAction: _numOfTimesToSkipAppUpdate != null &&
              _numOfTimesToSkipAppUpdate > 0?
              (){
            setNumOfTimesToSkipAppUpdate(_numOfTimesToSkipAppUpdate-1);
            Navigator.pop(context);
          }: null,
          dialogText: _numOfTimesToSkipAppUpdate <= 0 ?
          "Ryalto just got better click Update to get the latest version!" :
          "Ryalto just got better click Update to get the latest version!\n\nNote: you can skip this $_numOfTimesToSkipAppUpdate more ${_numOfTimesToSkipAppUpdate > 1 ? "times" : "time"}!"
      ).showAlertIfNecessary().then((willShowUpdateDialog){
        if(willShowUpdateDialog){
        setTimeWhenAppAppUpdateDialogLastShowed();
        }
      });
    }
  }
  
  clearUnreadNotificationCount() async {
    _backendNotificartionCount = 0;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("unSeen_Notifications", _backendNotificartionCount);
    notifyListeners();
  }

  Future<void> updateDeviceToken({@required String deviceToken}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");

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
        final httpIoClient = new IOClient(ioc);

        final String url = '$appDomain/device_token';

        final body = json.encode({'device_token': deviceToken});
        http.Response response = kIsWeb ?
        await http.put(Uri.parse(url), headers: headers, body: body) : await httpIoClient.put(Uri.parse(url), headers: headers, body: body);

        if (response.statusCode == 200) {
        } else {}
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> checkIfDeviceTokenExist({@required String deviceToken}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");

    if (storedUser != null) {
      final String token = jsonDecode(storedUser)['token'];
      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=1',
        'Content-Type': 'application/json',
        'Authorization': 'Token token=$token'
      };
      if(!kIsWeb){
        headers['Platform']= MyApp.platformIndex;
      }

      try {
        final ioc = new HttpClient();
        ioc.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        final httpp = new IOClient(ioc);

        _deviceToken = deviceToken;

        final String url = '$appDomain/device_token';
        http.Response response = await httpp.get(url, headers: headers);
        var responseJson = json.decode(response.body);

        if (response.statusCode == 200) {
          _hasDeviceToken = responseJson["device_token"];
          updateDeviceToken(deviceToken: deviceToken);
        } else {}
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }


  Future getUser(BuildContext context, {email}) async {
    this.stage = UsersStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final url = '$appDomain/user/me';


    if (storedUser != null) {
      String token = jsonDecode(storedUser)['token'];
      debugPrint("auth token is: $token");

      _numOfTimesToSkipAppUpdate = prefs.getInt("numOfTimesToSkipAppUpdate") != null ?
      prefs.getInt("numOfTimesToSkipAppUpdate") : 3;

      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=1',
        'Content-Type': 'application/json',
        'Authorization': 'Token token=$token'
      };
      // if(!kIsWeb){
      //   headers['Platform'] = MyApp.platformIndex;
      // }
      var responseString;
      try {
        // final httpIoClient = IOClient(ioc);
        //
        // http.Response response =
        // kIsWeb ? await http.get(Uri.parse(url), headers: headers):
        // await httpIoClient.get(Uri.parse(url), headers: headers);
        //
        // responseString = response.body;

        var request = http.MultipartRequest('GET', Uri.parse(url));
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        responseString = await response.stream.bytesToString();


        Map responseMap = json.decode(responseString);

        String userHospitalIds = "";
        String userMembershipsIds = "";

        if (response.statusCode == 200) {
          // print('getUserrrrrr ${responseMap}');

          final User user = User.fromJson(responseMap);
          setUserData(user);

          MyApp.userLoggedIn = true;

          user.hospitals.forEach((hospital) {
            userHospitalIds =
                userHospitalIds + "hospitals%5B%5D=${hospital["id"]}&";
          });

          user.memberships.forEach((membership) {
            userMembershipsIds =
                userMembershipsIds + "%7Cmembership_id%3A${membership["id"]}";
          });
          setUserTrustId(user.trust['id']);
          _countryId = user.country["id"];
          setHospitalIds(userHospitalIds);
          setMembershipsIds(userMembershipsIds);

          final FilterParameters filterParameters = FilterParameters();
          if (filterParameters.roleType == null) {
            filterParameters.setDefaultUserType(userData.roleType);
          }
          this.stage = UsersStage.DONE;
          notifyListeners();
          return true;
        }
        else if (response.statusCode == 403) {
          debugPrint("get user error");
          MyApp.userLoggedIn = false;
          // Provider.of<NewsProvider>(context, listen: false).clearOrgNews();
          // Provider.of<NewsProvider>(context, listen: false).clearProNews();
          // Provider.of<NewsProvider>(context, listen: false).clearFavouriteNews();
          // Provider.of<ChatProvider>(context, listen: false).unsubscribeFromChatChannels(deviceToken: _deviceToken);
          // Provider.of<ChatProvider>(context, listen: false).clearChannelUsers();
          // Provider.of<ChatProvider>(context, listen: false).clearChannels();
          // Provider.of<ChatProvider>(context, listen: false).clearOpenChannelName(context);
          // Provider.of<ChatProvider>(context, listen: false).clearGroupChannelParticipants();
          // Provider.of<ChatProvider>(context, listen: false).clearChannelsHistory();
          // Provider.of<ChatProvider>(context, listen: false).clearChatUnreadMessagesOnLogout();
          // clearUnreadNotificationCount();
          // setLevelForCompletingProfile(null);
          // setMinAcceptedLevelForCompletingProfile(null);
          //
          // Provider.of<ChatProvider>(context, listen: false).clearChannelsLastMsgOnLogout();
          // Provider.of<NotificationsProvider>(context, listen: false).clearOrgNotifications();
          //
          // Provider.of<ChatProvider>(context, listen: false).appLifeCyclesubscription.cancel();
          //
          // FirebaseMessaging.instance.deleteToken();
          //
          //
          // if (await TwilioVoice.instance.call.isOnCall()) {
          //   TwilioVoice.instance.call.hangUp();
          // }
          //
          //
          // Provider.of<DiscoveryProvider>(context, listen: false).clearFilterForCurrentUser();
          // Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(0);
          // Provider.of<CallProvider>(context, listen: false).unRegisterFromTwilioCalls(userId: userData.id);
          // Provider.of<DiscoveryProvider>(context, listen: false).resetFiltersWhenLogOut();
          // Provider.of<NewsProvider>(context, listen: false).clearUnreadNewsNotificationCount();
          // Provider.of<NewsProvider>(context, listen: false).clearUnreadMyOrganisationNewsNotificationCount();
          // Provider.of<NewsProvider>(context, listen: false).clearUnreadFocusedNewsNotificationCount();


          _isCurrentAppBackgroundSetToDefault = null;
          _copyDeviceFontSize = false;

          clearUserData();
          prefs.clear();

          RestartWidget.restartApp(context);
          this.stage = UsersStage.DONE;
          notifyListeners();
          return false;
          // Navigator.pushNamed(context, LandingPage.routeName);
        }
        else {
          showAnimatedCustomDialog(context,
              title: "Error", message: responseMap["message"]);
          this.stage = UsersStage.DONE;
          notifyListeners();
          return false;
        }



      } catch (e) {
        debugPrint(e.toString());
        this.stage = UsersStage.ERROR;
        notifyListeners();
        return false;

      }
    }
  }

  LocalAuthentication localAuth = LocalAuthentication();
  final storage = new FlutterSecureStorage();
  bool canCheckBiometrics = false;
  bool havefingerPrint = false;
  bool haveFaceprint = false;
  bool saveDataToLoginWithFinger = false;

  bioMetricLogin(BuildContext context) async {
    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint("error biome trics $e");
    }

    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint("error enumerate biometrics $e");
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      havefingerPrint = true;
    } else if (availableBiometrics.contains(BiometricType.face)) {
      haveFaceprint = true;
    }

    notifyListeners();
  }

  enableFingerPrint(BuildContext context, var isEnabled) async {
    if (isEnabled == false) {
      try {
        bool authenticated = false;
        authenticated = await localAuth.authenticateWithBiometrics(
            localizedReason: "Please verify your biometric",
            useErrorDialogs: true,
            stickyAuth: true,
            // iOSAuthStrings: null,
            //   androidAuthStrings: null,

            androidAuthStrings:
                AndroidAuthMessages(signInTitle: "Disable biometric login"));
        if (authenticated) {
          saveDataToLoginWithFinger = false;

          await storage.delete(key: "password");
          await storage.delete(key: "email");
          await storage.delete(key: "token");
          notifyListeners();
          // await storage.deleteAll();
        }
      } on PlatformException catch (e) {
        debugPrint(e.message);
      }
    }
    notifyListeners();
  }

  getFingerPrintToken() async {
    var myToken;
    myToken = await storage.read(key: "token");
    if (myToken != null) {
      saveDataToLoginWithFinger = true;
    } else {
      saveDataToLoginWithFinger = false;
      // await storage.deleteAll();
      await storage.delete(key: "password");
      await storage.delete(key: "email");
      await storage.delete(key: "token");
    }

    notifyListeners();
    return myToken;
  }

  isAuthWithBiometrics(BuildContext context, {Function showSnack}) async {
    bool authenticated = false;

    String password = await storage.read(key: "password");
    String token = await storage.read(key: "token");
    String email = await storage.read(key: "email");

    try {
      authenticated = await localAuth.authenticateWithBiometrics(
        localizedReason: "Please verify your biometric",
        useErrorDialogs: true,
        stickyAuth: true,
        // iOSAuthStrings: null,
        //   androidAuthStrings: null,
        androidAuthStrings: AndroidAuthMessages(signInTitle: "Log in"),
      );
      if (authenticated)
        login(context,
            password: password,
            token: token,
            email: email,
            checkFromSettingsScreen: false);
    } on PlatformException catch (e) {
      debugPrint("error using biometric auth: ${e.message}");
    }

    notifyListeners();
  }


  Future login(BuildContext context,
      {String email,
      String password,
      String token,
      checkFromSettingsScreen = false}) async {
    final url = "$appDomain/login" ;
    // final ioc = new HttpClient();
    // ioc.badCertificateCallback =
    //     (X509Certificate cert, String host, int port) => true;
    // final httpp = new IOClient(ioc);

    var headers = {
      // 0 --> iOS , 1 --> Android
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      //'UserAgent': 'RightNurse/1.2.3 (iPhone; iOS 10.3.1; Scale/3.00)',
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
    };


    Map<String, String> body = {'email': email, 'password': password, 'device_token': token};

    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // http.Response response =
      //     await httpp.post("$url", headers: headers, body: body);
      //
      // var responseJson = json.decode(response.body);

      String responseString;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(body);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      print(responseString);

      if (response.statusCode == 200) {
        Map<String, dynamic> user = json.decode(responseString);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user', jsonEncode(user));
        MyApp.userLoggedIn = true;

        if (!kIsWeb) {
          print('holaaaaaaaaaaaaaz');
          saveDataToLoginWithFinger = true;
          await storage.write(key: "password", value: password);
          await storage.write(key: "email", value: email);
          await storage.write(key: "token", value: token);


        _deviceToken = token;

        getUserSurveysLink();
        notifyListeners();

;
        if (checkFromSettingsScreen == false) {
          getUser(context).then((_) {


            Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_){
              /// this one will run for first time after user logs-In or Signs up and it can't be init load as users won't notified anyway while they are not logged in
              /// -----later on will add the InIt load here too when we save the last time user went to background on logout
              /// for each user at backend so it doesn't get cleared when user logs out as its saved locally for now -------///
              Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, isFromNewChatTab: true).then((_) {
                Provider.of<ChatProvider>(context, listen: false).registerForChatPushNotifications(Provider.of<UserProvider>(context, listen: false).deviceToken);
                Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
              });
            });

              Provider.of<CallProvider>(context, listen: false).registerTwilioClient(context,
                  id: userData.id,
                  name: userData.name,
                  myToken: userData.token);


              Timer.periodic(const Duration(minutes: 5), (timer) {
                if (MyApp.userLoggedIn) {
                  Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) {
                    Provider.of<ChatProvider>(context, listen: false).clearChannels();
                    Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                      Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                    });
                  });
                }
                /// new to stop the timer after logout !!!!!
                else{
                  timer.cancel();
                }
              });

              /// check if actually this works and updates the TwilioAcesstoken when it gets expired or not
              Timer.periodic(const Duration(minutes: 40), (timer) {
                if (MyApp.userLoggedIn) {
                  Provider.of<CallProvider>(context, listen: false).registerTwilioClient(context, id: Provider.of<UserProvider>(context, listen: false).userData.id,
                      name: Provider.of<UserProvider>(context, listen: false).userData.name,
                      myToken: Provider.of<UserProvider>(context, listen: false).userData.token);
                  // // added to update isInACall getter from Call Provider
                  // Provider.of<CallProvider>(context).waitForTwilioCall(context);
                }
                /// new to stop the timer after logout !!!!!
                else{
                  timer.cancel();
                }
              });
              // Provider.of<CallProvider>(context, listen: false).registerTwilioClient(context, id: Provider.of<UserProvider>(context, listen: false).userData.id,
              //     name: userData.name,
              //     myToken: userData.token);

              FirebaseMessaging.onMessage.listen((RemoteMessage message) async{

                if(Platform.isAndroid){
                  debugPrint("on message from Login Android *************************************** 11111112222222");
                  // (message.notification != null) is commented out as it prevents navigationHome error when announcement get sent
                  if (message != null && message.notification != null  &&  message.notification.title.contains("Chat:")) {
                    if (message.data != null) {
                      // this condition is to add the new created channel if its not in the users channels set
                      if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.toString().contains(message.data["channel_name"]) == false){
                        Provider.of<ChatProvider>(context, listen: false).clearChannels();
                        Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
                      }
                      // commented this part out since there is a listen already on the only for Android iOS requires this part
                      // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                      //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                      //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                      //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                      // }

                      /// to show local Notification when chat Message comes for Android
                      if(message != null && message.data['is_announcement'] == "false" &&
                          message.data["senderId"] != Provider.of<UserProvider>(context, listen: false).userData.id
                          &&  Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {

                        MyApp.flutterLocalNotificationsPlugin.show(
                            message.notification.hashCode,
                            "${message.data['text']}",
                            "",
                            MyApp.androidNotificationDetails
                        );
                      }


                    }

                  }
                  else if(message != null && message.notification!= null  && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
                    Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                  }

                  // handled for Android but still need to be handled for ios
                  if(message != null && message.data['notification_type'].toString()=='100'){
                    // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                    // if(message.data['title'] == 'Focused News'){
                    //   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                    // }
                    // else{
                    //   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                    // }

                    Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                        context,
                        pageOffset: 0,
                        trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                        hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                        membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                    Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                  }

                  /// to show local Notification when an Announcement Message comes for Android
                  if(message != null && message.data['is_announcement'] == "true" &&
                      message.data["sender_id"] != Provider.of<UserProvider>(context, listen: false).userData.id
                      &&  Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]){

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

                else if(Platform.isIOS){
                  debugPrint("on message iOS *************************************** 111111122222222");


                  // handling news notification for iOS is different as the bdy for the notification is different
                  if(await message != null && message.notification != null && await message.notification.title == 'Focused News'){
                    // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                    // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                    Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                  }
                  else if (await message != null && message.notification != null && await message.notification.title == 'My Organisation'){
                    // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                    // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();

                    Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                        context,
                        pageOffset: 0,
                        trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                        hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                        membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                  }


                  if (await message != null && await message.category != null) {
                    if(message.category.contains("channel-")){
                      if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
                        Provider.of<ChatProvider>(context, listen: false).clearChannels();
                        Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                          Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                        });
                      }

                      // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                      // if (message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                      //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                      //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                      //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                      // }

                      String iOSNotificationPayload = message.messageId.toString();
                      var startOfsenderId = "{title: ";
                      var endOfsenderId = ",";


                      var startIndex = iOSNotificationPayload.indexOf(startOfsenderId);
                      var endIndex = iOSNotificationPayload.indexOf(endOfsenderId, startIndex + startOfsenderId.length);
                      String senderName = iOSNotificationPayload.substring(startIndex + startOfsenderId.length, endIndex);


                      /// to show local Notification when chat Message comes for iOS
                      if(message != null && message.notification != null &&
                          senderName != user["name"]
                          && Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {

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
                  if(await message != null && await message.messageId != null){
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
                    String iOSNotificationPayload = message.messageId.toString();
                    var startOfsenderId = "sender_id:";
                    var endOfsenderId = "}";

                    var startIndex = iOSNotificationPayload.indexOf(startOfsenderId);
                    var endIndex = iOSNotificationPayload.indexOf(endOfsenderId, startIndex + startOfsenderId.length);
                    String senderId = iOSNotificationPayload.substring(startIndex + startOfsenderId.length, endIndex).trim();

                    var startOfisAnnouncement = "is_announcement:";
                    var endOfsAnnouncement = ",";

                    var startIndexisAnnouncement = iOSNotificationPayload.indexOf(startOfisAnnouncement);
                    var endIndexisAnnouncement = iOSNotificationPayload.indexOf(endOfsAnnouncement, startIndexisAnnouncement + startOfisAnnouncement.length);
                    isAnnouncement = iOSNotificationPayload.substring(startIndexisAnnouncement + startOfisAnnouncement.length, endIndexisAnnouncement).trim();

                    if((isAnnouncement == "true" || isAnnouncement == "tru") && senderId != Provider.of<UserProvider>(context, listen: false).userData.id){
                      debugPrint("on message *************************************** to show local Notification when an Announcement Message comes for iOS");

                      debugPrint("sender id: ${senderId}\n currentUserId: ${Provider.of<UserProvider>(context, listen: false).userData.id}");

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
                  if(await message != null && await message.category == null && isAnnouncement != "true" && isAnnouncement != "tru"){
                    Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                  }

                }

              });

              // this Method is to do what's needed when Notification is clicked if the app is in the background
              FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
                if(Platform.isAndroid){
                  if (message != null && message.notification.title.contains("Chat:")) {

                    Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_)async{

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
                      if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.data["channel_name"]) == false){
                        Provider.of<ChatProvider>(context, listen: false).clearChannels();
                        Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
                      }
                      /// this line is new
                      ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);

                      if(Provider.of<CallProvider>(context, listen: false).hasPushedToCallScreen == false){
                        Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
                        Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                      }

                    });


                    // commented this part out since there is a listen already on the only for Android iOS requires this part
                    // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                    //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                    //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                    //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                    // }
                  }else if(message != null && message.notification!= null && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
                    Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                  }

                  // handling News notifications
                  else if(message != null && message.data['notification_type'].toString()=='100'){
                    // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                    // if(message.data['title'] == 'Focused News'){
                    //   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                    // }
                    // else{
                    //   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                    // }

                    Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                        context,
                        pageOffset: 0,
                        trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                        hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                        membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                    Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                  }
                }
                else if(Platform.isIOS){
                  debugPrint("*************************************** 1111111 onMessageOpenedApp");
                  if (await message != null && await message.category != null) {

                    if(message.category.contains("channel-")){
                      Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) async{
                        // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                        //   "conversation_messages": null,
                        //   "channel": null,
                        //   "channel_name": message.category,
                        //   "pn":null,
                        //   "private_chat_user": null,
                        //   "type": null,
                        //   "current_user_id": null
                        // });

                        if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
                          Provider.of<ChatProvider>(context, listen: false).clearChannels();
                          Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                            Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                          });
                        }
                        /// this line is new
                        ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);

                        if(Provider.of<CallProvider>(context, listen: false).hasPushedToCallScreen == false){
                          Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
                          Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                        }
                      });
                      // this condition is to check if this channel is new or already included to current user's channels


                      // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                      // if(message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                      //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                      //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                      //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                      // }

                    }
                  }

                  // handling news notification for iOS is different as the body for the notification is different
                  if(await message != null && message.notification != null && await message.notification.title == 'Focused News'){
                    // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                    // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                    Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                  }
                  if (await message != null && message.notification != null && await message.notification.title == 'My Organisation'){
                    // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                    // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();

                    Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                        context,
                        pageOffset: 0,
                        trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                        hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                        membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                  }


                  if(await message != null && await message.category == null){
                    Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                  }

                }


              });




            Navigator.pushNamed(context, NavigationHome.routeName);
          });
        }
        }
        else{
          getUserSurveysLink();

          if (checkFromSettingsScreen == false) {
            getUser(context).then((_) {


              Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_){
                /// this one will run for first time after user logs-In or Signs up and it can't be init load as users won't notified anyway while they are not logged in
                /// -----later on will add the InIt load here too when we save the last time user went to background on logout
                /// for each user at backend so it doesn't get cleared when user logs out as its saved locally for now -------///
                Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, isFromNewChatTab: true).then((_) {
                  Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                });
              });



              Timer.periodic(const Duration(minutes: 5), (timer) {
                if (MyApp.userLoggedIn) {
                  Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) {
                    Provider.of<ChatProvider>(context, listen: false).clearChannels();
                    Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                      Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                    });
                  });
                }
                /// new to stop the timer after logout !!!!!
                else{
                  timer.cancel();
                }
              });

        //       FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
        //
        //         if(Platform.isAndroid){
        //           debugPrint("on message from Login Android *************************************** 11111112222222");
        //           // (message.notification != null) is commented out as it prevents navigationHome error when announcement get sent
        //           if (message != null && message.notification != null  &&  message.notification.title.contains("Chat:")) {
        //             if (message.data != null) {
        //               // this condition is to add the new created channel if its not in the users channels set
        //               if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.toString().contains(message.data["channel_name"]) == false){
        //                 Provider.of<ChatProvider>(context, listen: false).clearChannels();
        //                 Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
        //               }
        //               // commented this part out since there is a listen already on the only for Android iOS requires this part
        //               // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
        //               //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
        //               //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
        //               //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
        //               // }
        //
        //               /// to show local Notification when chat Message comes for Android
        //               if(message != null && message.data['is_announcement'] == "false" &&
        //                   message.data["senderId"] != Provider.of<UserProvider>(context, listen: false).userData.id
        //                   &&  Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
        //
        //                 MyApp.flutterLocalNotificationsPlugin.show(
        //                     message.notification.hashCode,
        //                     "${message.data['text']}",
        //                     "",
        //                     MyApp.androidNotificationDetails
        //                 );
        //               }
        //
        //
        //             }
        //
        //           }
        //           else if(message != null && message.notification!= null  && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
        //             Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
        //           }
        //
        //           // handled for Android but still need to be handled for ios
        //           if(message != null && message.data['notification_type'].toString()=='100'){
        //             // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
        //             // if(message.data['title'] == 'Focused News'){
        //             //   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
        //             // }
        //             // else{
        //             //   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
        //             // }
        //
        //             Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
        //                 context,
        //                 pageOffset: 0,
        //                 trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
        //                 hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
        //                 membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
        //             Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
        //           }
        //
        //           /// to show local Notification when an Announcement Message comes for Android
        //           if(message != null && message.data['is_announcement'] == "true" &&
        //               message.data["sender_id"] != Provider.of<UserProvider>(context, listen: false).userData.id
        //               &&  Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]){
        //
        //             var rng = Random();
        //             var code = rng.nextInt(900000) + 100000;
        //
        //             MyApp.flutterLocalNotificationsPlugin.show(
        //                 code,
        //                 "Announcement 📣",
        //                 "${message.data['text']}",
        //                 MyApp.androidNotificationDetails
        //             );
        //
        //
        //             /* this is the announcement body that gets sent to Android *******
        //                       new
        //                       {channel_name: channel-1627569163-d4f9bcd3867d48f889312c7abc2f48dfbd5d1b13e7d7fcebc7,
        //                        payload_id: 9ce7e749-cbe3-4274-9e37-3409c270d7b6,
        //                        is_system_message: false,
        //                        is_announcement: true,
        //                        text: test, channel_id: 4e83a2d7-1554-4852-99fb-4d3e369ec4f2,
        //                        version: 1.0.0,
        //                        sender_id: 2265b3b5-e649-4b4b-8c33-f50c2cb59164}
        //                       */
        //             // handled for Android but still need to be handled for ios
        //             // showNotificationsCustomDialog(
        //             //   context,
        //             //   key: Key("value"),
        //             //   width: double.infinity,
        //             //   title: "New Announcement",
        //             //   subTitle: "${message.data['text']}",
        //             //   mainPhoto: Image.asset("images/AppIcon.png"),
        //             // );
        //           }
        //
        //         }
        //
        //         else if(Platform.isIOS){
        //           debugPrint("on message iOS *************************************** 111111122222222");
        //
        //
        //           // handling news notification for iOS is different as the bdy for the notification is different
        //           if(await message != null && message.notification != null && await message.notification.title == 'Focused News'){
        //             // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
        //             // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
        //             Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
        //           }
        //           else if (await message != null && message.notification != null && await message.notification.title == 'My Organisation'){
        //             // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
        //             // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
        //
        //             Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
        //                 context,
        //                 pageOffset: 0,
        //                 trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
        //                 hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
        //                 membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
        //           }
        //
        //
        //           if (await message != null && await message.category != null) {
        //             if(message.category.contains("channel-")){
        //               if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
        //                 Provider.of<ChatProvider>(context, listen: false).clearChannels();
        //                 Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
        //                   Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
        //                 });
        //               }
        //
        //               // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
        //               // if (message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
        //               //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
        //               //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
        //               //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
        //               // }
        //
        //               String iOSNotificationPayload = message.messageId.toString();
        //               var startOfsenderId = "{title: ";
        //               var endOfsenderId = ",";
        //
        //
        //               var startIndex = iOSNotificationPayload.indexOf(startOfsenderId);
        //               var endIndex = iOSNotificationPayload.indexOf(endOfsenderId, startIndex + startOfsenderId.length);
        //               String senderName = iOSNotificationPayload.substring(startIndex + startOfsenderId.length, endIndex);
        //
        //
        //               /// to show local Notification when chat Message comes for iOS
        //               if(message != null && message.notification != null &&
        //                   senderName != user["name"]
        //                   && Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
        //
        //                 var rng = Random();
        //                 var code = rng.nextInt(900000) + 100000;
        //
        //                 MyApp.flutterLocalNotificationsPlugin.show(
        //                     code,
        //                     "${message.notification.title}",
        //                     "${message.notification.body}",
        //                     MyApp.iOSNotificationDetails
        //                 );
        //               }
        //
        //             }
        //           }
        //           String isAnnouncement = '';
        //           if(await message != null && await message.messageId != null){
        //             /*
        // * {is_system_message: false,
        // *  payload_id: d41a9e31-26e1-4474-8422-034c9027b24b,
        // *  channel_id: 7eb9bfba-73cc-4ff6-8912-6e60bf2a42d9,
        // *  is_announcement: true,
        // *  channel_name: channel-1609782388-3d387982b0e974626ad17b8b8442afc0bef80d11b45a7de1e1,
        // *  version: 1.0.0,
        // *  sender_id: e613bb99-af6c-4afb-bc63-1909a19c8b92}
        // * }
        // * */
        //             /// to show local Notification when an Announcement Message comes for iOS
        //             String iOSNotificationPayload = message.messageId.toString();
        //             var startOfsenderId = "sender_id:";
        //             var endOfsenderId = "}";
        //
        //             var startIndex = iOSNotificationPayload.indexOf(startOfsenderId);
        //             var endIndex = iOSNotificationPayload.indexOf(endOfsenderId, startIndex + startOfsenderId.length);
        //             String senderId = iOSNotificationPayload.substring(startIndex + startOfsenderId.length, endIndex).trim();
        //
        //             var startOfisAnnouncement = "is_announcement:";
        //             var endOfsAnnouncement = ",";
        //
        //             var startIndexisAnnouncement = iOSNotificationPayload.indexOf(startOfisAnnouncement);
        //             var endIndexisAnnouncement = iOSNotificationPayload.indexOf(endOfsAnnouncement, startIndexisAnnouncement + startOfisAnnouncement.length);
        //             isAnnouncement = iOSNotificationPayload.substring(startIndexisAnnouncement + startOfisAnnouncement.length, endIndexisAnnouncement).trim();
        //
        //             if((isAnnouncement == "true" || isAnnouncement == "tru") && senderId != Provider.of<UserProvider>(context, listen: false).userData.id){
        //               debugPrint("on message *************************************** to show local Notification when an Announcement Message comes for iOS");
        //
        //               debugPrint("sender id: ${senderId}\n currentUserId: ${Provider.of<UserProvider>(context, listen: false).userData.id}");
        //
        //               var rng = Random();
        //               var code = rng.nextInt(900000) + 100000;
        //
        //               MyApp.flutterLocalNotificationsPlugin.show(
        //                   code,
        //                   "Announcement 📣",
        //                   "${message.notification.body}",
        //                   MyApp.iOSNotificationDetails
        //               );
        //
        //             }
        //
        //           }
        //           if(await message != null && await message.category == null && isAnnouncement != "true" && isAnnouncement != "tru"){
        //             Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
        //           }
        //
        //         }
        //
        //       });
        //
        //       // this Method is to do what's needed when Notification is clicked if the app is in the background
        //       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        //         if(Platform.isAndroid){
        //           if (message != null && message.notification.title.contains("Chat:")) {
        //
        //             Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_)async{
        //
        //               // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
        //               //   "conversation_messages": null,
        //               //   "channel": null,
        //               //   "channel_name": message.data["channel_name"],
        //               //   "pn":null,
        //               //   "private_chat_user": null,
        //               //   "type": null,
        //               //   "current_user_id": null
        //               // });
        //
        //               // this condition is to add the new created channel if its not in the users channels set
        //               if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.data["channel_name"]) == false){
        //                 Provider.of<ChatProvider>(context, listen: false).clearChannels();
        //                 Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
        //               }
        //               /// this line is new
        //               ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
        //
        //               if(Provider.of<CallProvider>(context, listen: false).hasPushedToCallScreen == false){
        //                 Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));
        //                 Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
        //               }
        //
        //             });
        //
        //
        //             // commented this part out since there is a listen already on the only for Android iOS requires this part
        //             // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
        //             //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
        //             //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
        //             //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
        //             // }
        //           }else if(message != null && message.notification!= null && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
        //             Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
        //           }
        //
        //           // handling News notifications
        //           else if(message != null && message.data['notification_type'].toString()=='100'){
        //             // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
        //             // if(message.data['title'] == 'Focused News'){
        //             //   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
        //             // }
        //             // else{
        //             //   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
        //             // }
        //
        //             Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
        //                 context,
        //                 pageOffset: 0,
        //                 trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
        //                 hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
        //                 membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
        //             Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
        //           }
        //         }
        //         else if(Platform.isIOS){
        //           debugPrint("*************************************** 1111111 onMessageOpenedApp");
        //           if (await message != null && await message.category != null) {
        //
        //             if(message.category.contains("channel-")){
        //               Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) async{
        //                 // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
        //                 //   "conversation_messages": null,
        //                 //   "channel": null,
        //                 //   "channel_name": message.category,
        //                 //   "pn":null,
        //                 //   "private_chat_user": null,
        //                 //   "type": null,
        //                 //   "current_user_id": null
        //                 // });
        //
        //                 if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
        //                   Provider.of<ChatProvider>(context, listen: false).clearChannels();
        //                   Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
        //                     Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
        //                   });
        //                 }
        //                 /// this line is new
        //                 ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
        //
        //                 if(Provider.of<CallProvider>(context, listen: false).hasPushedToCallScreen == false){
        //                   Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));
        //                   Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
        //                 }
        //               });
        //               // this condition is to check if this channel is new or already included to current user's channels
        //
        //
        //               // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
        //               // if(message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
        //               //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
        //               //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
        //               //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
        //               // }
        //
        //             }
        //           }
        //
        //           // handling news notification for iOS is different as the body for the notification is different
        //           if(await message != null && message.notification != null && await message.notification.title == 'Focused News'){
        //             // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
        //             // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
        //             Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
        //           }
        //           if (await message != null && message.notification != null && await message.notification.title == 'My Organisation'){
        //             // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
        //             // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
        //
        //             Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
        //                 context,
        //                 pageOffset: 0,
        //                 trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
        //                 hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
        //                 membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
        //           }
        //
        //
        //           if(await message != null && await message.category == null){
        //             Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
        //           }
        //
        //         }
        //
        //
        //       });




              Navigator.pushNamed(context, WebMainScreen.routeName);
            });
          }
        }

        /// Google analytics
        AnalyticsManager.track('login_success');
      } else {
        Map<String, dynamic> responseJson = json.decode(responseString);

        debugPrint(responseJson["message"]);
        showAnimatedCustomDialog(context,
            title: "Error", message: responseJson["message"]);
        AnalyticsManager.track('login_fail');
      }
    } catch (e) {
      this.stage = UsersStage.ERROR;
      showAnimatedCustomDialog(context, title: "Error", message: e.toString());
      debugPrint(e.toString());
    }
  }

  Future resetPassword(BuildContext context, {email}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");

    var headers = {
      'Platform': MyApp.platformIndex,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
    };

    final url = '$appDomain/forgot_password';
    var body = {"email": "$email"};
    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      String responseString;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(body);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();


      // http.Response request = await httpp.post('$appDomain/forgot_password',
      //     headers: headers, body: body);

      // responseString = request.body;
      Map responseMap = json.decode(responseString);

      if (response.statusCode == 200) {
        showAnimatedCustomDialog(context, message: responseMap["message"],
            onClicked: () {
          Navigator.of(context)
              .popUntil(ModalRoute.withName(LoginScreen.routName));
        });
      } else {
        showAnimatedCustomDialog(context,
            title: "Error", message: responseMap["message"]);
      }
    } catch (e) {
      this.stage = UsersStage.ERROR;
      print(e);
    }
  }

  Future changePassword(BuildContext context,
      {String oldPassword, String newPassword}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Right-Nurse-Version': Domain.appVersion,
      'Authorization': 'Token token=$token'
    };

    var responseString;
    final url = '$appDomain/reset_password';
    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);

      var body = {"current_password": "$oldPassword", "new_password": "$newPassword"};

      // http.Response request = await httpp.post('$appDomain/reset_password',
      //     headers: headers, body: body);

      String responseString;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(body);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();


      // http.Response request = await httpp.post('$appDomain/forgot_password',
      //     headers: headers, body: body);

      // responseString = request.body;
      // Map responseMap = json.decode(responseString);

      // responseString = request.body;
      Map responseMap = json.decode(responseString);
      if (response.statusCode == 200) {
        showAnimatedCustomDialog(context,
            message: "Password changed successfully.", onClicked: () {
          Navigator.of(context)
              .popUntil(ModalRoute.withName(SettingsScreen.routName));
        });
      } else {
        showAnimatedCustomDialog(context,
            title: "Error", message: responseMap["message"]);
      }
    } catch (e) {
      this.stage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
  }

  Future logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    final url = '$appDomain/logout';

    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // http.Response response =
      //     await httpp.post('$appDomain/logout', headers: headers);
      String responseString;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      // request.fields.addAll(body);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        MyApp.userLoggedIn = false;


          Provider.of<ChatProvider>(context, listen: false).clearChannelUsers();
          Provider.of<ChatProvider>(context, listen: false).clearChannels();
          Provider.of<ChatProvider>(context, listen: false).clearOpenChannelName(context);
          Provider.of<ChatProvider>(context, listen: false).clearGroupChannelParticipants();
          Provider.of<ChatProvider>(context, listen: false).clearChannelsHistory();
          Provider.of<ChatProvider>(context, listen: false).clearChatUnreadMessagesOnLogout();
          setLevelForCompletingProfile(null);
          setMinAcceptedLevelForCompletingProfile(null);
          clearUnreadNotificationCount();
          Provider.of<DiscoveryProvider>(context, listen: false).clearFilterForCurrentUser();
          Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(0);
          Provider.of<DiscoveryProvider>(context, listen: false).resetFiltersWhenLogOut();
          Provider.of<DiscoveryProvider>(context, listen: false).resetFiltersWhenLogOut();
          Provider.of<NewsProvider>(context, listen: false).clearUnreadNewsNotificationCount();
          Provider.of<NewsProvider>(context, listen: false).clearUnreadMyOrganisationNewsNotificationCount();
          Provider.of<NewsProvider>(context, listen: false).clearUnreadFocusedNewsNotificationCount();

        if(!kIsWeb){
          Provider.of<NewsProvider>(context, listen: false).clearOrgNews();
          Provider.of<NewsProvider>(context, listen: false).clearProNews();
          Provider.of<NewsProvider>(context, listen: false).clearFavouriteNews();
          Provider.of<ChatProvider>(context, listen: false).unsubscribeFromChatChannels(deviceToken: _deviceToken);



          Provider.of<ChatProvider>(context, listen: false).clearChannelsLastMsgOnLogout();
          Provider.of<NotificationsProvider>(context, listen: false).clearOrgNotifications();

          Provider.of<ChatProvider>(context, listen: false).appLifeCyclesubscription.cancel();
          FirebaseMessaging.instance.deleteToken();
          if (await TwilioVoice.instance.call.isOnCall()) {
            TwilioVoice.instance.call.hangUp();
          }


          Provider.of<CallProvider>(context, listen: false).unRegisterFromTwilioCalls(userId: userData.id);
          Provider.of<DiscoveryProvider>(context, listen: false).resetFiltersWhenLogOut();



          _isCurrentAppBackgroundSetToDefault = null;
          _copyDeviceFontSize = false;



          // Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));
          // Navigator.of(context).pushReplacementNamed(LandingPage.routeName);

          // Navigator.pushNamedAndRemoveUntil(context, LandingPage.routeName, (route) => false);
          AnalyticsManager.track('logout');
        }
        clearUserData();
        prefs.clear();

        RestartWidget.restartApp(context);









      } else {
        // Navigator.pop(context);
        showAnimatedCustomDialog(context,
            title: "Error", message: "some error has occurred");
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getUserSurveysLink() async {
    final url = '$appDomain/surveys';
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;
    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // http.Response response =
      //     await httpp.get(url, headers: headers);
      //
      // responseString = response.body;
      String responseString;
      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      Map responseMap = json.decode(responseString);

      if (response.statusCode == 200) {
        _userSurveyLink = responseMap["url"];
        print('_userSurveyLink ${_userSurveyLink}');
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future getTrusts(BuildContext context, {String countryCode}) async {
    this.trustsStage = UsersStage.LOADING;
    var headers = {
      // 'Platform': '0',
      'Right-Nurse-Version': '11.2.2',
      'UserAgent': 'RightNurse/1.2.3 (iPhone; iOS 10.3.1; Scale/3.00)',
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
    };

    // print('$appDomain/trusts?country=GB');
    if(kIsWeb){
      // headers['Access-Control-Allow-Origin'] = "*";
      headers['Access-Control-Allow-Origin'] = "Access-Control-Allow-Origin, Accept";

    }
    final httpClient = universal.HttpClient();

    final res = httpClient.getUrl(Uri.parse('$appDomain/trusts?country=GB'));

    String responseString;
    var request = http.MultipartRequest('GET', Uri.parse('$appDomain/trusts?country=GB'));
    request.headers.addAll(headers);
    // print(await request.send());

    http.StreamedResponse response = await request.send();
    responseString = await response.stream.bytesToString();
    var responseList = json.decode(responseString);

    print(response.statusCode);
    List<Trust> trusts = [];
    if (response.statusCode == 200) {
      responseList.forEach((element) {
        Trust trust = Trust.fromJson(element);
        trusts.add(trust);
      });
      print("$trusts");

      setTrustsList(trusts);
      this.trustsStage = UsersStage.DONE;
      // return trusts;
    }
    else {
      this.trustsStage = UsersStage.ERROR;
      // notifyListeners();
      // return trusts;
    }
    // if (response.statusCode == 200) {
    //   // print(await response.stream.bytesToString());
    // }
    // else {
    //   print(response.reasonPhrase);
    // }
    notifyListeners();

  }

  Future getHospitals(BuildContext context,
      {String countryCode, String trustId}) async {
    this.hospitalsStage = UsersStage.LOADING;
    final url = '$appDomain/hospitals?trust_id=$trustId&country=$countryCode';

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
    };


    var responseString;
    try {
      if (countryCode == null) {
        countryCode = 'GB';
      }

      if(kIsWeb){
        // headers['Access-Control-Allow-Origin'] = "*";
        headers['Access-Control-Allow-Origin'] = "Access-Control-Allow-Origin, Accept";

      }
      final httpClient = universal.HttpClient();

      final res = httpClient.getUrl(Uri.parse('$appDomain/trusts?country=GB'));

      String responseString;
      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);

      // http.Response response = await httpp.get(
      //     '$appDomain/hospitals?trust_id=$trustId&country=$countryCode',
      //     headers: headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      var responseList = json.decode(responseString);

      List<Hospital> hospitals = [];

      if (response.statusCode == 200) {
        this.hospitalsStage = UsersStage.DONE;

        responseList.forEach((element) {
          Hospital hospital = Hospital.fromJson(element);
          hospitals.add(hospital);
        });
        setHospitalsList(hospitals);
        debugPrint(hospitals.toString());

        // this.hospitalsStage = UsersStage.DONE;
        notifyListeners();
        return hospitals;
      } else {
        this.hospitalsStage = UsersStage.ERROR;
        notifyListeners();
        return hospitals;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      notifyListeners();
      this.hospitalsStage = UsersStage.ERROR;
    }
    notifyListeners();
  }

  Future register(
    BuildContext context, {
    @required firstName,
    @required lastName,
    @required email,
    @required phoneNumber,
    @required password,
    @required trustId,
    @required hospitals,
    @required timezone,
    @required countryCode,
    @required deviceToken,
    @required userType,
    @required dialingCode,
  }) async {
    String url = userType == 1
        ? '$appDomain/nurse'
        : userType == 2
            ? '$appDomain/doctors'
            : '$appDomain/basic_user';

    var headers = {
      // 0 --> iOS , 1 --> Android
      'Platform': //"1",
          MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json'
    };

    // var body = json.encode({
    //   'first_name': firstName,
    //   'last_name': lastName,
    //   'email': email,
    //   'phone_number': "$dialingCode$phoneNumber", // it was like this "$dialingCode$phoneNumber" before but we changed it
    //   'password': password,
    //   'trust_id': trustId,
    //   'hospitals': hospitals,
    //   'user_type_id': userType,
    //   'country_code': countryCode ?? 'GB',
    //   'timezone': timezone ?? 'Europe/London',
    //   'device_token': deviceToken
    // });

    Map<String, String> body = {
      'first_name': firstName.toString(),
      'last_name': lastName.toString(),
      'email': email.toString(),
      'phone_number': "$dialingCode$phoneNumber", // it was like this "$dialingCode$phoneNumber" before but we changed it
      'password': password.toString(),
      'trust_id': trustId.toString(),
      'hospitals': hospitals.toString(),
      'user_type_id': userType.toString(),
      'country_code': countryCode.toString() ?? 'GB',
      'timezone': timezone.toString() ?? 'Europe/London',
      'device_token': deviceToken.toString()
    };

    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // http.Response response =
      //     await httpp.post("$url", headers: headers, body: body);
      //
      // var responseJson = json.decode(response.body);

      String responseString;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(body);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      print(responseString);

      if (response.statusCode == 200) {
        Map<String, dynamic> user = json.decode(responseString);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user', jsonEncode(user));
        final User userr = User.fromJson(user);
        setUserData(userr);

        if (!kIsWeb) {
          saveDataToLoginWithFinger = true;
          await storage.write(key: "password", value: password);
          await storage.write(key: "email", value: email);
          await storage.write(key: "token", value: deviceToken);
          _deviceToken = deviceToken;

        }


        MyApp.userLoggedIn = true;
        // before calling Twillio because Twillio not ready yet

        Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_){
          /// this one will run for first time after user logs-In or Signs up and it can't be init load as users won't notified anyway while they are not logged in
          /// -----later on will add the InIt load here too when we save the last time user went to background on logout
          /// for each user at backend so it doesn't get cleared when user logs out as its saved locally for now -------///
          Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, isFromNewChatTab: true).then((_) {
            if (!kIsWeb) {
              Provider.of<ChatProvider>(context, listen: false).registerForChatPushNotifications(Provider.of<UserProvider>(context, listen: false).deviceToken);
            }
            Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
          });
        });


        if (!kIsWeb) {
          Provider.of<CallProvider>(context, listen: false).registerTwilioClient(context,
              id: userData.id,
              name: userData.name,
              myToken: userData.token);
        }

          Timer.periodic(const Duration(minutes: 5), (timer) {
            if (MyApp.userLoggedIn) {
            Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) {
              Provider.of<ChatProvider>(context, listen: false).clearChannels();
              Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
              });
            });
            }
            /// new to stop the timer after logout !!!!!
            else{
              timer.cancel();
            }
          });
          
          /// check if actually this works and updates the TwilioAcesstoken when it gets expired or not
          if (!kIsWeb) {
            Timer.periodic(const Duration(minutes: 40), (timer) {
              if (MyApp.userLoggedIn) {
              Provider.of<CallProvider>(context, listen: false).registerTwilioClient(context, id: Provider.of<UserProvider>(context, listen: false).userData.id,
                  name: Provider.of<UserProvider>(context, listen: false).userData.name,
                  myToken: Provider.of<UserProvider>(context, listen: false).userData.token);
              // // added to update isInACall getter from Call Provider
              // Provider.of<CallProvider>(context).waitForTwilioCall(context);
              }
              /// new to stop the timer after logout !!!!!
              else{
                timer.cancel();
              }

            });

            FirebaseMessaging.onMessage.listen((RemoteMessage message) async{

              if(Platform.isAndroid){
                debugPrint("on message Android *************************************** 1111111");
                // (message.notification != null) is commented out as it prevents navigationHome error when announcement get sent
                if (message != null && message.notification != null  &&  message.notification.title.contains("Chat:")) {
                  if (message.data != null) {
                    // this condition is to add the new created channel if its not in the users channels set
                    if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.data["channel_name"]) == false){
                      Provider.of<ChatProvider>(context, listen: false).clearChannels();
                      Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
                    }
                    // commented this part out since there is a listen already on the only for Android iOS requires this part
                    // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                    //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                    //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                    //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                    // }

                    /// to show local Notification when chat Message comes for Android
                    if(message != null && message.data['is_announcement'] == "false" &&
                        message.data["senderId"] != Provider.of<UserProvider>(context, listen: false).userData.id
                        && Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {

                      MyApp.flutterLocalNotificationsPlugin.show(
                          message.notification.hashCode,
                          "${message.data['text']}",
                          "",
                          MyApp.androidNotificationDetails
                      );
                    }


                  }


                }
                else if(message != null && message.notification!= null  && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
                  Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                }

                // handled for Android but still need to be handled for ios
                if(message != null && message.data['notification_type'].toString()=='100'){
                  // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                  // if(message.data['title'] == 'Focused News'){
                  //   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                  // }
                  // else{
                  //   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                  // }

                  Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                      context,
                      pageOffset: 0,
                      trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                      hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                      membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                  Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                }


                /// to show local Notification when an Announcement Message comes for Android
                if(message != null && message.data['is_announcement'] == "true" &&
                    message.data["sender_id"] != Provider.of<UserProvider>(context, listen: false).userData.id
                    &&  Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]){

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

              else if(Platform.isIOS){
                debugPrint("on message iOS *************************************** 1111111");

                // handling news notification for iOS is different as the bdy for the notification is different
                if(await message != null && message.notification != null && await message.notification.title == 'Focused News'){
                  // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                  // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                  Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                }
                else if (await message != null && message.notification != null && await message.notification.title == 'My Organisation'){
                  // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                  // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();

                  Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                      context,
                      pageOffset: 0,
                      trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                      hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                      membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                }


                if (await message != null && await message.category != null) {
                  if(message.category.contains("channel-")){
                    if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
                      Provider.of<ChatProvider>(context, listen: false).clearChannels();
                      Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                        Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                      });
                    }

                    // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                    // if (message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                    //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                    //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                    //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                    // }

                    String iOSNotificationPayload = message.messageId.toString();
                    var startOfsenderId = "{title: ";
                    var endOfsenderId = ",";


                    var startIndex = iOSNotificationPayload.indexOf(startOfsenderId);
                    var endIndex = iOSNotificationPayload.indexOf(endOfsenderId, startIndex + startOfsenderId.length);
                    String senderName = iOSNotificationPayload.substring(startIndex + startOfsenderId.length, endIndex);


                    /// to show local Notification when chat Message comes for iOS
                    if(message != null && message.notification != null &&
                        senderName != user["name"]
                        &&  Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {

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
                if(await message != null && await message.messageId != null){
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
                  String iOSNotificationPayload = message.messageId.toString();
                  var startOfsenderId = "sender_id:";
                  var endOfsenderId = "}";

                  var startIndex = iOSNotificationPayload.indexOf(startOfsenderId);
                  var endIndex = iOSNotificationPayload.indexOf(endOfsenderId, startIndex + startOfsenderId.length);
                  String senderId = iOSNotificationPayload.substring(startIndex + startOfsenderId.length, endIndex).trim();

                  var startOfisAnnouncement = "is_announcement:";
                  var endOfsAnnouncement = ",";

                  var startIndexisAnnouncement = iOSNotificationPayload.indexOf(startOfisAnnouncement);
                  var endIndexisAnnouncement = iOSNotificationPayload.indexOf(endOfsAnnouncement, startIndexisAnnouncement + startOfisAnnouncement.length);
                  isAnnouncement = iOSNotificationPayload.substring(startIndexisAnnouncement + startOfisAnnouncement.length, endIndexisAnnouncement).trim();

                  if((isAnnouncement == "true" || isAnnouncement == "tru") && senderId != Provider.of<UserProvider>(context, listen: false).userData.id){

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
                if(await message != null && await message.category == null && isAnnouncement != "true" && isAnnouncement != "tru"){
                  Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                }

              }

            });

            // this Method is to do what's needed when Notification is clicked if the app is in the background
            FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
              if(Platform.isAndroid){
                if (message != null && message.notification.title.contains("Chat:")) {

                  Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_)async{

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
                    if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.data["channel_name"]) == false){
                      Provider.of<ChatProvider>(context, listen: false).clearChannels();
                      Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
                    }
                    /// this line is new
                    ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);

                    if(Provider.of<CallProvider>(context, listen: false).hasPushedToCallScreen == false){
                      Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
                      Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                    }

                  });


                  // commented this part out since there is a listen already on the only for Android iOS requires this part
                  // if (message.data['senderId'] != Provider.of<UserProvider>(context, listen: false).userData.id &&
                  //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.data["channel_name"]) {
                  //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.data["channel_name"]);
                  //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                  // }
                }else if(message != null && message.notification!= null && !message.notification.title.contains("Chat:") && message.data['notification_type'].toString() != '100'){
                  Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                }

                // handling News notifications
                else if(message != null && message.data['notification_type'].toString()=='100'){
                  // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                  // if(message.data['title'] == 'Focused News'){
                  //   Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                  // }
                  // else{
                  //   Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();
                  // }

                  Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                      context,
                      pageOffset: 0,
                      trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                      hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                      membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                  Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                }
              }
              else if(Platform.isIOS){
                debugPrint("*************************************** 1111111");
                if (await message != null && await message.category != null) {

                  if(message.category.contains("channel-")){
                    Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_) async{
                      // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                      //   "conversation_messages": null,
                      //   "channel": null,
                      //   "channel_name": message.category,
                      //   "pn":null,
                      //   "private_chat_user": null,
                      //   "type": null,
                      //   "current_user_id": null
                      // });

                      if(Provider.of<ChatProvider>(context, listen: false).channelNamesSet.contains(message.category) == false){
                        Provider.of<ChatProvider>(context, listen: false).clearChannels();
                        Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context).then((_) {
                          Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                        });
                      }
                      /// this line is new
                      ///Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);

                      if(Provider.of<CallProvider>(context, listen: false).hasPushedToCallScreen == false){
                        Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
                        Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                      }
                    });
                    // this condition is to check if this channel is new or already included to current user's channels


                    // this part is required for iOS as listen on chat provider is not working for the first msg it will not be read till the user refresh the chat tab
                    // if(message.senderId != Provider.of<UserProvider>(context, listen: false).userData.id &&
                    //     Provider.of<ChatProvider>(context, listen: false).openedChannelName != message.category) {
                    //   Provider.of<ChatProvider>(context, listen: false).setNewMSGforChannelToTrue(message.category);
                    //   Provider.of<ChatProvider>(context, listen: false).updateUnreadMsgsCount();
                    // }

                  }
                }

                // handling news notification for iOS is different as the body for the notification is different
                if(await message != null && message.notification != null && await message.notification.title == 'Focused News'){
                  // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                  // Provider.of<NewsProvider>(context, listen: false).increaseFocusedNewsNotificationCount();
                  Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: 0, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id']);
                }
                if (await message != null && message.notification != null && await message.notification.title == 'My Organisation'){
                  // Provider.of<NewsProvider>(context, listen: false).increaseNewsNotificationCount();
                  // Provider.of<NewsProvider>(context, listen: false).increaseMyOrganisationNewsNotificationCount();

                  Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(
                      context,
                      pageOffset: 0,
                      trustId: Provider.of<UserProvider>(context, listen: false).userData.trust['id'],
                      hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds,
                      membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);
                }


                if(await message != null && await message.category == null){
                  Provider.of<UserProvider>(context, listen: false).increaseBackendNotificationCount();
                }

              }


            });
          }




        Navigator.pushNamed(context, NavigationHome.routeName);

        getUserSurveysLink();
        AnalyticsManager.track('signup_success');
        notifyListeners();
      } else {
        Map<String, dynamic> responseJson = json.decode(responseString);

        showAnimatedCustomDialog(context,
            title: "Error", message: responseJson["message"]);
        AnalyticsManager.track('signup_fail');

      }
    } catch (e) {
      this.stage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
  }

  List<UserTypeModel> _userTypes = [];
  List<UserTypeModel> get userTypes => this._userTypes;

  setUserTypes(List<UserTypeModel> userTypes) {
    _userTypes = userTypes;
  }

  Future getUserTypes({country_code = 'GB'}) async {
    this.userTypesStage = UsersStage.LOADING;
    final url = '$appDomain/user_types?country_code=$country_code';
    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
    };

    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // http.Response response = await httpp.get(
      //     '$appDomain/user_types?country_code=$country_code',
      //     headers: headers);
      //
      // var responseString;

      String responseString;
      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      var responseList = json.decode(responseString);

      if (response.statusCode == 200) {
        // responseString = await response.body;
        List<dynamic> responseList = json.decode(responseString);
        this.userTypesStage = UsersStage.DONE;

        List<UserTypeModel> types = [];
        responseList.forEach((element) {
          UserTypeModel type = UserTypeModel.fromJson(element);
          types.add(type);
        });
        setUserTypes(types);
      } else {
        this.userTypesStage = UsersStage.ERROR;
      }
    } on Exception catch (e) {
      this.userTypesStage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  List<CountryModel> _countries = [];
  List<CountryModel> get countries => this._countries;

  setCountries(List<CountryModel> countries) {
    _countries = countries;
  }

  Future getCountries() async {
    this.countriesStage = UsersStage.LOADING;
    String url = '$appDomain/countries';
    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
    };

    // if(!kIsWeb){
    //   headers['Platform']= MyApp.platformIndex;
    // }

    var responseString;

    try {
      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      var responseList = json.decode(responseString);
      print('countriesssss ${responseList}');

      if (response.statusCode == 200) {
        this.countriesStage = UsersStage.DONE;

        List<CountryModel> countries = [];
        responseList.forEach((element) {
          CountryModel type = CountryModel.fromJson(element);
          countries.add(type);
        });
        setCountries(countries);
      } else {
        this.countriesStage = UsersStage.ERROR;
      }
    } on Exception catch (e) {
      this.countriesStage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  List<AvailablePosition> _availablePositions = [];
  List<AvailablePosition> get availablePositions => this._availablePositions;

  setPositions(List<AvailablePosition> availablePositions) {
    _availablePositions = availablePositions;
  }

  Future getPositions({context, locale, role_type, trustId}) async {
    this.specialitiesStage = UsersStage.LOADING;
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    String url =
        '$appDomain/available_positions?role_type=$role_type&trust_id=$trustId';
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final httpp = new IOClient(ioc);

    http.Response response = await httpp.get(url, headers: headers);
    var responseString;
    try {
      if (response.statusCode == 200) {
        responseString = response.body;
        List<dynamic> responseList = json.decode(responseString);

        this.specialitiesStage = UsersStage.DONE;

        List<AvailablePosition> positions = [];
        responseList.forEach((element) {
          AvailablePosition position = AvailablePosition.fromJson(element);
          positions.add(position);
        });
        setPositions(positions);
        notifyListeners();
      } else {
        this.specialitiesStage = UsersStage.ERROR;
        debugPrint(response.reasonPhrase);
        notifyListeners();
      }
    } on Exception catch (e) {
      this.specialitiesStage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  String _editedFirstName;
  String get editedFirstName => this._editedFirstName;

  String _editLastName;
  String get editedLastName => this._editLastName;

  String _editedProfilePic;
  String get editedProfilePic => this._editedProfilePic;

  String _editedEmail;
  String get editedEmail => this._editedEmail;

  String _editedPhoneNo;
  String get editedPhoneNo => this._editedPhoneNo;

  String _editedEmployeeNo;
  String get editedEmployeeNo => this._editedEmployeeNo;

  setEditProfileData(
      {String firstName,
      String lastName,
      String profilePic,
      String email,
      String phoneNumber,
      String employeeNumber}) {
    this._editedFirstName = firstName;
    this._editLastName = lastName;
    this._editedProfilePic = profilePic;
    this._editedEmail = email;
    this._editedPhoneNo = phoneNumber;
    this._editedEmployeeNo = employeeNumber;
    notifyListeners();
  }



  Future updateProfile(
    BuildContext context, {
    String firstName, // analytics done
    String lastName, // analytics done
    String email, // analytics done
    String levelId, // analytics done
    String phoneNumber, // analytics done
    employeeNumber, // analytics done
    trustId,
    hospitals, // analytics done
    languages, // analytics done
    skills, // analytics done
    wards, // analytics done
    List<String> memberships, // analytics done
    List<String> roles, // analytics done
    userType,
    String dialingCode = "44",
    String minimumLevelId,
    String profilePic,
    isFromCompleteProfile = false,
    isUpdatingLevelsFromCompleteProfile = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    String url = userType == 0
        ?
    '$appDomain/bank_admin'
        :
    userType == 1
        ?
    '$appDomain/nurse'
        :
    userType == 2
            ?
    '$appDomain/doctors'
            :
    '$appDomain/basic_user';

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };


    Map<String, dynamic> body = {
      'first_name':
          firstName == null || firstName == '' ? userData.firstName.toString() : firstName.toString(),
      'last_name':
          lastName == null || lastName == '' ? userData.lastName.toString() : lastName.toString(),
      'phone_number': phoneNumber == null || phoneNumber == ''
          ? userData.phone.toString()
          : phoneNumber.toString(),
      'employee_number': employeeNumber == null || employeeNumber == ''
          ? userData.employee_number.toString()
          : employeeNumber.toString(),
      'email': email == null || email == '' ? userData.email.toString() : email.toString(),
      'trust_id': trustId.toString() ?? userData.trust["id"].toString(),
      'hospitals': hospitals.toString(),
    };

    if (profilePic != null && profilePic != "") {
      body['profile_image'] = profilePic;
    }

    if(roles != null && roles.isNotEmpty){
      body['roles'] = roles;
    }

    if(memberships != null && memberships.isNotEmpty){
      body['memberships'] = memberships;
    }

    if(skills != null && skills.isNotEmpty){
      body['skills'] = skills;
    }

    if(wards != null && wards.isNotEmpty){
      body['wards'] = wards;
    }

    if(languages != null && languages.isNotEmpty){
      body['languages'] = languages;
    }

    if (userType == 2) {
      if (levelId != null) {
        body['grade_id'] = levelId;
      }
      if (minimumLevelId != null) {
        body['minimum_accepted_grade_id'] = minimumLevelId;
      }
    } else {
      if (levelId != null) {
        body['band_id'] = levelId;
      }
      if (minimumLevelId != null) {
        body['minimum_accepted_band_id'] = minimumLevelId;
      }
    }

    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);

      // http.Response response =
      //     await httpp.put("$url", headers: headers, body: json.encode(body));

      var request = http.Request('PUT', Uri.parse(url));
      request.headers.addAll(headers);
      request.body = json.encode(body);
      http.StreamedResponse response = await request.send();
      String responseString = await response.stream.bytesToString();
      print('updateeeeee ${body}');
      var responseJson = json.decode(responseString);

      if (response.statusCode == 200) {
        if(profilePic != null && firstName != ''){
          AnalyticsManager.track('profile_picture_changed');
        }
        if(firstName != null && firstName != ''){
          AnalyticsManager.track('profile_first_name_changed');
        }
        if(lastName != null && lastName != ''){
          AnalyticsManager.track('profile_last_name_changed');
        }
        if(email != null && email != ''){
          AnalyticsManager.track('profile_email_changed');
        }
        if(phoneNumber != null && phoneNumber != ''){
          AnalyticsManager.track('profile_phone_changed');
        }
        if(hospitals != null && hospitals.isNotEmpty){
          AnalyticsManager.track('profile_hospitals_changed');
        }
        if(roles != null && roles.isNotEmpty){
          AnalyticsManager.track('profile_roles_changed');
        }
        if(memberships != null && memberships.isNotEmpty){
          AnalyticsManager.track('profile_memberships_changed');
        }
        if(languages != null && languages.isNotEmpty){
          AnalyticsManager.track('profile_languages_changed');
        }
        if(wards != null && wards.isNotEmpty){
          AnalyticsManager.track('profile_areas_work_changed');
        }
        if(skills != null && skills.isNotEmpty){
          AnalyticsManager.track('profile_skills_changed');
        }
        if (userType == 2) {
          if((minimumLevelId != null || minimumLevelId == '') && (userData.minAcceptedGrade != null && minimumLevelId != userData.minAcceptedGrade['id'])){
            AnalyticsManager.track('profile_minimum_band_changed');
          }
        }
        if (userType == 1) {
          if((minimumLevelId != null || minimumLevelId == '') && (userData.minAcceptedBand != null && minimumLevelId != userData.minAcceptedBand['id'])){
            AnalyticsManager.track('profile_minimum_band_changed');
          }
        }
        if (userType == 2) {
          // print(userData.grade);
          if((levelId != null || levelId == '') && (userData.grade != null && levelId != userData.grade['id'])){
            AnalyticsManager.track('profile_band_changed');
          }
        }
        if (userType == 1) {
          if((levelId != null || levelId == '') && (userData.band != null && levelId != userData.band['id'])){
            AnalyticsManager.track('profile_band_changed');
          }
        }


        getUser(context).then((_) {

            if(isFromCompleteProfile){
              if(userData.profileCompleted){
                Navigator.pushReplacementNamed(context, Congrats.routeName);
              }
              // else{
              //   Navigator.pushReplacementNamed(context, MyAccountsScreen.routName);
              // }
            } else{
              Navigator.pushReplacementNamed(context, EditProfile.routeName);
            }

        });
      } else {
        showAnimatedCustomDialog(context,
            title: "Error", message: responseJson["message"]);
      }
      notifyListeners();
    } catch (e) {
      this.stage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
  }

  List<Membership> _memberships = [];
  List<Membership> get memberships => this._memberships;

  setMemberships(List<Membership> memberships) {
    _memberships = memberships;
  }

  Future getMemberships(
      {context, locale, role_type, userType, countryCode}) async {
    this.membershipsStage = UsersStage.LOADING;
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    String url =
        '$appDomain/memberships?role_type=$role_type&userType=$userType';

    var responseString;
    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // http.Response response = await httpp.get(url, headers: headers);

      var request =
      http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // responseString = response.body;
        List<dynamic> responseList = json.decode(responseString);
        this.membershipsStage = UsersStage.DONE;

        List<Membership> memberships = [];
        responseList.forEach((element) {
          Membership membership = Membership.fromJson(element);
          memberships.add(membership);
        });
        setMemberships(memberships);
        notifyListeners();
      } else {
        this.membershipsStage = UsersStage.ERROR;
        notifyListeners();
      }
    } on Exception catch (e) {
      this.membershipsStage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  List<Level> _bands = [];
  List<Level> get bands => this._bands;

  setBands(List<Level> bands) {
    _bands = bands;
  }

  List<Level> _grades = [];
  List<Level> get grades => this._grades;

  setGrades(List<Level> grades) {
    _grades = grades;
  }

  List<Skill> _skills = [];
  List<Skill> get skills => this._skills;

  setSkills(List<Skill> skills) {
    _skills = skills;
  }

  List<Language> _languages = [];
  List<Language> get languages => this._languages;

  setLanguages(List<Language> languages) {
    _languages = languages;
  }

  Future getCompetencies({context}) async {
    this.competenciesStage = UsersStage.LOADING;
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    String url =
        '$appDomain/competencies?role_type=${userData.roleType}&trust_id=${userData.trust["id"]}';

    var responseString;
    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      // http.Response response = await httpp.get(url, headers: headers);

      var request =
      http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // responseString = response.body;
        Map<String, dynamic> responseData = json.decode(responseString);

        List<dynamic> jsonBands = responseData['bands'];
        List<dynamic> jsonGrades = responseData['grades'];
        List<dynamic> jsonSkills = responseData['skills'];
        List<dynamic> jsonLanguages = responseData['languages'];

        List<Level> bands = [];
        jsonBands.forEach((element) {
          Level band = Level.fromJson(element);
          bands.add(band);
        });
        setBands(bands);

        List<Level> grades = [];
        jsonGrades.forEach((element) {
          Level grade = Level.fromJson(element);
          grades.add(grade);
        });
        setGrades(grades);

        List<Skill> skills = [];
        jsonSkills.forEach((element) {
          Skill skill = Skill.fromJson(element);
          skills.add(skill);
        });
        setSkills(skills);

        List<Language> languages = [];
        jsonLanguages.forEach((element) {
          Language language = Language.fromJson(element);
          languages.add(language);
        });
        setLanguages(languages);
        notifyListeners();
        this.competenciesStage = UsersStage.DONE;
      } else {
        this.competenciesStage = UsersStage.ERROR;
        showAnimatedCustomDialog(context,
            title: "Error", message: response.reasonPhrase);
        notifyListeners();
      }
    } on Exception catch (e) {
      this.competenciesStage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  List<HospitalForUserAttributes> _hospitalsForAttributes = [];
  List<HospitalForUserAttributes> get hospitalsForAttributes =>
      this._hospitalsForAttributes;

  setWards(List<HospitalForUserAttributes> list) {
    _hospitalsForAttributes = list;
  }

  Future getAttributes({context, attributeType}) async {
    this.hospitalsStage = UsersStage.LOADING;
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

    String url = '$appDomain/profile/attributes/$attributeType';

    var responseString;

    try {
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      // http.Response response = await httpp.get(url, headers: headers);

      var request =
      http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // responseString = response.body;

        var responseData = json.decode(responseString);

        List<dynamic> jsonWards = responseData;

        List<HospitalForUserAttributes> hospitalsForAreaOfWork = [];

        jsonWards.forEach((element) {
          HospitalForUserAttributes ward =
              HospitalForUserAttributes.fromJson(element);
          hospitalsForAreaOfWork.add(ward);
        });
        setWards(hospitalsForAreaOfWork);
        this.hospitalsStage = UsersStage.DONE;
        notifyListeners();
        // return hospitals;
      } else {
        this.hospitalsStage = UsersStage.ERROR;
        showAnimatedCustomDialog(context,
            title: "Error", message: response.reasonPhrase);
        notifyListeners();
      }
    } on Exception catch (e) {
      this.hospitalsStage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future resendEmailVerification({context, email, scaffoldKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var body = json.encode({'email': email});
    //}

    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);
      http.Response response = await httpp.post(
          "$appDomain/resend_email_verification",
          headers: headers,
          body: body);

      var responseJson = json.decode(response.body);
      if (response.statusCode == 200) {
        showSnack(
            context: context,
            millSeconds: 3900,
            msg: '${responseJson['message']}',
            fullHeight: 60.0,
            isFloating: true,
            scaffKey: scaffoldKey);
        AnalyticsManager.track('profile_verification_ask_support_submit');
      } else {
        showSnack(
            context: context,
            millSeconds: 3000,
            msg: 'Something is wrong !',
            fullHeight: 30.0,
            isFloating: true,
            scaffKey: scaffoldKey);
      }
    } catch (e) {
      this.stage = UsersStage.ERROR;
      debugPrint(e.toString());
    }
  }

  Future answerSurvey(BuildContext context, questionId,
  {String answerId}) async {
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


    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);


      String url = "$appDomain/user_survey_responses?user_survey_question_id=$questionId";
      if(answerId != null && answerId.isNotEmpty){
        url = "$appDomain/user_survey_responses?user_survey_question_id=$questionId&user_survey_answer_id=$answerId";
      }

      http.Response response = await httpp.post(
          Uri.parse(url),
          headers: headers,
      );

      debugPrint("the url for answering pop-up surveys  ---> $url");

      if (response.statusCode == 200) {
        debugPrint("the response for answering pop-up surveys  ---> ${response.body}");
        AnalyticsManager.track('survey_answered');

      } else {
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }



  SurveyModel _currentSurvey;
  SurveyModel get currentSurvey => this._currentSurvey;



  void setCurrentSurvey(SurveyModel survey){
    _currentSurvey = survey;
    notifyListeners();
  }

  void clearSurveyAfterAnswering(){
    _currentSurvey = null;
    notifyListeners();
  }

  Future getPopUpSurveys(BuildContext context) async {
    this.stage = UsersStage.LOADING;
    final url = '$appDomain/user_survey_questions';

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    if (storedUser != null) {
      String token = jsonDecode(storedUser)['token'];

      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=2',
        'Content-Type': 'application/json',
        'Authorization': 'Token token=$token'
      };
      if(!kIsWeb){
        headers['Platform'] = MyApp.platformIndex;
      }

      var responseString;
      try {
        // final ioc = new HttpClient();
        // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        // final httpp = new IOClient(ioc);
        //
        // http.Response response = await httpp.get('$appDomain/user_survey_questions', headers: headers);
        //
        // responseString = response.body;
        String responseString;
        var request = http.MultipartRequest('GET', Uri.parse(url));
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        responseString = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          List<dynamic> responseList = json.decode(responseString);
          debugPrint('getPopUpSurveys ${responseList.toString()}');
          if (responseList.isNotEmpty) {
            setCurrentSurvey(SurveyModel.fromJson(responseList.first));
            showSurvey(context,currentSurvey);
          }
        }

        this.stage = UsersStage.DONE;
      } catch (e) {
        debugPrint(e.toString());
        this.stage = UsersStage.ERROR;
      }
      notifyListeners();
    }
  }


  nhspLoginToUpdateNhspStaffId(BuildContext context,{@required String username,@required String password})async{
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");

    if (storedUser != null) {
      final String token = jsonDecode(storedUser)['token'];
      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=1',
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Content-Length': "93",
        'Accept-Language': "en",
        'Authorization': 'Token token=$token'
      };
      if(!kIsWeb){
        headers['Platform'] = MyApp.platformIndex;
      }

      try {
        final ioc = new HttpClient();
        ioc.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        final httpp = new IOClient(ioc);

        final String url = userData.roleType == 3 ? '$appDomain/basic_user' : userData.roleType == 1 ? '$appDomain/nurse' : '$appDomain/doctors';

        final body = json.encode({"nhsp_web_user_id":"$username","nhsp_password":"$password","employee_number_unavailable":false});
        http.Response response =
        await httpp.put(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          getUser(context);
        } else {
          showAnimatedCustomDialog(context,
              title: "Error!", message: 'The username or password you entered was incorrect.');
        }
  }
  catch(e){
        debugPrint(e.toString());
  }
  notifyListeners();
  }

}

}
