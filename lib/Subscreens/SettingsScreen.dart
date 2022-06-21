// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/ThemesProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialFirst.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:websafe_svg/websafe_svg.dart';
import '../main.dart';
import 'Notifications.dart';
import 'Password.dart';

class SettingsScreen extends StatefulWidget{

  static const routName = "/Settings_Screen";

  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  var isVerifingUser = false;
  final TextEditingController _textEditingControllerForPassCheck = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool isSwitched = false;

  bool isDefaultFonSizeEnabled = false;

  getIsDeviceFontEnabled()async{
    final prefs = await SharedPreferences.getInstance();
    isDefaultFonSizeEnabled = prefs.get("isDefaultFonSizeEnabled");
  }

  @override
  void initState() {
    if (!kIsWeb) {
      Provider.of<UserProvider>(context,listen: false).getFingerPrintToken();
    }
    Provider.of<UserProvider>(context,listen: false).bioMetricLogin(context);
    getIsDeviceFontEnabled();
    super.initState();
  }


  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _textEditingControllerForPassCheck.dispose();
    super.dispose();
  }

  showAlertDialogToEnterPassword(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: isVerifingUser?Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor)),
      ):Text(
        "Ok",
        style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "DIN", fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        setState(() {
          isVerifingUser = true;
        });
        Navigator.pop(context);
        String email = Provider.of<UserProvider>(context,listen: false).userData.email;
        await Provider.of<UserProvider>(context, listen: false).login(context,
             checkFromSettingsScreen: true, email: email, token: Provider.of<UserProvider>(context, listen: false).deviceToken ,password: _textEditingControllerForPassCheck.text);
        setState(() {
          isVerifingUser = false;
          _textEditingControllerForPassCheck.text = "";
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text('Please enter your password',
        style: TextStyle(fontWeight: FontWeight.bold),),
      content: SizedBox(
        height: 40,
        width: MediaQuery.of(context).size.width *0.8,
        child: TextField(
          focusNode: _passwordFocusNode,
          cursorColor: Theme.of(context).primaryColor,
          textAlignVertical: TextAlignVertical.top,
          controller: _textEditingControllerForPassCheck,
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
              //Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(15.0),

            ),
          ),
        ),
      )?? const SizedBox(),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final userDataFromProvider = Provider.of<UserProvider>(context);

    return Consumer<ThemesProvider>(
        builder: (context, theme, _) =>WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, NavigationHome.routeName);
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (!kIsWeb) {
            if (Platform.isIOS) {
              if (details.primaryVelocity.compareTo(0) == 1) {
                Navigator.pushReplacementNamed(context, NavigationHome.routeName);
              }
            }
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: screenAppBar(context, media, appbarTitle: const Text("Settings"), showLeadingPop: true, hideProfilePic: true,
                onBackPressed: ()=>  kIsWeb ? Navigator.pushReplacementNamed(context, WebMainScreen.routeName) : Navigator.pushReplacementNamed(context, NavigationHome.routeName)),
            body: SizedBox(
              height: media.height,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 15.0,),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
                          child: Material(
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                            child:
                            Padding(
                              padding: const EdgeInsets.only(bottom:15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  kIsWeb ? const SizedBox()
                                      :
                                  InkWell(
                                    onTap: ()=> Navigator.pushNamed(context, NotificationsScreen.routName),
                                    child: ListTile(
                                      title: Text("Notifications",style: TextStyle(color: Theme.of(context).primaryColor,),),
                                      leading: Padding(
                                        padding: const EdgeInsets.only(left:8.0),
                                          child: WebsafeSvg.asset('images/notification-filled.svg', color: Theme.of(context).primaryColor,width: 20,height: 20,)
                                      ),
                                    ),
                                  ),
                                  kIsWeb ? const SizedBox(): const Divider(
                                    color: Color(0xffF2F2F2),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Password.routName);
                                      AnalyticsManager.track('settings_password');
                                    },
                                    child: SizedBox(
                                      height:40,
                                      child: ListTile(
                                        title: Text("Password",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                        leading: Padding(
                                          padding: const EdgeInsets.only(left: 4),
                                          child: Transform.scale(
                                            child: Icon(Icons.lock, color: Theme.of(context).primaryColor, size: 30.0,),
                                            scale: 0.9,
                                            alignment: Alignment.center,),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),


                        // ************************************************* enable finger print ****************************************************

                        Provider.of<UserProvider>(context, listen: false).canCheckBiometrics == false ?
                        Container():
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Material(
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:6.0),
                              child: ListTile(
                                  title: Text("Biometric Login",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,)),
                                  leading: Transform.scale(
                                    child: Image.asset(
                                      Provider.of<UserProvider>(context, listen: false).havefingerPrint == true &&
                                          Provider.of<UserProvider>(context, listen: false).haveFaceprint == false ? "images/finger.png":
                                      Provider.of<UserProvider>(context, listen: false).haveFaceprint == true &&
                                          Provider.of<UserProvider>(context, listen: false).havefingerPrint == false ? "images/face.png" :
                                      "images/finger&face.png",
                                      color: Theme.of(context).primaryColor,width: 40.0,) ,
                                    scale: 0.9,
                                    alignment: Alignment.center,
                                  ),
                                  trailing: Switch(value: Provider.of<UserProvider>(context, listen: false).saveDataToLoginWithFinger,
                                      activeTrackColor: Colors.grey,
                                      activeColor: Theme.of(context).primaryColor,
                                      onChanged: (val)async{

                                        if(Provider.of<UserProvider>(context, listen: false).saveDataToLoginWithFinger == false){
                                          await showAlertDialogToEnterPassword(context);
                                          //saveDataForFinger =  Provider.of<UserProvider>(context,listen: false).saveDataToLoginWithFinger;
                                        }else{
                                          Provider.of<UserProvider>(context,listen: false).enableFingerPrint(context,false);
                                          setState(() {

                                          });
                                        }
                                      })

                              ),
                            ),
                          ),
                        ),

// ************************************************* enable finger print ****************************************************


                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Material(
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, HelpAndSupport.routName),
                                  child: ListTile(
                                    title: Text("Help & Support",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                    leading: Padding(
                                      padding: const EdgeInsets.only(left:8.0),
                                        child: WebsafeSvg.asset('images/question-filled.svg', color: Theme.of(context).primaryColor,width: 20,height: 20,)
                                    )
                                  ),
                                ),
                                const Divider(
                                  color: Color(0xffF2F2F2),
                                ),
                                kIsWeb ? const SizedBox() : InkWell(
                                  onTap: () {
                                          Navigator.pushNamed(
                                              context, TutorialFirst.routeName);
                                          AnalyticsManager.track('settings_tutorial');

                                  },
                                  child: ListTile(
                                    title: Text("Tutorial",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                    leading: Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: Icon(Icons.live_help_rounded, color: Theme.of(context).primaryColor,),
                                    )
                                  ),
                                ),
                                kIsWeb ? const SizedBox() : const Divider(
                                  color: Color(0xffF2F2F2),
                                ),
                                InkWell(
                                  onTap: () async{
                                if (await canLaunch(faqUrl)) {
                                    await launch(faqUrl,
                                        forceSafariVC: true,
                                        forceWebView: true,
                                        enableJavaScript: true,
                                        );
                                  }else{
                                  debugPrint("Couldn't launch url");
                                  }
                                AnalyticsManager.track('settings_faq');
                                  },
                                  child: ListTile(
                                    title: Text("FAQ",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                    leading: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                        child: Icon(Icons.question_answer_rounded, color: Theme.of(context).primaryColor,)
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),

                        kIsWeb ? const SizedBox() : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Material(
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:4.0),
                              child:
                              GestureDetector(
                                onTap: () async{
                                    await Share.share("Hi,\n\n${userDataFromProvider.userData.name} has invited you to join them on Ryalto.\n\nRyalto helps hospitals and nurses communicate directly and connect in an instant."
                                        "\n\nDownload it now and find the right job for your needs.\n"
                                        "App Store: https://apps.apple.com/gb/app/ryalto/id1144521219\n"
                                        "Play Store: https://play.google.com/store/apps/details?id=com.ryaltoapp.rightnurse"
                                        "\n\nTeam Ryalto");
                                    AnalyticsManager.track('settings_share');
                                },
                                child: ListTile(
                                  title: Text("Share",style: TextStyle(color: Theme.of(context).primaryColor,),),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left:6.0),
                                    child: WebsafeSvg.asset('images/share-filled.svg', color: Theme.of(context).primaryColor,width: 20,height: 20,)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        //   child: Material(
                        //         borderRadius: BorderRadius.circular(6),
                        //         color: Colors.white,
                        //         elevation: 2.0,
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: <Widget>[
                        //         InkWell(
                        //           onTap: () async{
                        //             if (await canLaunch(privacyPolicyUrl)) {
                        //               await launch(privacyPolicyUrl,
                        //                 forceSafariVC: true,
                        //                 forceWebView: true,
                        //                 enableJavaScript: true,
                        //               );
                        //             }else{
                        //               debugPrint("Couldn't launch url");
                        //             }
                        //           },
                        //           child: ListTile(
                        //             title: Text("Privacy Policy",style: TextStyle(color: Theme.of(context).primaryColor,)),
                        //             leading: Padding(
                        //               padding: const EdgeInsets.only(left: 6.0),
                        //               child: WebSafeSvg.asset('images/privacy-filled.svg',color: Theme.of(context).primaryColor,
                        //                 width: 20.0,height: 20,),
                        //             ),
                        //           ),
                        //         ),
                        //         const Divider(
                        //           color: Color(0xffF2F2F2),
                        //         ),
                        //         InkWell(
                        //           onTap: () async{
                        //             if (await canLaunch(userDataFromProvider.userData.trust["id"] == nhspTrustId ? nhspTermsUrl :termsUrl)) {
                        //               await launch(userDataFromProvider.userData.trust["id"] == nhspTrustId ? nhspTermsUrl : termsUrl,
                        //                 forceSafariVC: true,
                        //                 forceWebView: true,
                        //                 enableJavaScript: true,
                        //               );
                        //             }else{
                        //               debugPrint("Couldn't launch url");
                        //             }
                        //           },
                        //           child: ListTile(
                        //             title: Text("Terms of Service",style: TextStyle(color: Theme.of(context).primaryColor,)),
                        //             leading:
                        //             Transform.scale(
                        //               child:
                        //               Image.asset('images/terms.png',color: Theme.of(context).primaryColor,
                        //                 width: 40.0,
                        //                 // height: 18.0,
                        //               ) ,
                        //               scale: 0.55,
                        //               alignment: Alignment.center,
                        //             ),
                        //           ),
                        //         ),
                        //
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Material(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                elevation: 2.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
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
                                    AnalyticsManager.track('settings_privacy');
                                  },
                                  child: ListTile(
                                    title: Text("Privacy Policy",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                    leading: Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: WebsafeSvg.asset('images/privacy-filled.svg',color: Theme.of(context).primaryColor,
                                        width: 20.0,height: 20,),
                                    ),
                                  ),
                                ),
                                const Divider(
                                  color: Color(0xffF2F2F2),
                                ),
                                InkWell(
                                  onTap: () async{
                                    if (await canLaunch(userDataFromProvider.userData.trust["id"] == nhspTrustId ? nhspTermsUrl :termsUrl)) {
                                      await launch(userDataFromProvider.userData.trust["id"] == nhspTrustId ? nhspTermsUrl : termsUrl,
                                        forceSafariVC: true,
                                        forceWebView: true,
                                        enableJavaScript: true,
                                      );
                                    }else{
                                      debugPrint("Couldn't launch url");
                                    }
                                    AnalyticsManager.track('settings_terms');
                                  },
                                  child: ListTile(
                                    title: Text("Terms of Service",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                    leading:
                                    Transform.scale(
                                      child:
                                      Image.asset('images/terms.png',color: Theme.of(context).primaryColor,
                                        width: 40.0,
                                        // height: 18.0,
                                      ) ,
                                      scale: 0.55,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                        (kIsWeb) ? const SizedBox() : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Material(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                elevation: 2.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ListTile(
                                  title: Text("Copy device font size",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 1.0),
                                    child: Transform.scale(
                                      child: Image.asset('images/font.png',color: Theme.of(context).primaryColor,
                                        width: 40.0,
                                      ) ,
                                      scale: 0.58,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: Provider.of<UserProvider>(context,listen: false).copyDeviceFontSize,
                                    onChanged: (value) {
                                        Provider.of<UserProvider>(context,listen: false).changeFontSize(value);
                                    },
                                    activeTrackColor: Colors.grey,
                                    activeColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                                // const Divider(
                                //   color: Color(0xffF2F2F2),
                                // ),
                                // InkWell(
                                //   onTap: () {
                                //     // Provider.of<UserProvider>(context,listen: false).changeFontSize(bodyText1: 10.0,bodyText2: 12.0,);
                                //
                                //   },
                                //   child: ListTile(
                                //     title: Text("Enable dark mode",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                //     leading: Padding(
                                //       padding: const EdgeInsets.only(left: 1.0),
                                //       child: Transform.scale(
                                //         child: Image.asset('images/darkmode.png',color: Theme.of(context).primaryColor,
                                //           width: 40.0,
                                //         ) ,
                                //         scale: 0.58,
                                //         alignment: Alignment.center,
                                //       ),
                                //     ),
                                //     trailing: Switch(
                                //       value: Provider.of<ThemesProvider>(context,listen: false).isDarkTheme,
                                //       onChanged: (value) {
                                //         if(Provider.of<ThemesProvider>(context,listen: false).isDarkTheme){
                                //           theme.setLightMode();
                                //         }
                                //         else{
                                //           theme.setDarkMode();
                                //         }
                                //       },
                                //       activeTrackColor: Colors.grey,
                                //       activeColor: Theme.of(context).primaryColor,
                                //     ),
                                //   ),
                                // ),
                                Provider.of<UserProvider>(context,listen: false).userData != null && Provider.of<UserProvider>(context,listen: false).userData.trust['id'] == "055eb500-09c7-4574-b957-e7dbc278d993" ? const Divider(
                                  color: Color(0xffF2F2F2),
                                )
                                    :
                                const SizedBox(),
                                Provider.of<UserProvider>(context,listen: false).userData != null && Provider.of<UserProvider>(context,listen: false).userData.trust['id'] == "055eb500-09c7-4574-b957-e7dbc278d993"
                                    ?
                                ListTile(
                                  title: Text("Default background image",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 1.0),
                                    child: Transform.scale(
                                      child: Image.asset('images/gallery.png',color: Theme.of(context).primaryColor,
                                        width: 40.0,
                                      ) ,
                                      scale: 0.58,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: !Provider.of<UserProvider>(context,listen: false).isCurrentAppBackgroundSetToDefault,
                                    onChanged: (value) {
                                      if(value == false){
                                        Provider.of<UserProvider>(context,listen: false).setCurrentAppBackground("images/karmaSanctum.png");
                                      }
                                      else{
                                        Provider.of<UserProvider>(context,listen: false).setCurrentAppBackground('images/chatBackground.png');
                                      }
                                    },
                                    activeTrackColor: Colors.grey,
                                    activeColor: Theme.of(context).primaryColor,
                                  ),
                                )
                                    :
                                const SizedBox(),

                              ],
                            ),
                          ),
                        ),

                        // // Change app font size widget
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        //   child: Material(
                        //     borderRadius: BorderRadius.circular(6),
                        //     color: Colors.white,
                        //     elevation: 2.0,
                        //     child: InkWell(
                        //       onTap: () {
                        //         // Provider.of<UserProvider>(context,listen: false).changeFontSize(bodyText1: 10.0,bodyText2: 12.0,);
                        //
                        //       },
                        //       child: ListTile(
                        //         title: Text("Copy device font size",style: TextStyle(color: Theme.of(context).primaryColor,)),
                        //         leading: Padding(
                        //           padding: const EdgeInsets.only(left: 1.0),
                        //           child: Transform.scale(
                        //             child: Image.asset('images/font.png',color: Theme.of(context).primaryColor,
                        //               width: 40.0,
                        //             ) ,
                        //             scale: 0.58,
                        //             alignment: Alignment.center,
                        //           ),
                        //         ),
                        //         trailing: Switch(
                        //           value: Provider.of<UserProvider>(context,listen: false).isDefaultFonSizeEnabled,
                        //           onChanged: (value) {
                        //             Provider.of<UserProvider>(context,listen: false).enableDeviceFontSize(value);
                        //             if(value){
                        //               Provider.of<UserProvider>(context,listen: false).changeFontSize(
                        //                   bodyText1: 10.0,
                        //                   bodyText2: 12.0,
                        //                   subtitle2: 10.0,
                        //                   overline: 10.0,
                        //                   headline6: 10.0,
                        //                   headline5: 10.0,
                        //                   caption: 10.0,
                        //                   button: 10.0,
                        //                   subtitle1: 10.0,
                        //                   headline1: 10.0,
                        //                   headline2: 10.0,
                        //                   headline3: 10.0,
                        //                   headline4: 10.0
                        //               );
                        //             }
                        //             setState(() {
                        //               isSwitched = value;
                        //               print(isSwitched);
                        //             });
                        //           },
                        //           activeTrackColor: Colors.grey,
                        //           activeColor: Theme.of(context).primaryColor,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Material(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                elevation: 2.0,
                            child: InkWell(
                              onTap: () {
                                showLogoutDialog(context: context);
                                // showDialog(
                                //   context: context,builder: (_) => NetworkGiffyDialog(
                                //   image: Image.network("https://cdn.dribbble.com/users/1797873/screenshots/5310497/logout.gif",errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                //     return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],);
                                //   },),
                                //   title: Text('Are you sure you want to log out?',
                                //     maxLines: 3,
                                //     textAlign: TextAlign.center,
                                //     style: TextStyle(
                                //         fontSize: 18.0,
                                //         fontWeight: FontWeight.w600)),
                                //   cornerRadius: 15.0,
                                //   entryAnimation: EntryAnimation.BOTTOM,
                                //   buttonOkColor: Theme.of(context).primaryColor,
                                //   onOkButtonPressed: () async{ await Provider.of<UserProvider>(context,listen:false).logOut(context);},
                                //     )
                                //   );

                              },
                              child: ListTile(
                                title: Text("Logout",style: TextStyle(color: Theme.of(context).primaryColor,)),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 1.0),
                                  child: Transform.scale(
                                    child: Image.asset('images/logout.png',color: Theme.of(context).primaryColor,
                                      width: 40.0,
                                    ) ,
                                    scale: 0.58,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 65.0,),

                      ],
                    ),
                  ),

                  Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child:  Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              spreadRadius: 0.0,
                              offset: Offset(2.0, 2.0),
                            )
                          ],
                        ),

                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right:15.0, top: 8, bottom: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("images/ryLogo.png", height: 35.0, width: 100.0,),
                              Text("v${Domain.appVersion}", style: style3,)
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            )
        ),
      )
    ));
  }
}