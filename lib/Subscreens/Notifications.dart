// ignore_for_file: file_names, curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/Notification.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NotificationsProvider.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Providers/changeIndexPage.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/Subscreens/NewsFeed/NewsDetails.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftDetails.dart';
import 'package:rightnurse/Subscreens/SurveysScreen.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class NotificationsScreen extends StatefulWidget {
  static const routName = "/Notifications_Screen";

  const NotificationsScreen({Key key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoadingData =true;
  int pageOffset = 0;
  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = Container();
  List<Color> cardsColors;
  List<NotificationModel> notifications=[];
  ScrollController scScrollController;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    pageOffset = 0;
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<NotificationsProvider>(context, listen: false)
        .clearOrgNotifications();
    await Provider.of<NotificationsProvider>(context, listen: false)
        .getAllNotifications(pageOffset: pageOffset).then((value){
      notifications = Provider.of<NotificationsProvider>(context,listen: false).notifications;

    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      lastItemBottomPadding = 8.0;
      bottomGapToShowLoadingMoreStatus = const SizedBox(
        height: 60.0,
      );
    });
    pageOffset += 15;
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<NotificationsProvider>(context, listen: false)
        .getAllNotifications(pageOffset: pageOffset).then((value) {
      notifications = Provider.of<NotificationsProvider>(context,listen: false).notifications;

    });
    _refreshController.refreshCompleted();
    if (mounted) {
      setState(() {
        lastItemBottomPadding = 55.0;
        bottomGapToShowLoadingMoreStatus = Container();
      });
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
    scScrollController = ScrollController(initialScrollOffset: 0.0);
    Provider.of<NotificationsProvider>(context, listen: false)
        .getAllNotifications().then((value) {
      _isLoadingData=false;
      notifications = Provider.of<NotificationsProvider>(context,listen: false).notifications;
    });
    AnalyticsManager.track('screen_notifications');
  }


  @override
  void dispose() {
    super.dispose();
    scScrollController.dispose();
  }

  _updateNotification(notificationId){
    Provider.of<NotificationsProvider>(context,listen: false).updateNotifications(context,notificationId: notificationId);
  }
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final notificationsProvider = Provider.of<NotificationsProvider>(context);
    final chatProvider =  Provider.of<ChatProvider>(context);
    // final stage = notificationsProvider.stage;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (Platform.isIOS) {
            if (details.primaryVelocity.compareTo(0) == 1) {
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: screenAppBar(context, media,
                appbarTitle: const Text("Notifications"),
                showLeadingPop: true,
                hideProfilePic: true,
                centerTitle: true,
                onBackPressed: ()=>  kIsWeb ? Navigator.pushReplacementNamed(context, WebMainScreen.routeName) : Navigator.pushReplacementNamed(context, NavigationHome.routeName)),
            body: !_isLoadingData
                ? Theme(
              data: ThemeData(highlightColor: Colors.blue),
                  child: Scrollbar(
                    controller: scScrollController,
                    thickness: 3,
                    showTrackOnHover: true,
                    isAlwaysShown: true,
                    radius: const Radius.circular(15),
                    child: kIsWeb ? ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },),
                      child: NotificationListener<ScrollNotification>(
                        // ignore: missing_return
                        onNotification: (scrollNotification){
                          // if (scrollNotification is ScrollStartNotification) {
                          //   _onStartScroll(scrollNotification.metrics);
                          // } else if (scrollNotification is ScrollUpdateNotification) {
                          //   _onUpdateScroll(scrollNotification.metrics);
                          // } else if (scrollNotification is ScrollEndNotification) {
                          //   _onEndScroll(scrollNotification.metrics);
                          // }
                          if (kIsWeb) {
                            if (scrollNotification is ScrollStartNotification) {
                              // stop playing
                            }else if(scrollNotification is ScrollEndNotification){
                              print("vbvbvbbvbvbcc ${scrollNotification.metrics.maxScrollExtent}");
                              print("njnjnjjnjnjjn ${scrollNotification.metrics.pixels}");
                              if(scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                                _onLoading();
                              } // resume playing
                            }
                          }
                          // if (scrollNotification is ScrollEndNotification) {
                          //   print(channelsScrollController.position.pixels);
                          // }
                        },
                        child: ListView(
                            controller: scScrollController,
                            shrinkWrap: true,
                            // itemCount: notifications.length,
                            physics: BouncingScrollPhysics(),
                            children: List.generate(notifications.length, (i) {
                              var format = DateFormat('dd MMM yyyy hh:mm');
                              var date = DateTime.fromMillisecondsSinceEpoch(
                                  notifications[i].created_at * 1000);
                              var finalDate = format.format(date);

                              return Padding(
                                padding: i == notifications.length -1 ? const EdgeInsets.only(bottom: 10.0) : const EdgeInsets.all(0.0),
                                child: InkWell(
                                    onTap: ()async{
                                      _updateNotification(notifications[i].id);

                                      debugPrint("!!!!!!!!!!!!!!!!!!!!!!!!!!! ${notifications[i].metadata}");

                                      switch(notifications[i].notification_type) {
                                        case 1: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 2: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 3: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 5: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 6: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 7: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 10: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 11: {
                                          Provider.of<UserProvider>(context, listen: false).getUser(context);
                                        }
                                        break;

                                        case 13: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 14: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 15: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 16: {
                                          if(notifications[i].metadata['offerId'] != null){
                                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                            Navigator.pushNamed(context, ShiftDetails.routeName);
                                          }
                                        }
                                        break;

                                        case 17: {
                                          Navigator.pushNamed(context, SurveysScreen.routeName);
                                          if(Provider.of<UserProvider>(context, listen: false).userSurveyLink == null)
                                            Provider.of<UserProvider>(context, listen: false).getUserSurveysLink();
                                        }
                                        break;

                                        case 18: {
                                          Navigator.pushNamed(context, SurveysScreen.routeName);
                                          if(Provider.of<UserProvider>(context, listen: false).userSurveyLink == null)
                                            Provider.of<UserProvider>(context, listen: false).getUserSurveysLink();
                                        }
                                        break;

                                        case 21: {
                                          chatProvider.clearChannels();
                                          chatProvider.fetchGroupChannels(context).then((_){
                                            Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
                                            Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);

                                            if(chatProvider.channels.firstWhere((ch) => ch.id == notifications[i].metadata["channel_id"]) != null)
                                            {
                                              chatProvider.setNewMSGforChannelToTrue(
                                                  chatProvider.channels.firstWhere((ch) => ch.id == notifications[i].metadata["channel_id"]).name);
                                            }
                                          });
                                          // Provider.of<ChangeIndex>(context,listen: false).changeIndexFunction(2);
                                          // // _updateNotification(notifications[i].id);
                                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigationHome()));
                                        }
                                        break;

                                        case 100: {
                                          Navigator.pushNamed(context, NewsDetails.routeName,
                                              arguments: {
                                                "id": notifications[i].metadata['post_id'],
                                              });
                                        }
                                        break;


                                        default: {}
                                        break;
                                      }

                                    },
                                    child: notificationCard(context,
                                        notificationTitle: notifications[i].message,
                                        notificationClicked: notifications[i].status == 204 ? true : false,
                                        notificationType: notifications[i].notification_type,
                                        isDefaultNotification: notifications[i].notification_type == 10 ||notifications[i].notification_type ==14||notifications[i].notification_type ==17||notifications[i].notification_type ==18 ? false : true,
                                        notificationDate: finalDate)),
                              );
                            }),
                            // itemBuilder: (context, i) {
                            //   var format = DateFormat('dd MMM yyyy hh:mm');
                            //   var date = DateTime.fromMillisecondsSinceEpoch(
                            //       notifications[i].created_at * 1000);
                            //   var finalDate = format.format(date);
                            //
                            //   return Padding(
                            //     padding: i == notifications.length -1 ? const EdgeInsets.only(bottom: 10.0) : const EdgeInsets.all(0.0),
                            //     child: InkWell(
                            //         onTap: ()async{
                            //           _updateNotification(notifications[i].id);
                            //
                            //           debugPrint("!!!!!!!!!!!!!!!!!!!!!!!!!!! ${notifications[i].metadata}");
                            //
                            //           switch(notifications[i].notification_type) {
                            //             case 1: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 2: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 3: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 5: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 6: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 7: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 10: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 11: {
                            //               Provider.of<UserProvider>(context, listen: false).getUser(context);
                            //             }
                            //             break;
                            //
                            //             case 13: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 14: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 15: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 16: {
                            //               if(notifications[i].metadata['offerId'] != null){
                            //                 Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                            //                 Navigator.pushNamed(context, ShiftDetails.routeName);
                            //               }
                            //             }
                            //             break;
                            //
                            //             case 17: {
                            //               Navigator.pushNamed(context, SurveysScreen.routeName);
                            //               if(Provider.of<UserProvider>(context, listen: false).userSurveyLink == null)
                            //                 Provider.of<UserProvider>(context, listen: false).getUserSurveysLink();
                            //             }
                            //             break;
                            //
                            //             case 18: {
                            //               Navigator.pushNamed(context, SurveysScreen.routeName);
                            //               if(Provider.of<UserProvider>(context, listen: false).userSurveyLink == null)
                            //                 Provider.of<UserProvider>(context, listen: false).getUserSurveysLink();
                            //             }
                            //             break;
                            //
                            //             case 21: {
                            //               chatProvider.clearChannels();
                            //               chatProvider.fetchGroupChannels(context).then((_){
                            //                 Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
                            //                 Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);
                            //
                            //                 if(chatProvider.channels.firstWhere((ch) => ch.id == notifications[i].metadata["channel_id"]) != null)
                            //                 {
                            //                   chatProvider.setNewMSGforChannelToTrue(
                            //                       chatProvider.channels.firstWhere((ch) => ch.id == notifications[i].metadata["channel_id"]).name);
                            //                 }
                            //               });
                            //               // Provider.of<ChangeIndex>(context,listen: false).changeIndexFunction(2);
                            //               // // _updateNotification(notifications[i].id);
                            //               // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigationHome()));
                            //             }
                            //             break;
                            //
                            //             case 100: {
                            //               Navigator.pushNamed(context, NewsDetails.routeName,
                            //                   arguments: {
                            //                     "id": notifications[i].metadata['post_id'],
                            //                   });
                            //             }
                            //             break;
                            //
                            //
                            //             default: {}
                            //             break;
                            //           }
                            //
                            //         },
                            //         child: notificationCard(context,
                            //             notificationTitle: notifications[i].message,
                            //             notificationClicked: notifications[i].status == 204 ? true : false,
                            //             notificationType: notifications[i].notification_type,
                            //             isDefaultNotification: notifications[i].notification_type == 10 ||notifications[i].notification_type ==14||notifications[i].notification_type ==17||notifications[i].notification_type ==18 ? false : true,
                            //             notificationDate: finalDate)),
                            //   );
                            // }
                            ),
                      ),
                    ) : SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      scrollController: scScrollController,
                      footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus mode) {
                            Widget body;
                            if (mode == LoadStatus.loading) {
                              body = const CupertinoActivityIndicator();
                            } else if (mode == LoadStatus.failed) {
                              body = const Text("Load Failed!Click retry!");
                            } else if (mode == LoadStatus.canLoading) {
                            } else if(mode == LoadStatus.noMore){
                              body = const Text("No more to load!");
                            }
                            return Center(child: body);
                          },
                        ),
                      child: ListView.builder(
                          controller: scScrollController,
                            shrinkWrap: true,
                            itemCount: notifications.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, i) {
                              var format = DateFormat('dd MMM yyyy hh:mm');
                              var date = DateTime.fromMillisecondsSinceEpoch(
                                  notifications[i].created_at * 1000);
                              var finalDate = format.format(date);

                              return Padding(
                                padding: i == notifications.length -1 ? const EdgeInsets.only(bottom: 10.0) : const EdgeInsets.all(0.0),
                                child: InkWell(
                                  onTap: ()async{
                                    _updateNotification(notifications[i].id);

                                    debugPrint("!!!!!!!!!!!!!!!!!!!!!!!!!!! ${notifications[i].metadata}");

                                     switch(notifications[i].notification_type) {
                                       case 1: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 2: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 3: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 5: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 6: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 7: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 10: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 11: {
                                         Provider.of<UserProvider>(context, listen: false).getUser(context);
                                       }
                                       break;

                                       case 13: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 14: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 15: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 16: {
                                         if(notifications[i].metadata['offerId'] != null){
                                           Provider.of<ShiftsProvider>(context,listen: false).setCurrentOfferId(notifications[i].metadata['offerId']);
                                           Navigator.pushNamed(context, ShiftDetails.routeName);
                                         }
                                       }
                                       break;

                                       case 17: {
                                         Navigator.pushNamed(context, SurveysScreen.routeName);
                                         if(Provider.of<UserProvider>(context, listen: false).userSurveyLink == null)
                                           Provider.of<UserProvider>(context, listen: false).getUserSurveysLink();
                                       }
                                       break;

                                       case 18: {
                                         Navigator.pushNamed(context, SurveysScreen.routeName);
                                         if(Provider.of<UserProvider>(context, listen: false).userSurveyLink == null)
                                           Provider.of<UserProvider>(context, listen: false).getUserSurveysLink();
                                       }
                                       break;

                                       case 21: {
                                        chatProvider.clearChannels();
                                        chatProvider.fetchGroupChannels(context).then((_){
                                           Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));
                                           Provider.of<ChangeIndex>(context, listen: false).changeIndexFunction(2);

                                          if(chatProvider.channels.firstWhere((ch) => ch.id == notifications[i].metadata["channel_id"]) != null)
                                           {
                                            chatProvider.setNewMSGforChannelToTrue(
                                              chatProvider.channels.firstWhere((ch) => ch.id == notifications[i].metadata["channel_id"]).name);
                                           }
                                         });
                                         // Provider.of<ChangeIndex>(context,listen: false).changeIndexFunction(2);
                                         // // _updateNotification(notifications[i].id);
                                         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigationHome()));
                                       }
                                       break;

                                       case 100: {
                                         Navigator.pushNamed(context, NewsDetails.routeName,
                                             arguments: {
                                               "id": notifications[i].metadata['post_id'],
                                             });
                                       }
                                       break;


                                       default: {}
                                       break;
                                     }

                                  },
                                    child: notificationCard(context,
                                        notificationTitle: notifications[i].message,
                                        notificationClicked: notifications[i].status == 204 ? true : false,
                                        notificationType: notifications[i].notification_type,
                                        isDefaultNotification: notifications[i].notification_type == 10 ||notifications[i].notification_type ==14||notifications[i].notification_type ==17||notifications[i].notification_type ==18 ? false : true,
                                        notificationDate: finalDate)),
                              );
                            }),
                    ),
                  ),
                )
                : Container(
                    width: media.width,
                    height: media.height*0.9,
                    child: Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 45.0,
                      ),
                    ),
                  )),
      ),
    );
  }
}
