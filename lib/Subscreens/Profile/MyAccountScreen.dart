// ignore_for_file: file_names, curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ShakingValidator.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/CompleteProfileInfo.dart';
import 'package:rightnurse/Subscreens/Profile/EditProfile.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';
import 'package:websafe_svg/websafe_svg.dart';

class MyAccountsScreen extends StatefulWidget{

  static const routName = "/MyAccount_Screen";

  const MyAccountsScreen({Key key}) : super(key: key);

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountsScreen> {

  Map<String, ShakingErrorController> controllers = {
    'Level' : ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    'AreaOfWork' : ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    'Skills' : ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    'Positions' : ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    'Sites' : ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
    'MinAcceptLevel' : ShakingErrorController(initialErrorText: '*', hiddenInitially: false),
  };


  @override
  void initState() {
    if(Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);
    AnalyticsManager.track('screen_profile');
    super.initState();

  }

  _upperSection(var height,{coverImg}){
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          // image: DecorationImage(
          //   image: coverImg == null ? AssetImage("${MyApp.appBackground}"):
          //   NetworkImage(coverImg),
          //   fit: BoxFit.fitWidth,
          //
          // )
      ),
      child:
      coverImg == null
          ?
      Image.asset(Provider.of<UserProvider>(context,listen: false).currentAppBackground,fit: BoxFit.fitWidth,)
          :
      Image.network(
          coverImg,
          fit: BoxFit.fitWidth,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SpinKitCubeGrid(color: Theme.of(context).primaryColor,size: 40,),
            );
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
        return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],fit: BoxFit.fill,);
      }),
    );

  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);

    return WillPopScope(
        onWillPop: () {
          Navigator.pushReplacementNamed(context, NavigationHome.routeName);
          return Future.value(false);
        },
        child: MyApp.userLoggedIn == false ? const SizedBox():
        GestureDetector(
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
              backgroundColor: Colors.grey[200],
              body: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                  return <Widget>[
                    SliverAppBar(
                      iconTheme: const IconThemeData(
                        color: Colors.black,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      expandedHeight: 220,
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
                          if (!kIsWeb) {
                            Navigator.pushReplacementNamed(context, NavigationHome.routeName);
                          }
                          else{
                            Navigator.pushReplacementNamed(context, WebMainScreen.routeName);
                          }
                        },
                      ),

                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        titlePadding: const EdgeInsets.only(left: 40,bottom: 10),
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
                                backgroundImage: userData.userData == null ? const AssetImage('images/person.png'):
                                NetworkImage(userData.userData.profilePic),
                                radius: 40.0,
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Flexible(child: Text(userData.userData.name, style: const TextStyle(color: Colors.white,fontSize: 20), overflow: TextOverflow.ellipsis,)),

                          ],
                        ),
                        background: userData.userData.trust["trust_icon"] == null
                            ?
                        Image.asset(Provider.of<UserProvider>(context,listen: false).currentAppBackground,fit: BoxFit.fitWidth,)
                            :
                        Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                  userData.userData.trust["trust_icon"],
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
                                    return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],fit: BoxFit.fill,);
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
                      ),
                    ),
                  ];
                },
                body: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                color: Colors.white,
                                width: media.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0, left: 20.0, right: 10.0,top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            WebsafeSvg.asset("images/role-filled.svg",
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
                                                    userData.userData.roleType.toString() ==
                                                        "2"
                                                        ? "Specialities"
                                                        : "Positions",
                                                    style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold),
                                                  ),
                                                  // Text("${userData.userData.name}", style: style1, overflow: TextOverflow.ellipsis,),
                                                  userData.userData.roles == null || userData.userData.roles.isEmpty
                                                      ?
                                                  Text('Not set',style: TextStyle(color: Colors.grey[600]),)
                                                      :
                                                  SizedBox(
                                                    width: media.width * 0.6,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top:4),
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: SizedBox(
                                                          width: media.width,
                                                          child:
                                                          Wrap(
                                                            spacing: 5.0,
                                                            runSpacing: 5.0,
                                                            children: userData.userData.roles.take(3).map((item) => Container(
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(color: Theme.of(context).primaryColor),
                                                                  borderRadius: BorderRadius.circular(8)
                                                              ),
                                                              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                                              child: Text(userData.userData.roles.indexOf(item) == 2
                                                                  ?
                                                              "+${userData.userData.roles.length-2} more "
                                                                  :
                                                              "${item["name"]}",
                                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(color: Colors.grey[900])),
                                                            )).toList().cast<Widget>(),
                                                          ),
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

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 0),
                                        child: GestureDetector(
                                          onTap: (){
                                            AnalyticsManager.track('screen_profile_edit');
                                            Navigator.pushNamed(context, EditProfile.routeName);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor,
                                                border: Border.all(color: Theme.of(context).primaryColor),
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: const Text('Edit Profile',style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 10.0, bottom: 2.0),
                              //   child: Align(
                              //       alignment: Alignment.topLeft,
                              //       child: Text("Work Details", style: style1,)),
                              // ),
                              userData.userData.profileCompleted
                                  ?
                              const SizedBox()
                                  :
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Container(
                                  width: media.width,
                                  color: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          WebsafeSvg.asset(
                                            'images/alert-filled.svg',
                                            width: 20,
                                            color: const Color(0xFFFCC306),
                                          ),
                                          const SizedBox(
                                            width: 12.0,
                                          ),
                                          const Text('Your account is incomplete',style: TextStyle(color: Color(0xFFFCC306)),),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: (){
                                          Navigator.push(context,MaterialPageRoute(builder: (context)=>CompleteProfileInfo()));
                                        },
                                        child: Text('Complete', style: styleBlue,),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top:16,left: 8),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Work Details", style: style1,)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8,bottom: 16),
                                child: Material(
                                  // borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                  // elevation: 2.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(left: 1.0),
                                                  child: WebsafeSvg.asset("images/site-filled.svg", height: 20.0, width: 20.0,
                                                      color: Theme.of(context).primaryColor)
                                              ),
                                              const SizedBox(width: 12.0,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Sites",style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:4),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: SizedBox(
                                                        width: media.width*0.7,
                                                        child: userData.userData.hospitals == null || userData.userData.hospitals.isEmpty ? Text('Not set',style: TextStyle(color: Colors.grey[600]),) : Wrap(
                                                          spacing: 5.0,
                                                          runSpacing: 5.0,
                                                          children: userData.userData.hospitals.map((item) => Container(
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

                              Material(
                                // borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                // elevation: 0.0,
                                child: SizedBox(
                                  width: media.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(left: 1.0),
                                            child: WebsafeSvg.asset("images/min-level.svg", color: Theme.of(context).primaryColor,width: 24,height: 22,)
                                        ),
                                        const SizedBox(width: 12.0,),
                                        Row(
                                          children: [
                                            Text(userData.userData.roleType == 2 ? "Min Accepted Grade" : "Min Accepted Level", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const Spacer(),
                                        userData.userData.minAcceptedBand == null && userData.userData.minAcceptedGrade != null
                                            ?
                                        Text("${userData.userData.minAcceptedGrade["name"]}", style: styleBlue2,)
                                            :
                                        userData.userData.minAcceptedBand != null && userData.userData.minAcceptedGrade == null
                                            ?
                                        Text("${userData.userData.minAcceptedBand["name"]}", style: styleBlue2,)
                                            :
                                        Text('Not set',style: TextStyle(color: Colors.grey[600]),)
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top:16,left: 8),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Competencies", style: style1,)),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top:8,bottom:16),
                                child: Material(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                  // elevation: 2.0,
                                  child: SizedBox(
                                    width: media.width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                      child: Column(
                                        children: [
                                          // Padding(
                                          //   padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 2.0),
                                          //   child: Align(
                                          //       alignment: Alignment.centerLeft,
                                          //       child: Text("Competencies", style: style1,)),
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(right:16,left: 16,top: 10,bottom: 4),
                                            child: Row(
                                              children: [
                                                Padding(
                                                    padding: const EdgeInsets.only(left: 1.0),
                                                    child: WebsafeSvg.asset("images/level-filled.svg", color: Theme.of(context).primaryColor,width: 20,height: 20,)
                                                ),
                                                const SizedBox(width: 12.0,),
                                                Text(userData.userData.roleType == 2 ? "Grade" : "Level", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                                const Spacer(),
                                                userData.userData.band == null && userData.userData.grade != null
                                                    ?
                                                Text("${userData.userData.grade["name"]}", style: styleBlue2,)
                                                    :
                                                userData.userData.band != null && userData.userData.grade == null
                                                    ?
                                                Text("${userData.userData.band["name"]}", style: styleBlue2,)
                                                    :
                                                Text('Not set',style: TextStyle(color: Colors.grey[600]),)
                                                // userData.userData.grade == null ? Container():
                                                // Text("${userData.userData.grade["name"]}", style: styleBlue2,)
                                              ],
                                            ),
                                          ),
                                          const Divider(),
                                          Padding(
                                            padding: const EdgeInsets.only(right:16,left: 16,top: 4,bottom: 6),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    WebsafeSvg.asset('images/area-of-work-filled.svg',color: Theme.of(context).primaryColor,width: 20,),
                                                    // Image.asset('images/area-of-work.svg', color: Theme.of(context).primaryColor,width: 20,),
                                                    const SizedBox(width: 12,),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Areas of Work", style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold),),
                                                        Padding(
                                                            padding: const EdgeInsets.only(top: 5.0),
                                                            child: Align(
                                                              alignment: Alignment.centerLeft,
                                                              child: SizedBox(
                                                                width: media.width*0.75,
                                                                child: userData.userData.wards == null || userData.userData.wards.isEmpty
                                                                    ?
                                                                Text('Not set',style: TextStyle(color: Colors.grey[600]),)
                                                                    :
                                                                Wrap(
                                                                  children: userData.userData.wards.map((item) => Padding(
                                                                    padding: const EdgeInsets.all(5),
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
                                                    )
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
                                padding: const EdgeInsets.only(top:0,left: 8,bottom: 8),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Other", style: style1,)),
                              ),

                              Material(
                                // elevation: 2.0,
                                child: Container(
                                  color: Colors.white,
                                  width: media.width,
                                  padding:const EdgeInsets.symmetric(horizontal: 24,vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(left: 1.0,),
                                                child: WebsafeSvg.asset('images/skills-filled.svg', color: Theme.of(context).primaryColor,width: 25,)
                                            ),
                                            const SizedBox(width: 12.0,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Skills", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                                Padding(
                                                    padding: const EdgeInsets.only(top: 5.0),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: SizedBox(
                                                        width: media.width*0.75,
                                                        child: userData.userData.skills == null || userData.userData.skills.isEmpty
                                                            ?
                                                        Text('Not set',style: TextStyle(color: Colors.grey[600]),)
                                                            :
                                                        Wrap(
                                                          children: userData.userData.skills.map((item) => Padding(
                                                            padding: const EdgeInsets.all(5),
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
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(left: 1.0),
                                              child: WebsafeSvg.asset('images/language-filled.svg', color: Theme.of(context).primaryColor,width: 25,)
                                          ),
                                          const SizedBox(width: 12.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Languages", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color:Colors.grey[600],fontSize: 16,fontWeight: FontWeight.bold)),
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 5.0),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: SizedBox(
                                                      width: media.width*0.75,
                                                      child: userData.userData.languages == null || userData.userData.languages.isEmpty
                                                          ?
                                                      Text('Not set',style: TextStyle(color: Colors.grey[600]),)
                                                          :
                                                      Wrap(
                                                        children: userData.userData.languages.map((item) => Padding(
                                                          padding: const EdgeInsets.all(5),
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

                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0,)
                            ],
                          ),
                          // Positioned(
                          //   top: 120.0,
                          //   left: 20.0,
                          //   // right: 0.0,
                          //   child: Align(
                          //     alignment: Alignment.center,
                          //     child: Container(
                          //       width: 70,
                          //       height: 70,
                          //       decoration: BoxDecoration(
                          //           border: Border.all(
                          //               color: Colors.white,
                          //               width: 5.0
                          //           ),
                          //           borderRadius: BorderRadius.circular(60.0,)
                          //
                          //       ),
                          //       child: CircleAvatar(
                          //         backgroundColor: Colors.blue[200],
                          //         backgroundImage: userData.userData == null ? AssetImage('images/person.png'):
                          //         NetworkImage(userData.userData.profilePic),
                          //         radius: 40.0,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // Positioned(
                    //   top: 5.0,
                    //   left: 5.0,
                    //   child: Container(
                    //     width: 70,
                    //     height: 70,
                    //     decoration: BoxDecoration(
                    //     border: Border.all(
                    //     color: Colors.white,
                    //     width: 5.0
                    //     ),
                    //     borderRadius: BorderRadius.circular(60.0,)
                    //
                    //     ),
                    //     child: CircleAvatar(
                    //     backgroundColor: Colors.blue[200],
                    //     backgroundImage: userData.userData == null ? AssetImage('images/person.png'):
                    //     NetworkImage(userData.userData.profilePic),
                    //     radius: 40.0,
                    //     ),
                    //     ),
                    // ),
                    // Positioned(
                    //     bottom: 0.0,
                    //     left: 0.0,
                    //     right: 0.0,
                    //     child: Container(
                    //       height: 65.0,
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.only(
                    //             topLeft: Radius.circular(15),
                    //             topRight: Radius.circular(15)),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.grey.withOpacity(0.5),
                    //             spreadRadius: 5,
                    //             blurRadius: 7,
                    //             offset: Offset(0, 3), // changes position of shadow
                    //           ),
                    //         ],
                    //       ),
                    //       child: Row(
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //         children: [
                    //           InkWell(
                    //             splashColor: Colors.transparent,
                    //             onTap: ()async {
                    //               if(await Permission.microphone.isGranted == true){
                    //                 final callProvider = Provider.of<CallProvider>(context, listen: false);
                    //                 callProvider.initiateTwilioCall(callToUser: users[i]);
                    //               }
                    //               else{
                    //                 await Permission.microphone.request().then((value) {
                    //                   final callProvider = Provider.of<CallProvider>(context, listen: false);
                    //                   callProvider.initiateTwilioCall(callToUser: users[i]);
                    //                 });
                    //               }
                    //
                    //             },
                    //             child: Image.asset(
                    //               "images/callIcon.png",
                    //               color: Theme.of(context).primaryColor,
                    //               width: 25,
                    //             ),
                    //           ),
                    //           // Expanded(
                    //           //   child: roundedButton(
                    //           //       color: Colors.white,
                    //           //       titleColor: Theme.of(context).primaryColor,
                    //           //       context: context,
                    //           //       icon: Image.asset(
                    //           //         "images/callIcon.png",
                    //           //         color: Theme.of(context).primaryColor,
                    //           //         width: 25,
                    //           //       ),
                    //           //       title: "Call",
                    //           //       onClicked: ()async {
                    //           //         if(await Permission.microphone.isGranted == true){
                    //           //           final callProvider = Provider.of<CallProvider>(context, listen: false);
                    //           //           callProvider.initiateTwilioCall(callToUser: users[i]);
                    //           //         }
                    //           //         else{
                    //           //           await Permission.microphone.request().then((value) {
                    //           //             final callProvider = Provider.of<CallProvider>(context, listen: false);
                    //           //             callProvider.initiateTwilioCall(callToUser: users[i]);
                    //           //           });
                    //           //         }
                    //           //
                    //           //       }),
                    //           // ),
                    //           SizedBox(
                    //             width: 40.0,
                    //           ),
                    //           // Expanded(
                    //           //   child: roundedButton(
                    //           //       buttonWidth: media.width * 0.4,
                    //           //       color: Colors.white,
                    //           //       titleColor: Theme.of(context).primaryColor,
                    //           //       context: context,
                    //           //       icon: Image.asset(
                    //           //         "images/chat.png",
                    //           //         color: Theme.of(context).primaryColor,
                    //           //         width: 25,
                    //           //       ),
                    //           //       title: "Message",
                    //           //       onClicked: ()async{
                    //           //         Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                    //           //           usersIds: [users[i].id, userData.userData.id],
                    //           //           channelType: "private",
                    //           //           channelDisplayName: users[i].name,
                    //           //         );
                    //           //       }),
                    //           // ),
                    //           InkWell(
                    //             splashColor: Colors.transparent,
                    //             onTap: ()async{
                    //               Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                    //                 usersIds: [users[i].id, userData.userData.id],
                    //                 channelType: "private",
                    //                 channelDisplayName: users[i].name,
                    //               );
                    //             },
                    //             child: Image.asset(
                    //               "images/chat.png",
                    //               color: Theme.of(context).primaryColor,
                    //               width: 25,
                    //             ),
                    //           )
                    //           // Padding(
                    //           //   padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 20.0),
                    //           //   child: roundedButton(
                    //           //     context: context,
                    //           //     buttonHeight: 45.0,
                    //           //     title: "Comment",
                    //           //     icon: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 25.0,),
                    //           //     onClicked: () => Navigator.pushNamed(context, CommentScreen.routeName, arguments: {
                    //           //       "id":passedData["id"]
                    //           //     }),
                    //           //   )
                    //           //   // Row(
                    //           //   //   mainAxisAlignment: MainAxisAlignment.center,
                    //           //   //   children: [
                    //           //   //     Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor, size: 25.0,),
                    //           //   //     SizedBox(width: 5.0,),
                    //           //   //     Text("Comment", style: styleBlue,),
                    //           //   //   ],
                    //           //   // ),
                    //           // ),
                    //         ],
                    //       ),
                    //     ))
                    // Positioned(
                    //   top: 340.0,
                    //   left: 0.0,
                    //   right: 0.0,
                    //   bottom: 0.0,
                    //   child: Material(
                    //     // elevation: 5.0,
                    //     color: Colors.white,
                    //     // borderRadius: const BorderRadius.only(
                    //     //   topRight: const Radius.circular(8),
                    //     //   topLeft: const Radius.circular(8.0)
                    //     // ),
                    //     child: ListView(
                    //       shrinkWrap: true,
                    //       children: <Widget>[
                    //         Padding(
                    //           padding: const EdgeInsets.only(left: 10.0, bottom: 2.0),
                    //           child: Align(
                    //               alignment: Alignment.topLeft,
                    //               child: Text("Work Details", style: style1,)),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //           child: Material(
                    //             borderRadius: BorderRadius.circular(6),
                    //             color: Colors.white,
                    //             elevation: 2.0,
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                    //               child: Column(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 children: [
                    //                     Row(
                    //                       children: [
                    //                         Padding(
                    //                             padding: const EdgeInsets.only(left: 1.0),
                    //                             child: Image.asset("images/hospital.png", height: 30.0, width: 28.0,
                    //                                 color: Theme.of(context).primaryColor)
                    //                         ),
                    //                         SizedBox(width: 12.0,),
                    //                         Text("Hospitals",style: style2),
                    //                       ],
                    //                     ),
                    //
                    //                   Padding(
                    //                     padding: const EdgeInsets.only(left:8.0, top: 3.0),
                    //                     child: Align(
                    //                       alignment: Alignment.centerLeft,
                    //                       child: Wrap(
                    //                         spacing: 5.0,
                    //                         runSpacing: 5.0,
                    //                         children: userData.userData.hospitals.map((item) => Container(
                    //                             decoration: BoxDecoration(
                    //                               color: Theme.of(context).primaryColor,
                    //                               borderRadius: BorderRadius.circular(8.0),
                    //                             ),
                    //                             child: Padding(
                    //                               padding: const EdgeInsets.all(6.0),
                    //                               child: Text("${item["name"]}",
                    //                                   maxLines: 1, overflow: TextOverflow.ellipsis,
                    //                                   style: TextStyle(color: Colors.white)),
                    //                             ))).toList().cast<Widget>(),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 2.0),
                    //           child: Align(
                    //               alignment: Alignment.centerLeft,
                    //               child: Text("Preferences", style: style1,)),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //           child: Material(
                    //             borderRadius: BorderRadius.circular(6),
                    //             color: Colors.white,
                    //             elevation: 2.0,
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    //               child: Row(
                    //                 children: [
                    //                   Padding(
                    //                       padding: const EdgeInsets.only(left: 1.0),
                    //                       child: Icon(Icons.bookmark_border_outlined, color: Theme.of(context).primaryColor,)
                    //                   ),
                    //                   SizedBox(width: 12.0,),
                    //                   Text("Min Accepted Level", maxLines: 2, overflow: TextOverflow.ellipsis, style: style2),
                    //                   Spacer(),
                    //                   userData.userData.minAcceptedBand == null ? Container():
                    //                   Text("${userData.userData.minAcceptedBand["name"]}", style: styleBlue2,)
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 2.0),
                    //           child: Align(
                    //               alignment: Alignment.centerLeft,
                    //               child: Text("Competencies", style: style1,)),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //           child: Material(
                    //             borderRadius: BorderRadius.circular(6),
                    //             color: Colors.white,
                    //             elevation: 2.0,
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    //               child: Column(
                    //                 children: [
                    //                   Row(
                    //                     children: [
                    //                       Padding(
                    //                           padding: const EdgeInsets.only(left: 1.0),
                    //                           child: Icon(Icons.bookmark_border_rounded, color: Theme.of(context).primaryColor,)
                    //                       ),
                    //                       SizedBox(width: 12.0,),
                    //                       Text("Level", maxLines: 2, overflow: TextOverflow.ellipsis, style: style2),
                    //                       Spacer(),
                    //                       userData.userData.grade == null ? Container():
                    //                       Text("${userData.userData.grade["name"]}", style: styleBlue2,)
                    //                     ],
                    //                   ),
                    //                   Divider(),
                    //                   Row(
                    //                     children: [
                    //                       Icon(Icons.work_rounded, color: Theme.of(context).primaryColor,),
                    //                       SizedBox(width: 12.0,),
                    //                       Text("Areas of Work", style: style2,),
                    //                     ],
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.only(left:8.0, top: 8.0),
                    //                     child: Align(
                    //                       alignment: Alignment.centerLeft,
                    //                       child: Wrap(
                    //                         children: userData.userData.wards.map((item) => Padding(
                    //                             padding: const EdgeInsets.all(5),
                    //                           child: Container(
                    //                               decoration: BoxDecoration(
                    //                                       color: Theme.of(context).primaryColor,
                    //                                       borderRadius: BorderRadius.circular(8.0),
                    //                                     ),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets.all(6.0),
                    //                                 child: Text(item["name"],style: TextStyle(color: Colors.white)),
                    //                               )),
                    //                         )).toList().cast<Widget>(),
                    //                       ),
                    //                     )
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 2.0),
                    //           child: Align(
                    //               alignment: Alignment.centerLeft,
                    //               child: Text("Other", style: style1,)),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //           child: Material(
                    //             borderRadius: BorderRadius.circular(6),
                    //             color: Colors.white,
                    //             elevation: 2.0,
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    //               child: Column(
                    //                 children: [
                    //                   Row(
                    //                     children: [
                    //                       Padding(
                    //                           padding: const EdgeInsets.only(left: 1.0),
                    //                           child: Icon(Icons.done_outline_sharp, color: Theme.of(context).primaryColor,)
                    //                       ),
                    //                       SizedBox(width: 12.0,),
                    //                       Text("Skills", maxLines: 2, overflow: TextOverflow.ellipsis, style: style2),
                    //                     ],
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.only(left:8.0, top: 8.0),
                    //                     child: Align(
                    //                       alignment: Alignment.centerLeft,
                    //                       child: Wrap(
                    //                         children: userData.userData.skills.map((item) => Padding(
                    //                           padding: const EdgeInsets.all(5),
                    //                           child: Container(
                    //                               decoration: BoxDecoration(
                    //                                 color: Theme.of(context).primaryColor,
                    //                                 borderRadius: BorderRadius.circular(8.0),
                    //                               ),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets.all(6.0),
                    //                                 child: Text(item["name"],style: TextStyle(color: Colors.white)),
                    //                               )),
                    //                         )).toList().cast<Widget>(),
                    //                       ),
                    //                     )
                    //                   ),
                    //                   Divider(),
                    //                   Row(
                    //                     children: [
                    //                       Padding(
                    //                           padding: const EdgeInsets.only(left: 1.0),
                    //                           child: Icon(Icons.language_rounded, color: Theme.of(context).primaryColor,)
                    //                       ),
                    //                       SizedBox(width: 12.0,),
                    //                       Text("Languages", maxLines: 2, overflow: TextOverflow.ellipsis, style: style2),
                    //                     ],
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.only(left:8.0, top: 8.0),
                    //                     child: Align(
                    //                       alignment: Alignment.centerLeft,
                    //                       child: Wrap(
                    //                         children: userData.userData.languages.map((item) => Padding(
                    //                           padding: const EdgeInsets.all(5),
                    //                           child: Container(
                    //                               decoration: BoxDecoration(
                    //                                 color: Theme.of(context).primaryColor,
                    //                                 borderRadius: BorderRadius.circular(8.0),
                    //                               ),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets.all(6.0),
                    //                                 child: Text(item["name"],style: TextStyle(color: Colors.white)),
                    //                               )),
                    //                         )).toList().cast<Widget>(),
                    //                       ),
                    //                     )
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(height: 20.0,)
                    //       ],
                    //     ),
                    //   ),
                    // ),




                    // Positioned(
                    //   top: 18.0,
                    //   child: IconButton(icon: Icon(
                    //   Icons.keyboard_arrow_left, color: Colors.white, size: 45.0,),
                    //     onPressed: () => Navigator.of(context).pop(),),),

                  ],
                ),
              ),
          ),
        )
    );
  }
}