// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/Providers/ShakingValidator.dart';
import 'package:rightnurse/main.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPersonalInformation extends StatefulWidget {
  static const String routeName = "/RegisterPersonalInformation_Screen";

  const RegisterPersonalInformation({Key key}) : super(key: key);

  @override
  _RegisterPersonalInformationState createState() =>
      _RegisterPersonalInformationState();
}

class _RegisterPersonalInformationState
    extends State<RegisterPersonalInformation> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const eventStream = EventChannel('ryalto.com/streamApnsTokenChange');
  StreamSubscription<dynamic> tokenChangedStream;

  String dropdownValue ;
  bool _showPass = true;
  String _token;
  Map passedData = {};
  bool _isInit = true;
  bool _isSubmitting = false;
  List<String> codes=[];

  final List<ShakingErrorController> controllers = [
    ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
  ];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController  _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  // static FirebaseAnalytics analytics = FirebaseAnalytics();
  // static FirebaseAnalyticsObserver observer =
  // FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    // analytics.(name: name)
    
    super.initState();

    if (!kIsWeb) {
      if (Platform.isIOS) {
        tokenChangedStream = eventStream.receiveBroadcastStream().listen((event) {
          final token = event as String;
          debugPrint('---new apns token: $token');
          _token = token;
        });
      } else {
        _firebaseMessaging.getToken().then((token) {
          _token = token;

        });
      }
    }
    // this part to force user not to add "0" before number in case selected country is U K
    _phoneNumberController.addListener(() {
      if(countryDialingCode == "+44" && _phoneNumberController.text.startsWith("0")){
        _phoneNumberController.clear();
      }
    });
  }
