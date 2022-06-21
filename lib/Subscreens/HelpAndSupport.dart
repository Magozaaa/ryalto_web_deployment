// ignore_for_file: file_names, prefer_null_aware_operators, curly_braces_in_flow_control_structures, prefer_adjacent_string_concatenation

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';

class HelpAndSupport extends StatefulWidget{

  static const routName = "/helpAndSupport_Screen";

  const HelpAndSupport({Key key}) : super(key: key);

  @override
  _HelpAndSupportState createState() => _HelpAndSupportState();
}

class _HelpAndSupportState extends State<HelpAndSupport> {

  final _formKey = GlobalKey<FormState>();
  var _enableBorder = true;

  _textFieldBorder(){
  return _enableBorder ?
    OutlineInputBorder(
    borderSide: BorderSide(width: 2.0,color: Theme.of(context).primaryColor),
    borderRadius: textFieldBorderRadius) : null;
  }
  String msg='',_email,_firstName,_lastName,_phone;
  _sendMail({email,id,organisation}) async {
    // Android and iOS
    String uri;

    if (!kIsWeb) {
      if(Platform.isIOS){
        final mailtoLink = Mailto(
          to: ['support@ryalto.zendesk.com'],
          subject: 'Support',
          body: msg = id != null
              ?
          "Email : $email      User id : $id      Organisation : $organisation      Message : $msg"
              :
          "Email : $email      Message : $msg",
        );
        if (await canLaunch("$mailtoLink")) {
          await launch("$mailtoLink");
          AnalyticsManager.track('landing_ask_support_submit');
        } else {
          debugPrint('Could not launch $mailtoLink');
        }
      }else{
        msg = id != null
            ?
        "Email : $email\n" + "\n" + "User id : $id" + "\n" + "Organisation : $organisation" + "\n"+ "Message : $msg"
            :
        "Email : $email" + "\n"+  "Message : $msg";
        uri = 'mailto:${"support@ryalto.zendesk.com?subject=Support&body=$msg"}';
        if (await canLaunch(uri)) {
          await launch(uri);
          AnalyticsManager.track('landing_ask_support_submit');
        } else {
          debugPrint('Could not launch $uri');
        }
      }
    }



  }

  @override
  void initState() {
    if(Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);
    AnalyticsManager.track('landing_ask_support');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context).userData;

    return WillPopScope(
      onWillPop: () {
      Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onHorizontalDragEnd: (DragEndDetails details){
          if (Platform.isIOS) {
            if (details.primaryVelocity.compareTo(0) == 1) {
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: screenAppBar(context, media, appbarTitle: const Text("Support"), showLeadingPop: true, hideProfilePic: true,
                onBackPressed: ()=>  kIsWeb ? Navigator.pushReplacementNamed(context, WebMainScreen.routeName) : Navigator.pushReplacementNamed(context, NavigationHome.routeName)),
                // onBackPressed: ()=> Navigator.pop(context)),
                    //Navigator.push(context, MaterialPageRoute(builder: (context)=> NavigationHome(idx: 1,)))),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 0 : media.width * 0.07),
              child: Align(
                alignment: AlignmentDirectional.topCenter,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 25.0,),
                      Text("Need help?", style: style1,),
                      const SizedBox(height: 18.0,),
                      Text("Fill out the form below and we'll get back to you as soon as possible",
                      style: style3,),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  width: kIsWeb ? buttonWidth : null,
                                  child: TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    initialValue: userData != null ? userData.firstName:null,
                                    onChanged: (val)=>_firstName=val,
                                    decoration: InputDecoration(
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText: "First Name*",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  width: kIsWeb ? buttonWidth : null,
                                  child: TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    initialValue: userData != null ? userData.lastName:null,
                                    onChanged: (val)=>_lastName=val,
                                    decoration: InputDecoration(
                                        focusedBorder:_textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom:_enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText: "Last Name*",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  width: kIsWeb ? buttonWidth : null,
                                  child: TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Required';
                                      }else if(text.contains("@") == false){
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Invalid Email';
                                      }
                                      return null;
                                    },
                                    initialValue: userData != null ? userData.email : null,
                                    onChanged: (val)=>_email=val,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                        border:_textFieldBorder(),
                                        hintText: "Email*",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  width: kIsWeb ? buttonWidth : null,
                                  child: TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText: "Message*",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                    onChanged: (val){
                                      setState(() {
                                        msg=val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10.0,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: roundedButton(context: context, title: "Send",
                            buttonWidth: kIsWeb ? buttonWidth : null,

                            onClicked: (){
                          if (_formKey.currentState.validate()) {
                            // TODO submit
                            _sendMail(email:userData != null ? userData.email:_email,id: userData != null ? userData.id : null,organisation: userData != null ? userData.trust["name"] : null);
                          }
                        }),
                      )

                    ],
                  ),
                ),
              ),
            )
        ),
      ),
    );
  }
}