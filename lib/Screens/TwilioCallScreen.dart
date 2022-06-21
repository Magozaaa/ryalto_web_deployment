// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:rightnurse/Providers/CallProvider.dart';
// import 'package:rightnurse/Screens/navigationHome.dart';
// import 'package:rightnurse/Widgets/commonWidgets.dart';
// import 'package:twilio_voice/twilio_voice.dart';
//
// class TwilioCallScreen extends StatefulWidget {
//   const TwilioCallScreen({Key key}) : super(key: key);
//
//   static const String routeName = "/TwilioCall_Screen";
//
//   @override
//   _TwilioCallScreenState createState() => _TwilioCallScreenState();
// }
//
// class _TwilioCallScreenState extends State<TwilioCallScreen> {
//   bool speaker = false;
//   bool mute = false;
//   bool isEnded = false;
//   Timer showConnectionTime;
//   DateTime callStartTime;
//   String connectedTimeString = '00:00:00';
//
//   @override
//   initState() {
//     super.initState();
//     // listenCall();
//     initialiseTimer();
//     if(!Provider.of<CallProvider>(context,listen: false).isInACall){
//       Provider.of<CallProvider>(context,listen: false).clearCallCounter();
//     }
//
//   }
//
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//   }
//
//   @override
//   dispose() {
//     showConnectionTime?.cancel();
//     // callStateListener.cancel();
//     super.dispose();
//   }
//
//   String getDurationAsHoursMinsSec(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }
//
//
// // this method is used to update current value of activeCallCounter in CallProvider taking the same Timer Duration
//   void initialiseTimer() {
//     Timer(Duration(milliseconds: 500), () {
//       if (mounted) {
//         callStartTime = DateTime.now();
//         showConnectionTime = Timer.periodic(Duration(milliseconds: 500), (timer) {
//           if (mounted) {
//             setState(() {});
//           }
//         });
//       }
//     });
//   }
//
//
//   // StreamSubscription<CallEvent> callStateListener;
//
//   // void listenCall() {
//   //   callStateListener = TwilioVoice.instance.callEventsListener.listen((event) {
//   //
//   //     switch (event) {
//   //       case CallEvent.callEnded:
//   //         if (!isEnded) {
//   //           isEnded = true;
//   //           Provider.of<CallProvider>(context,listen: false).clearCallCounter();
//   //           Navigator.of(context).pop();
//   //
//   //         }
//   //         break;
//   //       case CallEvent.mute:
//   //         setState(() {
//   //           mute = true;
//   //         });
//   //         break;
//   //       case CallEvent.unmute:
//   //         setState(() {
//   //           mute = false;
//   //         });
//   //         break;
//   //       case CallEvent.speakerOn:
//   //         setState(() {
//   //           speaker = true;
//   //         });
//   //         break;
//   //       case CallEvent.speakerOff:
//   //         setState(() {
//   //           speaker = false;
//   //         });
//   //         break;
//   //       case CallEvent.ringing:
//   //         Provider.of<CallProvider>(context,listen: false).clearCallCounter();
//   //         // Provider.of<CallProvider>(context,listen: false).initialiseActiveCallCounter();
//   //         setState(() {});
//   //         break;
//   //       case CallEvent.answer:
//   //         Provider.of<CallProvider>(context,listen: false).initialiseActiveCallCounter();
//   //         setState(() {});
//   //         break;
//   //       case CallEvent.log:
//   //         break;
//   //       case CallEvent.connected:
//   //         Provider.of<CallProvider>(context,listen: false).initialiseActiveCallCounter();
//   //         setState(() {});
//   //         break;
//   //       case CallEvent.hold:
//   //       case CallEvent.unhold:
//   //         break;
//   //       default:
//   //         break;
//   //     }
//   //   });
//   // }
//
//   String caller = '';
//
//   String getCaller() {
//     final activeCall = TwilioVoice.instance.call.activeCall;
//     if (activeCall != null) {
//       return activeCall.callDirection == CallDirection.outgoing ? activeCall.to : activeCall.from;
//     }
//     return "Unknown";
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final incomingUser = Provider.of<CallProvider>(context, listen: false).currentCallFromUser;
//     final outgoingUser = Provider.of<CallProvider>(context, listen: false).currentCallToUser;
//     final userToShow = (outgoingUser == null) ? incomingUser : outgoingUser;
//     final media = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () {
//         Provider.of<CallProvider>(context, listen: false).setInACallValue(true);
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => NavigationHome()),
//                 (route) => false);
//         return Future.value(false);
//       },
//       child: Scaffold(
//           // backgroundColor: Theme.of(context).accentColor,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           elevation: 0.0,
//           backgroundColor: Color(0xFF289cf4),
//           leading: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: Colors.white,
//               ),
//               onPressed: (){
//                 Provider.of<CallProvider>(context, listen: false).setInACallValue(true);
//                 Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => NavigationHome()),
//                         (route) => false);
//               }),
//         ),
//           body: Container(
//             height: media.height,
//             width: media.width,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF289cf4),
//               ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 40,top: 10,right: 20,left: 20),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text('Ryalto Call', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)),
//                       const SizedBox(height: 12.0),
//                       userProfileImage(imageUrl: userToShow != null ? userToShow.profilePic : '', radius: 75),
//                       const SizedBox(height: 12.0),
//                       Text(
//                         userToShow == null || userToShow.name.isEmpty ? '' : userToShow.name,
//                         style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.white),
//                       ),
//                       const SizedBox(height: 8.0),
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Consumer<CallProvider>(
//                             builder: (context,callProvider,child){
//                               return Text(
//                                 "${Provider.of<CallProvider>(context).activeCallCounter}",
//                                 style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white54,fontSize: 14),
//                               );
//                             },
//                           ),
//                           // Text(
//                           //   // Provider.of<CallProvider>(context,listen: false).activeCallCounter ?? connectedTimeString,
//                           //   "${Provider.of<CallProvider>(context).activeCallCounter}",
//                           //   style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white54,fontSize: 14),
//                           // ),
//                           const SizedBox(
//                             height: 60,
//                           ),
//                           Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                             Material(
//                               type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
//                               child: Ink(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.white, width: 1.0),
//                                   color: !Provider.of<CallProvider>(context, listen: false).mute ? Color(0xFF289cf4) : Colors.white60,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
//                                   child: Padding(
//                                     padding: EdgeInsets.all(20.0),
//                                     child: SvgPicture.asset("images/mute.svg",color: Colors.white,height: 35),
//                                   ),
//                                   onTap: () {
//                                     TwilioVoice.instance.call.toggleMute(!Provider.of<CallProvider>(context, listen: false).mute);
//                                     // setState(() {
//                                     //   mute = !mute;
//                                     // });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Material(
//                               type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
//                               child: Ink(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.white, width: 1.0),
//                                   color: !Provider.of<CallProvider>(context, listen: false).speaker ? Color(0xFF289cf4) : Colors.white60,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
//                                   child: Padding(
//                                     padding: EdgeInsets.all(20.0),
//                                     child: SvgPicture.asset("images/speakerOn.svg",color: Colors.white,height: 35,),
//                                   ),
//                                   onTap: () {
//                                     TwilioVoice.instance.call.toggleSpeaker(!Provider.of<CallProvider>(context, listen: false).speaker);
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ]),
//                           const SizedBox(
//                             height: 60,
//                           ),
//                           RawMaterialButton(
//                             elevation: 2.0,
//                             fillColor: Colors.red,
//                             child: SvgPicture.asset("images/endCall.svg",color: Colors.white,height: 35),
//                             padding: EdgeInsets.all(20.0),
//                             shape: CircleBorder(),
//                             onPressed: () async {
//                               final isOnCall = await TwilioVoice.instance.call.isOnCall();
//                               if (isOnCall) {
//                                 TwilioVoice.instance.call.hangUp();
//                               }
//                             },
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )),
//     );
//   }
// }


// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'dart:convert';

class TwilioCallScreen extends StatefulWidget {
  const TwilioCallScreen({Key key}) : super(key: key);

  static const String routeName = "/TwilioCall_Screen";



  @override
  _TwilioCallScreenState createState() => _TwilioCallScreenState();
}

class _TwilioCallScreenState extends State<TwilioCallScreen> {
  // bool speaker = false;
  // bool mute = false;
  bool isEnded = false;
  // Timer showConnectionTime;
  // DateTime callStartTime;
  // String connectedTimeString = '00:00:00';

  User incomingUser;
  User outgoingUser;
  String callerId;
  User userToShow;
  String currentUserId;
  CallProvider callProvider;


  @override
  initState() {
    callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.listenCall(context);
    // callProvider.initialiseTimer();


    if (callProvider.currentCallToUser == null) {

      if (callProvider.currentCallFromUser == null) {
        Timer(const Duration(milliseconds: 250), () async{

          callerId = callProvider.callerId ?? TwilioVoice.instance.call.activeCall.from.replaceAll("_", "-");

          Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: callerId).then((user){
            if(user != null){
              if (mounted) {
                setState(() {
                  userToShow = user as User;
                });
              }
              TwilioVoice.instance.registerClient(user.id, user.name);
            }
          });

            });
      }
      else{
        if (mounted) {
          setState(() {
            userToShow = callProvider.currentCallFromUser;
          });
        }
      }
    } else{
    if (mounted) {
      setState(() {
        userToShow = callProvider.currentCallToUser;
      });
    }
    }


