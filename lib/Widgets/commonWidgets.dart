// ignore_for_file: file_names, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/ShiftModel.dart';
import 'package:rightnurse/Models/SurveyModel.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/ShakingValidator.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/TwilioCallScreen.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Chat/Contacts.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/NewsFeed/NewsDetails.dart';
import 'package:rightnurse/Subscreens/Profile/MyAccountScreen.dart';
import 'package:rightnurse/Subscreens/Notifications.dart';
import 'package:rightnurse/Subscreens/SettingsScreen.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:flutter/rendering.dart';
import 'package:rightnurse/Subscreens/SurveysScreen.dart';
import 'package:rightnurse/main.dart';
import 'package:share/share.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:websafe_svg/websafe_svg.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:package_info_plus/package_info_plus.dart';



/////////////////////************************** General Constants **************************/////////////////////


final BorderRadius textFieldBorderRadius = BorderRadius.circular(8.0);
final style1 = const TextStyle(color: Color(0xFF212121), fontSize: 17.0, fontWeight: FontWeight.w600);
final style2 = const TextStyle(color: Colors.black, fontSize: 14.0);
final style3 = const TextStyle(color: Colors.grey, fontSize: 14.0);
final style4 = const TextStyle(color: Colors.grey, fontSize: 12.0);
final style5 = const TextStyle(color: Colors.white, fontSize: 14.0);
final style6 = const TextStyle(color: Color(0xFF757575), fontSize: 10.0);
final style7 = const  TextStyle(color: const Color(0xFFF0BA03), fontSize: 14.0, fontWeight: FontWeight.bold);
final style8 = const TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w500);
final style9 = const TextStyle(color: Color(0xFF212121), fontSize: 14.0, fontWeight: FontWeight.w400,height: 0.8);
final style10 = const TextStyle(color: Color(0xFF212121), fontSize: 18.0, fontWeight: FontWeight.w700);
final style11 = const TextStyle(color: Color(0xFF424242), fontSize: 12.0);
final style12= const TextStyle(color: Color(0xFF212121), fontSize: 16.0, fontWeight: FontWeight.w600,height: 0.8);
final style15 = const TextStyle(color: Colors.white, fontSize: 18.0,fontWeight: FontWeight.w700);
final styleGrey = const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold);
final styleBlue = const TextStyle(color: Colors.blue, fontSize: 16.0, fontWeight: FontWeight.bold);
final styleYellow = const TextStyle(color: Color(0xFFFFC306), fontSize: 16.0, fontWeight: FontWeight.bold);
final styleBlue2 = const TextStyle(color: Colors.blue, fontSize: 14.0,);
final greyStyle = const TextStyle(color: Color(0xFF808080), fontSize: 12.0,);
final secondColor = const Color(0xFFFCC306);
final greyColor = const Color(0xFF808080);
final greyColor2 = const Color(0xFFE8E9EB);
final greenColor = const Color(0xFF49B568);
final greenColor2 = const Color(0xFFB2E59B);

bool isMorining = false;
bool isNoon = false;
bool isNight = false;



bool priorityShiftsOnly = false;
bool newlyAddedShiftsOnly = false;
bool isWorkAreasVisibleInShiftsFilter = false;
bool isSubFilterInAnnouncementVisible = false;






/////////////////////************************** SubScreens/NewsFeed **************************/////////////////////



void showNotificationsCustomDialog(context,{mainPhoto,key,onClicked,barrierDismissible=true,height,buttonW,buttonH,width,buttonText,title,subTitle}) {
  bool disMissed = false;
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 500),
    context: context,
    pageBuilder: (_, __, ___) {
      Timer(const Duration(milliseconds: 3000), ()async{
        if (disMissed == false) {
          Navigator.pop(context);
        }
      });
      return SafeArea(
        child: Dismissible(
            onDismissed: (val){
              disMissed = true;
              Navigator.pop(context);
            },
            key: key, child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            textStyle: TextStyle(fontSize: 16,color: Colors.white),
            color: Colors.transparent,
            child: Container(
              height: 80,
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(height: 35,width: 35,child: Transform.scale(scale: 1,child: mainPhoto??Image.asset('images/AppIcon.png'))),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title!=null?Padding(padding: EdgeInsets.symmetric(vertical: 5),child: Text(title,style: TextStyle(fontSize: 11,color: Colors.grey[900],fontWeight: FontWeight.bold),),):const SizedBox(),
                        subTitle!=null?Expanded(child: Padding(padding: EdgeInsets.only(bottom: 10),child: Text(subTitle,style: TextStyle(fontSize: 16,color: Colors.grey[700]),overflow: TextOverflow.ellipsis,),)):const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 50, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        )),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 0), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}




