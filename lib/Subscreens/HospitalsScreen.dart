// ignore_for_file: file_names, must_be_immutable, prefer_typing_uninitialized_variables, no_logic_in_create_state, avoid_function_literals_in_foreach_calls

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/HospitalModel.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/SelectUserTypeScreen.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';


class HospitalsScreen extends StatefulWidget {
  static const String routeName = "/HospitalsScreen_Screen";
  var trustId;

  HospitalsScreen({Key key}) : super(key: key);

  @override
  _HospitalsScreenState createState() => _HospitalsScreenState(trustId: trustId);
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  var trustId;
  _HospitalsScreenState({@required this.trustId});
  List isSelected = [];
  Map passedData = {};
  bool _isInit = true;
  int pageOffset = 0;
  var userTrustId;
  var trustIdToGetHospitals;
  final TextEditingController _searchController = TextEditingController();
  List<String> ids = [];
  List<String> hospitalsNames = [];
  bool _isNavigatingToUserTypeScreen = false;
  @override
  void initState() {

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      /// TODO : need to be moved to initState and handle the logic to get current items preSelection

      Provider.of<UserProvider>(context, listen: false)
          .getHospitals(context,trustId: passedData['trustId'],countryCode: passedData['countryCode'] )
          .then((_) {
        isSelected = List.filled(Provider.of<UserProvider>(context, listen: false).hospitals.length, false);

        for (int w=0; w<Provider.of<UserProvider>(context, listen: false).hospitals.length; w++) {
          if (Provider.of<UserProvider>(context, listen: false).userData != null) {
            for (var v = 0; v<Provider.of<UserProvider>(context, listen: false).userData.hospitals.length; v++) {
              if (Provider.of<UserProvider>(context, listen: false).hospitals[w].id == "${Provider.of<UserProvider>(context, listen: false).userData.hospitals[v]['id']}") {
                isSelected[w] = true;
                ids.add(Provider.of<UserProvider>(context, listen: false).hospitals[w].id);
              }
            }
          }
        }
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hospital> _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    Provider.of<UserProvider>(context, listen: false).hospitals.forEach((hospital) {
      if (hospital.name.toLowerCase().contains(text)) {
        setState(() {
          _searchResult.add(hospital);
        });
      }
    });

    setState(() {});
  }
  Map<String,List<String>> hospitalsDataToGoToEditProfile;

  bool _isUpdatingProfile=false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);
    final hospitals = userData.hospitals;
    final hospitalStage = userData.hospitalsStage;


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onHorizontalDragEnd: (DragEndDetails details){
        if (!kIsWeb) {
          if (Platform.isIOS) {
            if (details.primaryVelocity.compareTo(0) == 1) {
              Navigator.pop(context);
            }
          }
        }
      },
      child: WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              leadingWidth: 120,
              leading: Row(
                children: [
                  IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _isUpdatingProfile==true?(){}:() => Navigator.pop(context)),
                  // const SizedBox(width: 5.0,),
                  // Provider.of<CallProvider>(context).isInACall ? returnToCallScreen(context) : const SizedBox()
                ],
              ),
              title: Text(
                passedData["screen_title"],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                passedData['screen_title'] == "Sites"
                    ?
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _isUpdatingProfile ==true ? const SpinKitCircle(color: Colors.white,size: 25,) :InkWell(
                      onTap:
                      // hospitalsDataToGoToEditProfile == null ?() {} :
                          () async {
                        // Navigator.pop(context,trustDataToGoToEditProfile);
                        setState(() {
                          _isUpdatingProfile = true;
                        });
                        await Provider.of<UserProvider>(context, listen: false)
                            .updateProfile(context,
                            // email: userData.userData.email,
                            // firstName: userData.userData.firstName,
                            // lastName: userData.userData.lastName,
                            trustId: userData.userData.trust['id'],
                            // phoneNumber: userData.userData.phone,
                            // employeeNumber: userData.userData.employee_number,
                            userType: userData.userData.roleType,
                            // minimumLevelId: userData.userData.roleType == 2 ? userData.userData.minAcceptedGrade == null ? null : userData.userData.minAcceptedGrade['id'] : userData.userData.minAcceptedBand == null ? null : userData.userData.minAcceptedBand['id'],
                            // levelId: userData.userData.roleType == 2 ? userData.userData.grade == null ? null : userData.userData.grade['id'] : userData.userData.band == null ? null : userData.userData.band['id'],
                            // roles: userData.roles,
                            // wards: userData.wards,
                            // languages: userData.languages,
                            hospitals: ids
                        ).then((_) {
                          setState(() {
                            _isUpdatingProfile = false;
                          });
                        });
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                            color: hospitalsDataToGoToEditProfile == null ? Colors.black26:Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                    :
                const SizedBox()
              ],
            ),
            body: hospitalStage == UsersStage.DONE? SizedBox(
              height: media.height,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.white,
                          elevation: 7.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 40.0,
                                  child: Center(
                                    child: Text(
                                      "Where do you work?",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color:
                                          Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 40.0,
                                  child: TextFormField(
                                    controller: _searchController,
                                    onChanged: (value) async {
                                      if (value.length > 2) {
                                        onSearchTextChanged(value.toLowerCase());
                                      } else {
                                        setState(() {
                                          _searchResult.clear();
                                         // isSelected.clear();
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color:
                                          Theme.of(context).primaryColor,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2.0,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            borderRadius:
                                            textFieldBorderRadius),
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 0.0,
                                            left: 15.0,
                                            right: 15.0),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2.0,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            borderRadius:
                                            textFieldBorderRadius),
                                        hintText: "Search",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _searchResult.isNotEmpty ? SizedBox(
                          height: media.height * 0.7,
                          child: hospitalsListWidget(context, media,
                              list: _searchResult ),
                        )
                            :
                        SizedBox(
                          height: media.height * 0.7,
                          child: hospitalsListWidget(context, media,
                              list: hospitals ),
                        ),
                      ],
                    ),
                  ),
                  passedData['screen_title'] == "Sites"
                      ?
                  const SizedBox()
                      :
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset:
                            const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 12.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Text(
                          //         "Not working in ",
                          //         textAlign: TextAlign.center,
                          //         maxLines: 2,
                          //       ),
                          //       Text(
                          //         "United Kingdom?",
                          //         textAlign: TextAlign.center,
                          //         maxLines: 2,
                          //         style: TextStyle(
                          //             fontWeight: FontWeight.bold),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          // Text(
                          //   "Tab here to change country",
                          //   textAlign: TextAlign.center,
                          //   maxLines: 2,
                          //   style: TextStyle(
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          // ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          _isNavigatingToUserTypeScreen ? Center(child: SpinKitCircle(color: Theme.of(context).primaryColor,size: 30,))
                              :
                          roundedButton(
                              context: context,
                              title: "Next",
                              buttonWidth: kIsWeb ? buttonWidth : media.width * 0.8,
                              color: isSelected.contains(true) || hospitals.isEmpty
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                              titleColor: isSelected.contains(true) || hospitals.isEmpty
                                  ? Colors.white
                                  : Colors.grey,
                              onClicked:
                              isSelected.contains(true) || hospitals.isEmpty
                                  ?
                                  (){
                                setState(() {
                                  _isNavigatingToUserTypeScreen = true;
                                });
                                Provider.of<UserProvider>(context,listen: false).getUserTypes().then((_) {
                                  Navigator.pushNamed(
                                      context, SelectUserTypeScreen.routeName,
                                      arguments: {
                                        "screen_title": "Sign Up",
                                        "trustId":
                                        passedData['trustId'],
                                        "hospitalsIds": ids,
                                        "timezone" : passedData['timezone'],
                                        "countryCode" : passedData['countryCode'],
                                      });
                                  AnalyticsManager.track('signup_hospital_changed');
                                  setState(() {
                                    _isNavigatingToUserTypeScreen = false;
                                  });
                                });


                              }
                              :(){})
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
                :
            hospitalStage == UsersStage.LOADING
                ? SizedBox(
              height: media.height,
              width: media.width,
              child: Center(
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 45.0,
                ),
              ),
            )
          :
          SizedBox(
              height: media.height,
              width: media.width,
              child: Center(
                child: InkWell(
                  onTap: (){
                    Provider.of<UserProvider>(context, listen: false)
                        .getHospitals(context,trustId: passedData['trustId'],countryCode: passedData['countryCode'] )
                        .then((_) {
                      isSelected = List.filled(Provider.of<UserProvider>(context, listen: false).hospitals.length, false);

                      for (int w=0; w<Provider.of<UserProvider>(context, listen: false).hospitals.length; w++) {
                        if (Provider.of<UserProvider>(context, listen: false).userData != null) {
                          for (var v = 0; v<Provider.of<UserProvider>(context, listen: false).userData.hospitals.length; v++) {
                            if (Provider.of<UserProvider>(context, listen: false).hospitals[w].id == "${Provider.of<UserProvider>(context, listen: false).userData.hospitals[v]['id']}") {
                              isSelected[w] = true;
                              ids.add(Provider.of<UserProvider>(context, listen: false).hospitals[w].id);
                            }
                          }
                        }
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Network Error retry? "),
                      Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget hospitalsListWidget(context, media, {list}) {
    return SizedBox(
      width: media.width,
      height: media.height,
      child: SizedBox(
        height: media.height * 0.7,
        child: list.isEmpty
            ? SizedBox(
          height: media.height,
          width: media.width,
          child: Center(child: Text('There are no Hospitals for this Trust in selected Country!',style: style2,textAlign: TextAlign.center,)),
        )
            : ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      "${list[i].name}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: style2,
                    ),
                    trailing: !isSelected[i]
                        ? Container(
                      width: 1.0,
                    )
                        : Icon(
                      Icons.done,
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () {
                      setState(() {
                        isSelected[i]=!isSelected[i];
                        if(isSelected[i]==true){
                          ids.add(list[i].id.toString());
                          hospitalsNames.add(list[i].name.toString());
                        }
                        else if(isSelected[i]==false){
                          ids.remove(list[i].id.toString());
                          hospitalsNames.remove(list[i].name.toString());
                        }
                      });
                      hospitalsDataToGoToEditProfile={
                        "HospitalsIds" : ids,
                        "HospitalsNames" : hospitalsNames
                      };
                    },
                  ),
                  (i==list.length - 1) ? const SizedBox(height: 60,) : const Divider(),
                ],
              );
            }
          // }
        ),
      ),
    );
  }
}
