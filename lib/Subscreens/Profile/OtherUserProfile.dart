// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';

class OtherUserProfile extends StatefulWidget {
  static const routName = "/OtherUserProfile_Screen";

  const OtherUserProfile({Key key}) : super(key: key);

  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  var _isInit = true;
  User user;
  bool _isGetUserLoading = false;
  Map passedData = {};
  ScrollController _scrollController ;
  bool isBottomWidgetShown = true;

  listen(){
    final direction = _scrollController.position.userScrollDirection;

    if(_scrollController.position.pixels<=50){
      _showBottomWidget();
    }
    else{
      _hideBottomWidget();
    }
  }

  _showBottomWidget(){
    if (!isBottomWidgetShown) {
      setState(() {
        isBottomWidgetShown = true;
      });
    }
  }

  _hideBottomWidget(){
    if (isBottomWidgetShown) {
      setState(() {
        isBottomWidgetShown = false;
      });
    }
  }
  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      if(passedData['user_id'] != null){
        _isGetUserLoading = true;
        Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: passedData['user_id']).then((value) {
          user = value as User ;
          setState(() {
            _isGetUserLoading = false;
          });
        });
      }
      else{
        user = passedData['user'] as User;
      }
      _scrollController = ScrollController();
      _scrollController.addListener(listen);
      _isInit = false;

    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.removeListener(listen);

  }

  // String getJobRolesCommaSeparatedList(List<dynamic> roles) {
  //   String ret = '';
  //   if (roles == null || roles.isEmpty) {
  //     return '';
  //   }
  //   switch (roles.length) {
  //     case 1:
  //       ret += roles[0]['name'];
  //       break;
  //     case 2:
  //       ret += roles[0]['name'] + ', ' + roles[1]['name'];
  //       break;
  //     default:
  //       ret += roles[0]['name'] + ', ' + roles[1]['name'] + ' + ${roles.length - 2} more';
  //   }
  //
  //   return ret;
  // }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);

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
            backgroundColor: Colors.grey[200],
            body: NestedScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    expandedHeight: user != null ? 180 : null,
                    pinned: true,
                    floating: true,

                    // actions: [
                    //   Provider.of<CallProvider>(context).isInACall ? Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                    //     child: returnToCallScreen(context),
                    //   ) : const SizedBox()
                    // ],
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 27.0,),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),

                    flexibleSpace: !_isGetUserLoading
                        ?
                    user != null
                        ?
                    FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      titlePadding: const EdgeInsets.only(left: 35,bottom: 10),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white,
                                    width: 1.5
                                ),
                                borderRadius: BorderRadius.circular(60.0,)

                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.blue[200],
                              backgroundImage: user == null ? const AssetImage('images/person.png'):
                              NetworkImage(user.profilePic),
                              radius: 40.0,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Flexible(child: Text(user.name, style: const TextStyle(color: Colors.white,fontSize: 20), overflow: TextOverflow.ellipsis,)),

                        ],
                      ),
                      background: user.trust["trust_icon"] == null
                          ?
                      Image.asset(Provider.of<UserProvider>(context,listen: false).currentAppBackground,fit: BoxFit.fitWidth,)
                          :
                      Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                                user.trust["trust_icon"],
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SpinKitCubeGrid(color: Colors.white,size: 40,),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                  return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],fit: BoxFit.fill,);
                                }),
                          ),
                          Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black87],
                                    )
                                ),
                              )
                          )
                        ],
                      ),
                    )
                        :
                    const SizedBox()
                        :
                    const SizedBox()
                    ,
                  ),
                ];
              },
              body: _isGetUserLoading
                  ?
              SpinKitCircle(color: Theme.of(context).primaryColor,size: 50,)
                  :
              user == null
                  ?
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Image.asset(
                      "images/noProfile.png",
                      height: 200.0,
                      width: 200.0,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: media.width * 0.15),
                      child: Center(
                        child: Text("No matching profiles found.", textAlign: TextAlign.center, style: style1),
                      ),
                    ),
                    const SizedBox(
                      height: 120.0,
                    ),
                  ],
                ),
              )
                  :
              Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: media.width,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0, left: 30.0, right: 10.0,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset("images/role.svg",
                                        height: 25.0,
                                        width: 26.0,
                                        color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 12.0,),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.roleType.toString() ==
                                                "2"
                                                ? "Specialities"
                                                : "Positions",
                                            style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold),
                                          ),
                                          // Text("${user.name}", style: style1, overflow: TextOverflow.ellipsis,),
                                          user.roles.isEmpty
                                              ?
                                          Container(padding: const EdgeInsets.only(top: 5),child: Text('Not set',style: TextStyle(color: Colors.grey[600]),),)
                                              :
                                          Padding(
                                            padding: const EdgeInsets.only(top:4),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: SizedBox(
                                                width: media.width,
                                                child: user.roles == null || user.roles.isEmpty
                                                    ?
                                                Text('Not set',style: TextStyle(color: Colors.grey[600]),)
                                                    :
                                                Wrap(
                                                  spacing: 5.0,
                                                  runSpacing: 5.0,
                                                  children: user.roles.take(3).map((item) => Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Theme.of(context).primaryColor),
                                                        borderRadius: BorderRadius.circular(8)
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                    child: Text(user.roles.indexOf(item) == 2
                                                        ?
                                                    "+${user.roles.length-2} more "
                                                        :
                                                    "${item["name"]}",
                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(color: Colors.grey[900])),
                                                  )).toList().cast<Widget>(),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8,top: 18.0, bottom: 2.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Work Details", style: style1,)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Material(
                                // borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                // elevation: 2.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(top:10,left: 16,right: 16,bottom: 6),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Padding(
                                      //   padding: const EdgeInsets.only(bottom: 5),
                                      //   child: Align(
                                      //       alignment: Alignment.topLeft,
                                      //       child: Text("Work Details", style: style1,)),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(left: 1.0),
                                                child: SvgPicture.asset("images/organisation.svg", height: 25.0, width: 25.0,
                                                    color: Theme.of(context).primaryColor)
                                            ),
                                            const SizedBox(width: 12.0,),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Organisation",style: TextStyle(color: Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text("${user.trust != null ? user.trust["name"] : ""}",
                                                          maxLines: 2, overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(color: Colors.grey[900])),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16,left: 16),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(left: 1.0),
                                                child: SvgPicture.asset("images/site.svg", height: 20.0, width: 20.0,
                                                    color: Theme.of(context).primaryColor)
                                            ),
                                            const SizedBox(width: 12.0,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Sites",style: TextStyle(color: Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                                Padding(
                                                  padding: const EdgeInsets.only(top:4),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: SizedBox(
                                                      width: media.width*0.7,
                                                      child: user.hospitals == null || user.hospitals.isEmpty ? Text('Not set',style: TextStyle(color: Colors.grey[600]),) : Wrap(
                                                        spacing: 5.0,
                                                        runSpacing: 5.0,
                                                        children: user.hospitals.map((item) => Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(color: Theme.of(context).primaryColor),
                                                              borderRadius: BorderRadius.circular(8)
                                                          ),
                                                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                          child: Text("${item["name"]}",
                                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(color: Colors.grey[900])),
                                                        )).toList().cast<Widget>(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16,bottom: 0),
                              child: Material(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                // elevation: 2.0,
                                child: SizedBox(
                                  width: media.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 1.0),
                                                    child: SvgPicture.asset("images/min-level.svg", color: Theme.of(context).primaryColor,width: 26,height: 25,),
                                                  ),
                                                  const SizedBox(width: 12.0,),
                                                  Text(user.roleType == 2 ? "Min Accepted Grade" : "Min Accepted Level", overflow: TextOverflow.ellipsis , style: TextStyle(color:Colors.grey[600],fontSize: 16,height: 1.6,fontWeight: FontWeight.bold),),

                                                ],
                                              ),
                                              Text(user.roleType == 2 && user.minAcceptedGrade != null ? user.minAcceptedGrade['name'] : user.roleType != 2 && user.minAcceptedBand != null ? user.minAcceptedBand['name'] : "Not set", style: TextStyle(color:Colors.grey[600],height: 1.6,fontSize: 14,fontWeight: FontWeight.w400),),

                                            ],
                                          ),

                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8,top: 18.0, bottom: 0.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Competencies", style: style1,)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6,bottom: 8),
                              child: Material(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                // elevation: 2.0,
                                child: SizedBox(
                                  width: media.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 1.0),
                                                    child: SvgPicture.asset("images/level-filled.svg", color: Theme.of(context).primaryColor,width: 24,),
                                                  ),
                                                  const SizedBox(width: 12.0,),
                                                  Text(user.roleType == 2 ? "Grade" : "Level",style: TextStyle(color:Colors.grey[600],fontSize: 16,height: 1.4,fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                              user.roleType == 2 && user.grade != null
                                                  ?
                                              Text('${user.grade['name']}',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.w600))
                                                  :
                                              user.roleType != 2 && user.band != null
                                                  ?
                                              Text('${user.band['name']}',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.w600),)
                                                  :
                                              Text('Not set',style: TextStyle(color:Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 1.0),
                                                child: SvgPicture.asset("images/area-of-work.svg", color: Theme.of(context).primaryColor,width: 25,),
                                              ),
                                              const SizedBox(width: 12.0,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Areas of Work", overflow: TextOverflow.ellipsis , style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold),),
                                                  Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: user.wards == null || user.wards.isEmpty ? Text('Not set',style: TextStyle(color: Colors.grey[700])) : SizedBox(
                                                        width: media.width*0.7,
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Wrap(
                                                            children: user.wards.map((item) => Padding(
                                                              padding: const EdgeInsets.only(top:5,right: 5),
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Theme.of(context).primaryColor,
                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(6.0),
                                                                    child: Text(item["name"],style: const TextStyle(color: Colors.white)),
                                                                  )),
                                                            )).toList().cast<Widget>(),
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ],
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
                            Padding(
                              padding: const EdgeInsets.only(left: 8,top:8,bottom: 4),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Other", style: style1,)),
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                color: Colors.white,
                                width: media.width,
                                padding:const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(left: 1.0),
                                              child: SvgPicture.asset("images/skills.svg", color: Theme.of(context).primaryColor,width: 25,)
                                          ),
                                          const SizedBox(width: 12.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Skills", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                              Padding(
                                                  padding: const EdgeInsets.only( top: 8.0),
                                                  child:  user.skills == null || user.skills.isEmpty ? Text('Not set',style: TextStyle(color: Colors.grey[700])) : SizedBox(
                                                    width: media.width*0.7,
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Wrap(
                                                        children: user.skills.map((item) => Padding(
                                                          padding: const EdgeInsets.only(right: 5,top:5),
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(context).primaryColor,
                                                                borderRadius: BorderRadius.circular(8.0),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(6.0),
                                                                child: Text(item["name"],style: const TextStyle(color: Colors.white)),
                                                              )),
                                                        )).toList().cast<Widget>(),
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(left: 1.0),
                                              child: SvgPicture.asset("images/language.svg", color: Theme.of(context).primaryColor,width: 25,)
                                          ),
                                          const SizedBox(width: 12.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Languages", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                              Padding(
                                                  padding: const EdgeInsets.only( top: 8.0),
                                                  child:  user.languages == null || user.languages.isEmpty ? Text('Not set',style: TextStyle(color: Colors.grey[700])) :SizedBox(
                                                    width: media.width*0.7,
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Wrap(
                                                        children: user.languages.map((item) => Padding(
                                                          padding: const EdgeInsets.only(right: 5,top:5),
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(context).primaryColor,
                                                                borderRadius: BorderRadius.circular(8.0),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(6.0),
                                                                child: Text(item["name"],style: const TextStyle(color: Colors.white)),
                                                              )),
                                                        )).toList().cast<Widget>(),
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 120.0,)
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        height: isBottomWidgetShown ? 75:0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            isBottomWidgetShown ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                onTap: Provider.of<CallProvider>(context).isInCall ? null :
                                    ()async {
                                      if(await Permission.microphone.isGranted == true){
                                    final callProvider = Provider.of<CallProvider>(context, listen: false);
                                    callProvider.initiateTwilioCall(context, callToUser: user);
                                  }
                                  else{
                                    await Permission.microphone.request().then((value) {
                                      final callProvider = Provider.of<CallProvider>(context, listen: false);
                                      callProvider.initiateTwilioCall(context, callToUser: user);
                                    });
                                  }
                                      AnalyticsManager.track('profile_detail_call');
                                },
                                child: SvgPicture.asset(
                                  "images/call.svg",
                                  color:
                                  Provider.of<CallProvider>(context).isInCall ? Colors.grey :
                                  Theme.of(context).primaryColor,
                                  width: 25,
                                ),
                              ),
                              const SizedBox(
                                width: 40.0,
                              ),
                              Provider.of<ChatProvider>(context).creatingNewChatChannel == ChatStage.LOADING ?
                              Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 25,),):
                              InkWell(
                                splashColor: Colors.transparent,
                                onTap: ()async{
                                  Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                                    usersIds: [user.id, userData.userData.id],
                                    channelType: "private",
                                    channelDisplayName: user.name,
                                  );
                                  AnalyticsManager.track('profile_detail_chat');

                                },
                                child: SvgPicture.asset(
                                  "images/chatOutline.svg",
                                  color: Theme.of(context).primaryColor,
                                  width: 25,
                                ),
                              )
                            ],
                          ) : const SizedBox()
                          ],
                        ),
                      ))

                ],
              ),
            ),
          ),
        )
    );
  }
}