Widget leadingNews(BuildContext context,
    {String title,
      String thumbnail,
      String largeThumbnail,
      String id,
      String description,
      String url,
      var commentsCount,
      var author,
      var tags,
      bool favourite,
      String published,
      Function onShareClicked,
      reactionsCount,
      bool isNewArticle,
      isSharable,
      String documentUrl,
      Function onFavouriteClicked}) {
  return Padding(
    padding:
    const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 5.0),
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, NewsDetails.routeName,
            arguments: {
              "url": url,
              "isFavoured": favourite,
              "id": id,
              'commentsCount':commentsCount,
              "articleThumbnail" : largeThumbnail??thumbnail,
              "articleTitle" : title,
              "isArticleFavourite" : favourite,
              "articleCommentsCount" : commentsCount,
              "articleId" : id
            });
      },
      child: Material(
        color: Theme.of(context).backgroundColor,
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: Container(
                color: Colors.transparent,
                height: 170.0,
                width: double.infinity,
                foregroundDecoration: isNewArticle ? const RotatedCornerDecoration(
                  color: Colors.red,
                  geometry: const BadgeGeometry(width: 64, height: 64),
                  textSpan: TextSpan(
                    text: 'New',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  labelInsets: const LabelInsets(baselineShift: 2),
                ): null,
                child: Image.network(
                  "${largeThumbnail ?? thumbnail}",
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                        child: SpinKitCubeGrid(
                          color: Theme.of(context).primaryColor,
                          size: 40.0,
                        ));
                  },
                  errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                    return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],);
                  },
                ),
              ),
            ),
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, left: 16),
                    child: Text(
                      "${DateFormat('d MMM ' 'yyyy').format(DateTime.parse("$published"))}",
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "$title",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: style1,
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Text(
                "$description",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: style11,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8,top: 18,right: 30,left: 30),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: isSharable
                      ?
                  [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, NewsDetails.routeName,
                              arguments: {
                                "url": url,
                                "isFavoured": favourite,
                                "id": id,
                                'commentsCount':commentsCount,
                                "articleThumbnail" : largeThumbnail??thumbnail,
                                "articleTitle" : title,
                                "isArticleFavourite" : favourite,
                                "articleCommentsCount" : commentsCount,
                                "articleId" : id
                              });
                        },
                        child: Container(
                          height: 30.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    WebsafeSvg.asset(
                                      'images/like.svg',
                                      color: Colors.grey[900],
                                      width: 30,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 3,),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 7),
                                        child:Text('$reactionsCount',style: TextStyle(color:Colors.grey[900],),)
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 2.0,
                              ),
                              // Text(
                              //   "${commentsCount == 0 ? "" : commentsCount}",
                              //   style: TextStyle(
                              //       color: Colors.black, fontSize: 14.0),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, NewsDetails.routeName,
                              arguments: {
                                "url": url,
                                "isFavoured": favourite,
                                "id": id,
                                'commentsCount':commentsCount,
                                "articleThumbnail" : largeThumbnail??thumbnail,
                                "articleTitle" : title,
                                "isArticleFavourite" : favourite,
                                "articleCommentsCount" : commentsCount,
                                "articleId" : id
                              });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top:2.0),
                          height: 25.0,
                          child: Stack(
                            children: [
                              WebsafeSvg.asset(
                                'images/comment.svg',
                                color: Colors.grey[900],
                                width: 22,
                              ),
                              Positioned(
                                bottom: 3,
                                top: 2,
                                right: 2,
                                left: 2,
                                child: Center(
                                  child: Text(
                                    "${commentsCount == 0 ? "" : commentsCount > 99 ? '99+' : commentsCount}",
                                    style: TextStyle(
                                        color: Colors.grey[900], fontSize: 10.0,fontWeight: FontWeight.bold,height: 0.8),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(right: 7.0, left:10.0),
                      child: GestureDetector(
                        onTap: onFavouriteClicked,
                        child: favourite == false
                            ? Image.asset(
                          'images/star.png',
                          color: Colors.grey[900],
                          width: 22,
                        )
                            : Image.asset(
                          'images/starFill.png',
                          color: const Color(0xFFff9c01),
                          width: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: GestureDetector(
                        onTap: () async {
                          print("url from leading $url");
                          showSelectSharePicker(
                              context,
                              url:url,
                              thumbnail: largeThumbnail??thumbnail,
                              articleTitle: title,
                              isFavourite: favourite,
                              id: id,
                              commentsCount: commentsCount,
                            title: title
                          );

                          // await Share.share(url);
                        },
                        child: WebsafeSvg.asset(
                          'images/share.svg',
                          color: Colors.grey[900],
                          width: 22,
                        ),
                      ),
                    )
                  ]
                      :
                  [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, NewsDetails.routeName,
                              arguments: {
                                "url": url,
                                "isFavoured": favourite,
                                "id": id,
                                'commentsCount':commentsCount,
                                "articleThumbnail" : largeThumbnail??thumbnail,
                                "articleTitle" : title,
                                "isArticleFavourite" : favourite,
                                "articleCommentsCount" : commentsCount,
                                "articleId" : id
                              });
                        },
                        child: Container(
                          height: 30.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    WebsafeSvg.asset(
                                      'images/like.svg',
                                      color: Colors.grey[900],
                                      width: 30,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 3,),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 7),
                                        child:Text('$reactionsCount',style: TextStyle(color:Colors.grey[900],),)
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 2.0,
                              ),
                              // Text(
                              //   "${commentsCount == 0 ? "" : commentsCount}",
                              //   style: TextStyle(
                              //       color: Colors.black, fontSize: 14.0),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, NewsDetails.routeName,
                              arguments: {
                                "url": url,
                                "isFavoured": favourite,
                                "id": id,
                                'commentsCount':commentsCount,
                                "articleThumbnail" : largeThumbnail??thumbnail,
                                "articleTitle" : title,
                                "isArticleFavourite" : favourite,
                                "articleCommentsCount" : commentsCount,
                                "articleId" : id
                              });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top:2.0),
                          height: 25.0,
                          child: Stack(
                            children: [
                              WebsafeSvg.asset(
                                'images/comment.svg',
                                color: Colors.grey[900],
                                width: 22,
                              ),
                              Positioned(
                                bottom: 3,
                                top: 2,
                                right: 2,
                                left: 2,
                                child: Center(
                                  child: Text(
                                    "${commentsCount == 0 ? "" : commentsCount > 99 ? '99+' : commentsCount}",
                                    style: TextStyle(
                                        color: Colors.grey[900], fontSize: 10.0,fontWeight: FontWeight.bold,height: 0.8),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: GestureDetector(
                        onTap: onFavouriteClicked,
                        child: favourite == false
                            ? Image.asset(
                          'images/star.png',
                          color: Colors.grey[900],
                          width: 22,
                        )
                            : Image.asset(
                          'images/starFill.png',
                          color: const Color(0xFFff9c01),
                          width: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}


Widget newsCard(BuildContext context,
    {screenMedia,
      String title,
      String description,
      String thumbnail,
      String largeThumbnail,
      String id,
      String url,
      var commentsCount,
      var reactionsCount,
      var author,
      var tags,
      bool favourite,
      String published,
      Function onShareClicked,
      bool isSharable,
      bool isNewArticle,
      String documentUrl,
      Function onFavouriteClicked}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, NewsDetails.routeName,
            arguments: {
              "url": url,
              "isFavoured": favourite,
              "id": id,
              'commentsCount':commentsCount,
              "articleThumbnail" : largeThumbnail??thumbnail,
              "articleTitle" : title,
              "isArticleFavourite" : favourite,
              "articleCommentsCount" : commentsCount,
              "articleId" : id
            });
      },
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 5.0,
        color: Theme.of(context).backgroundColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            foregroundDecoration:
            isNewArticle ?
            const RotatedCornerDecoration(
              color: Colors.red,
              geometry: const BadgeGeometry(width: 45, height: 45),
              textSpan: TextSpan(
                text: 'New',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              labelInsets: const LabelInsets(baselineShift: 2),
            )
                : null
            ,
            child: Padding(
              padding:
              const EdgeInsets.only(left: 12.0,right: 5, bottom: 10.0,top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5, top: 0),
                              child: Text(
                                "${DateFormat('d MMM ' 'yyyy').format(DateTime.parse("$published"))}",
                                style: TextStyle(fontSize: 10.0, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                width: screenMedia.width * 0.44,
                                child: Text(
                                  "$title",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: style1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 1,bottom: 5),
                              child: Container(
                                width: screenMedia.width * 0.44,
                                child: Text(
                                  "$description",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: style11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        child: Container(
                          height: 120.0,
                          width: 160.0,
                          color: Theme.of(context).primaryColor,
                          child: Image.network(
                            "${largeThumbnail ?? thumbnail}",
                            fit: BoxFit.cover,
                            height: 120.0,
                            width: 160.0,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                  child: SpinKitCubeGrid(
                                    // color: Theme.of(context).primaryColor,
                                    color: Colors.white,
                                    size: 35.0,
                                  ));
                            },
                            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                              return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: isSharable ? [
                        Padding(
                          padding:
                          const EdgeInsets.only(right: 7.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, NewsDetails.routeName,
                                  arguments: {
                                    "url": url,
                                    "isFavoured": favourite,
                                    "id": id,
                                    'commentsCount':commentsCount,
                                    "articleThumbnail" : largeThumbnail??thumbnail,
                                    "articleTitle" : title,
                                    "isArticleFavourite" : favourite,
                                    "articleCommentsCount" : commentsCount,
                                    "articleId" : id
                                  });
                              // Navigator.pushNamed(
                              //     context, CommentScreen.routeName,
                              //     arguments: {"id": id});
                              // await Provider.of<NewsProvider>(context, listen: false).fetchCommentsForNewsObject(context, id.toString(),pageOffset: 0);
                            },
                            child: Container(
                              height: 30.0,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: WebsafeSvg.asset(
                                      'images/like.svg',
                                      color: Colors.grey[900],
                                      width: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 2.0,
                                  ),
                                  Text(
                                    "${reactionsCount == 0 ? "" : reactionsCount}",
                                    style: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 14.0),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 7.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, NewsDetails.routeName,
                                  arguments: {
                                    "url": url,
                                    "isFavoured": favourite,
                                    "id": id,
                                    'commentsCount':commentsCount,
                                    "articleThumbnail" : largeThumbnail??thumbnail,
                                    "articleTitle" : title,
                                    "isArticleFavourite" : favourite,
                                    "articleCommentsCount" : commentsCount,
                                    "articleId" : id
                                  });
                              // Navigator.pushNamed(
                              //     context, CommentScreen.routeName,
                              //     arguments: {"id": id});
                              // await Provider.of<NewsProvider>(context, listen: false).fetchCommentsForNewsObject(context, id.toString(),pageOffset: 0);
                            },
                            child: Container(
                                padding: const EdgeInsets.only(top:2.0),
                                height: 25.0,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: WebsafeSvg.asset(
                                        'images/comment.svg',
                                        color: Colors.grey[900],
                                        width: 22,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 2,
                                      top: 2,
                                      right: 2,
                                      left: 2,
                                      child: Center(
                                        child: Text(
                                          "${commentsCount == 0 ? "" : commentsCount > 99 ? '99+' : commentsCount}",
                                          style: TextStyle(
                                              color: Colors.grey[900], fontSize: 8.0,fontWeight: FontWeight.bold,height: 0.3),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 7.0),
                          child: GestureDetector(
                              onTap: onFavouriteClicked,
                              child: favourite == false
                                  ? Image.asset(
                                'images/star.png',
                                color: Colors.grey[900],
                                width: 22,
                              )
                                  : Image.asset(
                                'images/starFill.png',
                                color: Color(0xFFff9c01),
                                width: 22,
                              )),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 7.0),
                          child: GestureDetector(
                            onTap: () async {
                              print("url from newsCard $url");

                              showSelectSharePicker(
                                  context,
                                  url:url,
                                  thumbnail: largeThumbnail??thumbnail,
                                  articleTitle: title,
                                  isFavourite: favourite,
                                  commentsCount: commentsCount,
                                  id: id,
                                  title: title
                              );
                              // await Share.share(url);
                            },
                            child: WebsafeSvg.asset(
                              'images/share.svg',
                              color: Colors.grey[900],
                              width: 22,
                            ),
                          ),
                        )
                      ]
                          :
                      [
                        Padding(
                          padding:
                          const EdgeInsets.only(right: 7.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, NewsDetails.routeName,
                                  arguments: {
                                    "url": url,
                                    "isFavoured": favourite,
                                    "id": id,
                                    'commentsCount':commentsCount,
                                    "articleThumbnail" : largeThumbnail??thumbnail,
                                    "articleTitle" : title,
                                    "isArticleFavourite" : favourite,
                                    "articleCommentsCount" : commentsCount,
                                    "articleId" : id
                                  });
                              // Navigator.pushNamed(
                              //     context, CommentScreen.routeName,
                              //     arguments: {"id": id});
                              // await Provider.of<NewsProvider>(context, listen: false).fetchCommentsForNewsObject(context, id.toString(),pageOffset: 0);
                            },
                            child: Container(
                              height: 30.0,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: WebsafeSvg.asset(
                                      'images/like.svg',
                                      color: Colors.grey[900],
                                      width: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2.0,
                                  ),
                                  Text(
                                    "${reactionsCount == 0 ? "" : reactionsCount}",
                                    style: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 14.0),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 7.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, NewsDetails.routeName,
                                  arguments: {
                                    "url": url,
                                    "isFavoured": favourite,
                                    "id": id,
                                    'commentsCount':commentsCount,
                                    "articleThumbnail" : largeThumbnail??thumbnail,
                                    "articleTitle" : title,
                                    "isArticleFavourite" : favourite,
                                    "articleCommentsCount" : commentsCount,
                                    "articleId" : id
                                  });
                              // Navigator.pushNamed(
                              //     context, CommentScreen.routeName,
                              //     arguments: {"id": id});
                              // await Provider.of<NewsProvider>(context, listen: false).fetchCommentsForNewsObject(context, id.toString(),pageOffset: 0);
                            },
                            child: Container(
                                padding: const EdgeInsets.only(top:2.0),
                                height: 25.0,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: WebsafeSvg.asset(
                                        'images/comment.svg',
                                        color: Colors.grey[900],
                                        width: 22,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 2,
                                      top: 2,
                                      right: 2,
                                      left: 2,
                                      child: Center(
                                        child: Text(
                                          "${commentsCount == 0 ? "" : commentsCount > 99 ? '99+' : commentsCount}",
                                          style: TextStyle(
                                              color: Colors.grey[900], fontSize: 8.0,fontWeight: FontWeight.bold,height: 0.3),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 7.0),
                          child: GestureDetector(
                              onTap: onFavouriteClicked,
                              child: favourite == false
                                  ? Image.asset(
                                'images/star.png',
                                color: Colors.grey[900],
                                width: 22,
                              )
                                  : Image.asset(
                                'images/starFill.png',
                                color: Color(0xFFff9c01),
                                width: 22,
                              )),
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
    ),
  );
}



Widget emptyNewsFeed(context, media, {isVerified}) {
  return ListView(
    children: [
      SizedBox(
        height: media.height * 0.11,
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "images/news.png",
            height: 100.0,
            width: 100.0,
            color: Theme.of(context).primaryColor,
          ),
          Image.asset(
            "images/line.png",
            height: 139.0,
            width: 150.0,
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
      SizedBox(
        height: 25.0,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.15),
        child: Center(
          child: Text(isVerified ? "This feed is lonely without your stories!" : "Check back soon",
              textAlign: TextAlign.center, style: style1),
        ),
      ),
      const SizedBox(
        height: 15.0,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.12),
        child: Center(
            child: Text(
              isVerified
                  ?
              "There's no news to display here right now - check back soon"
                  :
              "We need to verify your account before you can access these articles - we'll let you know once it's done ",
              textAlign: TextAlign.center,
              style: style3,
            )),
      ),
    ],
  );
}



Widget emptyFavourites(context, media, {isVerified}) {
  return ListView(
    children: [

      SizedBox(height: media.height * 0.22,),

      Image.asset('images/starFill.png', color: Color(0xFFff9c01),width: 100,height: 100,),

      SizedBox(height: 30.0,),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.15),
        child: Center(
          child: Text(isVerified ? "You have no saved articles" : "Check back soon",
              textAlign: TextAlign.center,
              style: style1),
        ),
      ),


      SizedBox(height: 20.0,),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.12),
        child: Center(
            child: Text(
              isVerified
                  ?
              "Save your favourite articles for later - you\'ll see them appear here"
                  :
              "We need to verify your account before you can access these articles - we'll let you know once it's done ",
              textAlign: TextAlign.center,
              style: style3,)

        ),
      ),

    ],
  );
}



void showSelectSharePicker(context,
    {url, title,thumbnail, articleTitle, isFavourite, commentsCount, id}) async {
  final status = await Permission.storage.request();

  if (status.isGranted) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20))),
              child:  Wrap(
                children: <Widget>[
                  ListTile(
                      horizontalTitleGap: 0,
                      leading: WebsafeSvg.asset(
                        'images/chatOutline.svg',
                        color: Colors.grey[900],
                        width: 18,
                      ),
                      title:  Text('Share with a Colleague'),
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, ContactsScreen.routeName,arguments: {
                          "articleUrl" : "$url",
                          "articleThumbnail":"$thumbnail",
                          "articleTitle" : "$articleTitle",
                          "isArticleFavourite" : isFavourite,
                          "articleCommentsCount" : commentsCount,
                          "articleId" : id
                        });
                      }
                  ),
                  ListTile(
                    horizontalTitleGap: 0,
                    leading: WebsafeSvg.asset(
                      'images/share.svg',
                      color: Colors.grey[900],
                      width: 18,
                    ),
                    title:  Text('More Options'),
                    onTap: () async {
                      Navigator.pop(context);
                      Share.share(url).then((value) {
                        AnalyticsManager.track(
                            'news_article_share',
                            parameters: {
                              "share_type": "external",
                              "article_name": "$title"
                            }
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}


Widget commentCard(context,
    {userProfilePic,
      userName,
      commentBody,
      commentId,
      postId,
      reactionId,
      commentDate,
      reactionsCount,
      reactions,
      isMessage = false,
      bool isEditing = false,
      commentEditor,
      initialReaction,
      Function onSaveEditingComment,
      Function onCancelEditingComment,
      Function onReplyComment,
      Function onEdit,
      Function onReact,
      reactionsButton,
      bool isMe = false,
      bool canReply=true,
      bool isSubmittingCommentAlteration=false,
      Widget replies,
      Function onProfilePicClicked}) {
  return Padding(
    padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onProfilePicClicked,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(80.0),
            child: Container(
              height: 30.0,
              width: 30.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(80.0),
              ),
              child: userProfilePic == null
                  ? Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Image.asset(
                  "images/person.png",
                  fit: BoxFit.contain,
                  color: Colors.grey[400],
                ),
              )
                  : Image.network(
                userProfilePic,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                  return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],);
                },
              ),
            ),
          ),
        ),
        Flexible(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5,bottom: 5,top: 5),
                        child: Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(right: 10,top: 8),
                        child: commentDate == null
                            ? const SizedBox()
                            : isMessage
                            ? Text(
                            "${DateTime.fromMillisecondsSinceEpoch(commentDate)}",
                            style: TextStyle(
                                fontSize: 10.0,
                                height: 0.2,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey))
                            : Text(
                          "${DateFormat('d MMM ' 'yyyy').format(DateTime.parse("$commentDate"))}",
                          style: TextStyle(
                              fontSize: 10.0,
                              height: 2.2,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFebf5fe),
                          // gradient: LinearGradient(
                          //     end: Alignment.topRight,
                          //     begin: Alignment.bottomLeft,
                          //     colors: [Color(0xffFDFDFD), Color(0xffFDFDFD)]),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(6.0),
                            bottomLeft: Radius.circular(6.0),
                            topRight: Radius.circular(6.0),
                          ),
                        ),
                        // color: Colors.blue[200],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: isEditing
                                  ? commentEditor
                                  : Text(
                                "${commentBody ?? ""}",
                                style: TextStyle(color: Colors.grey[900]),
                                maxLines: null,
                              ),
                            ),
                            !isEditing
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10,vertical: 5),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        reactionsButton,
                                        // FlutterReactionButtonCheck(
                                        //   onReactionChanged:
                                        //       (reaction, index, isChecked) {
                                        //     debugPrint('gygygygyg $index ${reaction.title}');
                                        //     // reaction
                                        //         String reactType = '';
                                        //         if(reaction.id == 1 || reaction.id == 0){
                                        //           reactType = "like";
                                        //         }
                                        //         else if(reaction.id == 2){
                                        //           reactType = "support";
                                        //         }
                                        //         else if(reaction.id == 3){
                                        //           reactType = "insightful";
                                        //         }
                                        //         else if(reaction.id == 4){
                                        //           reactType = "celeberate";
                                        //         }
                                        //         debugPrint("ijijijij ${reaction.id}");
                                        //         if (reactType != '') {
                                        //           Provider.of<NewsProvider>(context,listen: false).reactComment(context,postId:postId,commentId: commentId,reactionType: reactType ).then((_) {
                                        //             Provider.of<NewsProvider>(context,listen: false).fetchCommentsForNewsObject(context,postId,pageOffset: 0);
                                        //           });
                                        //         }
                                        //         // onReact();
                                        //
                                        //       },
                                        //   boxAlignment: Alignment.topCenter,
                                        //   boxPosition: Position.TOP,
                                        //   boxRadius: 8.0,
                                        //   boxPadding: EdgeInsets.symmetric(
                                        //       vertical: 4, horizontal: 6),
                                        //   boxItemsSpacing: 12.0,
                                        //     reactions: <Reaction>[
                                        //       Reaction(
                                        //         previewIcon: Padding(
                                        //           padding: const EdgeInsets.only(bottom: 5),
                                        //           child: WebsafeSvg.asset(
                                        //             'images/like-active.svg',
                                        //             // color: Colors.grey[900],
                                        //             width: 22,
                                        //             height: 22,
                                        //           ),
                                        //         ),
                                        //         icon: WebsafeSvg.asset(
                                        //           'images/like-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //         id: 1
                                        //       ),
                                        //       Reaction(
                                        //         previewIcon: WebsafeSvg.asset(
                                        //           'images/support-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //         icon: WebsafeSvg.asset(
                                        //           'images/support-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //         id: 2
                                        //       ),
                                        //       Reaction(
                                        //         previewIcon: WebsafeSvg.asset(
                                        //           'images/insightful-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //         icon: WebsafeSvg.asset(
                                        //           'images/insightful-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //         id: 3
                                        //       ),
                                        //       Reaction(
                                        //         previewIcon: WebsafeSvg.asset(
                                        //           'images/celeberate-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //         icon: WebsafeSvg.asset(
                                        //           'images/celeberate-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //         id: 4
                                        //       ),
                                        //     ],
                                        //     initialReaction: initialReaction??Reaction(
                                        //       icon: WebsafeSvg.asset(
                                        //         'images/like.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //         color: Colors.grey[700],
                                        //       ),
                                        //     ),
                                        //     selectedReaction: Reaction(
                                        //       icon: WebsafeSvg.asset(
                                        //         'images/like-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //         // color: Colors.grey[700],
                                        //       ),
                                        //       id: 0
                                        //     ),
                                        // ),
                                        const SizedBox(width: 16,),
                                        canReply ? GestureDetector(
                                          child: Image.asset(
                                            'images/reply.png',
                                            width: 22,
                                            color: Colors.grey[700],
                                          ),
                                          onTap: onReplyComment,

                                        ) : const SizedBox(),

                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(padding: const EdgeInsets.only(top: 5),
                                        child: Text("$reactionsCount"??'',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600],fontSize: 12),),
                                      ),
                                      const SizedBox(width: 3,),
                                      reactions
                                    ],
                                  ),
                                ),
                              ],
                            )
                                : SizedBox()
                          ],
                        ),
                      ),
                      isEditing
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8,left: 2,bottom: 10),
                          child: isSubmittingCommentAlteration
                              ?
                          SpinKitCircle(color: Theme.of(context).primaryColor,size: 20,)
                              :
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                  onTap: onSaveEditingComment,
                                  child: Text(
                                    'save',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  )),
                              const SizedBox(width: 20,),
                              InkWell(
                                  onTap: onCancelEditingComment,
                                  child: Text('cancel',
                                      style: TextStyle(
                                          color:
                                          Theme.of(context).primaryColor))),
                            ],
                          ),
                        ),
                      )
                          : SizedBox(),
                    ],
                  ),
                ),
                replies == null ? SizedBox() : replies
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget replyCard(context,
    {userProfilePic,
      userName,
      commentBody,
      commentDate,
      reactionsCount,
      reactions,
      isMessage = false,
      bool isEditing = false,
      commentEditor,
      Function onSaveEditingComment,
      Function onCancelEditingComment,
      Function onEdit,
      reactionsButton=const SizedBox(),
      bool isMe = false,
      bool isSubmittingCommentAlteration =false,
      Function onProfilePicClicked}) {
  return Padding(
    padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onProfilePicClicked,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(80.0),
            child: Container(
              height: 30.0,
              width: 30.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(80.0),
              ),
              child: userProfilePic == null
                  ? Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Image.asset(
                  "images/person.png",
                  fit: BoxFit.contain,
                  color: Colors.grey[400],
                ),
              )
                  : Image.network(
                userProfilePic,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                  return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],);
                },
              ),
            ),
          ),
        ),
        Flexible(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5,bottom: 5,top: 5),
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 10),
                      child: commentDate == null
                          ? const SizedBox()
                          : isMessage
                          ? Text(
                          "${DateTime.fromMillisecondsSinceEpoch(commentDate)}",
                          style: TextStyle(
                              fontSize: 10.0,
                              height: 1.8,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey))
                          : Text(
                        "${DateFormat('d MMM ' 'yyyy').format(DateTime.parse("$commentDate"))}",
                        style: TextStyle(
                            fontSize: 10.0,
                            height: 1.8,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color : Color(0xFFebf5fe),
                          // gradient: LinearGradient(
                          //     end: Alignment.topRight,
                          //     begin: Alignment.bottomLeft,
                          //     colors: [Color(0xffFDFDFD), Color(0xffFDFDFD)]),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(6.0),
                            bottomLeft: Radius.circular(6.0),
                            topRight: Radius.circular(6.0),
                          ),
                        ),
                        // color: Colors.blue[200],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: isEditing
                                  ? commentEditor
                                  : Text(
                                "${commentBody ?? ""}",
                                style: TextStyle(color: Colors.grey[900]),
                                maxLines: null,
                              ),
                            ),
                            !isEditing
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10,vertical: 5),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        reactionsButton
                                        // FlutterReactionButtonCheck(
                                        //   onReactionChanged:
                                        //       (reaction, index, isChecked) {
                                        //
                                        //   },
                                        //   boxAlignment: Alignment.topCenter,
                                        //   boxPosition: Position.TOP,
                                        //   boxRadius: 8.0,
                                        //   boxPadding: EdgeInsets.symmetric(
                                        //       vertical: 4, horizontal: 6),
                                        //   boxItemsSpacing: 12.0,
                                        //   reactions: <Reaction>[
                                        //     Reaction(
                                        //       previewIcon: Padding(
                                        //         padding: const EdgeInsets.only(bottom: 5),
                                        //         child: WebsafeSvg.asset(
                                        //           'images/like-active.svg',
                                        //           // color: Colors.grey[900],
                                        //           width: 22,
                                        //           height: 22,
                                        //         ),
                                        //       ),
                                        //       icon: WebsafeSvg.asset(
                                        //         'images/like-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //       ),
                                        //     ),
                                        //     Reaction(
                                        //       previewIcon: WebsafeSvg.asset(
                                        //         'images/support-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //       ),
                                        //       icon: WebsafeSvg.asset(
                                        //         'images/support-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //       ),
                                        //     ),
                                        //     Reaction(
                                        //       previewIcon: WebsafeSvg.asset(
                                        //         'images/insightful-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //       ),
                                        //       icon: WebsafeSvg.asset(
                                        //         'images/insightful-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //       ),
                                        //     ),
                                        //     Reaction(
                                        //       previewIcon: WebsafeSvg.asset(
                                        //         'images/celeberate-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //       ),
                                        //       icon: WebsafeSvg.asset(
                                        //         'images/celeberate-active.svg',
                                        //         // color: Colors.grey[900],
                                        //         width: 22,
                                        //         height: 22,
                                        //       ),
                                        //     ),
                                        //   ],
                                        //   initialReaction: Reaction(
                                        //     icon: WebsafeSvg.asset(
                                        //       'images/like.svg',
                                        //       // color: Colors.grey[900],
                                        //       width: 22,
                                        //       height: 22,
                                        //       color: Colors.grey[700],
                                        //     ),
                                        //   ),
                                        //   selectedReaction: Reaction(
                                        //     icon: WebsafeSvg.asset(
                                        //       'images/like.svg',
                                        //       // color: Colors.grey[900],
                                        //       width: 22,
                                        //       height: 22,
                                        //       color: Colors.grey[700],
                                        //     ),
                                        //   ),
                                        // ),

                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(padding: const EdgeInsets.only(top: 5),
                                        child: Text("$reactionsCount"??'',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600],fontSize: 12),),
                                      ),
                                      const SizedBox(width: 3,),
                                      reactions
                                    ],
                                  ),
                                ),
                              ],
                            )
                                : SizedBox()
                          ],
                        ),
                      ),
                      isEditing
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8,left: 2,bottom: 10),
                          child: isSubmittingCommentAlteration ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 20,) : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                  onTap: onSaveEditingComment,
                                  child: Text(
                                    'save',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  )),
                              const SizedBox(width: 20,),
                              InkWell(
                                  onTap: onCancelEditingComment,
                                  child: Text('cancel',
                                      style: TextStyle(
                                          color:
                                          Theme.of(context).primaryColor))),
                            ],
                          ),
                        ),
                      )
                          : SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


