// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Profile/AccountDetails.dart';
import 'package:rightnurse/Subscreens/Profile/Competencies.dart';
import 'package:rightnurse/Subscreens/Profile/MyAccountScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class EditProfile extends StatefulWidget {
  static const String routeName = "/EditProfile_Screen";

  const EditProfile({Key key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with AutomaticKeepAliveClientMixin<EditProfile> {
  @override
  bool get wantKeepAlive => true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();


  bool _isUpdatingProfile = false;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, NavigationHome.routeName);
        return Future.value(false);
      },
      child: DefaultTabController(
        length: 2,
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
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(120.0),
              child: AppBar(
                centerTitle: true,
                title: const Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold),
                ),
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _isUpdatingProfile
                          ?
                      const Center(child: SpinKitCircle(color: Colors.white,size: 25,),)
                          :
                      InkWell(
                        onTap: userData.editedFirstName != null ||
                                userData.editedLastName != null ||
                                userData.editedEmail != null ||
                                userData.editedPhoneNo != null ||
                                userData.editedEmployeeNo != null ||
                                userData.editedProfilePic != null
                            ? () {
                                setState(() {
                                  _isUpdatingProfile = true;
                                });
                                userData
                                    .updateProfile(context,
                                        userType: userData.userData.roleType,
                                        trustId: userData.userData.trust["id"],
                                    minimumLevelId: userData.userData.roleType == 2 ? userData.userData.minAcceptedGrade == null ? null : userData.userData.minAcceptedGrade['id'] : userData.userData.minAcceptedBand == null ? null : userData.userData.minAcceptedBand['id'],
                                    levelId: userData.userData.roleType == 2 ? userData.userData.grade == null ? null : userData.userData.grade['id'] : userData.userData.band == null ? null : userData.userData.band['id'],
                                        email: userData.editedEmail,
                                        firstName: userData.editedFirstName,
                                        lastName: userData.editedLastName,
                                        phoneNumber: userData.editedPhoneNo,
                                        employeeNumber: userData.editedEmployeeNo,
                                        profilePic: userData.editedProfilePic)
                                    .then((_) {
                                  setState(() {
                                    _isUpdatingProfile = true;
                                  });
                                  userData.setEditProfileData(
                                      firstName: null,
                                      lastName: null,
                                      phoneNumber: null,
                                      email: null,
                                      employeeNumber: null,
                                      profilePic: null);
                                });
                              }
                            : null,
                        child: Text(
                          'Save',
                          style: TextStyle(
                              color: userData.editedFirstName != null ||
                                  userData.editedLastName != null ||
                                  userData.editedEmail != null ||
                                  userData.editedPhoneNo != null ||
                                  userData.editedEmployeeNo != null ||
                                  userData.editedProfilePic != null
                                  ?Colors.white:Colors.transparent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
                elevation: 0.0,
                bottom: PreferredSize(
                    child: Align(
                      alignment: Alignment.center,
                      child: TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.white,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: const BoxDecoration(color:Colors.white,borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5))),
                        isScrollable: kIsWeb ? false : true,
                        tabs: List<Widget>.generate(2, (int index) {
                          return Tab(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 3.0,
                                  left: media.width * .1,
                                  right: media.width * .1),
                              child: Text(
                                index == 0 ? "Account Details" : "Competencies",
                                softWrap: true,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontFamily: "DIN"),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    preferredSize: const Size.fromHeight(30.0)),
                leadingWidth: 120,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.pushReplacementNamed(
                              context, MyAccountsScreen.routName);
                          userData.setEditProfileData(
                              firstName: null,
                              lastName: null,
                              phoneNumber: null,
                              email: null,
                              employeeNumber: null,
                              profilePic: null);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5.0,),
                      //Provider.of<CallProvider>(context).isInACall ? returnToCallScreen(context) : const SizedBox()
                    ],
                  ),
                ),
              ),
            ),
            // appBar: AppBar(
            //   automaticallyImplyLeading: false,
            //   title: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       FlatButton(
            //           onPressed: ()=>  Navigator.pop(context),
            //           child: Text("Cancel", style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 18.0
            //           ),)),
            //
            //       Text("Edit Profile", style: TextStyle(color: Colors.white,
            //         fontSize: 19.0, fontWeight: FontWeight.bold),),
            //
            //       userData.editedFirstName != null || userData.editedLastName != null || userData.editedEmail != null || userData.editedPhoneNo != null ||
            //       userData.editedEmployeeNo != null || userData.editedProfilePic != null ?
            //       FlatButton(
            //           onPressed: (){
            //            userData.updateProfile(context, userType: userData.userData.roleType,
            //              trustId: userData.userData.trust["id"], email: userData.editedEmail ?? userData.userData.email,
            //                firstName: userData.editedFirstName ?? userData.userData.firstName,
            //                lastName: userData.editedLastName ?? userData.userData.lastName,
            //                phoneNumber: userData.editedPhoneNo ?? userData.userData.phone,
            //                employeeNumber: userData.editedEmployeeNo ?? userData.userData.employee_number,
            //                profilePic: userData.editedProfilePic ?? null
            //            ).then((_){
            //              userData.setEditProfileData(firstName: null, lastName: null, phoneNumber: null, email: null, employeeNumber: null, profilePic: null);
            //            });
            //           },
            //           child: Text("Save", style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 18.0
            //           ),)) : Container(),
            //     ],
            //   ),
            //   bottom: PreferredSize(
            //       child:Align(
            //         alignment:Alignment.center,
            //         child: TabBar(
            //           labelColor: Theme.of(context).primaryColor,
            //           unselectedLabelColor: Colors.white,
            //           indicatorSize: TabBarIndicatorSize.tab,
            //           indicator: new BubbleTabIndicator(
            //             indicatorHeight: 25.0,
            //             indicatorColor: Color(0xffF0F0F0),
            //             tabBarIndicatorSize: TabBarIndicatorSize.tab,
            //           ),
            //           isScrollable: true,
            //           tabs: List<Widget>.generate(2, (int index){
            //             return  Tab(child: Padding(
            //               padding: EdgeInsets.only(top:3.0, left: media.width * .1, right: media.width * .1),
            //               child: Text(index == 0 ? "Account Details" : "Competencies",
            //                 softWrap: true,
            //                 style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontFamily: "DIN"),),
            //             ),);
            //           }),
            //         ),
            //       ),
            //       preferredSize: Size.fromHeight(30.0)
            //   ),
            // ),
            body: Form(
              key: _formKey,
              child: TabBarView(
                children: <Widget>[
                  AccountDetails(),
                  const Competencies(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
