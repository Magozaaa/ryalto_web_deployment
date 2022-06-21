import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Providers/changeIndexPage.dart';
import 'package:rightnurse/Screens/newChatScreen.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/Notifications.dart';
import 'package:rightnurse/Subscreens/Profile/MyAccountScreen.dart';
import 'package:rightnurse/Subscreens/SettingsScreen.dart';
import 'package:rightnurse/Subscreens/SurveysScreen.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/WebModel/Responsive.dart';
import 'package:rightnurse/WebModel/extensions.dart';
import 'package:rightnurse/WebModel/side_menu_items.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:websafe_svg/websafe_svg.dart';


import 'package:flutter/foundation.dart' show kIsWeb;

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Consumer<ChangeIndex>(
      builder: (context, changeIndex, child) {

        return Container(
          height: double.infinity,
          padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
          color: kBgLightColor,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Transform.scale(
                              scale: 1.8,
                              child: Image.asset(
                                "images/ryLogo.png",
                                width: 60,
                              ),
                            ),
                          ),
                          Spacer(),
                          if (!Responsive.isDesktop(context))  Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child:CloseButton(),
                          ),
                        ],
                      ),
                      const SizedBox(height: kDefaultPadding,),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (Provider.of<UserProvider>(context, listen: false).userData == null)
                                await Provider.of<UserProvider>(context, listen: false).getUser(context);
                              // showCustomBottomSheet(
                              //     profilePicPath: userData.userData.profilePic,
                              //     context: context,
                              //     screenMedia: screenMedia);
                            },
                            child: userData.userData != null
                                ?
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                                const SizedBox():
                                SpinKitRipple(
                                  color: Colors.red[700],
                                  size: 220,
                                  // duration: Duration(milliseconds: 1700),
                                  borderWidth: 30.0,

                                ) ,
                                (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                                const SizedBox():
                                SpinKitRipple(
                                  color: Colors.red[700],
                                  size: 220,
                                  // duration: Duration(milliseconds: 2500),
                                  borderWidth: 30.0,
                                ) ,
                                (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                                const SizedBox():
                                SpinKitRipple(
                                  color: Colors.red[500],
                                  size: 250,
                                  // duration: Duration(milliseconds: 1700),
                                  borderWidth: 30.0,
                                ) ,
                                (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                                const SizedBox():
                                SpinKitRipple(
                                  color: Colors.red[500],
                                  size: 250,
                                  // duration: Duration(milliseconds: 2500),
                                  borderWidth: 30.0,
                                ) ,
                                (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                                const SizedBox():
                                SpinKitRipple(
                                  color: Colors.red[500],
                                  size: 250,
                                  // duration: Duration(milliseconds: 2500),
                                  borderWidth: 30.0,
                                ) ,
                                Container(
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(45.0)
                                    ),
                                    child:
                                    userData.userData == null ?
                                    Image.asset('images/person.png', fit: BoxFit.contain,):
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          shape:BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(userData.userData.profilePic),
                                              fit: BoxFit.cover
                                          )
                                      ),
                                    )
                                ),
                              ],
                            ) : const SizedBox(),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userData.userData == null ? "": "${userData.userData.name}",style: Theme.of(context).textTheme.button.copyWith(color: kTextColor,fontSize: 14,fontWeight: FontWeight.bold),),
                                const SizedBox(height: 5,),
                                Text(userData.userData == null ? "": "${userData.userData.trust["name"]}",style: Theme.of(context).textTheme.button.copyWith(color: kTextColor,fontSize: 12)),
                              ],
                            ),
                          ),
                          // Spacer(),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: kDefaultPadding * 2),
                  // // Menu Items
                  // SideMenuItem(
                  //   press: () {
                  //     changeIndex.changeIndexFunction(0);
                  //   },
                  //   title: "News",
                  //   iconSrc: changeIndex.index == 0 ? "images/newsIconFilled.svg" : "images/newsIconOutline.svg",
                  //   isActive: changeIndex.index == 0 ? true : false,
                  //   itemCount: 3,
                  // ),
                  // SideMenuItem(
                  //   press: () {
                  //     changeIndex.changeIndexFunction(1);
                  //   },
                  //   title: "Shifts",
                  //   iconSrc: changeIndex.index == 1 ? "images/shiftsFilled.svg" : "images/shiftsOutLine.svg",
                  //   isActive: changeIndex.index == 1 ? true : false,
                  // ),
                  Stack(
                    children: [
                      SideMenuItem(
                        press: () {
                          changeIndex.changeIndexFunction(2);
                          // Navigator.pushNamed(context, ChatScreen.routeName);
                        },
                        title: "Chat",
                        iconSrc: changeIndex.index == 2 ? "images/chatFilled.svg" : "images/chatOutline.svg",
                        isActive: changeIndex.index == 2 ? true : false,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 22,
                        top: 22,
                        child: changeIndex.index == 2 && chatProvider.unreadChatMsgs > 0 ?
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0,right: 5),
                          child: Container(
                            alignment: Alignment.center,
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                                color: kBadgeColor,
                                borderRadius: BorderRadius.circular(40)
                            ),
                            child: Text('${chatProvider.unreadChatMsgs}',style: const TextStyle(fontSize: 10,color: Colors.white),),
                          ).addNeumorphism(
                            blurRadius: 4,
                            borderRadius: 8,
                            offset: Offset(2, 2),
                          ),
                        )
                            :const SizedBox(),
                      )
                    ],
                  ),
                  // SideMenuItem(
                  //   press: () {
                  //     changeIndex.changeIndexFunction(3);
                  //   },
                  //   title: "Directory",
                  //   iconSrc: changeIndex.index == 3 ? "images/directoryFilled.svg" : "images/directoryOutline.svg",
                  //   isActive: changeIndex.index == 3 ? true : false,
                  //   showBorder: false,
                  // ),

                  SizedBox(height: kDefaultPadding * 2),
                  // const Divider(),
                  ExpandChild(
                    indicatorBuilder: (context, showMoreFunction, isOpened) {
                      return InkWell(onTap: showMoreFunction,child: isOpened
                          ? Row(
                        children: [
                          Text('Show less',style: Theme.of(context).textTheme.button.copyWith(color: kTextColor,fontSize: 12),),
                          Icon(Icons.arrow_drop_up,color: kTextColor,)
                        ],
                      ) : Row(
                            children: [
                              Text('Show more options',style: Theme.of(context).textTheme.button.copyWith(color: kTextColor,fontSize: 12),),
                              Icon(Icons.arrow_drop_down_outlined,color: kTextColor,)
                            ],
                          ) );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: Provider.of<UserProvider>(context).userData.profileCompleted ? 20.0 : 10.0),
                          child: InkWell(
                            onTap: () => Navigator.popAndPushNamed(
                                context, MyAccountsScreen.routName),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Provider.of<UserProvider>(context).userData.profileCompleted ?
                                    const SizedBox():
                                    SpinKitRipple(
                                      color: Colors.red[700],
                                      size: 44,
                                      borderWidth: 20.0,
                                      duration: const Duration(milliseconds: 2500),
                                    ) ,
                                    Provider.of<UserProvider>(context).userData.profileCompleted ?
                                    const SizedBox():
                                    SpinKitRipple(
                                      color: Colors.red[700],
                                      size: 44,
                                      borderWidth: 20.0,
                                      duration: const Duration(milliseconds: 2500),
                                    ) ,
                                    Provider.of<UserProvider>(context).userData.profileCompleted ?
                                    const SizedBox():
                                    SpinKitRipple(
                                      color: Colors.red[500],
                                      size: 50,
                                      duration: const Duration(milliseconds: 2500),
                                      borderWidth: 25.0,
                                    ) ,
                                    Provider.of<UserProvider>(context).userData.profileCompleted ?
                                    const SizedBox():
                                    SpinKitRipple(
                                      color: Colors.red[500],
                                      size: 50,
                                      duration: const Duration(milliseconds: 2500),
                                      borderWidth: 25.0,
                                    ) ,
                                    Provider.of<UserProvider>(context).userData.profileCompleted ?
                                    const SizedBox():
                                    SpinKitRipple(
                                      color: Colors.red[500],
                                      size: 50,
                                      duration: const Duration(milliseconds: 2500),
                                      borderWidth: 25.0,
                                    ) ,
                                    Padding(
                                      padding: EdgeInsets.only(left: Provider.of<UserProvider>(context,listen: false).userData.profileCompleted ? 6 : 0),
                                      child: Container(
                                          height: 32.0,
                                          width: 32.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(80.0),
                                          ),
                                          child:  Provider.of<UserProvider>(context).userData.profilePic == null
                                              ? Padding(
                                            padding: const EdgeInsets.only(top: 2.0,),
                                            child: Image.asset(
                                              "images/person.png",
                                              fit: BoxFit.contain,
                                              color: Colors.grey[400],
                                            ),
                                          )
                                              : Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                shape:BoxShape.circle,
                                                image: DecorationImage(
                                                    image: NetworkImage(Provider.of<UserProvider>(context).userData.profilePic),
                                                    fit: BoxFit.cover
                                                )
                                            ),
                                          )

                                      ),
                                    ),

                                  ],
                                ),
                                SizedBox(
                                  width: Provider.of<UserProvider>(context).userData.profileCompleted ? 32.0 : 19.0 ,
                                ),
                                Text(
                                  "My Profile",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        Provider.of<UserProvider>(context, listen: false).userSurveyLink == null ? const SizedBox():
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: InkWell(
                            onTap: () async {
                              if (kIsWeb) {
                                if (await canLaunch(Provider.of<UserProvider>(context, listen: false)
                                    .userSurveyLink)) {
                                  await launch(Provider.of<UserProvider>(context, listen: false)
                                    .userSurveyLink,
                                    forceSafariVC: true,
                                    forceWebView: true,
                                    enableJavaScript: true,
                                  );
                                }else{
                                  debugPrint("Couldn't launch url");
                                }
                              }
                              else {
                                if (Provider.of<UserProvider>(context, listen: false)
                                    .userSurveyLink !=
                                    null)
                                  Navigator.popAndPushNamed(
                                      context, SurveysScreen.routeName);
                              }
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Image.asset(
                                    "images/survey-filled.png",
                                    color: Theme.of(context).primaryColor,
                                    fit: BoxFit.cover,
                                    height: 25,
                                    width: 25,
                                    //color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(
                                  width: 27.0,
                                ),
                                Text(
                                  "Surveys",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 25.0),
                        //   child: InkWell(
                        //     onTap: () {
                        //       Navigator.popAndPushNamed(context, NotificationsScreen.routName);
                        //       Provider.of<UserProvider>(context, listen: false).clearUnreadNotificationCount();
                        //       Provider.of<NewsProvider>(context, listen: false).clearUnreadNewsNotificationCount();
                        //     },
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Row(
                        //           children: [
                        //             Padding(
                        //               padding: const EdgeInsets.only(left: 10.0),
                        //               child: Image.asset("images/notification-filled.png",
                        //                 color: Theme.of(context).primaryColor,width: 25,),
                        //             ),
                        //             const SizedBox(
                        //               width: 37.0,
                        //             ),
                        //             Text(
                        //               "Notifications",
                        //               overflow: TextOverflow.ellipsis,
                        //               style: TextStyle(
                        //                   color: Theme.of(context).primaryColor,
                        //                   fontSize: 16.0),
                        //             )
                        //           ],
                        //         ),
                        //         Provider.of<UserProvider>(context, listen: false).backendNotificationCount == 0 && Provider.of<NewsProvider>(context, listen: false).newsNotificationCount == 0
                        //             ?
                        //         const SizedBox()
                        //             :
                        //         Container(
                        //           height: 23,
                        //           width: 23,
                        //           decoration: BoxDecoration(
                        //               shape: BoxShape.circle,
                        //               color: Color(0xFFff0f0f)
                        //           ),
                        //           padding: const EdgeInsets.all(2),
                        //           alignment: Alignment.center,
                        //           child: Text((Provider.of<UserProvider>(context, listen: false).backendNotificationCount + Provider.of<NewsProvider>(context, listen: false).newsNotificationCount) <= 99 ? "${Provider.of<UserProvider>(context, listen: false).backendNotificationCount + Provider.of<NewsProvider>(context, listen: false).newsNotificationCount}" : "99+",
                        //             style: TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.w600),),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.popAndPushNamed(context, HelpAndSupport.routName);
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Image.asset('images/question-filled.png',
                                    color: Theme.of(context).primaryColor,height: 25,
                                    width: 25,),
                                ),
                                const SizedBox(
                                  width: 37.0,
                                ),
                                Text(
                                  "Help/Support",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: InkWell(
                            onTap: () => Navigator.popAndPushNamed(
                                context, SettingsScreen.routName),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Image.asset('images/setting-filled.png',
                                    color: Theme.of(context).primaryColor,height: 25,
                                    width: 25,),
                                ),
                                SizedBox(
                                  width: 37.0,
                                ),
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16.0),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tags
                  // Tags(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}