showCommentsBottomSheet(
    {BuildContext context,
      Function onDelete,
      Function onEdit,
      Function onReply}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(15.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            onEdit();
                          },
                          child: Text(
                            "Edit",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 23.0,
                            ),
                          )),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            onDelete();
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 23.0,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Material(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Cancel",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 23.0,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              )
            ],
          ),
        );
      });
}


void showServeysDialoge(
    {context}) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 500),
    context: context,
    pageBuilder: (_, __, ___) {
      return StatefulBuilder(builder: (context,setState){
        return Align(
          alignment: Alignment.center,
          child: Material(
            textStyle: TextStyle(
              fontSize: 16,),
            color: Colors.transparent,
            child: Container(
              // height: height??300,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text('At work there is someone who encourages my development',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey[800],height: 1.4),textAlign: TextAlign.center,),
                  ),
                  const SizedBox(height: 40,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap:(){
                              setState(() {

                              });
                            },
                            child: Image.asset("images/strongly-disAgree.png",height: 40,width: 40,)
                        ),
                        Image.asset("images/disAgree.png",height: 40,width: 40,),
                        Image.asset("images/Neither-agree-nor-disagree.png",height: 40,width: 40,),
                        Image.asset("images/agree.png",height: 40,width: 40,),
                        Image.asset("images/strongly-agree.png",height: 40,width: 40,),

                      ],
                    ),
                  ),
                  const SizedBox(height: 40,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('your response is anonymous - it will help us to make improvements',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey[400],height: 1.2,fontSize: 12),textAlign: TextAlign.center,),
                  ),
                  const SizedBox(height: 30,),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Skip',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  )
                ],
              ),
              margin: EdgeInsets.only(bottom: 50, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      });
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}


