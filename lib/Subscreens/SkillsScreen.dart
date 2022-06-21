// ignore_for_file: file_names, prefer_final_fields, unnecessary_string_interpolations

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/HospitalModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class SkillsScreen extends StatefulWidget{

  static const String routeName = "/SkillsScreen_Screen";

  const SkillsScreen({Key key}) : super(key: key);

  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {

  List<List> isSelected = [];
  List isChildSelected = [];
  Map<String,dynamic> selected ={};
  List<bool> selectAll = [];

  Map passedData = {};
  var _isInit = true;

  List<bool> _isExpanded = [];

  List<HospitalForUserAttributes> hospitals = [];
  Set<String> ids = {};
  List<String> skillsNames = [];
  Map<String,dynamic> skillsDataToGoToCompetencies;
  User userData;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<UserProvider>(context,listen: false).getAttributes(context: context,attributeType: 'skill').then((_) {
      userData = Provider.of<UserProvider>(context,listen: false).userData;
      hospitals = Provider.of<UserProvider>(context,listen: false).hospitalsForAttributes;
      selectAll = List.filled(hospitals.length, false);

      for(int i=0;i<hospitals.length;i++){

        selected['${hospitals[i].id}'] = List.filled(hospitals[i].skills.length, false);
        for (int w=0; w<hospitals[i].skills.length; w++) {
          for (var v = 0; v<userData.skills.length; v++) {
            if (hospitals[i].skills[w]["id"] == "${userData.skills[v]['id']}") {
              selected['${hospitals[i].id}'][w] = true;
              ids.add(hospitals[i].skills[w]["id"]);
            }
          }
          // to set select all field
          if(!selected['${hospitals[i].id}'].any((element) => element == false) && selected['${hospitals[i].id}'].isNotEmpty ){
            selectAll[i] = true;
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  bool _isUpdatingProfile= false;

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final wardsStage = Provider.of<UserProvider>(context).hospitalsStage;


    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (!kIsWeb) {
            if (Platform.isIOS) {
              if (details.primaryVelocity.compareTo(0) == 1) {
                Navigator.pop(context);
              }
            }
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              leadingWidth: 120,
              leading: Row(
                children: [
                  IconButton(icon: Icon(passedData==null ? Icons.close:Icons.arrow_back_ios_rounded, color: Colors.white,),
                      onPressed: _isUpdatingProfile ==true ?(){}:() {
                        Provider.of<UserProvider>(context,listen: false).clearSkillsForCompletingProfile();
                        Navigator.pop(context);
                      }),
                  // const SizedBox(width: 5.0,),
                  // Provider.of<CallProvider>(context).isInACall ? returnToCallScreen(context) : const SizedBox()
                ],
              ),
              title: const Text("Skills", style: TextStyle(color: Colors.white,
                  fontSize: 19.0, fontWeight: FontWeight.bold),),
              actions: [
                passedData==null ? const SizedBox() : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _isUpdatingProfile == true ? const SpinKitCircle(color: Colors.white,size: 25,) : InkWell(
                      onTap: skillsDataToGoToCompetencies == null ? (){}:() async {
                        setState(() {
                          _isUpdatingProfile = true;
                        });
                        await Provider.of<UserProvider>(context, listen: false)
                            .updateProfile(context,
                            trustId: userData.trust['id'],
                            userType: userData.roleType,
                            skills: ids.toList()
                        ).then((_) {
                          setState(() {
                            _isUpdatingProfile = false;
                          });
                        });
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                            color: skillsDataToGoToCompetencies == null ? Colors.black26:Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: wardsStage == UsersStage.LOADING
                ?
            SizedBox(
              height: media.height,
              child: Center(child: SpinKitCircle(color: Theme.of(context).primaryColor,size: 50,),),
            )
                :
            wardsStage == UsersStage.DONE && hospitals.isNotEmpty
                ?
            SizedBox(
              height: media.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: hospitals.length,
                  itemBuilder: (context, i) {
                    // selected['${wards[i].id}'] = ;
                    _isExpanded.add(false);
                    isSelected.add(isChildSelected);
                    return expansionTileCard(
                        context: context,
                        title: "${hospitals[i].name}",
                        doExpansion: (_){
                          setState(() {
                            _isExpanded[i] = ! _isExpanded[i];
                          });
                        },
                        isExpanded: _isExpanded[i],
                        content: [
                          hospitals[i].skills.isEmpty ? const SizedBox() :ListTile(
                            title: Text("Select all", overflow: TextOverflow.ellipsis, maxLines: 2, style: style2,),
                            trailing: !selectAll[i] ? Container(width: 1.0,) : Icon(Icons.done, color: Theme.of(context).primaryColor,),
                            onTap: (){
                                // ids.clear();
                                // skillsNames.clear();
                              for(int j=0;j<hospitals[i].skills.length;j++){
                                if (selectAll[i] == true) {
                                  setState(() {
                                    if (ids.contains(hospitals[i].skills[j]['id'])) {
                                      ids.remove(hospitals[i].skills[j]['id']);
                                    }
                                    if (skillsNames.contains(hospitals[i].skills[j]['name'])) {
                                      skillsNames.remove(hospitals[i].skills[j]['name']);
                                    }

                                    selected['${hospitals[i].id}'][j] = false;
                                    skillsNames.add(hospitals[i].skills[j]['name']);
                                    skillsDataToGoToCompetencies={
                                      "skillsIds" : ids.toList(),
                                      "skillsNames" : skillsNames,
                                      // "TrustId" : trustId
                                    };
                                  });
                                }
                                else{
                                  setState(() {
                                    selected['${hospitals[i].id}'][j] = true;
                                    ids.add(hospitals[i].skills[j]['id']);
                                    Provider.of<UserProvider>(context,listen: false).setSkillsForCompletingProfile(ids.toList());
                                    skillsNames.add(hospitals[i].skills[j]['name']);
                                    skillsDataToGoToCompetencies={
                                      "skillsIds" : ids.toList(),
                                      "skillsNames" : skillsNames,
                                      // "TrustId" : trustId
                                    };
                                  });
                                }
                              }
                              setState(() {
                                selectAll[i] = !selectAll[i];
                                // isSelected[i].elementAt(index) = !isChildSelected[index];
                              });

                            },
                          ),
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: hospitals[i].skills.length,
                              itemBuilder: (context, index) {
                                isChildSelected.add(false);
                                return ClipRRect(
                                  borderRadius: index == hospitals[i].skills.length-1 ?
                                  const BorderRadius.only(
                                      bottomLeft: Radius.circular(7),
                                      bottomRight: Radius.circular(7)): BorderRadius.circular(0.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: Text("${hospitals[i].skills[index]['name']}", overflow: TextOverflow.ellipsis, maxLines: 2, style: style2,),
                                          trailing: !selected['${hospitals[i].id}'][index] ? Container(width: 1.0,) : Icon(Icons.done, color: Theme.of(context).primaryColor,),
                                          onTap: (){
                                            setState(() {
                                              selected['${hospitals[i].id}'][index] = !selected['${hospitals[i].id}'][index];
                                              if(selected['${hospitals[i].id}'][index]==true){
                                                ids.add(hospitals[i].skills[index]['id']);
                                                skillsNames.add(hospitals[i].skills[index]['name']);
                                              }
                                              else if(selected['${hospitals[i].id}'][index]==false){
                                                ids.remove(hospitals[i].skills[index]['id']);
                                                skillsNames.remove(hospitals[i].skills[index]['name']);
                                                // to update select all field
                                                if(selected['${hospitals[i].id}'].contains(false)){
                                                  selectAll[i] = false;
                                                }
                                              }
                                            });
                                            Provider.of<UserProvider>(context, listen: false).setSkillsForCompletingProfile(ids.toList());
                                            skillsDataToGoToCompetencies={
                                              "skillsIds" : ids.toList(),
                                              "skillsNames" : skillsNames,
                                              // "TrustId" : trustId
                                            };
                                          },
                                        ),
                                        index == hospitals[i].skills.length-1 ? const SizedBox() : const Divider(),
                                      ],
                                    ),
                                  ),
                                );
                              }

                          )
                        ]
                    );
                  }

              ),
            )
                :
            wardsStage == UsersStage.DONE && hospitals.isEmpty
                ?
            SizedBox(
              height: media.height,
              child: const Center(child: Text('There is no data to show for your site(s)'),),
            )
                :
            wardsStage == UsersStage.ERROR
            ?
            SizedBox(
              height: media.height,
              child: Center(
                child: InkWell(
                  onTap: (){
                    Provider.of<UserProvider>(context,listen: false).getAttributes(context: context,attributeType: 'skill').then((_) {
                      userData = Provider.of<UserProvider>(context,listen: false).userData;
                      hospitals = Provider.of<UserProvider>(context,listen: false).hospitalsForAttributes;
                      selectAll = List.filled(hospitals.length, false);

                      for(int i=0;i<hospitals.length;i++){

                        selected['${hospitals[i].id}'] = List.filled(hospitals[i].skills.length, false);
                        for (int w=0; w<hospitals[i].skills.length; w++) {
                          for (var v = 0; v<userData.skills.length; v++) {
                            if (hospitals[i].skills[w]["id"] == "${userData.skills[v]['id']}") {
                              selected['${hospitals[i].id}'][w] = true;
                              ids.add(hospitals[i].skills[w]["id"]);
                            }
                          }
                          // to set select all field
                          if(!selected['${hospitals[i].id}'].any((element) => element == false) && selected['${hospitals[i].id}'].isNotEmpty ){
                            selectAll[i] = true;
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
                )
              ),
            )
                :
                const SizedBox()


        ),
      ),
    );
  }
}