String countryDialingCode="+44";

  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    tokenChangedStream?.cancel();
    tokenChangedStream = null;
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  submit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _isSubmitting = true;
      });

      print(_firstNameController.text);
      print(_lastNameController.text);
      print(_emailController.text);
      print(_passwordController.text);
      print(_phoneNumberController.text);

      if (_firstNameController.text == null || _firstNameController.text.isEmpty ||
          _lastNameController.text == null || _lastNameController.text.isEmpty ||
          _emailController.text == null || _emailController.text.isEmpty ||
          _passwordController.text == null || _passwordController.text.isEmpty ||
          _phoneNumberController.text == null || _phoneNumberController.text.isEmpty)
      {
        setState(() {
          _isSubmitting = false;
        });
      }
      else{
        await Provider.of<UserProvider>(context, listen: false).register(context,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
            password: _passwordController.text,
            trustId: passedData['trustId'],
            hospitals: passedData['hospitalsIds'],
            timezone: passedData['timezone'],
            userType: passedData['userRoleType'],
            countryCode: passedData['countryCode'],
            dialingCode: countryDialingCode,
            deviceToken: _token
          ).then((_) {
          setState(() {
            _isSubmitting = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onHorizontalDragEnd: (DragEndDetails details){
        if (!kIsWeb) {
          if (Platform.isIOS) {
            if (details.primaryVelocity.compareTo(0) == 1) {
              Navigator.pop(context);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor:Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context)),
          title: const Text(
            'Personal Information',
            style: TextStyle(
                color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          height: media.height,
          width: media.width,
          color: Colors.white,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Colors.white,
                          accentColor: Colors.white,
                          hintColor: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10, left: 40),
                              child: Container(
                                height: 45,
                                // constraints: BoxConstraints.tight(const Size(200, 50)),
                                child: TextFormField(
                                  controller: _firstNameController,
                                  validator: (String value) {
                                    if (value == null || value.isEmpty) {
                                      controllers[0].shakeErrorText();
                                    } else {}
                                    return null;
                                  },
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(color: Colors.grey[800]),
                                  decoration: InputDecoration(
                                    hintText: 'First Name',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        ),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[400])),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[500]),
                                    ),
                                  ),
                                  // onSaved: (String value) => _firstName = value,
                                  // onChanged: (String value) => _firstName = value,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: ShakingErrorText(
                              controller: controllers[0],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Colors.white,
                          accentColor: Colors.white,
                          hintColor: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10, left: 40),
                              child: Container(
                                height: 45,
                                // constraints: BoxConstraints.tight(const Size(200, 50)),
                                child: TextFormField(
                                  controller: _lastNameController,
                                  validator: (String value) {
                                    if (value == null || value.isEmpty) {
                                      controllers[1].shakeErrorText();
                                    } else {}
                                    return null;
                                  },
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(color: Colors.grey[800]),
                                  decoration: InputDecoration(
                                    hintText: 'Last Name',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        ),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[400])),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[500]),
                                    ),
                                  ),
                                  // onSaved: (String value) => _lastName = value,
                                  // onChanged: (String value) => _lastName = value,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: ShakingErrorText(
                              controller: controllers[1],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Colors.white,
                          accentColor: Colors.white,
                          hintColor: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10, left: 40),
                              child: SizedBox(
                                height: 45,
                                // constraints: BoxConstraints.tight(const Size(200, 50)),
                                child: TextFormField(
                                  controller: _emailController,
                                  validator: (String value) {
                                    if (value == null || value.isEmpty || !value.contains("@")) {
                                      controllers[2].shakeErrorText();
                                      return "Email is not correct";
                                    } else {
                                      return null;
                                    }

                                  },
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(color: Colors.grey[800]),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        ),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[400])),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[500]),
                                    ),
                                  ),
                                  // onSaved: (String value) => _email = value,
                                  // onChanged: (String value) => _email = value,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: ShakingErrorText(
                              controller: controllers[2],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Theme(
                      data: ThemeData(
                          primaryColor: Colors.white,
                          accentColor: Colors.white,
                          hintColor: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40, right: 10),
                              child: SizedBox(
                                height: 45,
                                // constraints: BoxConstraints.tight(const Size(200, 50)),
                                child: TextFormField(
                                  controller: _passwordController,
                                  validator: (String value) {
                                    if (value == null || value.isEmpty) {
                                      controllers[3].shakeErrorText();
                                    }
                                    else if(value.length<10){
                                      controllers[3].shakeErrorText();
                                      return "Password must be at least 10 characters";
                                    }
                                    else {}
                                    return null;
                                  },
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(color: Colors.grey[800]),
                                  obscureText: _showPass,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        ),
                                    suffixIcon: IconButton(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      icon: Icon(
                                        _showPass
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showPass = !_showPass;
                                        });
                                      },
                                    ),
                                    border: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[500]),
                                    ),
                                  ),
                                  // onSaved: (String value) => _password = value,
                                  // onChanged: (String value) => _password = value,

                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: ShakingErrorText(
                              controller: controllers[3],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Theme(
                          data: ThemeData(
                              primaryColor: Colors.white,
                              accentColor: Colors.white,
                              hintColor: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25,),
                            child: SizedBox(
                              height: 45,
                              // constraints: BoxConstraints.tight( Size(media.width*0.2, 50)),
                              child: CountryCodePicker(
                                onChanged: (val){
                                  setState(() {
                                    countryDialingCode = "$val";
                                    print(countryDialingCode);
                                  });
                                },
                                flagWidth: 60,
                                hideMainText: true,
                                showFlagMain: true,
                                showFlag: true,
                                initialSelection: 'GB',
                                dialogSize: Size(media.width*0.8,media.height*0.6),
                                searchDecoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(width: 2.0, color: Colors.grey),
                                        borderRadius: textFieldBorderRadius),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
                                        borderRadius: textFieldBorderRadius)
                                ),
                                hideSearch: false,
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                showFlagDialog: true,
                                showDropDownButton: false,
                                flagDecoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                                alignLeft: true,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Theme(
                            data: ThemeData(
                                primaryColor: Colors.white,
                                accentColor: Colors.white,
                                hintColor: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, right: 10),
                              child: SizedBox(
                                height: 45,
                                // constraints: BoxConstraints.tight(const Size(200, 50)),
                                child: TextFormField(
                                  controller: _phoneNumberController,
                                  maxLength: 11,
                                  validator: (String value) {
                                    if (value == null || value.isEmpty || value.length <10) {
                                      controllers[4].shakeErrorText();
                                      return "Phone number is not correct";
                                    } else {
                                      return null;
                                    }
                                  },
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(color: Colors.grey[800]),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Phone',
                                    hintStyle: TextStyle(color: Colors.grey[400],),
                                      suffixIcon: IconButton(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        icon: Icon(
                                          Icons.info,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                        onPressed: () {
                                          showAnimatedCustomDialog(context,message: "We use this to verify your identity and keep you updated in case of issues",title: "Why is your phone number required?");
                                        },
                                      ),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[400])),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[500]),
                                    ),
                                  ),
                                  // onSaved: (String value) => _phoneNumber = value,
                                  // onChanged: (String value) => _phoneNumber = value,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: ShakingErrorText(
                            controller: controllers[4],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: Text(
                      '* Required Fields',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Theme(
                        data: ThemeData(
                            primaryColor: Colors.white,
                            accentColor: Colors.white,
                            hintColor: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, right: 40),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                                // constraints: BoxConstraints.tight(const Size(200, 50)),
                                child: Text(
                                  'By continuing, you agree to our',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                // constraints: BoxConstraints.tight(const Size(200, 50)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () async{
                                          if (passedData['trustId'] == "18928788-e701-4b8d-b810-431a20a7dca8" ? await canLaunch(nhspTermsUrl) : await canLaunch(termsUrl) ) {
                                            await launch(passedData['trustId'] == "18928788-e701-4b8d-b810-431a20a7dca8" ? nhspTermsUrl : termsUrl,
                                              forceSafariVC: true,
                                              forceWebView: true,
                                              enableJavaScript: true,
                                            );
                                          }else{
                                            debugPrint("Couldn't launch url");
                                          }
                                        },
                                        child: Text(
                                          'Terms Of Service',
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).primaryColor),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        'and',
                                        style: TextStyle(color: Colors.grey[500]),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async{
                                        if (await canLaunch(privacyPolicyUrl)) {
                                          await launch(privacyPolicyUrl,
                                            forceSafariVC: true,
                                            forceWebView: true,
                                            enableJavaScript: true,
                                          );
                                        }else{
                                          debugPrint("Couldn't launch url");
                                        }
                                      },
                                      child: Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _isSubmitting ? Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 45.0,
                      ),
                    ):roundedButton(
                        context: context,
                        title: "Accept and join",
                        buttonWidth: kIsWeb ? buttonWidth : media.width * 0.8,
                        color: _firstNameController.text == null || _firstNameController.text.isEmpty ||
                            _lastNameController.text == null || _lastNameController.text.isEmpty ||
                            _emailController.text == null || _emailController.text.isEmpty ||
                            _passwordController.text == null || _passwordController.text.isEmpty ||
                            _phoneNumberController.text == null || _phoneNumberController.text.isEmpty ?
                        Colors.grey[300] : Theme.of(context).primaryColor,

                        titleColor: _firstNameController.text == null || _firstNameController.text.isEmpty ||
                            _lastNameController.text == null || _lastNameController.text.isEmpty ||
                            _emailController.text == null || _emailController.text.isEmpty ||
                            _passwordController.text == null || _passwordController.text.isEmpty ||
                            _phoneNumberController.text == null || _phoneNumberController.text.isEmpty ? Colors.grey : Colors.white,
                        onClicked: () {
                          submit();
                          AnalyticsManager.track('signup_submit_clicked');
                        }),
                  ),
                 const SizedBox(height: 25.0,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