Widget showReactionsBottomSheet({
  BuildContext context,
  screenMedia,
  Widget content=const SizedBox(),
  profilePicPath,
  tabBarItems
}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return DefaultTabController(
          initialIndex: 0,
          length: tabBarItems,
          child: Stack(
            children: [
              Positioned(
                right: MediaQuery.of(context).size.width*0.4,
                left: MediaQuery.of(context).size.width*0.4,
                top: 10,
                child: Container(
                  width: MediaQuery.of(context).size.width*0.2,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20)
                  ),
                ),
              ),
              content,
            ],
          ),
        );
      });
}

/////////////////////******************************************************************************************/////////////////////


/////////////////////************************** Screens/directory.dart **************************/////////////////////

Widget directoryUserCard(
    {context,
      name,
      job,
      profilePicPath,
      trust,
      workArea,
      List<Widget> buttonList}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
    child: Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8)),
              )),
          Positioned.fill(
              child: Image.asset(
                '${Provider.of<UserProvider>(context,listen: false).currentAppBackground}',
                fit: BoxFit.fitWidth,
                color: Colors.grey[600],
              )),
          Row(
            children: [
              SizedBox(width: 50),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // borderRadius: BorderRadius.circular(8),
                          border: Border(
                            top:
                            BorderSide(width: 1.2, color: Colors.grey[200]),
                          ),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 35, top: 5, bottom: 5),
                                          child: Text(
                                            '$name',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: style1,
                                          ),
                                        ),
                                        job == null || job == ""
                                            ? const SizedBox()
                                            : Padding(
                                          padding: const EdgeInsets.only(
                                              left: 35, top: 0, bottom: 10),
                                          child: Text(
                                            '$job',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: style3,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Divider(
                            //   color: Colors.grey[300],
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5.0, bottom: 10.0, left: 45.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WebsafeSvg.asset(
                                    'images/organisation.svg',
                                    color: Colors.grey,
                                    width: 25.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Text(
                                        "$trust",
                                        style: style9,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            workArea != null
                                ? Padding(
                              padding: const EdgeInsets.only(left: 45),
                              child: Container(
                                // color: Colors.red,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top:5),
                                      child: WebsafeSvg.asset(
                                        'images/area-of-work.svg',
                                        color: Colors.grey,
                                        width: 25,
                                      ),
                                    ),
                                    Expanded(child: Padding(padding: EdgeInsets.only(left: 5),child: workArea,))
                                  ],
                                ),
                              ),
                            )
                                : const SizedBox(),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 2.0),
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 2.0),
                              child:
                              Provider.of<ChatProvider>(context).creatingNewChatChannel == ChatStage.LOADING ?
                              Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 25,),):
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: buttonList,
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 20.0,
            left: 15,
            // right: 0.0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3.5),
                  borderRadius: BorderRadius.circular(
                    60.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.blue[200],
                  backgroundImage: profilePicPath == null
                      ? AssetImage('images/person.png')
                      : NetworkImage(profilePicPath),
                  radius: 40.0,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


String getJobRolesCommaSeparatedList(List<dynamic> roles) {
  String ret = '';
  if (roles == null || roles.isEmpty) {
    return '';
  }
  switch (roles.length) {
    case 1:
      ret += roles[0]['name'];
      break;
    case 2:
      ret += roles[0]['name'] + ', ' + roles[1]['name'];
      break;
    default:
      ret += roles[0]['name'] +
          ', ' +
          roles[1]['name'] +
          ' + ${roles.length - 2} more';
  }

  return ret;
}


Widget emptyDirectory(context, media, {isVerified}) {
  return ListView(
    children: [

      SizedBox(height: media.height * 0.22,),

      Image.asset('images/starFill.png', color: const Color(0xFFff9c01),width: 100,height: 100,),

      SizedBox(height: 30.0,),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.15),
        child: Center(
          child: Text(isVerified ? "You have no saved articles" : "Check back soon",
              textAlign: TextAlign.center,
              style: style1),
        ),
      ),


      SizedBox(height: 20.0,),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.12),
        child: Center(
            child: Text(
              isVerified
                  ?
              "Save your favourite articles for later - you\'ll see them appear here"
                  :
              "We need to verify your account before you can access these articles - we'll let you know once it's done ",
              textAlign: TextAlign.center,
              style: style3,)

        ),
      ),

    ],
  );
}



/////////////////////******************************************************************************************/////////////////////


/////////////////////************************** Screens/shifts.dart **************************/////////////////////

Widget shiftsBottomSheet(BuildContext context,
    {Function isNoonClicked,
      Function isMorningClicked,
      Function isNightClicked,
      Function onToggle,
      Function apply,
      bool isNewActive = false,
      screenMedia}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        bool newActive = isNewActive;

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return isWorkAreasVisibleInShiftsFilter
                  ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Image.asset(
                              'images/area.png',
                              color: Theme.of(context).primaryColor,
                              width: 25,
                            ),
                            onPressed: () {
                              setState(() {
                                isWorkAreasVisibleInShiftsFilter = false;
                              });
                            }),
                        Text(
                          "Areas of Work",
                          style: style1,
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              isWorkAreasVisibleInShiftsFilter = false;
                            });
                          },
                          child: Text(
                            "Done",
                            style: styleYellow,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                          onTap: null,
                          child: Row(
                            children: [
                              Text(
                                "Select all",
                                style: style1,
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Icon(
                                  Icons.done,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          )),
                    ),
                    Text(
                      "PORTSMOUTH MVC",
                      style: styleBlue,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: screenMedia.height * 0.26,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 16,
                          itemBuilder: (context, i) => Column(
                            children: [
                              Container(
                                height: 30.0,
                                child: ListTile(
                                  onTap: null,
                                  title: Text(
                                    "A - Entrance",
                                    style: style2,
                                  ),
                                  trailing: Icon(
                                    Icons.done,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Divider()
                            ],
                          )),
                    )
                  ],
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: styleYellow,
                          ),
                        ),
                        Text(
                          "Shift Filter",
                          style: style1,
                        ),
                        FlatButton(
                          onPressed: apply ?? null,
                          child: Text(
                            "Apply",
                            style: styleYellow,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isWorkAreasVisibleInShiftsFilter = true;
                          });
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'images/area.png',
                              color: Theme.of(context).primaryColor,
                              width: 25,
                            ),
                            SizedBox(
                              width: 7.0,
                            ),
                            Text(
                              "Areas of Work",
                              style: style2,
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isWorkAreasVisibleInShiftsFilter = true;
                                    });
                                  },
                                  child: Text(
                                    "Any",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            WebsafeSvg.asset(
                              'images/shiftsOutLine.svg',
                              color: Theme.of(context).primaryColor,
                              width: 25,
                            ),
                            const SizedBox(
                              width: 7.0,
                            ),
                            Text(
                              "Shift Types",
                              style: style2,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 6.0),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                                child: GestureDetector(
                                  onTap: isMorningClicked,
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:  Colors.grey[400]),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                        child: WebsafeSvg.asset("images/halfSun.svg",width: 20,)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                                child: GestureDetector(
                                  onTap: isNoonClicked,
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:  Colors.grey[400]),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                        child: WebsafeSvg.asset("images/sun.svg",width: 24,)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                                child: GestureDetector(
                                  onTap: isNightClicked,
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey[400]),
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.transparent,
                                    ),
                                    child: Center(
                                        child: WebsafeSvg.asset("images/moon.svg",width: 20,)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),

                    // const Divider(),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         Icons.priority_high_rounded,
                    //         color: Colors.grey,
                    //       ),
                    //       SizedBox(
                    //         width: 7.0,
                    //       ),
                    //       Text(
                    //         "Top priority shifts only",
                    //         style: style2,
                    //       ),
                    //       Spacer(),
                    //       SizedBox(
                    //         height: 40,
                    //         // width: 100,
                    //         child: LiteRollingSwitch(
                    //           value: false,
                    //           colorOff: Colors.grey,
                    //           colorOn: Theme.of(context).primaryColor,
                    //           textOff: "OFF",
                    //           textOn: "ON",
                    //           iconOn: Icons.done,
                    //           iconOff: Icons.cancel,
                    //           textSize: 16.0,
                    //           onChanged: (bool value) {
                    //           },
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 7.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Newly added only",
                                style: style2,
                              ),
                              const Text(
                                "(within past 24 hours)",
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.grey),
                              )
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 40,
                            // width: 100,
                            child: FlutterSwitch(
                              height: 30,
                              width: 60,
                              showOnOff: true,
                              activeText: '',
                              inactiveText: '',
                              // activeTextColor: Colors.black,
                              // inactiveTextColor: Colors.blue[50],
                              inactiveColor: Colors.black38,
                              value: newActive,
                              onToggle:(val){
                                onToggle();
                                newActive = val;
                                setState(() {
                                  newActive = val;
                                });
                                print("hh ${newActive}");
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    )
                  ],
                ),
              );
            });
      });
}

Widget showCustomBottomSheet({
  BuildContext context,
  screenMedia,
  profilePicPath,
}) {
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
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
                                child: profilePicPath == null
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
                                          image: NetworkImage(profilePicPath),
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
                            fontSize: 18.0),
                      )
                    ],
                  ),
                ),
              ),
              Provider.of<UserProvider>(context, listen: false).userSurveyLink == null ? const SizedBox():
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: InkWell(
                  onTap: () {
                    if (Provider.of<UserProvider>(context, listen: false)
                        .userSurveyLink !=
                        null)
                      Navigator.popAndPushNamed(
                          context, SurveysScreen.routeName);
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: WebsafeSvg.asset(
                          "images/survey-filled.svg",
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
                            fontSize: 18.0),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: InkWell(
                  onTap: () {
                    Navigator.popAndPushNamed(context, NotificationsScreen.routName);
                    Provider.of<UserProvider>(context, listen: false).clearUnreadNotificationCount();
                    Provider.of<NewsProvider>(context, listen: false).clearUnreadNewsNotificationCount();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: WebsafeSvg.asset("images/notification-filled.svg",
                              color: Theme.of(context).primaryColor,width: 25,),
                          ),
                          const SizedBox(
                            width: 37.0,
                          ),
                          Text(
                            "Notifications",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18.0),
                          )
                        ],
                      ),
                      Provider.of<UserProvider>(context, listen: false).backendNotificationCount == 0 && Provider.of<NewsProvider>(context, listen: false).newsNotificationCount == 0
        ?
                      const SizedBox()
                          :
                      Container(
                        height: 23,
                        width: 23,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFff0f0f)
                        ),
                        padding: const EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text((Provider.of<UserProvider>(context, listen: false).backendNotificationCount + Provider.of<NewsProvider>(context, listen: false).newsNotificationCount) <= 99 ? "${Provider.of<UserProvider>(context, listen: false).backendNotificationCount + Provider.of<NewsProvider>(context, listen: false).newsNotificationCount}" : "99+",
                          style: TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.w600),),
                      )
                    ],
                  ),
                ),
              ),
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
                        child: WebsafeSvg.asset('images/support-filled.svg',
                          color: Theme.of(context).primaryColor,height: 25,
                          width: 25,),
                      ),
                      SizedBox(
                        width: 37.0,
                      ),
                      Text(
                        "Help/Support",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18.0),
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
                        child: WebsafeSvg.asset('images/setting-filled.svg',
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
                            fontSize: 18.0),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}


