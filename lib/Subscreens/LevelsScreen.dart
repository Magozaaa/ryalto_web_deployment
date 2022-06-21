// ignore_for_file: file_names, must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, no_logic_in_create_state

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class LevelsScreen extends StatefulWidget{
  var screen_title,screen_content,section;
  LevelsScreen({Key key, this.screen_title,this.screen_content,this.section}) : super(key: key);

  static const String routeName = "/LevelsScreen_Screen";

  @override
  _LevelsScreenState createState() => _LevelsScreenState(screen_content: screen_content,screen_title: screen_title,section: section);
}

class _LevelsScreenState extends State<LevelsScreen> {
  var screen_title,screen_content,section;
  _LevelsScreenState({this.screen_title,this.screen_content,this.section});


  List isSelected = [];
  Map passedData;
  int pageOffset = 0;
  var userTrustId;
  final TextEditingController _searchController = TextEditingController();

  List levels = [];
  User userData;
  String levelId;
  var userLevels = {};
  var userMinLevel = {};
  String userLevelId;
  String userMinLevelId;
  bool _isLoadingUserData = true;

  getDataInInitState(){
    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    userData = Provider.of<UserProvider>(context,listen: false).userData;
    // isSelected = List.filled(levels.length, false);


    Provider.of<UserProvider>(context, listen: false).getCompetencies(
      context: context,
    ).then((_) {

      levels = userData.roleType == 2 ?
      Provider.of<UserProvider>(context,listen: false).grades :
      Provider.of<UserProvider>(context,listen: false).bands;

      userLevels = userData.roleType == 2 ?
      Provider.of<UserProvider>(context,listen: false).userData.grade :
      Provider.of<UserProvider>(context,listen: false).userData.band;

      userMinLevel = userData.roleType == 2 ?
      Provider.of<UserProvider>(context,listen: false).userData.minAcceptedGrade :
      Provider.of<UserProvider>(context,listen: false).userData.minAcceptedBand;


      if(levels != null && levels.isNotEmpty && userLevels != null && userLevels["value"] != null){
        if(screen_title == "Minimum Accepted Level" || screen_title == "Minimum Accepted Grade"){
          if(userLevels != null && userLevels.isNotEmpty){
            levels.removeWhere((level) => level.value > userLevels["value"]);
          }
          else if (complete == "Complete" && userLevels != null && userLevels.isNotEmpty) {
            levels.removeWhere((level) => level.value > userLevels["value"]);
          }
        }
      }
      isSelected = List.filled(levels.length, false);

      if(screen_title == "Minimum Accepted Level" || screen_title == "Minimum Accepted Grade"){
        if(userMinLevel != null){
          userMinLevelId = userMinLevel['id'];
          for (int w=0; w < levels.length; w++) {
            if (levels[w].id == "${userMinLevel['id']}") {
              isSelected[w] = true;
              levelId = levels[w].id;
            }
          }
        }
      }else if(screen_title == "Grade" || screen_title == "Level"){
        if(userLevels != null){
          userLevelId = userLevels['id'];
          for (int w=0; w < levels.length; w++) {
            if (levels[w].id == "${userLevels['id']}") {
              isSelected[w] = true;
              levelId = levels[w].id;
            }
          }
        }
      }


    });
  }
  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false).getUser(context).then((_) {
      getDataInInitState();
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    });
    super.initState();
  }
  final String complete='Complete';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isUpdatingProfile= false;


  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    var userProviderStage = Provider.of<UserProvider>(context).competenciesStage;


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
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              // leadingWidth: 120,
              leading: IconButton(icon: Icon(section == "Complete" ? Icons.close : Icons.arrow_back_ios_rounded, color: Colors.white,),
                  onPressed: _isUpdatingProfile==true?(){}:() => Navigator.pop(context)) ,

              title: Text(screen_title == "Minimum Accepted Level" ? screen_title : "$screen_title",
                style: TextStyle(color: Colors.white,
                  fontSize: screen_title == "Minimum Accepted Level" ? 14.0 : 19.0, fontWeight: FontWeight.bold),),
              actions: section != complete
                  ?
              [
                screen_title == "Minimum Accepted Level" || screen_title == "Minimum Accepted Grade"?
                  Center(
                      child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                child: _isUpdatingProfile == true ? const SpinKitCircle(color: Colors.white,size: 25,):InkWell(
                  onTap: levelId == null || levelId == userMinLevelId  ?
                      (){}:
                      () async {
                    setState(() {
                      _isUpdatingProfile = true;
                    });
                    await Provider.of<UserProvider>(context,
                        listen: false)
                        .updateProfile(context,
                        // email: userData.email,
                        // firstName: userData.firstName,
                        // lastName: userData.lastName,
                        trustId: userData.trust['id'],
                        // phoneNumber: userData.phone,
                        // employeeNumber: userData.employee_number,
                        userType: userData.roleType,
                        levelId: userLevels != null ? userLevels["id"] : null,
                        minimumLevelId: levelId
                    ).then((_) {
                      // AnalyticsManager.track('profile_minimum_band_changed');
                      setState(() {
                        _isUpdatingProfile = false;
                      });
                    });
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                        color: levelId == null || levelId == userMinLevelId ? Colors.black26 : Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
                    :
                 Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _isUpdatingProfile == true ? const SpinKitCircle(color: Colors.white,size: 25,):InkWell(
                      onTap: levelId == null || levelId == userLevelId   ?
                          (){}:
                          () async {
                        setState(() {
                          _isUpdatingProfile = true;
                        });
                        await Provider.of<UserProvider>(context,
                            listen: false)
                            .updateProfile(context,
                            // email: userData.email,
                            // firstName: userData.firstName,
                            // lastName: userData.lastName,
                            trustId: userData.trust['id'],
                            // phoneNumber: userData.phone,
                            // employeeNumber: userData.employee_number,
                            userType: userData.roleType,
                            minimumLevelId:  userMinLevel != null ? userMinLevel["id"]:null,
                            levelId: levelId
                        ).then((_) {
                          // AnalyticsManager.track('profile_band_changed');
                          setState(() {
                            _isUpdatingProfile = false;
                          });
                        });
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                            color: levelId == null || levelId == userLevelId ? Colors.black26 : Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ]:[],
            ),
            body: userProviderStage == UsersStage.LOADING || _isLoadingUserData
                ?
            Center(
              child: SpinKitCircle(
                color: Theme.of(context).primaryColor,
                size: 45.0,
              ),
            )
                :
            userProviderStage == UsersStage.ERROR
                ?
            Center(
              child: InkWell(
              onTap: (){
                getDataInInitState();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Network Error retry? "),
                  Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
                ],
              ),
            ),)
                :
            levels.isEmpty
                ?
            SizedBox(height: media.height*0.5,child: Center(child:Text(userData.roleType == 2 ? 'There is no Grades' : 'There is no Levels')),)
                :
            levels.isEmpty && (screen_title == "Minimum Accepted Level" || screen_title == "Minimum Accepted Grade")
                ?
            SizedBox(height: media.height*0.5,child: Center(child:Text(userData.roleType == 2 ? 'There is no Grades' : 'There is no Levels')),):
            userProviderStage == UsersStage.DONE
                ?
            SizedBox(
              height: media.height,
              child: ListView.builder(
                // shrinkWrap: true,
                itemCount: levels.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, i) => i == levels.length ?  const SizedBox(height: 130,):
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text("${levels[i].name}", overflow: TextOverflow.ellipsis, maxLines: 2, style: style2,),
                      trailing: isSelected.isEmpty ? const SizedBox() : !isSelected[i] ? Container(width: 1.0,) : Icon(Icons.done, color: Theme.of(context).primaryColor,),
                      onTap: (){
                        setState(() {
                          for(int j = 0; j <levels.length; j++){
                            isSelected[j] = false;
                            levelId = levels[i].id;
                            if (screen_title != "Minimum Accepted Level" && screen_title != "Minimum Accepted Grade") {
                              Provider.of<UserProvider>(context, listen: false).setLevelForCompletingProfile(levels[i]);
                            }
                            else{
                              Provider.of<UserProvider>(context, listen: false).setMinAcceptedLevelForCompletingProfile(levels[i]);
                            }
                          }
                          isSelected[i] = true;
                        });
                      },
                    ),
                    const Divider(),
                  ],
                ),


              ),
            )
                :
            Center(child: InkWell(
              onTap: (){
                getDataInInitState();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Network Error retry? "),
                  Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
                ],
              ),
            ),)

        ),
      ),
    );
  }
}