// ignore_for_file: must_be_immutable, file_names, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:eraser/eraser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/SurveyModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Providers/changeIndexPage.dart';
import 'package:rightnurse/Screens/directory.dart';
import 'package:rightnurse/Screens/news.dart';
import 'package:rightnurse/Screens/shifts.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:twilio_voice/twilio_voice.dart';
import '../main.dart';
import 'newChatScreen.dart';
import 'package:new_version/new_version.dart';


class NavigationHome extends StatefulWidget {
  static const String routeName = '/this_is_homeNavigation_screen';

  @override
  _NavigationHomeState createState() => _NavigationHomeState();

}
class _NavigationHomeState extends State<NavigationHome> with TickerProviderStateMixin, WidgetsBindingObserver{

  List<Widget> _widgets = [];

  String _token;
  static const eventStream = EventChannel('ryalto.com/streamApnsTokenChange');
  StreamSubscription<dynamic> tokenChangedStream;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
   if (!kIsWeb) {
     Provider.of<CallProvider>(context, listen: false).setAppState(state);

      // if on an active call, go to call screen
      if (state == AppLifecycleState.resumed) {
        Provider.of<CallProvider>(context, listen: false).checkActiveTwilioCall(context);
        // print("Heeey app is now ACTIVE %%%%%%%%%%%%%%%%%%%%%%%%%%");
        // Provider.of<ChatProvider>(context, listen: false).getTimeWhenAppCameToLiveFromBackground().then((_){
        //   debugPrint("********************************* difference in minutes ${Provider.of<ChatProvider>(context, listen: false).differenceInMinutes}");
        //   if(Provider.of<ChatProvider>(context, listen: false).differenceInMinutes != null && Provider.of<ChatProvider>(context, listen: false).differenceInMinutes > 4){
        //
        //     RestartWidget.restartApp(context);
        //     // Phoenix.rebirth(context);
        //
        //   }
        //   else{
        //     // createNewAuthKey(context).then((_) {
        //     //   _shouldShowLoaderInChatTab = true;
        //     // clearChannels();
        //     // clearChannelsLastMsgOnLogout();
        //
        //     Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, offset: 0).then((_){
        //
        //       // if iOS still don't show badge when app goes inActive especially when screen is locked on Message recieving uncomment this code
        //       /// this solution will work if this call get triggered after 20 mins from putting app in background
        //
        //       /// ----- if Flagging chaneels are enabled in the _pubnub listen we can comment this out
        //       /// and it will work as listen is still working for few mins while app is in background ------
        //       Provider.of<ChatProvider>(context, listen: false).getSavedLastMsgTimeForChannelsBeforeAppGoesInactive().then((_){
        //
        //         /// see if we can alter the sortChannels function and sort according to last_message_at that comes from fetchGroupChannels
        //         // fetchHistoryForChannels(_userAuthKey);
        //
        //         // _shouldShowLoaderInChatTab = false;
        //
        //         // to Erase the badge on the App Icon for Android
        //         if(Platform.isAndroid){
        //           Eraser.clearAllAppNotifications();
        //         }
        //
        //       });
        //
        //       // });
        //
        //     });
        //   }
        // });
      }
   }
    // if(state == AppLifecycleState.inactive){
    //   print("Heeey app went inACTIVE ££££££££££££££££££££");
    //   Provider.of<ChatProvider>(context, listen: false).setTimeWhenAppWentToBackground();
    // }

  }



  @override
  void initState() {

    if(Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);

    WidgetsBinding.instance.addObserver(this);
    _widgets = [
      const News(),
      Shifts(),
      ChatScreen(),
      Directory()
    ];


    if (Provider.of<UserProvider>(context, listen: false).numOfTimesToSkipAppUpdate == null) {
      Provider.of<UserProvider>(context, listen: false).setNumOfTimesToSkipAppUpdate(3);
    }else{
      if (!kIsWeb) {
        Provider.of<UserProvider>(context, listen: false).getTimeWhenAppAppUpdateDialogLastShowed(context);
      }
    }


    Provider.of<UserProvider>(context, listen: false).checkIfCurrentUserIsFromKarma();
    Provider.of<UserProvider>(context, listen: false).getPopUpSurveys(context); // not giving errors

    if(Provider.of<UserProvider>(context, listen: false).userSurveyLink == null)
      Provider.of<UserProvider>(context, listen: false).getUserSurveysLink(); // not giving errors


    if (!kIsWeb) {
      if (Platform.isIOS) {
        tokenChangedStream = eventStream.receiveBroadcastStream().listen((event) {
          final token = event as String;
          _token = token;
          Provider.of<UserProvider>(context, listen: false).checkIfDeviceTokenExist(deviceToken:_token);

          if(_token != null){

            Provider.of<ChatProvider>(context, listen: false).registerForChatPushNotifications(_token);

            Provider.of<UserProvider>(context, listen: false).setDeviceToken(_token);
          }

        });

        // iOS can not navigate to TwilioCallScreen if answered right away while app was terminated
        Provider.of<CallProvider>(context, listen: false).checkActiveTwilioCall(context);

      }
      else if(Platform.isAndroid){
        _firebaseMessaging.getToken().then((token) {
          _token = token;
          debugPrint("print fcm token to send notifications from firebase $_token");
          Provider.of<UserProvider>(context, listen: false).checkIfDeviceTokenExist(deviceToken:_token);

          if(_token != null){
            Provider.of<ChatProvider>(context, listen: false).registerForChatPushNotifications(_token);
            Provider.of<UserProvider>(context, listen: false).setDeviceToken(_token);
          }

        });
      }
    }

    // this code will run if when user Logs-in after a Logout or SignUp
    // if(Provider.of<ChatProvider>(context, listen: false).channels.isEmpty){
    //
    //   // Provider.of<CallProvider>(context, listen: false).registerTwilioClient(context, id: Provider.of<UserProvider>(context, listen: false).userData.id,
    //   //     name: Provider.of<UserProvider>(context, listen: false).userData.name,
    //   //     myToken: Provider.of<UserProvider>(context, listen: false).userData.token);
    //
    //
    // }


    super.initState();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    if (!kIsWeb) {
      tokenChangedStream?.cancel();
      tokenChangedStream = null;

    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // to set color to the status bar that shows (battery,network_signal,....,etc)
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top,SystemUiOverlay.bottom,]);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent, // Color for Android
      ));
    }
    final media = MediaQuery.of(context).size;
    final chatProvider = Provider.of<ChatProvider>(context);
    final userData = Provider.of<UserProvider>(context);

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Consumer<ChangeIndex>(
        builder: (context, changeIndex, child) {

          return Scaffold(
              body: userData.userData == null ? const SizedBox():
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        _widgets[changeIndex.index],
                        Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          // padding: const EdgeInsets.only(top: 6),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40),
                            ),
                            child: BottomNavigationBar(
                              // backgroundColor: Colors.transparent,
                              elevation: 0.0,
                              currentIndex: changeIndex.index,
                              selectedItemColor: Theme.of(context).primaryColor,
                              unselectedItemColor: Colors.grey,
                              items: [
                                BottomNavigationBarItem(
                                    icon: Stack(
                                      children: [
                                        SizedBox(
                                          width: media.width*0.12,
                                          // height: media.height*0.04,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: SvgPicture.asset('images/newsIconOutline.svg',color: Colors.grey,width: media.width * 0.06,),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child:
                                          Provider.of<NewsProvider>(context).newsNotificationCount > 0 ?
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0,right: 5),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFFff0f0f),
                                                  borderRadius: BorderRadius.circular(40)
                                              ),
                                              child: Text(Provider.of<NewsProvider>(context).newsNotificationCount > 99 ? '99+' : '${Provider.of<NewsProvider>(context, listen: false).newsNotificationCount}',style: TextStyle(fontSize: 10,color: Colors.white),),
                                            ),
                                          )
                                              :
                                          const SizedBox(),
                                        )
                                      ],
                                    ),
                                    activeIcon: Stack(
                                      children: [
                                        SizedBox(
                                          width: media.width*0.12,
                                          // height: media.height*0.04,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: SvgPicture.asset('images/newsIconFilled.svg',
                                              color: Theme.of(context).accentColor,
                                              width: media.width * 0.06,),
                                            // ImageIcon(
                                            //   AssetImage('images/newsIcon.png'),
                                            //   size: media.width * 0.06,
                                            // ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child:
                                          Provider.of<NewsProvider>(context).newsNotificationCount > 0 ?
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0,right: 5),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFFff0f0f),
                                                  borderRadius: BorderRadius.circular(40)
                                              ),
                                              child: Text(Provider.of<NewsProvider>(context).newsNotificationCount > 99 ? '99+' : '${Provider.of<NewsProvider>(context, listen: false).newsNotificationCount}',style: const TextStyle(fontSize: 10,color: Colors.white),),
                                            ),
                                          )
                                              :Container(),
                                        )
                                      ],
                                    ),
                                    label: 'News'
                                    // title: Text(
                                    //   'News',
                                    //   style: TextStyle(
                                    //     fontSize: media.width * 0.028,
                                    //   ),
                                    // )
                                ),
                                BottomNavigationBarItem(
                                    icon: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: SvgPicture.asset('images/shiftsOutLine.svg',color: Colors.grey,width: media.width * 0.06,),
                                    ),
                                    activeIcon: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: SvgPicture.asset('images/shiftsFilled.svg',color: Theme.of(context).accentColor,width: media.width * 0.06,),
                                    ),
                                    label: 'Shifts',
                                    // title: Text(
                                    //     'Shifts',
                                    //     style: TextStyle(
                                    //       fontSize: media.width * 0.028,
                                    //     ))
                                ),
                                BottomNavigationBarItem(
                                    icon: Stack(
                                      children: [
                                        Container(
                                          width: media.width * 0.12,
                                          // height: media.height*0.04,
                                          // color: Colors.green,
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: SvgPicture.asset('images/chatOutline.svg',color: Colors.grey,width: media.width * 0.06,),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child:
                                          chatProvider.unreadChatMsgs > 0 ?
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0,right: 5),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFFff0f0f),
                                                  borderRadius: BorderRadius.circular(40)
                                              ),
                                              child: Text('${chatProvider.unreadChatMsgs}',style: const TextStyle(fontSize: 10,color: Colors.white),),
                                            ),
                                          )
                                              :Container(),
                                        )
                                      ],
                                    ),
                                    activeIcon: Stack(
                                      children: [
                                        Container(
                                          width: media.width * 0.12,
                                          // height: media.height*0.04,
                                          // color: Colors.green,
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: SvgPicture.asset('images/chatFilled.svg',color: Theme.of(context).accentColor,width: media.width * 0.06,),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child:
                                          chatProvider.unreadChatMsgs > 0 ?
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0,right: 5),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFFff0f0f),
                                                  borderRadius: BorderRadius.circular(40)
                                              ),
                                              child: Text('${chatProvider.unreadChatMsgs}',style: const TextStyle(fontSize: 10,color: Colors.white),),
                                            ),
                                          )
                                              :Container(),
                                        )
                                      ],
                                    ),
                                    label: 'Chat'
                                    // title: Text(
                                    //     'Chat',
                                    //     style: TextStyle(
                                    //       fontSize: media.width * 0.028,
                                    //     ))
                                ),
                                BottomNavigationBarItem(
                                    icon: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: SvgPicture.asset('images/directoryOutline.svg',color: Colors.grey,width: media.width * 0.06,),
                                    ),
                                    activeIcon: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: SvgPicture.asset('images/directoryFilled.svg',color: Theme.of(context).accentColor,width: media.width * 0.06,),
                                    ),
                                    label: "Directory"
                                    // title: Text(
                                    //     "Directory",
                                    //     style: TextStyle(
                                    //       fontSize: media.width * 0.028,
                                    //     ))
                                ),
                              ],
                              onTap: (index) {
                                changeIndex.changeIndexFunction(index);
                                if(index==0){
                                  Provider.of<NewsProvider>(context, listen: false).clearUnreadNewsNotificationCount();
                                  // Provider.of<NewsProvider>(context, listen: false).clearUnreadMyOrganisationNewsNotificationCount();
                                  // Provider.of<NewsProvider>(context, listen: false).clearUnreadFocusedNewsNotificationCount();
                                }
                              },
                            ),
                          ),
                        ))
                      ],
                    ),
                  ),
                ],
              )
          );
        },
      ),
    );
  }

}