Widget shiftCard(BuildContext context, { Offer offer}) {
  return Stack(
    children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                color: const Color(0xFFEEF6FE),
                // shiftType == 0 ? Color(0xFFFDF5D7) : shiftType == 1 ? Color(0xFFFFEBD6) : Color(0xFFEEF6FE),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${formatStringTimeToDayAndMonth(stringTime: readTimestamp(offer.startDate))}",
                            style: TextStyle(color: greyColor, fontSize: 13.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: offer.shiftType.value == 1
                                      ? WebsafeSvg.asset("images/sun.svg",width: 20,)
                                      : offer.shiftType.value  == 0
                                      ? WebsafeSvg.asset("images/halfSun.svg",width: 20,)
                                      : WebsafeSvg.asset("images/moon.svg",width: 16,),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Text(
                                    "${formatStringTimeToWeekDay(stringTime: readTimestamp(offer.startDate))}",
                                    style: style8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${convertTimestampToHoursAndMinutes(offer.startDate)} - ${convertTimestampToHoursAndMinutes(offer.endDate)}",
                            style: TextStyle(color: greyColor, fontSize: 13.0),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: hasCoreRate ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Text(
                    offer.hospital.name ?? "",
                    style: TextStyle(color: greyColor, fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10,bottom: 1),
                    child: Text(
                      offer.ward.name ?? "",
                      style: style12,
                      // maxLines: 2,
                    ),
                  ),
                  offer.coreRate > 0.0 ? const Divider():
                  const SizedBox(),
                  Row(
                    children: [
                      offer.coreRate > 0.0 ? Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: WebsafeSvg.asset("images/core-rate.svg",height: 20,color: Colors.grey,),
                      )
                          :
                      const SizedBox(),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              offer.coreRate > 0.0
                                  ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Core Rate:",
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${offer.currency.symbol}${offer.coreRate}",
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13.0),
                                  ),
                                ],
                              )
                                  :
                              const SizedBox(),
                              const SizedBox(height: 2,),
                              // offer.enhancedRateValue > 0.0 ? "${shiftsProvider.upComingWeeks[i].offers[index].enhancedRateValue}" : null
                              // offer.enhancedRateValue != null &&
                                  offer.enhancedRateValue > 0.0
                                  ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Enhanced Rate: ",
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${offer.currency.symbol}${offer.enhancedRateValue}",
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13.0),
                                  ),
                                ],
                              )
                                  :
                              const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // showShiftStatus
                  //     ? Padding(
                  //         padding: const EdgeInsets.only(top: 3.0),
                  //         child: Text(
                  //           "$shiftStatus",
                  //           style: TextStyle(
                  //             color: Colors.yellow[800],
                  //           ),
                  //         ),
                  //       )
                  //     : const SizedBox()
                ],
              ),
            )
          ],
        ),
      ),
      Positioned(
        right: 3,
        top: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            offer.bookingType == "bid" ? WebsafeSvg.asset("images/bid.svg",height: 24,) : const SizedBox(),
            offer.newShift ?
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 1,top: 2),
                child: Text('New',style: TextStyle(color: Theme.of(context).primaryColor),),
              ),
            )
                : const SizedBox(),
          ],
        ),
      )
    ],
  );
}


Widget timeSheetCard(BuildContext context, { TimeSheetDay timeSheetDay}) {
  return Stack(
    children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                color: const Color(0xFFEEF6FE),
                height: 70,
                // width: 70,
                // shiftType == 0 ? Color(0xFFFDF5D7) : shiftType == 1 ? Color(0xFFFFEBD6) : Color(0xFFEEF6FE),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${DateFormat('EEE').format(timeStampToDateTime(timeSheetDay.start_date))}",
                        style: style8,
                      ),
                      Text(
                        "${timeStampToDateTime(timeSheetDay.start_date).day} ${DateFormat('MMM').format(timeStampToDateTime(timeSheetDay.start_date))}",
                        style: TextStyle(color: greyColor, fontSize: 13.0),
                      ),
                      Text(
                        "${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetDay.provider['booked_start_time']))} - ${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetDay.provider['booked_end_time']))}",
                        style: TextStyle(color: greyColor, fontSize: 11.0),
                      )

                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: hasCoreRate ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Text(
                    timeSheetDay.timesheet_status['name'] ?? "",
                    style: TextStyle(color: const Color(0xFFff9c01), fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7,bottom: 3),
                    child: Text(
                      timeSheetDay.ward['name'] ?? "",
                      style: style12,
                      // maxLines: 2,
                    ),
                  ),
                  Text(
                    timeSheetDay.hospital['name'] ?? "",
                    style: TextStyle(color: greyColor, fontSize: 13.0),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ],
  );
}

Widget emptyShifts(BuildContext context,media,type){
  return Container(
    // height: media.height,
    width: media.width,
    alignment: Alignment.center,
    child: ListView(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 15,),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Image.asset("images/shiftsOutLine.png",height: 80,color: Colors.grey[800],),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(Provider.of<ShiftsProvider>(context,listen: false).currentShiftType == 0
              ?
          "Eligible shift requests and  scheduled shifts will show here if your profile is complete and updated" :
          Provider.of<ShiftsProvider>(context,listen: false).currentShiftType == 1 ?
            "Your accepted shifts will show here" :
            "Completed shifts will show here",
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 60,),
        Center(
          child: InkWell(
              onTap: ()async{
                Navigator.pushReplacementNamed(context, MyAccountsScreen.routName);
              },
              child: Text("Check Profile",style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 18),)
          ),
        ),
        const SizedBox(height: 15,),
        Align(
          alignment: Alignment.bottomCenter,
          child: needHelp(context,type: type),
        ),
        const SizedBox(height: 100,)
      ],
    ),
  );
}

Widget emptyShiftsForDayOffers(BuildContext context,media ){
  return Container(
    height: media.height,
    width: media.width,
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const SizedBox(height: 100,),
        Image.asset("images/shiftsOutLine.png",height: 80,color: Colors.grey[800],),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No shifts for this date",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(20.0),
        //   child: Text("See if there are any upcoming shifts for this date instead.",textAlign: TextAlign.center,),
        // ),
        // const SizedBox(height: 60,),
        // InkWell(
        //     onTap: ()async{
        //       Navigator.pushReplacementNamed(context, MyAccountsScreen.routName);
        //     },
        //     child: Text("Check Profile",style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 18),)
        // ),
        // const Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: needHelp(context,type: 'offers'),
        ),
        // const SizedBox(height: 100,)
      ],
    ),
  );
}

/////////////////////******************************************************************************************/////////////////////




/////////////////////************************** SubScreens/SettingsScreen.dart **************************/////////////////////

