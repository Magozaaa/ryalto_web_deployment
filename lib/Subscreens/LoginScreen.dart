import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/ResetPassowrd.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';


class LoginScreen extends StatefulWidget {
  static const routName = "/LoginScreen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  var _enableBorder = true;
  bool _isLoading = false;
  String _token = '';
  bool _isLoggingWithFingerprint = false;
  List<bool> _showPass;

  static const eventStream = const EventChannel('ryalto.com/streamApnsTokenChange');
  StreamSubscription<dynamic> tokenChangedStream;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      Provider.of<UserProvider>(context, listen: false).getFingerPrintToken();
    }

    if (!kIsWeb) {
      if (Platform.isIOS) {
        tokenChangedStream = eventStream.receiveBroadcastStream().listen((event) {
          final token = event as String;
          debugPrint('---new apns token: $token');
          _token = token;

        });
      }else{
        _firebaseMessaging.getToken().then((String token) {
        _token = token;
        });
        }
    }
    _showPass = [false];
  }

  @override
  void dispose() {
    tokenChangedStream?.cancel();
    tokenChangedStream = null;
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _textFieldBorder() {
    return _enableBorder
        ? OutlineInputBorder(
            borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
            borderRadius: textFieldBorderRadius)
        : null;
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: screenAppBar(context, media,
              appbarTitle: Text("Log In"),
              showLeadingPop: true,
              hideProfilePic: true,
              centerTitle: true,
              onBackPressed: () => Navigator.pop(context)),
          body: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: media.width * 0.07),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 25.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                                  child: Container(
                                    height: 40.0,
                                    width: 400,
                                    child: TextFormField(
                                      controller: _emailController,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          setState(() {
                                            _enableBorder = false;
                                          });
                                          return 'Required';
                                        } else if (text.contains("@") == false) {
                                          setState(() {
                                            _enableBorder = false;
                                          });
                                          return 'Invalid Email';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          focusedBorder: _textFieldBorder(),
                                          contentPadding: EdgeInsets.only(
                                              bottom: _enableBorder == true ? 0.0 : 15.0, left: 15.0, right: 15.0),
                                          border: _textFieldBorder(),
                                          hintText: "Email",
                                          hintStyle: TextStyle(color: Colors.grey, fontFamily: 'DIN')),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                                  child: Container(
                                    height: 40.0,
                                    width: kIsWeb ? 400 : null,
                                    child: TextFormField(
                                      controller: _passwordController,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          setState(() {
                                            _enableBorder = false;
                                          });
                                          return 'Enter your password';
                                        }
                                        return null;
                                      },
                                      obscureText: !_showPass[0],
                                      decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            padding: EdgeInsets.only(bottom: _enableBorder == true ? 0.0 : 15.0),
                                            icon: Icon(
                                              _showPass[0] ? Icons.visibility : Icons.visibility_off,
                                              color: Theme.of(context).primaryColorDark,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showPass[0] = !_showPass[0];
                                              });
                                            },
                                          ),
                                          focusedBorder: _textFieldBorder(),
                                          contentPadding: EdgeInsets.only(
                                              bottom: _enableBorder == true ? 0.0 : 15.0, left: 15.0, right: 15.0),
                                          border: _textFieldBorder(),
                                          hintText: "Password",
                                          hintStyle: TextStyle(color: Colors.grey, fontFamily: 'DIN')),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: Center(
                            child: GestureDetector(
                                onTap: (){
                                  Navigator.pushNamed(context, ResetPassword.routName);
                                  AnalyticsManager.track('forgot_password');
                                },
                                child: Text(
                                  "Forgot your password?",
                                  style: styleBlue,
                                )),
                          ),
                        ),
                        _isLoading
                            ? Center(
                            child: SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                              size: 40.0,
                            ))
                            : SizedBox(
                          width: kIsWeb ? 400 : media.width * 0.7,
                              child: roundedButton(
                              context: context,
                              title: "Log In",
                              buttonWidth: !kIsWeb ? 400 : media.width * 0.7,
                              buttonHeight: media.height * 0.06,
                              onClicked: () {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  Provider.of<UserProvider>(context, listen: false).login(context,
                                      checkFromSettingsScreen: false,
                                      email: _emailController.text,
                                      password: _passwordController.text, token: _token)
                                      .then((_) {
                                    setState(() {
                                      _isLoading = false;
                                      // _emailController.text = "";
                                      // _passwordController.text = "";
                                    });
                                  });
                                  //Navigator.pushNamed(context, NavigationHome.routName);
                                }
                              }),
                            ),
                        (Provider.of<UserProvider>(context, listen: false).havefingerPrint == true ||
                            Provider.of<UserProvider>(context, listen: false).haveFaceprint == true) &&
                            Provider.of<UserProvider>(context, listen: false).canCheckBiometrics == true &&
                            Provider.of<UserProvider>(context, listen: false).saveDataToLoginWithFinger
                            ? Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
                          child: Container(
                            height: 35.0,
                            width: 400,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: media.width * 0.25,
                                    child: Divider(
                                      thickness: 2.0,
                                      color: Colors.black,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                    width: media.width * 0.25,
                                    child: Divider(
                                      thickness: 2.0,
                                      color: Colors.black,
                                    )),
                              ],
                            ),
                          ),
                        )
                            : const SizedBox(),
                        !kIsWeb && (Provider.of<UserProvider>(context, listen: false).havefingerPrint == true ||
                            Provider.of<UserProvider>(context, listen: false).haveFaceprint == true) &&
                            Provider.of<UserProvider>(context, listen: false).canCheckBiometrics == true &&
                            Provider.of<UserProvider>(context, listen: false).saveDataToLoginWithFinger
                            ? _isLoggingWithFingerprint == true
                            ? Center(
                            child: SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                              size: 45.0,
                            ))
                            : roundedButton(
                            buttonWidth: media.width * 0.7, buttonHeight: media.height * 0.06,
                            title: "Login with biometric",
                            icon: Image.asset(
                              Provider.of<UserProvider>(context, listen: false).havefingerPrint == true &&
                                  Provider.of<UserProvider>(context, listen: false).haveFaceprint == false
                                  ? "images/finger.png"
                                  : Provider.of<UserProvider>(context, listen: false).haveFaceprint == true &&
                                  Provider.of<UserProvider>(context, listen: false).havefingerPrint == false
                                  ? "images/face.png"
                                  : "images/finger&face.png",
                              height: 35.0,
                              width: 35.0,
                              color: Colors.white,
                            ),
                            // titleColor: Colors.green,
                            //   titleImgPath:
                            context: context,
                            // buttonColor: Theme.of(context).primaryColor,
                            // buttonTitle: "Login with biometric",
                            // sidesPading: 50.0,
                            onClicked: () async {
                              if ((Provider.of<UserProvider>(context, listen: false).havefingerPrint == true ||
                                  Provider.of<UserProvider>(context, listen: false).haveFaceprint == true) &&
                                  Provider.of<UserProvider>(context, listen: false).canCheckBiometrics == true) {
                                setState(() {
                                  _isLoggingWithFingerprint = true;
                                });
                                Provider.of<UserProvider>(context, listen: false)
                                    .isAuthWithBiometrics(context)
                                    .then((_) {
                                  setState(() {
                                    _isLoggingWithFingerprint = false;
                                  });
                                });
                              } else {
                                showAnimatedCustomDialog(context,
                                    title: "Error", message: "Biometrics are not working correctly on this device");
                              }
                            })
                            : const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.only(top: 40,left: 30,right: 30),
                          child: Center(
                            child:  Text('By logging in and using the app you are agreeing to the Terms and Conditions of Service found under ‘Settings’ when logged in.',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.grey[700]),textAlign: TextAlign.center,),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Expanded(child: Image.asset(Provider.of<UserProvider>(context,listen: false).currentAppBackground,fit: BoxFit.fill,))
            ],
          )),
    );
  }
}

webLogin(){
  return Row(
    children: [
      Expanded(
        flex: 6,
        child: LoginScreen(),
      ),
      Expanded(
        flex: 9,
        child: LoginScreen()
      ),
    ],
  );
}

