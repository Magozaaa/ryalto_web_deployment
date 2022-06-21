// ignore_for_file: file_names, unnecessary_string_interpolations

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/HospitalModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class RolesScreen extends StatefulWidget{

  static const String routeName = "/RolesScreen_Screen";

  const RolesScreen({Key key}) : super(key: key);

  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {

  Map<String,dynamic> selected ={};
  List<bool> selectAll = [];

  Map passedData = {};
  var _isInit = true;

  List<bool> _isExpanded = [];

  List<HospitalForUserAttributes> hospitals = [];
  Set<String> ids = {};
  List<String> positionsNames = [];
  Map<String,dynamic> positionsDataToGoToCompetencies;
  User userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<UserProvider>(context, listen: false).getCompetencies(
      context: context,
    ).then((value) {
      Provider.of<UserProvider>(context,listen: false).getAttributes(context: context,attributeType: 'position').then((_) {
        userData = Provider.of<UserProvider>(context,listen: false).userData;
        hospitals = Provider.of<UserProvider>(context,listen: false).hospitalsForAttributes;
        selectAll = List.filled(hospitals.length, false);

        // to check selected role when press previous page in complete profile
        if (Provider.of<UserProvider>(context,listen: false).rolesIdsForCompletingProfile == null || Provider.of<UserProvider>(context,listen: false).rolesIdsForCompletingProfile.isEmpty ) {
          for(int i=0;i<hospitals.length;i++){

            selected['${hospitals[i].id}'] = List.filled(hospitals[i].positions.length, false);

            for (int w=0; w<hospitals[i].positions.length; w++) {
              for (var v = 0; v<userData.roles.length; v++) {
                if (hospitals[i].positions[w]["id"] == "${userData.roles[v]['id']}") {
                  selected['${hospitals[i].id}'][w] = true;
                  ids.add(hospitals[i].positions[w]["id"]);
                }
              }
            }
            if(!selected['${hospitals[i].id}'].any((element) => element == false) && selected['${hospitals[i].id}'].isNotEmpty ){
              selectAll[i] = true;
            }
          }
        }
        else{
          for(int i=0;i<hospitals.length;i++){

            selected['${hospitals[i].id}'] = List.filled(hospitals[i].positions.length, false);

            for (int w=0; w<hospitals[i].positions.length; w++) {
              for (var v = 0; v<Provider.of<UserProvider>(context,listen: false).rolesIdsForCompletingProfile.length; v++) {
                if (hospitals[i].positions[w]["id"] == "${Provider.of<UserProvider>(context,listen: false).rolesIdsForCompletingProfile[v]}") {
                  selected['${hospitals[i].id}'][w] = true;
                  ids.add(hospitals[i].positions[w]["id"]);
                }
              }
            }
            if(!selected['${hospitals[i].id}'].any((element) => element == false) && selected['${hospitals[i].id}'].isNotEmpty ){
              selectAll[i] = true;
            }
          }
        }
      });
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

  bool _isUpdatingProfile=false;

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final hospitalsStage = Provider.of<UserProvider>(context).hospitalsStage;


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
              leadingWidth: 120,
              leading: Row(
                children: [
                  IconButton(icon: Icon(passedData==null ? Icons.close:Icons.arrow_back_ios_rounded, color: Colors.white,),
                      onPressed: _isUpdatingProfile==true?(){}:() {
                        Provider.of<UserProvider>(context, listen: false).clearRolesForCompletingProfile();
                        Navigator.pop(context);

                      }),
                  //const SizedBox(width: 5.0,),
                  //Provider.of<CallProvider>(context).isInACall ? returnToCallScreen(context) : const SizedBox()
                ],
              ),
              actions: [
                passedData==null
                    ?
                const SizedBox()
                    :
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _isUpdatingProfile == true ? SpinKitCircle(color: Colors.white,size: 25,)
                        :
                    InkWell(
                      onTap: positionsDataToGoToCompetencies == null
                          ?
                          (){}
                          :
                          () async {
                        setState(() {
                          _isUpdatingProfile = true;
                        });
                        await Provider.of<UserProvider>(context,
                            listen: false).updateProfile(context,
                            trustId: userData.trust['id'],
                            userType: userData.roleType,
                            roles: ids.toList()
                        ).then((_) {
                          setState(() {
                            _isUpdatingProfile = false;
                          });
                        });
                      },
                      child: Text("Done", style: TextStyle(
                          color: positionsDataToGoToCompetencies == null ? Colors.black26:Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                      )
                    ),
                  ),
                )
              ],
              title: Text(Provider.of<UserProvider>(context, listen: false).userData.roleType == 2
                  ?
              'Specialities'
                  :
              "Positions" ,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: hospitalsStage == UsersStage.LOADING
                ?
            Container(
              height: media.height,
              child: Center(child: SpinKitCircle(color: Theme.of(context).primaryColor,size: 50,),),
            )
                :
            hospitalsStage == UsersStage.DONE && hospitals.isNotEmpty
                ?

            Container(
              height: media.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: hospitals.length,
                  itemBuilder: (context, i) {
                    _isExpanded.add(false);
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
                          hospitals[i].positions.isEmpty
                              ?
                          const SizedBox()
                              :
                          ListTile(
                            title: Text("Select all", overflow: TextOverflow.ellipsis, maxLines: 2, style: style2,),
                            trailing: !selectAll[i] ? const SizedBox(width: 1.0,) : Icon(Icons.done, color: Theme.of(context).primaryColor,),
                            onTap: (){
                              // ids.clear();
                              // positionsNames.clear();
                              for(int j=0;j<hospitals[i].positions.length;j++){
                                if (selectAll[i] == true) {
                                  setState(() {
                                    if (ids.contains(hospitals[i].positions[j]['id'])) {
                                      ids.remove(hospitals[i].positions[j]['id']);
                                    }
                                    if (positionsNames.contains(hospitals[i].positions[j]['name'])) {
                                      positionsNames.remove(hospitals[i].positions[j]['name']);
                                    }
                                    selected['${hospitals[i].id}'][j] = false;
                                    positionsDataToGoToCompetencies={
                                      "positionsIds" : ids.toList(),
                                      "positionsNames" : positionsNames,
                                      // "TrustId" : trustId
                                    };
                                  });
                                }
                                else{
                                  setState(() {
                                    selected['${hospitals[i].id}'][j] = true;
                                    ids.add(hospitals[i].positions[j]['id']);
                                    positionsNames.add(hospitals[i].positions[j]['name']);
                                    positionsDataToGoToCompetencies={
                                      "positionsIds" : ids.toList(),
                                      "positionsNames" : positionsNames,
                                      // "TrustId" : trustId
                                    };
                                  });
                                }

                              }
                              Provider.of<UserProvider>(context, listen: false).setRolesForCompletingProfile(ids.toList());
                              print('${Provider.of<UserProvider>(context,listen: false).rolesIdsForCompletingProfile}');
                              print('${Provider.of<UserProvider>(context,listen: false).levelForCompletingProfile}');
                              print('${Provider.of<UserProvider>(context,listen: false).minAcceptedLevelForCompletingProfile}');
                              print('${Provider.of<UserProvider>(context,listen: false).areaOfWorkIdsForCompletingProfile}');
                              print('${Provider.of<UserProvider>(context,listen: false).languagesIdsForCompletingProfile}');
                              setState(() {
                                selectAll[i] = !selectAll[i];
                              });


                            },
                          ),
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: hospitals[i].positions.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: index == hospitals[i].positions.length-1
                                      ?
                                  BorderRadius.only(
                                      bottomLeft: Radius.circular(7),
                                      bottomRight: Radius.circular(7)
                                  )
                                      :
                                  BorderRadius.circular(0.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: Text("${hospitals[i].positions[index]['name']}", overflow: TextOverflow.ellipsis, maxLines: 2, style: style2,),
                                          trailing: !selected['${hospitals[i].id}'][index] ? Container(width: 1.0,) : Icon(Icons.done, color: Theme.of(context).primaryColor,),
                                          onTap: (){
                                            setState(() {
                                              selected['${hospitals[i].id}'][index] = !selected['${hospitals[i].id}'][index];
                                              if(selected['${hospitals[i].id}'][index]==true){
                                                ids.add(hospitals[i].positions[index]['id']);
                                                positionsNames.add(hospitals[i].positions[index]['name']);
                                              }
                                              else{
                                                ids.remove(hospitals[i].positions[index]['id']);
                                                positionsNames.remove(hospitals[i].positions[index]['name']);

                                                if(selected['${hospitals[i].id}'].contains(false)){
                                                  selectAll[i] = false;
                                                }
                                              }
                                              Provider.of<UserProvider>(context, listen: false).setRolesForCompletingProfile(ids.toList());
                                            });
                                            positionsDataToGoToCompetencies={
                                              "positionsIds" : ids.toList(),
                                              "positionsNames" : positionsNames,
                                              // "TrustId" : trustId
                                            };
                                          },
                                        ),
                                        index == hospitals[i].positions.length-1 ? Container(): Divider(),
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
            hospitalsStage == UsersStage.ERROR
                ?
            Container(
              height: media.height,
              child: Center(
                child: InkWell(
                  onTap: (){
                    Provider.of<UserProvider>(context, listen: false).getCompetencies(
                      context: context,
                    ).then((value) {
                      Provider.of<UserProvider>(context,listen: false).getAttributes(context: context,attributeType: 'position').then((_) {
                        userData = Provider.of<UserProvider>(context,listen: false).userData;
                        hospitals = Provider.of<UserProvider>(context,listen: false).hospitalsForAttributes;
                        selectAll = List.filled(hospitals.length, false);

                        for(int i=0;i<hospitals.length;i++){

                          selected['${hospitals[i].id}'] = List.filled(hospitals[i].positions.length, false);

                          for (int w=0; w<hospitals[i].positions.length; w++) {
                            for (var v = 0; v<userData.roles.length; v++) {
                              if (hospitals[i].positions[w]["id"] == "${userData.roles[v]['id']}") {
                                selected['${hospitals[i].id}'][w] = true;
                                ids.add(hospitals[i].positions[w]["id"]);
                              }
                            }
                          }
                          if(!selected['${hospitals[i].id}'].any((element) => element == false) && selected['${hospitals[i].id}'].isNotEmpty ){
                            selectAll[i] = true;
                          }
                        }
                      });
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
          hospitalsStage == UsersStage.DONE && hospitals.isEmpty
              ?
          Container(
            height: media.height,
            child: Center(child: Text('There is no data to show for your site(s)'),),
          )

                :
          const SizedBox()

        ),
      ),
    );
  }
}