void showLogoutDialog(
    {context,bool loggingOut=false}) {
  bool showLoader = loggingOut;

  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 500),
    context: context,
    pageBuilder: (_, __, ___) {
      return StatefulBuilder(builder: (context,setState){
        return Align(
          alignment: Alignment.center,
          child: Material(
            textStyle: TextStyle(
              fontSize: 16,),
            color: Colors.transparent,
            child: Container(
              // height: height??300,
              width: 400,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("images/logout.png",color: Theme.of(context).primaryColor,height: 40,width: 40,),


                  const SizedBox(height: 25,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Are you sure you want to log out ?',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey[800],height: 1.4),textAlign: TextAlign.center,),
                  ),
                  const SizedBox(height: 40,),
                  showLoader ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 25,) : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Cancel',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            showLoader = true;
                          });
                          Provider.of<UserProvider>(context,listen:false).logOut(context).then((_) => {
                            setState(() {
                              showLoader = false;
                            })
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Log out',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 35, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      });
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

/////////////////////******************************************************************************************/////////////////////


/////////////////////************************** SubScreens/CommentsScreen.dart **************************/////////////////////



/////////////////////******************************************************************************************/////////////////////





/////////////////////************************** SubScreens/Notifications.dart **************************/////////////////////



Widget notificationCard(BuildContext context,
    {notificationImg,
      String notificationTitle,
      String notificationDate,
      Color cardColor,
      bool isDefaultNotification=true,
      int notificationType=0, // it take an initial value of zero as it may take null value depending on notification type from meta data
      bool notificationClicked=false,
      Function onClick}) {
  return GestureDetector(
    onTap: onClick,
    child: Material(
      elevation: 0.0,
      color: notificationClicked ? Colors.white : Color(0xFFebf5fe) ,
      // borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300])),),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top:5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: notificationImg == null
                                ?
                            Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: notificationType == 1 || notificationType == 2 || notificationType == 3 || notificationType == 5 || notificationType == 6 || notificationType == 7 || notificationType == 10 || notificationType == 13 || notificationType == 14 || notificationType == 15 || notificationType == 16
                                    ?
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: WebsafeSvg.asset(notificationClicked ? 'images/shiftsOutLine.svg' : 'images/shiftsFilled.svg',width:25,color: Theme.of(context).primaryColor,),
                                )
                                    :
                                notificationType == 17 || notificationType == 18
                                    ?
                                WebsafeSvg.asset(
                                  notificationClicked ? 'images/survey3.svg' : 'images/survey2.svg',
                                  width: 30,
                                )
                                    :
                                Padding(
                                padding: const EdgeInsets.only(right: 3),
                                  child: WebsafeSvg.asset(notificationClicked ? 'images/notification.svg' : 'images/notification-filled.svg' ,color: Theme.of(context).primaryColor,width: 30,height: 30,),
                                )

                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(80.0),
                              child: Image.network(
                                notificationImg,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                  return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],);
                                },
                              ),
                            ),
                          ),
                          notificationClicked ? SizedBox() : Positioned(top: 1,right: 18,child: Container(width: 12,height: 12,decoration: BoxDecoration(shape: BoxShape.circle,color: const Color(0xFFFFC306)),))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 25,top: 5),
                        child: Text(
                          notificationTitle != null
                              ? "$notificationTitle"
                              : "Notification Title",
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: style2,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8,top: 10),
                  child: Text(
                    notificationDate != null ? "$notificationDate" : "",
                    style: style6,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}



/////////////////////******************************************************************************************/////////////////////




/////////////////////**************************  User Profile Image in Twillio Screen **************************/////////////////////

Widget userProfileImage({@required String imageUrl, @required int radius}) {
  return Container(
    width: radius * 2.0,
    height: radius * 2.0,
    decoration: BoxDecoration(
      image: DecorationImage(
        fit: BoxFit.fill,
        image: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : Image.asset(
          "images/person.png",
          fit: BoxFit.contain,
          color: Colors.white,
        ).image,
      ),
      shape: BoxShape.circle,
    ),
  );
}

/////////////////////********************************************************************/////////////////////




/////////////////////**************************  Shaking Widget for Validation **************************/////////////////////

enum ErrorAnimationProp { offset }

class ShakingErrorText extends StatelessWidget {
  final ShakingErrorController controller;
  final int timesToShake;
  final MultiTween<ErrorAnimationProp> _tween;

  ShakingErrorText({
    this.controller,
    this.timesToShake = 4,
  }) : _tween = MultiTween<ErrorAnimationProp>() {
    List.generate(
        timesToShake,
            (_) => _tween
          ..add(ErrorAnimationProp.offset, Tween<double>(begin: 0, end: 10),
              Duration(milliseconds: 100))
          ..add(ErrorAnimationProp.offset, Tween<double>(begin: 10, end: -10),
              Duration(milliseconds: 100))
          ..add(ErrorAnimationProp.offset, Tween<double>(begin: -10, end: 0),
              Duration(milliseconds: 100)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShakingErrorController>.value(
      value: controller,
      child: Consumer<ShakingErrorController>(
        builder: (context, errorController, child) {
          return CustomAnimation<MultiTweenValues<ErrorAnimationProp>>(
            control: errorController.controlSignal,
            curve: Curves.easeOut,
            duration: _tween.duration,
            tween: _tween,
            animationStatusListener: (status) {
              if (status == AnimationStatus.forward) {
                controller.onAnimationStarted();
              }
            },
            builder: (BuildContext context, Widget child, tweenValues) {
              return Transform.translate(
                offset: Offset(tweenValues.get(ErrorAnimationProp.offset), 0),
                child: child,
              );
            },
            child: Visibility(
              visible: controller.isVisible && controller.isMounted,
              maintainSize: controller.isMounted,
              maintainAnimation: controller.isMounted,
              maintainState: controller.isMounted,
              child: Text(errorController.errorText,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}

/////////////////////********************************************************************/////////////////////



/////////////////////************************** Screens/Chat **************************/////////////////////

showAttachImgBottomSheet(
    {BuildContext context, Function onCameraImg, Function onGalleryImg, isFromGroupDetails = false, Function removeGroupPhoto, isFromMessagingScreen = false, Function onDocument}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Provider.of<UserProvider>(context, listen: false).userData.canShareDocs && isFromMessagingScreen ?
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        onDocument();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                        child: Row(
                          children: [
                            Icon(Icons.insert_drive_file, color: Theme.of(context).primaryColor,),
                            const SizedBox(width: 10.0,),
                            Text(
                              "Send a document",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 19.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) : const SizedBox(),

                    Provider.of<UserProvider>(context, listen: false).userData.canShareDocs && isFromMessagingScreen ?
                    const Divider() : const SizedBox(),

                    InkWell(
                      onTap: (){
                        print('common widgets gallery');
                        Navigator.pop(context);
                        onGalleryImg();

                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                        child: Row(
                          children: [
                            Icon(Icons.photo, color: Theme.of(context).primaryColor,),
                            const SizedBox(width: 10.0,),
                            Text(
                              isFromMessagingScreen ? "Send a photo" : "Choose from library",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 19.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    kIsWeb ? const SizedBox() : const Divider(),
                    kIsWeb ? const SizedBox() : InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        onCameraImg();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt_rounded, color: Theme.of(context).primaryColor,),
                            const SizedBox(width: 10.0,),
                            Text(
                              "Take a photo",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 19.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    isFromGroupDetails ? const Divider() : const SizedBox(),
                    isFromGroupDetails
                        ?
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        removeGroupPhoto();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          "Remove group image",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 23.0,
                          ),
                        ),
                      ),
                    )
                        :
                    const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Material(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Cancel",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 23.0,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),

            ],
          ),
        );
      });
}


/////////////////////********************************************************************/////////////////////



/////////////////////************************** General Widgets **************************/////////////////////



formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return 0;
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals));
}


class SurveyReactions extends StatefulWidget {
  @override
  _SurveyReactionsState createState() => _SurveyReactionsState();
}

class _SurveyReactionsState extends State<SurveyReactions> {

  final String _filled = "-filled";

  Map<int,bool> _isSurveyReactionFilled = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
  };
  final List<Color> _surveysReactionsColors = [
    const Color(0xFFFFC6C6),
    const Color(0xFFFFE4C5),
    const Color(0xFFFDF5D7),
    const Color(0xFFF4FFD5),
    const Color(0xFFCDFFBB),

  ];
  final List<String> surveyEmojes = [
    "strongly-disAgree",
    "disAgree",
    "Neither-agree-nor-disagree",
    "agree",
    "strongly-agree",
  ];

  double _minHeightForSurveyReaction = 40.0;
  String selectedAnswerId;
  bool _isSubmitting = false;


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Align(
      alignment: Alignment.center,
      child: Material(
        textStyle: TextStyle(
          fontSize: 16,),
        color: Colors.transparent,
        child: Container(
          // height: height??300,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('${Provider.of<UserProvider>(context, listen: false).currentSurvey.question}',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey[800],height: 1.4),textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 18,),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Wrap(
                      spacing: 10.0,
                      runSpacing: 5.0,
                      children: userProvider.currentSurvey.user_survey_answers.map((item) =>
                          InkWell(
                              onTap:(){
                                _isSurveyReactionFilled.forEach((key, value) {
                                  if (userProvider.currentSurvey.user_survey_answers.indexWhere((element) => element.id == item.id) == key-1){
                                    print(key);
                                    setState(() {
                                      _isSurveyReactionFilled[key] = true;
                                      selectedAnswerId = item.id;
                                    });
                                  }
                                  else{
                                    setState(() {
                                      _isSurveyReactionFilled[key] = false;
                                    });
                                  }
                                  print(value);
                                });
                              },
                              child: Image.asset("images/${surveyEmojes[userProvider.currentSurvey.user_survey_answers.indexWhere((element) => element.id == item.id)]}${_isSurveyReactionFilled[int.parse(item.value)] == true?'$_filled':''}.png",height: _minHeightForSurveyReaction,width: _minHeightForSurveyReaction,)
                          ))
                          .toList()
                          .cast<Widget>()
                  )

              ),
              const SizedBox(height: 18,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(_isSurveyReactionFilled.containsValue(true) ? "Thank you for your feedback!\n" :'your response is anonymous - it will help us to make improvements',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey[_isSurveyReactionFilled.containsValue(true) ?900:400],height: 1.2,fontSize: 12),textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 20,),
              _isSubmitting ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 20,) : InkWell(
                onTap: (){
                  if (selectedAnswerId != null) {
                    setState((){
                      _isSubmitting = true;
                    });
                    Provider.of<UserProvider>(context,listen: false).answerSurvey(context, userProvider.currentSurvey.id, answerId: selectedAnswerId).then((_) =>{
                      setState((){
                        _isSubmitting = false;
                      }),
                      Navigator.pop(context)
                    });

                  }
                  else{
                    Provider.of<UserProvider>(context,listen: false).answerSurvey(context, userProvider.currentSurvey.id);
                    AnalyticsManager.track('survey_skipped');
                    Navigator.pop(context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(selectedAnswerId != null ? 'Answer' : 'Skip',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.w700),),
                  ),
                ),
              )
            ],
          ),
          margin: EdgeInsets.only(bottom: 50, left: 20, right: 20),
          decoration: BoxDecoration(
            color: _isSurveyReactionFilled[1] ? _surveysReactionsColors[0] : _isSurveyReactionFilled[2] ? _surveysReactionsColors[1] : _isSurveyReactionFilled[3] ? _surveysReactionsColors[2] : _isSurveyReactionFilled[4] ? _surveysReactionsColors[3] : _isSurveyReactionFilled[5] ? _surveysReactionsColors[4]:Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}




showSurvey(context,SurveyModel survey){
  print(survey.id);
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: false, // need to be false to make user answer survey
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 500),
    context: context,
    pageBuilder: (_, __, ___) {
      return StatefulBuilder(builder: (context,setState){
        return SurveyReactions();
      });
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}


Widget roundedButton(
    {context,
      icon,
      title,
      titleColor,
      Function onClicked,
      color,
      buttonWidth,
      buttonHeight,
      borderColor}) {
  print(buttonWidth);
  return GestureDetector(
    onTap: onClicked,
    child: Container(
      width: buttonWidth ?? 100,
      height: buttonHeight ?? 40.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          border: borderColor ?? null),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: color ?? Theme.of(context).primaryColor,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon ?? const SizedBox(),
              icon == null ? const SizedBox() : SizedBox(width: 10.0),

              Text(
                "$title",
                style: TextStyle(
                    color: titleColor ?? Colors.white,
                    fontSize: MediaQuery.of(context).size.height > 550 ? 18.0 : 15.0,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    ),
  );
}



showAlertDialog(BuildContext context, {Widget alertTitle, String content,onOk}) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text(
      "ok",
      style: TextStyle(
          color: Theme.of(context).backgroundColor,
          fontWeight: FontWeight.bold),
    ),
    onPressed: onOk??() {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(

    title: alertTitle ?? SizedBox(),
    content: Text(
      content,
      style: TextStyle(fontSize: 16,color: Theme.of(context).backgroundColor),
    ),
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



showToast(String msg,{Widget icon}) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.black54,
    ),
    child: Text(msg,style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 2,),
  );


  FToast().showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 5),
  );

  // Custom Toast Position
  // FToast().showToast(
  //     child: toast,
  //     toastDuration: Duration(seconds: 2),
  //     positionedToastBuilder: (context, child) {
  //       return Positioned(
  //         child: child,
  //         top: 16.0,
  //         left: 16.0,
  //       );
  //     });
}





formatStringTime({@required String stringTime}) {
  var format = DateFormat.Hm();
  DateTime dateTime = DateTime.parse(stringTime);
  var finalDate = format.format(dateTime);
  return finalDate;
}

formatStringTimeToDayAndMonth({@required String stringTime}) {
  var format = DateFormat('dd MMM');
  DateTime dateTime = DateTime.parse(stringTime);
  var finalDate = format.format(dateTime);
  return finalDate;
}

formatStringTimeToDayMonthAndYear({@required String stringTime}) {
  var format = DateFormat('dd MMM yyyy');
  DateTime dateTime = DateTime.parse(stringTime);
  var finalDate = format.format(dateTime);
  return finalDate;
}

formatStringTimeToDayMonthAndTime({@required String stringTime}) {
  // print("finalDate ${stringTime}");

  var format = DateFormat('dd MMM');
  DateTime dateTime = DateTime.parse(stringTime);
  var finalDate = format.format(dateTime);
  return finalDate;
}

formatStringTimeToWeekDay({@required String stringTime}) {
  var format = DateFormat('EEE');
  DateTime dateTime = DateTime.parse(stringTime);
  var finalDate = format.format(dateTime);
  return finalDate;
}

DateTime timeStampToDateTime(int timestamp){

  final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  // print(date);
  return date;

}

Timestamp dateToTimeStamp({@required date}){
  Timestamp myTimeStamp = Timestamp.fromDate(date);
  return myTimeStamp;
}

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('yyyy-MM-dd');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' DAY AGO';
    } else {
      time = diff.inDays.toString() + ' DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
    } else {

      time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
    }
  }

  return time;
}

String convertTimestampToHoursAndMinutes(int timestamp) {

  var now = DateTime.now();
  var format = DateFormat('HH:mm ');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' DAY AGO';
    } else {
      time = diff.inDays.toString() + ' DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
    } else {

      time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
    }
  }

  return time;
}

String convertTimeStampToHumanDate(int timeStamp) {
  var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  return DateFormat('dd MMM, HH:mm').format(dateToTimeStamp);
}

String convertTimestampDayMonthAndTime(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('dd-MM-yyyy');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' DAY AGO';
    } else {
      time = diff.inDays.toString() + ' DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
    } else {

      time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
    }
  }

  return time;
}



void showSnack(
    {msg, BuildContext context, var scaffKey, var millSeconds = null , fullHeight, Widget content,Color backgroundColor,double bottomMargin, isFloating = false}) {
  var _snackBar = SnackBar(
      duration: millSeconds == null ? null : Duration(milliseconds: millSeconds),
      behavior: isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.7),
      margin:  EdgeInsets.fromLTRB(4, 0, 4, bottomMargin??5),
      content: content ?? SizedBox(
        height: fullHeight ?? 89,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
                  "$msg",
                  style: const TextStyle(color: Colors.white, fontFamily: 'STC-Regular'),
                  maxLines: null,
                )),
            fullHeight == null
                ? const SizedBox(
              height: 60.0,
            )
                : const SizedBox()
          ],
        ),
      ));

  scaffKey.currentState.showSnackBar(_snackBar);
}



Widget needHelp(context, {color,type}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 75.0),
    child: GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, HelpAndSupport.routName);
        if(type == 'timeSheet'){
          AnalyticsManager.track('timesheet_empty_ask_support');
        }
        else if(type == 'openShifts' || type == 'upComingShifts'){
          AnalyticsManager.track('shift_list_empty_ask_support');
        }
        else if(type == 'offers'){
          AnalyticsManager.track('offer_list_empty_ask_support');
        }
        else if(type == 'chat'){
          AnalyticsManager.track('messaging_ask_support');
        }

        },
      child: Container(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WebsafeSvg.asset("images/support-filled.svg", height: 20.0, width: 20.0,
                color: Theme.of(context).primaryColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text("Need help?",
                  style: TextStyle(
                      color: color ?? Theme.of(context).primaryColor,
                      fontSize: 17.0)),
            )
          ],
        ),
      ),
    ),
  );
}


Widget netWorkError(context,media, {Function onRetry}){
    return Container(
      height: media.height,
      child: Center(
          child: InkWell(
            onTap: (){
              onRetry();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Provider.of<UserProvider>(context,listen: false).userData.trust['system_type']['name'] == "nhsp_api" ?
                const Text("NHSP server error retry?"):
                const Text("Network error retry? "),
                Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
              ],
            ),
          )
      ),
    );
}


