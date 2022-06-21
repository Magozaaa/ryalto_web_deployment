// ignore_for_file: must_be_immutable, curly_braces_in_flow_control_structures, unnecessary_this, no_logic_in_create_state

import 'dart:io';

import 'package:animated_widgets/animated_widgets.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/TwilioCallScreen.dart';
import 'package:rightnurse/Subscreens/NewsFeed/FavouriteNews.dart';
import 'package:rightnurse/Subscreens/NewsFeed/MyOrgNewsFeed.dart';
import 'package:rightnurse/Subscreens/NewsFeed/ProfessionalNews.dart';
import 'package:rightnurse/Subscreens/SearchScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';


class News extends StatefulWidget {
  const News({Key key}) : super(key: key);


  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> with TickerProviderStateMixin {
  TabController _controller;



  @override
  void initState() {
    if (Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context).then((_) {

      });
    // added to solve saving last Focused News item's published time for counting new posts
    if (Provider.of<NewsProvider>(context, listen: false).proNews.isEmpty) {
      Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(
          context,
          pageOffset: 0,
          trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]).then((_){
      });
    }
    _controller = TabController(vsync: this, length: 3);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);
    final newsProvider = Provider.of<NewsProvider>(context);

    return WillPopScope(
      onWillPop: () async{
        SystemNavigator.pop();
        return false;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          // backgroundColor: Colors.white,
          appBar: AppBar(
            titleSpacing: -12,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: !kIsWeb && Provider.of<CallProvider>(context).isInCall ? MainAxisAlignment.start : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userData.userData == null
                              ? "" : "${userData.userData.trust["name"]}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text("News Feed",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            elevation: 0.0,
            centerTitle: true,
            actions: [
              !kIsWeb && Provider.of<CallProvider>(context).isInCall ?
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 8.0),
                child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, TwilioCallScreen.routeName);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 15.0,
                      child: ShakeAnimatedWidget(
                        enabled: true,
                        duration: const Duration(milliseconds: 1700),
                        shakeAngle: Rotation.deg(z: 40),
                        curve: Curves.linear,
                        child: Transform.scale(
                          scale: 0.8,
                          child: SvgPicture.asset(
                            'images/call-filled.svg',
                            color: Colors.white,
                            width: 20,
                          ),
                        ),
                      ),
                    )
                ),
              )
                  :
              const SizedBox(
                width: 0,//18.0,
              ),

              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                    onTap: userData.userData == null
                        ? null
                        : userData.userData.verified
                            ? () {
                                Provider.of<NewsProvider>(context, listen: false)
                                    .clearSearchNews();
                                Navigator.pushNamed(
                                    context, SearchScreen.routeName,
                                    arguments: {
                                      "screen_title": "Search",
                                      "screen_content": null,
                                    });
                              }
                            : null,
                    child: Image.asset(
                      'images/search.png',
                      color: Colors.white,
                      width: 25,
                    )),
              )
            ],
            bottom: PreferredSize(
              child: Align(
                alignment: Alignment.center,
                child: TabBar(
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).backgroundColor,
                  indicatorSize: TabBarIndicatorSize.tab,

                  indicator:  BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5))),
                  isScrollable: !kIsWeb ? true : false,
                  onTap: (int index){
                    if(index == 0){
                      Provider.of<NewsProvider>(context, listen: false).clearUnreadMyOrganisationNewsNotificationCount();
                    }
                    else if(index == 1){
                      Provider.of<NewsProvider>(context, listen: false).clearUnreadFocusedNewsNotificationCount();
                    }
                  },
                  tabs: List<Widget>.generate(3, (int index) {
                    return Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                index == 0
                                    ? "MY ORGANISATION"
                                    : index == 1
                                        ? "FOCUSED NEWS"
                                        : "FAVOURITES",
                                softWrap: true,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,),
                              ),
                            ),
                            index == 0 && Provider.of<NewsProvider>(context).newsCounters['orgNewsCounter'] > 0 ? Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Container(
                                height: 15,
                                width: 15,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red
                                ),
                                child: Text(Provider.of<NewsProvider>(context).newsCounters['orgNewsCounter'] < 10 ?'${Provider.of<NewsProvider>(context).newsCounters['orgNewsCounter']}' : '10+',style: const TextStyle(color: Colors.white,fontSize: 10),),
                              ),
                            ) : const SizedBox(),
                            index == 1 && Provider.of<NewsProvider>(context).newsCounters['focusedNewsCounter'] > 0 ? Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Container(
                                height: 15,
                                width: 15,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red
                                ),
                                child: Text(Provider.of<NewsProvider>(context).newsCounters['focusedNewsCounter'] < 10 ?'${Provider.of<NewsProvider>(context).newsCounters['focusedNewsCounter']}' : '10+',style: const TextStyle(color: Colors.white,fontSize: 10),),
                              ),
                            ) : const SizedBox()
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              preferredSize: Size.fromHeight(!kIsWeb ? 60.0 : 120.0),
            ),
            // leadingWidth: 120,
            leading:GestureDetector(
              onTap: () async {
                if (Provider.of<UserProvider>(context, listen: false).userData == null)
                  await Provider.of<UserProvider>(context, listen: false)
                      .getUser(context);
                showCustomBottomSheet(
                    profilePicPath: userData.userData.profilePic,
                    context: context,
                    screenMedia: media);
              },
              child: userData.userData != null ? Stack(
                alignment: Alignment.center,
                children: [
                  (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                  const SizedBox():
                  SpinKitRipple(
                    color: Colors.red[700],
                    size: 220,
                    borderWidth: 30.0,
                  ) ,
                  (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                  const SizedBox():
                  SpinKitRipple(
                    color: Colors.red[700],
                    size: 220,
                    borderWidth: 30.0,
                  ) ,
                  (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                  const SizedBox():
                  SpinKitRipple(
                    color: Colors.red[500],
                    size: 250,
                    borderWidth: 30.0,
                  ) ,
                  (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                  const SizedBox():
                  SpinKitRipple(
                    color: Colors.red[500],
                    size: 250,
                    borderWidth: 30.0,
                  ) ,
                  (userData.userData.profileCompleted && userData.backendNotificationCount == 0 && newsProvider.newsNotificationCount == 0) ?
                  const SizedBox():
                  SpinKitRipple(
                    color: Colors.red[500],
                    size: 250,
                    borderWidth: 30.0,
                  ) ,
                  Container(
                      height: 35.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45.0),
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Expanded(
            //       child: GestureDetector(
            //         onTap: () async {
            //           if (Provider.of<UserProvider>(context, listen: false).userData == null)
            //             await Provider.of<UserProvider>(context, listen: false)
            //                 .getUser(context);
            //           showCustomBottomSheet(
            //               profilePicPath: userData.userData.profilePic,
            //               context: context,
            //               screenMedia: media);
            //         },
            //         child: userData.userData != null ? Stack(
            //           alignment: Alignment.center,
            //           children: [
            //             (userData.userData.profileCompleted && userData.backendNotificationCount == 0) ?
            //             const SizedBox():
            //             SpinKitRipple(
            //               color: Colors.red[700],
            //               size: 220,
            //               borderWidth: 30.0,
            //             ) ,
            //             (userData.userData.profileCompleted && userData.backendNotificationCount == 0) ?
            //             const SizedBox():
            //             SpinKitRipple(
            //               color: Colors.red[700],
            //               size: 220,
            //               borderWidth: 30.0,
            //             ) ,
            //             (userData.userData.profileCompleted && userData.backendNotificationCount == 0) ?
            //             const SizedBox():
            //             SpinKitRipple(
            //               color: Colors.red[500],
            //               size: 250,
            //               borderWidth: 30.0,
            //             ) ,
            //             (userData.userData.profileCompleted && userData.backendNotificationCount == 0) ?
            //             const SizedBox():
            //             SpinKitRipple(
            //               color: Colors.red[500],
            //               size: 250,
            //               borderWidth: 30.0,
            //             ) ,
            //             (userData.userData.profileCompleted && userData.backendNotificationCount == 0) ?
            //             const SizedBox():
            //             SpinKitRipple(
            //               color: Colors.red[500],
            //               size: 250,
            //               borderWidth: 30.0,
            //             ) ,
            //             Container(
            //                 height: 35.0,
            //                 decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(45.0),
            //                 ),
            //                 child:
            //                 userData.userData == null ?
            //                 Image.asset('images/person.png', fit: BoxFit.contain,):
            //                 Container(
            //                   width: 40,
            //                   height: 40,
            //                   decoration: BoxDecoration(
            //                       shape:BoxShape.circle,
            //                       image: DecorationImage(
            //                           image: NetworkImage(userData.userData.profilePic),
            //                           fit: BoxFit.cover
            //                       )
            //                   ),
            //                 )
            //             ),
            //           ],
            //         ) : const SizedBox(),
            //       ),
            //     ),
            //
            //     Provider.of<CallProvider>(context).isInCall ? Padding(
            //       padding: const EdgeInsets.only(left: 5),
            //       child: InkWell(
            //           onTap: (){
            //             Navigator.pushNamed(context, TwilioCallScreen.routeName);
            //           },
            //           child: Container(
            //             padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            //             decoration: BoxDecoration(
            //                 color: Colors.green,
            //                 borderRadius: BorderRadius.circular(20)
            //             ),
            //             child: ShakeAnimatedWidget(
            //               enabled: true,
            //               duration: const Duration(milliseconds: 1700),
            //               shakeAngle: Rotation.deg(z: 40),
            //               curve: Curves.linear,
            //               child: Transform.scale(
            //                 scale: 0.8,
            //                 child: SvgPicture.asset(
            //                   'images/call-filled.svg',
            //                   color: Colors.white,
            //                   width: 20,
            //                 ),
            //               ),
            //             ),
            //           )
            //       ),
            //     ):const SizedBox(width: 0,)
            //   ],
            // ),


          ),
          body: const TabBarView(
            children: <Widget>[
              MyOrgNewsFeed(),
              ProfessionalNews(),
              FavouriteNews()
            ],
          ),
        ),
      ),
    );
  }



}
