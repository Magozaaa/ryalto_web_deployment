import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/LoginScreen.dart';
import 'package:rightnurse/Subscreens/SearchScreen.dart';
import 'package:rightnurse/Subscreens/TrustsSearchScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class LandingPage extends StatefulWidget{

  static const routeName = "/LandingPage";

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {




  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(color: Colors.white),
                  Container(
                    height: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(88))),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: media.height*0.1,),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                  onTap: ()=> Navigator.pushNamed(context, HelpAndSupport.routName),
                                  child: Text("Need help?", style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),)),
                            ),
                          ),
                          SizedBox(height: media.height > 550 ? media.height*0.1 : media.height*0.07,),
                          Image.asset("images/img_logo.webp", width: media.width * 0.65,),
                          SizedBox(height: media.height > 550 ? media.height*0.1 : media.height*0.07,),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: media.width * 0.05,),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 100.0,
                                  child: Column(
                                    children: [
                                      Image.asset('images/newsIconOutline.png', height: media.width * 0.1, width: media.width * 0.1, color: Colors.white,),
                                      // SvgPicture.asset('images/newsIconOutline.svg', height: media.width * 0.1, width: media.width * 0.1, color: Colors.white,),
                                      SizedBox(height: 7.0,),
                                      Text("Read the latest news", maxLines: 2, textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white, fontSize: 16.0),)
                                    ],
                                  ),
                                ),

                                Container(
                                  width: 70.0,
                                  child: Column(
                                    children: [
                                      Image.asset('images/shiftsOutLine.png', height: media.width * 0.1, width: media.width * 0.1, color: Colors.white,),
                                      SizedBox(height: 7.0,),
                                      Text("Book shifts", maxLines: 2, textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white, fontSize: 16.0),)
                                    ],
                                  ),
                                ),

                                Container(
                                  width: 100.0,
                                  child: Column(
                                    children: [
                                      Image.asset('images/chatOutline.png', height: media.width * 0.1, width: media.width * 0.1, color: Colors.white,),
                                      // SvgPicture.asset("images/chatOutline.svg", height: media.width * 0.1, width: media.width * 0.1, color: Colors.white,),
                                      SizedBox(height: 7.0,),
                                      Text("Chat with people", maxLines: 2, textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white, fontSize: 16.0),)
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                          !kIsWeb ? const SizedBox() : SizedBox(height: media.height*0.07,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: media.height > 550 ? 220 : media.height*0.3,
              child: Stack(
                children: [
                  Container(
                      color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    width: media.width,
                    height: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(88))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: media.height*0.03,
                        ),
                        roundedButton(
                            title: "Sign Up", context: context, buttonWidth: media.width * 0.7, buttonHeight: media.height * 0.06,
                            onClicked: (){
                              Navigator.pushNamed(context, TrustsSearchScreen.routeName,
                                  arguments: {
                                    "screen_title": "Sign Up",
                                    "screen_content" : "LandingPage",
                                    "trustId" : null
                                  });
                              AnalyticsManager.track('screen_signup');
                            }
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                          child: Text("Already have an account?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: media.height > 550 ? 18.0 : 15.0,fontWeight: FontWeight.w700),),
                        ),
                        roundedButton(title: "Log In", context: context,
                            borderColor: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                            onClicked: ()=> Navigator.pushNamed(context, LoginScreen.routName),
                            color: Colors.white, titleColor: Theme.of(context).primaryColor,
                            buttonWidth: media.width * 0.7, buttonHeight: media.height * 0.06),
                         Expanded(
                           child: const SizedBox(
                            height: 10,
                        ),
                         )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        // Stack(
        //   children: [
        //     Positioned(
        //       top: 0.0,
        //       left: 0.0,
        //       right: 0.0,
        //       child: Container(
        //         height: media.height * 0.72,
        //         width: media.width,
        //         color: Theme.of(context).primaryColor,
        //         child: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Image.asset("images/img_logo.webp", width: media.width * 0.65,),
        //             SizedBox(height: 70.0,),
        //             Padding(
        //               padding: EdgeInsets.symmetric(horizontal: media.width * 0.05,),
        //               child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 children: [
        //
        //                   Container(
        //                     width: 100.0,
        //                     child: Column(
        //                       children: [
        //                         SvgPicture.asset('images/newsIconOutline.svg', height: 45.0, width: 40, color: Colors.white,),
        //                         SizedBox(height: 7.0,),
        //                         Text("Read the latest news", maxLines: 2, textAlign: TextAlign.center,
        //                         style: TextStyle(color: Colors.white, fontSize: 16.0),)
        //                       ],
        //                     ),
        //                   ),
        //
        //                   Container(
        //                     width: 70.0,
        //                     child: Column(
        //                       children: [
        //                         SvgPicture.asset('images/shiftsOutline.svg', height: 45.0, width: 40, color: Colors.white,),
        //                         SizedBox(height: 7.0,),
        //                         Text("Book shifts", maxLines: 2, textAlign: TextAlign.center,
        //                           style: TextStyle(color: Colors.white, fontSize: 16.0),)
        //                       ],
        //                     ),
        //                   ),
        //
        //                   Container(
        //                     width: 100.0,
        //                     child: Column(
        //                       children: [
        //                         SvgPicture.asset("images/chatOutline.svg", height: 45.0, width: 40, color: Colors.white,),
        //                         SizedBox(height: 7.0,),
        //                         Text("Chat with people", maxLines: 2, textAlign: TextAlign.center,
        //                           style: TextStyle(color: Colors.white, fontSize: 16.0),)
        //                       ],
        //                     ),
        //                   ),
        //
        //                 ],
        //               ),
        //             ),
        //
        //           ],
        //         ),
        //       ),
        //     ),
        //
        //     Positioned(
        //       bottom: 0.0,
        //       left: 0.0,
        //       right: 0.0,
        //       child: Container(
        //         color: Colors.white,
        //         height: media.height * 0.28,
        //         child: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             roundedButton(title: "Sign Up", context: context, buttonWidth: media.width * 0.8, buttonHeight: 50.0,
        //             onClicked: ()=>
        //                 Navigator.pushNamed(context, TrustsSearchScreen.routeName,
        //             arguments: {
        //               "screen_title": "Sign Up",
        //               "screen_content" : "LandingPage",
        //               "trustId" : null
        //             })
        //             // Navigator.pushNamed(context, SearchScreen.routeName,
        //             // arguments: {
        //             //   "screen_title": "Sign Up",
        //             //   "screen_content" : "trust",
        //             //   "trustId" : null
        //             // })
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
        //               child: Text("Already have an account?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 18.0),),
        //             ),
        //             roundedButton(title: "Log In", context: context,
        //                 borderColor: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
        //                 onClicked: ()=> Navigator.pushNamed(context, LoginScreen.routName),
        //                 color: Colors.white, titleColor: Theme.of(context).primaryColor,
        //                 buttonWidth: media.width * 0.8, buttonHeight: 50.0)
        //           ],
        //         ),
        //       ),
        //     ),
        //
        //
        //     Positioned(
        //         top: 65.0,
        //         right: 25.0,
        //         child: GestureDetector(
        //             onTap: ()=> Navigator.pushNamed(context, HelpAndSupport.routName),
        //             child: Text("Need help?", style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),)))
        //   ],
        // ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      Provider.of<UserProvider>(context, listen: false).bioMetricLogin(context);
      Provider.of<UserProvider>(context, listen: false).getFingerPrintToken();
    }

  }
}