Widget returnToCallScreen(BuildContext context){
  return GestureDetector(
    onTap: () async {
      print("push");
      // Provider.of<CallProvider>(context,listen: false).pushToTwilioCallScreen();
      Navigator.pushNamed(context, TwilioCallScreen.routeName);
    },
    child: Container(
      width: 40,
      height: 20,
      padding: EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: greenColor,
      ),
      child: ShakeAnimatedWidget(
        enabled: true,
        duration: Duration(milliseconds: 1500),
        shakeAngle: Rotation.deg(z: 30),
        curve: Curves.linear,
        child: Transform.scale(scale: 0.8,child: WebsafeSvg.asset("images/call-filled.svg",color: Colors.white,width: 10,)),
      ),
      // Transform.scale(scale: 0.8,child: WebsafeSvg.asset("images/call-filled.svg",color: Colors.white,width: 10,)),
    ),
  );
}

Widget screenAppBar(BuildContext context, screenMedia,
    {Widget appbarTitle,
      String profilePicPath,
      Function searchAction,
      bool hideProfilePic = false,
      Function filterAction,
      Function calendarAction,
      Function announcementAction,
      Function menuAction,
      Function createChatAction,
      Function callAction,
      Function infoAction,
      // isCenterTitle = false,
      bottomTabs,
      bool showLeadingPop = false,
      bool centerTitle = true,
      Function onBackPressed,
      Function addAction,
      Function favouriteAction,
      Function shareAction,
      String textButtonTitle,
      Function textButton,
      double elevation,
      double appBarHeight,
      isTextButtonLoading = false,
      bool isMainScreen = false,
      Function downloadDocAction,
      isFavoured = false}) {

  final userData = Provider.of<UserProvider>(context);
  final newsProvider = Provider.of<NewsProvider>(context);

  return PreferredSize(
    preferredSize: Size.fromHeight(!kIsWeb ? 60.0 : 80.0),
    child: AppBar(
      elevation: elevation ?? 5.0,
      automaticallyImplyLeading: false,
      // leadingWidth: 120,
      titleSpacing: isMainScreen ? null : -20.0,
      leading: showLeadingPop
          ? InkWell(
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 27.0,
        ),
        onTap: onBackPressed,
      )
          : hideProfilePic
          ? const SizedBox()
          : Padding(
        padding: const EdgeInsets.only(left: 9),
        child: GestureDetector(
          onTap: () async {
            if (Provider.of<UserProvider>(context, listen: false).userData == null)
              await Provider.of<UserProvider>(context, listen: false).getUser(context);
            showCustomBottomSheet(
                profilePicPath: userData.userData.profilePic,
                context: context,
                screenMedia: screenMedia);
          },
          child: userData.userData != null ? Stack(
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
                  height: 35.0,
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
      ),
      centerTitle: centerTitle??false,
      title: appbarTitle ?? const SizedBox(),
      bottom: bottomTabs,
      toolbarHeight: 100.0,
      actions: [

        !kIsWeb && Provider.of<CallProvider>(context).isInCall && callAction == null ?
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
                    child: WebsafeSvg.asset(
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
        const SizedBox(width: 0),

        announcementAction != null
            ? InkWell(
          onTap: announcementAction,
          child: Image.asset(
            "images/announce.png",
            height: 26.0,
            width: 26.0,
            color: Colors.white,
          ),
        )
            : const SizedBox(),
        announcementAction != null
            ? const SizedBox(
          width: 18.0,
        )
            : const SizedBox(),
        createChatAction != null
            ? InkWell(
          onTap: createChatAction,
          child: WebsafeSvg.asset(
            'images/new-chat-filled.svg',
            color: Colors.white,
            width:20,
          ),
        )
            : const SizedBox(),
        searchAction != null
            ? InkWell(
            onTap: searchAction,
            child: Image.asset(
              'images/search.png',
              color: Colors.white,
              width: 25,
            ))
            : const SizedBox(),
        calendarAction != null
            ? InkWell(
          onTap: calendarAction,
          child:
          Provider.of<ShiftsProvider>(context).isCalendarView == false
              ? WebsafeSvg.asset(
            "images/shiftsFilled.svg",
            color: Colors.white,
            width: 22,
          )
              : WebsafeSvg.asset(
            "images/list-view-filled.svg",
            color: Colors.white,
            width: 22,
          ),
        )
            : const SizedBox(),
        filterAction != null
            ? const SizedBox(
          width: 18.0,
        )
            : const SizedBox(),
        filterAction != null
            ? InkWell(
            onTap: filterAction,
            child: Image.asset(
              "images/filter.png",
              color: Colors.white,
              height: 20.0,
              width: 20.0,
            ))
            : const SizedBox(),
        shareAction != null
            ? InkWell(
          onTap: shareAction,
          child: WebsafeSvg.asset(
            "images/share-filled.svg",
            color: Colors.white,
          ),
        )
            : const SizedBox(),
        shareAction != null
            ? const SizedBox(
          width: 18.0,
        )
            : const SizedBox(),
        favouriteAction != null
            ? InkWell(
          onTap: favouriteAction,
          child: isFavoured
              ? WebsafeSvg.asset(
            "images/favourite.svg",
            // color: Colors.white,
            // width:20,
          )
          // WebsafeSvg.asset(
          //   "images/favourite.svg",
          // )
              : WebsafeSvg.asset(
            "images/favourite-filled.svg",
          ),
        )
            : const SizedBox(),
        menuAction != null
            ? InkWell(
          onTap: menuAction,
          child: const Icon(
            Icons.more_horiz_rounded,
            color: Colors.white,
          ),
        ) : const SizedBox(),

        callAction == null || kIsWeb || Provider.of<CallProvider>(context).isInCall
            ? const SizedBox()
            : Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
          onTap: callAction,
          child: WebsafeSvg.asset(
            'images/call-filled.svg',
            color: Colors.white,
            width:20,
          ),
          //       WebsafeSvg.asset(
          //     'images/call-filled.svg',
          //     color: Colors.white,
          //     width:20,
          // ),
        ),
            ),

        downloadDocAction != null ?
        InkWell(
          onTap: downloadDocAction,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, color: Colors.white,),
              Text("PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),)
            ],
          )
        )
       : const SizedBox(),

        infoAction != null
            ? InkWell(
          onTap: infoAction,
          child: WebsafeSvg.asset(
            'images/info-filled.svg',
            color: Colors.white,
            width:20,
          ),
          // WebsafeSvg.asset(
          //   'images/info-filled.svg',
          //   color: Colors.white,
          //   width:22,
          // ),
        )
            : const SizedBox(),
        addAction != null
            ? InkWell(
          onTap: addAction,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        )
            : const SizedBox(),
        textButton != null ?
        isTextButtonLoading ?
        const SpinKitCircle(
          color: Colors.white,
          size: 25.0,
        ):
        InkWell(
          onTap: textButton,
          child: Center(
              child: Text(
                "$textButtonTitle",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              )),
        )
            : const SizedBox(),
        const SizedBox(
          width: 18.0,
        ),


      ],
    ),
  );
}



Widget expansionTileCard(
    {double height,
      double width,
      String title,
      Color color,
      Color borderColor,
      Color defaultTrailingIconColor,
      double fontSize,
      bool isExpanded,
      Function doExpansion,
      Widget expansionArrow,
      List<Widget> content,
      BuildContext context}) {
  return Padding(
    padding:
    const EdgeInsets.only(bottom: 12.0, right: 12.0, left: 12.0, top: 10.0),
    child: Container(
      height:height,
      decoration: BoxDecoration(
          color: color??Color(0xffF1F1F1),
          border: Border.all(color: borderColor ?? Color(0xffE8E5E5)),
          borderRadius: BorderRadius.circular(5)),
      child: GroovinExpansionTile(
        inkwellRadius: BorderRadius.circular(0.0),
        onExpansionChanged: doExpansion,
        defaultTrailingIconColor: Theme.of(context).primaryColor,
        // onExpansionChanged: doExpansion ?? (x) {},
        initiallyExpanded: isExpanded,
        title: Text(
          title,
          style: TextStyle(
              color: Color(0xff616161), fontSize: fontSize??17.0),
        ),
        backgroundColor: Color(0xffF1F1F1),
        children: content,
      ),
    ),
  );
}



Widget showAnimatedCustomDialog(
    context,
    {onClicked,
      buttonText,
       statefulBuilder,
      String messageImg,
      title,
      message,
      Function updateFilterResults,
      String cancelButtonTitle,
      bool isDismissible = true,
      onCancelClicked}) {
  final media = MediaQuery.of(context).size;
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierColor: Colors.black.withOpacity(0.5),
    barrierDismissible: isDismissible,
    transitionDuration: Duration(milliseconds: 500),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
    pageBuilder: (_, __, ___) {
      return statefulBuilder ?? StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if(updateFilterResults != null){
              updateFilterResults();
            }
            return Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: kIsWeb ? media.width * 0.35 : media.width * 0.12 ),
                  child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          title == null
                              ? const SizedBox()
                              : Padding(
                            padding: const EdgeInsets.only(
                              top: kIsWeb ? 20 : 16.0,
                              bottom: kIsWeb ? 4 : 0
                            ),
                            child: Center(
                                child: Text(
                                  "$title",
                                  style: style1,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            child: Center(
                                child: 
                                messageImg != null ?
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("$messageImg", height: 50, width: 80,),
                                    const SizedBox(height: 10.0,),
                                    Text(
                                      "$message",
                                      maxLines: 6,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: style2,
                                    )
                                  ],
                                ):    
                                Text(
                                  "$message",
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: style2,
                                )),
                          ),
                          Divider(
                            thickness: 0.8,
                            height: 0,
                            color: Colors.grey[400],
                          ),
                          cancelButtonTitle == null
                              ? InkWell(
                            onTap: onClicked ?? () => Navigator.pop(context),
                            child: Container(
                              width: double.infinity,
                              height: 35.0,
                              child: Center(
                                  child: Text(
                                    buttonText ?? "Ok",
                                    style: styleBlue,
                                  )),
                            ),
                          )
                              : Container(
                            // height: 35.0,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: onCancelClicked ??
                                            () => Navigator.pop(context),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(
                                                  color: Colors.grey[400],
                                                  width: 0.5))),
                                      height: 35.0,
                                      child: Center(
                                          child: Text(
                                            cancelButtonTitle ?? "Cancel",
                                            style: styleBlue,
                                          )),
                                    ),
                                  ),
                                ),
                                // VerticalDivider(thickness: 2,width: 2,color: Colors.grey,),
                                Flexible(
                                  child: InkWell(
                                    onTap: onClicked ??
                                            () => Navigator.pop(context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  color: Colors.grey[400],
                                                  width: 0.5))),
                                      width: double.infinity,
                                      height: 35.0,
                                      child: Center(
                                          child: Text(
                                            buttonText ?? "Ok",
                                            style: styleBlue,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: 5.0,
                          // )
                        ],
                      )),
                ));
          });
    },
  );
}


/// Alert Dialog Content

class FailureConnectionAlertDialogContent extends StatefulWidget {
  Function onTryAgain;
  FailureConnectionAlertDialogContent(this.onTryAgain);

  @override
  _FailureConnectionAlertDialogContentState createState() => _FailureConnectionAlertDialogContentState();
}

class _FailureConnectionAlertDialogContentState extends State<FailureConnectionAlertDialogContent> {

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: media.width * 0.12),
          child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15.0),
                      child: Center(
                          child:
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("images/no-connection.png", height: 80, width: 80,color: Theme.of(context).primaryColor,),
                              const SizedBox(height: 10.0,),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16.0,
                                  bottom: 10
                                ),
                                child: Center(
                                    child: Text(
                                      "Connection Failed",
                                      style: style1,
                                    )),
                              ),
                              const SizedBox(height: 10.0,),
                              Text(
                                "Please check your internet connection and try again.",
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: style2,
                              )
                            ],
                          )
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        widget.onTryAgain();
                        },
                      child: Container(
                        width: media.width*0.6,
                        height: 35.0,
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Center(
                            child: Text(
                              "Try again",
                              style: style15,
                            )),
                      ),
                    )
                    // SizedBox(
                    //   height: 5.0,
                    // )
                  ],
                ),
              )),
        ));
  }
}