       // callProvider.getCallerFromId(context, callerId: callerId).then((_){
       //   userToShow = callProvider.currentCallFromUser;
         // callerId == currentUserId ?
         // callProvider.currentCallToUser : callProvider.currentCallFromUser;
       // });

    super.initState();
  }


  @override
  dispose() {
    // showConnectionTime?.cancel();
    // callProvider.cancelTimer();
    callProvider.cancelListeningToCall();
    super.dispose();
  }

  String getDurationAsHoursMinsSec(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // void initialiseTimer() {
  //   Timer(const Duration(milliseconds: 500), () {
  //
  //     if (mounted) {
  //       callStartTime = DateTime.now();
  //       showConnectionTime = Timer.periodic(const Duration(milliseconds: 500), (timer) {
  //         if (mounted) {
  //           final timeDiff = DateTime.now().difference(callStartTime);
  //           setState(() {
  //             connectedTimeString = getDurationAsHoursMinsSec(timeDiff);
  //           });
  //         }
  //       });
  //
  //
  //     }
  //   });
  // }

  // StreamSubscription<CallEvent> callStateListener;
  // void listenCall() {
  //   callStateListener = TwilioVoice.instance.callEventsListener.listen((event) {
  //
  //     switch (event) {
  //       case CallEvent.callEnded:
  //         if (!isEnded) {
  //           isEnded = true;
  //           Navigator.of(context).pop();
  //         }
  //         break;
  //       case CallEvent.mute:
  //         callProvider.toggleMute(true);
  //         // setState(() {
  //         //   mute = true;
  //         // });
  //         break;
  //
  //       case CallEvent.unmute:
  //         callProvider.toggleMute(false);
  //         // setState(() {
  //         //   mute = false;
  //         // });
  //         break;
  //
  //       case CallEvent.speakerOn:
  //         callProvider.toggleSpeaker(true);
  //         // setState(() {
  //         //   speaker = true;
  //         // });
  //         break;
  //       case CallEvent.connected:
  //       // this code is to enable speaker for iOS as it doesn't get turned on if user
  //       // has enabled it as soon as they made the call
  //         if(Platform.isIOS){
  //           // callProvider.toggleSpeaker(true);
  //           setState(() {
  //             TwilioVoice.instance.call.toggleSpeaker(callProvider.speaker);
  //           });
  //         }
  //         break;
  //       case CallEvent.speakerOff:
  //         callProvider.toggleSpeaker(false);
  //         // setState(() {
  //         //   speaker = false;
  //         // });
  //         break;
  //       case CallEvent.ringing:
  //           setState(() {
  //             // this code is to enable speaker for iOS as it doesn't get turned on if user
  //             // has enabled it as soon as they made the call
  //             if (Platform.isIOS) {
  //               TwilioVoice.instance.call.toggleSpeaker(callProvider.speaker);
  //             }
  //           });
  //         break;
  //
  //       case CallEvent.answer:
  //         setState(() {});
  //         break;
  //
  //       case CallEvent.log:
  //         break;
  //       case CallEvent.hold:
  //       case CallEvent.unhold:
  //         break;
  //       default:
  //         break;
  //     }
  //   });
  // }

  // String caller = '';
  //
  // String getCaller() {
  //   final activeCall = TwilioVoice.instance.call.activeCall;
  //   if (activeCall != null) {
  //     return activeCall.callDirection == CallDirection.outgoing ? activeCall.to : activeCall.from;
  //   }
  //   return "Unknown";
  // }

  @override
  Widget build(BuildContext context) {


    final media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        // backgroundColor: Theme.of(context).accentColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF289cf4),
          elevation: 0.0,
          leading: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 27.0,
            ),
          )
        ),
          body: Container(
            height: media.height,
            width: media.width,
            decoration: const BoxDecoration(
              color: Color(0xFF289cf4),
              // gradient: LinearGradient(
              //   colors: [
              //     Colors.black54,
              //     Colors.blue
              //   ],
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              // )
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Ryalto Call', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)),
                      const SizedBox(height: 12.0),
                    Container(
                      width: media.height <= 550 ? 85 : 150,
                      height:media.height <= 550 ? 85 : 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: userToShow != null
                              ? //CachedNetworkImageProvider(userToShow.profilePic)
                          NetworkImage(userToShow.profilePic)
                              : Image.asset(
                            "images/person.png",
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ).image,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                      // userProfileImage(imageUrl: userToShow != null ? userToShow.profilePic : '', radius: 75),
                      const SizedBox(height: 12.0),
                      Text(
                        userToShow == null ? "" : userToShow.name,
                        style: TextStyle(color: Colors.white,fontSize: media.height <= 550 ? 18 : 22,fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Consumer<CallProvider>(builder: (BuildContext context ,callProvider,child){
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Consumer<CallProvider>(builder: (BuildContext context ,callProvider,child){
                            //   return Text(
                            //     callProvider.connectedTimeString,
                            //     style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white54,fontSize: 14),
                            //   );
                            // }),
                            Text(
                              callProvider.connectedTimeString,
                              style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white54,fontSize: 14),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                              Material(
                                type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                                child: Ink(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1.0),
                                    color: !callProvider.mute ? const Color(0xFF289cf4) : Colors.white60,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SvgPicture.asset("images/mute.svg",color: Colors.white,height: media.height <= 550 ? 18 : 35),
                                    ),
                                    onTap: () {
                                      /// try to move this code to on pause inside NavHome to solve issue of Android
                                      /// while force lock !!!
                                      TwilioVoice.instance.call.toggleMute(!callProvider.mute);
                                      // setState(() {
                                      //   mute = !mute;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                              Material(
                                type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                                child: Ink(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1.0),
                                    color: !callProvider.speaker ? const Color(0xFF289cf4) : Colors.white60,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SvgPicture.asset("images/speakerOn.svg",color: Colors.white,height: media.height <= 550 ? 18 : 35,),
                                    ),
                                    onTap: () {
                                      TwilioVoice.instance.call.toggleSpeaker(!callProvider.speaker);
                                    },
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(
                              height: 60,
                            ),
                            RawMaterialButton(
                              elevation: 2.0,
                              fillColor: Colors.red,
                              child: SvgPicture.asset("images/endCall.svg",color: Colors.white,height: media.height <= 550 ? 18 : 35),
                              padding: const EdgeInsets.all(20.0),
                              shape: const CircleBorder(),
                              onPressed: () async {
                                final isOnCall = await TwilioVoice.instance.call.isOnCall();
                                if (isOnCall) {
                                  TwilioVoice.instance.call.hangUp();
                                }
                              },
                            )
                          ],
                        );
                      }),

                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}