/*
const APP_STORE_URL =
    'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=YOUR-APP-ID&mt=8';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=YOUR-APP-ID';

versionCheck(context) async {
  //Get Current installed version of app
  final PackageInfo info = await PackageInfo.fromPlatform();
  double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

  //Get Latest version info from firebase config
  final RemoteConfig remoteConfig = await RemoteConfig.instance;

  try {
    // Using default duration to force fetching from remote server.
    await remoteConfig.fetch(expiration: const Duration(seconds: 0));
    await remoteConfig.activateFetched();
    remoteConfig.getString('force_update_current_version');
    double newVersion = double.parse(remoteConfig
        .getString('force_update_current_version')
        .trim()
        .replaceAll(".", ""));
    if (newVersion > currentVersion) {
      _showVersionDialog(context);
    }
  }  catch (exception) {
    debugPrint('Unable to fetch remote config. Cached or default values will be '
        'used');
  }
}
//Show Dialog to force user to update
_showVersionDialog(context) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String title = "New Update Available";
      String message = "There is a newer version of app available please update it now.";
      String btnLabel = "Update Now";
      String btnLabelCancel = "Later";
      return Platform.isIOS
          ? new CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text(btnLabel),
            onPressed: () => _launchURL(APP_STORE_URL),
          ),
          FlatButton(
            child: Text(btnLabelCancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      )
          : new AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text(btnLabel),
            onPressed: () => _launchURL(PLAY_STORE_URL),
          ),
          FlatButton(
            child: Text(btnLabelCancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

*/



/// Alert Dialog Content

 showQueryCustomDialog(context, {bool isSubmitting = false,String query}){
   bool showLoader = isSubmitting;
   showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 500),
    context: context,
    pageBuilder: (_, __, ___) {
      return QueryDialog();
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}


class QueryDialog extends StatefulWidget {
  @override
  _QueryDialogState createState() => _QueryDialogState();
}

class _QueryDialogState extends State<QueryDialog> {
  bool showLoader = false;
  String message;
  TextEditingController _queryController = TextEditingController();
  var _enableBorder = true;

  _textFieldBorder() {
    return _enableBorder
        ? OutlineInputBorder(
        borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
        borderRadius: textFieldBorderRadius)
        : null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _queryController.dispose();
  }

  var keypadHeight;

  @override
  Widget build(BuildContext context) {
    keypadHeight = MediaQuery.of(context).viewInsets.bottom;

    return Align(
      alignment: Alignment.center,
      child: Material(
        textStyle: TextStyle(
          fontSize: 16,),
        color: Colors.transparent,
        child: Container(
          // height: height??300,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  height: 110.0,
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 4),
                  child: TextFormField(
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.top,
                    expands: true,
                    controller: _queryController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        setState(() {
                          _enableBorder = false;
                        });
                        return 'Required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(125),
                    ],
                    maxLines: null,
                    decoration: InputDecoration(
                        focusedBorder: _textFieldBorder(),
                        contentPadding: EdgeInsets.only(
                            bottom: _enableBorder == true ? 0.0 : 15.0, left: 15.0, right: 15.0,top: 15.0),
                        border: _textFieldBorder(),
                        hintText: "Write your query...",
                        hintStyle: TextStyle(color: Colors.grey,)),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text("(max 125 characters)",style: TextStyle(color: Colors.grey,),),
                ),
              ),
              const SizedBox(height: 20,),
              showLoader ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 25,) :
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Cancel',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        showLoader = true;
                      });
                      Provider.of<ShiftsProvider>(context,listen:false).updateTimeSheet(context,message: _queryController.text,timeSheetStatusId: MyApp.flavor == "staging" ? "5e904603-904e-4c6e-b857-5369ae0fbf0f" : "bcf15dd1-1775-4b9b-b13e-962691c2aabe").then((_) => {
                        setState(() {
                          showLoader = false;
                        })
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Send Query',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          margin:  EdgeInsets.only(bottom: keypadHeight != null ? keypadHeight : 8.0, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}



/////////////////////********************************************************************/////////////////////



/////////////////////************************** Unused Widgets **************************/////////////////////


showCountriesBottomSheet({
  BuildContext context,
  media,
  List list,
  onSelectCountry,
}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 20,
              right: 30,
              child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close)),
            ),
            Container(
              height: media.height * 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 50.0, horizontal: 15.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(list.length, (index) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: onSelectCountry ?? () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              width: media.width,
                              child: Text(list[index].name),
                            ),
                          ),
                          (index == list.length - 1)
                              ? SizedBox(
                            height: 20,
                          )
                              : Divider(
                            color: Colors.grey[500],
                          )
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      });
}



Widget bioLoginButton(
    {Function onClicked,
      var height,
      String titleImgPath,
      String buttonTitle,
      var titleFontSize,
      double sidesPadding,
      double buttonW,
      var buttonColor,
      var titleColor,
      BuildContext context}) =>
    Padding(
      padding: EdgeInsets.only(
          left: sidesPadding ?? 0.0, right: sidesPadding ?? 0.0, bottom: 5.0),
      child: GestureDetector(
        onTap: () {
          onClicked();
        },
        child: Container(
          height: height ?? 40.0,
          width: buttonW ?? null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            border: Border.all(color: Theme.of(context).iconTheme.color),
            //elevation: 8.0,
            color: buttonColor ??
                Theme.of(context).iconTheme.color, // changed the color here
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
            ),
            // child: Padding(
            // padding: const EdgeInsets.symmetric(horizontal:18.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonTitle,
                    style: TextStyle(
                        color: titleColor ?? Colors.white,
                        fontSize: titleFontSize ?? 17.0,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold),
                  ),
                  titleImgPath != null
                      ? SizedBox(
                    width: 8.0,
                  )
                      : const SizedBox(),
                  titleImgPath != null
                      ? Image.asset(
                    titleImgPath,
                    height: 35,
                    width: 35.0,
                    color: titleColor ?? Colors.white,
                  )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          // )
        ),
      ),
    );





Widget announcementBottomSheet(BuildContext context,
    {screenMedia, bottomButtonTitle, buttonTitleColor}) {
  var listHeight = 420.0;
  String filterSubtitle = "";
  bool isOtherExpanded = false;

  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return isSubFilterInAnnouncementVisible
                  ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                isSubFilterInAnnouncementVisible = false;
                              });
                            }),
                        Text(
                          "$filterSubtitle",
                          style: style1,
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              isWorkAreasVisibleInShiftsFilter = false;
                            });
                          },
                          child: Text(
                            "Done",
                            style: styleBlue,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                          onTap: null,
                          child: Row(
                            children: [
                              Text(
                                "Select all",
                                style: style1,
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Icon(
                                  Icons.done,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          )),
                    ),
                    Divider(),
                    Container(
                      height: screenMedia.height * 0.55,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 16,
                          itemBuilder: (context, i) => Column(
                            children: [
                              Container(
                                height: 30.0,
                                child: ListTile(
                                  onTap: null,
                                  title: Text(
                                    "A - Entrance",
                                    style: style2,
                                  ),
                                  trailing: Icon(
                                    Icons.done,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Divider()
                            ],
                          )),
                    )
                  ],
                ),
              )
                  : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlatButton(
                              onPressed: () => Navigator.pop(context),
                              child: Icon(
                                Icons.cancel_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              "Filter",
                              style: style1,
                            ),
                            FlatButton(
                              onPressed: null,
                              child: Text(
                                "Clear",
                                style: styleBlue,
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: listHeight,
                          child: ListView(
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(
                                  "Profession",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListTile(
                                leading: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "images/doctor.png",
                                      color: Theme.of(context).primaryColor,
                                      height: 25.0,
                                      width: 25.0,
                                    ),
                                    const SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      "User type",
                                      style: style2,
                                    )
                                  ],
                                ),
                                trailing: Text("Any", style: styleGrey),
                                onTap: () {
                                  setState(() {
                                    filterSubtitle = "User type";
                                    isSubFilterInAnnouncementVisible = true;
                                  });
                                },
                              ),
                              ListTile(
                                leading: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "images/roles.webp",
                                      color: Theme.of(context).primaryColor,
                                      height: 25.0,
                                      width: 25.0,
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      "Roles",
                                      style: style2,
                                    )
                                  ],
                                ),
                                trailing: Text("Any", style: styleGrey),
                                onTap: () {
                                  setState(() {
                                    filterSubtitle = 'Specialty';
                                    isSubFilterInAnnouncementVisible = true;
                                  });
                                },
                              ),
                              ListTile(
                                leading: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.work_outline_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      "Areas of Work",
                                      style: style2,
                                    )
                                  ],
                                ),
                                trailing: Text("Any", style: styleGrey),
                                onTap: () {
                                  setState(() {
                                    filterSubtitle = "Areas of Work";
                                    isSubFilterInAnnouncementVisible = true;
                                  });
                                },
                              ),
                              ListTile(
                                leading: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "images/membership.png",
                                      color: Theme.of(context).primaryColor,
                                      height: 20.0,
                                      width: 20.0,
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      "Memberships",
                                      style: style2,
                                    )
                                  ],
                                ),
                                trailing: Text("Any", style: styleGrey),
                                onTap: () {
                                  setState(() {
                                    filterSubtitle = "Institutions";
                                    isSubFilterInAnnouncementVisible = true;
                                  });
                                },
                              ),
                              Divider(),
                              expansionTileCard(
                                  context: context,
                                  title: "Other",
                                  isExpanded: isOtherExpanded,
                                  doExpansion: (val) {
                                    if (val) {
                                      setState(() {
                                        isOtherExpanded = true;
                                        listHeight = screenMedia.height * 0.6;
                                      });
                                    } else {
                                      setState(() {
                                        isOtherExpanded = false;
                                        listHeight = 420.0;
                                      });
                                    }
                                  },
                                  content: [
                                    Container(
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .bookmark_border_outlined,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 8.0,
                                                ),
                                                Text(
                                                  "Grade",
                                                  style: style2,
                                                )
                                              ],
                                            ),
                                            trailing:
                                            Text("Any", style: styleGrey),
                                            onTap: () {
                                              setState(() {
                                                filterSubtitle = "Grade";
                                                isSubFilterInAnnouncementVisible =
                                                true;
                                              });
                                            },
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.language_rounded,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 8.0,
                                                ),
                                                Text(
                                                  "Languages",
                                                  style: style2,
                                                )
                                              ],
                                            ),
                                            trailing:
                                            Text("Any", style: styleGrey),
                                            onTap: () {
                                              setState(() {
                                                filterSubtitle = "Languages";
                                                isSubFilterInAnnouncementVisible =
                                                true;
                                              });
                                            },
                                          ),
                                          Divider()
                                        ],
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(7),
                                          bottomRight: Radius.circular(7)),
                                      child: Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          leading: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.done_outline_rounded,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              SizedBox(
                                                width: 8.0,
                                              ),
                                              Text(
                                                "Skills",
                                                style: style2,
                                              )
                                            ],
                                          ),
                                          trailing:
                                          Text("Any", style: styleGrey),
                                          onTap: () {
                                            setState(() {
                                              filterSubtitle =
                                              "Additional Roles";
                                              isSubFilterInAnnouncementVisible =
                                              true;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ]),
                              SizedBox(
                                height: 105.0,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        height: 85.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                              Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 15.0,
                              bottom: 25.0),
                          child: roundedButton(
                            context: context,
                            title: bottomButtonTitle ?? "Continue",
                            titleColor: buttonTitleColor ?? Colors.grey,
                            buttonHeight: 50.0,
                          ),
                        ),
                      ))
                ],
              );
            });
      });
}



Widget notSet() {
  return Padding(
    padding: const EdgeInsets.only(left: 28.0),
    child: Text(
      "Not Set",
      style: TextStyle(color: Colors.grey, fontSize: 16.0),
    ),
  );
}