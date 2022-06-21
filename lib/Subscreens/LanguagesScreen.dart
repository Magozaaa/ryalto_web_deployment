// ignore_for_file: file_names, prefer_typing_uninitialized_variables, must_be_immutable, no_logic_in_create_state, unnecessary_string_interpolations, avoid_function_literals_in_foreach_calls, prefer_final_fields

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/HospitalModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';


class LanguagesScreen extends StatefulWidget {
  static const String routeName = "/LanguagesScreen_Screen";
  var trustId;
  var roleType;

  LanguagesScreen({Key key}) : super(key: key);

  @override
  _LanguagesScreenState createState() => _LanguagesScreenState(trustId: trustId,roleType: roleType);
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  var trustId;
  var roleType;
  _LanguagesScreenState({@required this.trustId,@required this.roleType});
  List isSelected = [];
  Map passedData = {};
  bool _isInit = true;
  int pageOffset = 0;
  var userTrustId;
  var trustIdToGetHospitals;
  final TextEditingController _searchController = TextEditingController();

  List<String> ids = [];
  List<String> languagesNames = [];
  Map<String,dynamic> skillsDataToGoToCompetencies;
  User userData;
  List languages;

  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false).getCompetencies(
      context: context,
    ).then((value) {
      languages = Provider.of<UserProvider>(context,listen: false).languages;
      isSelected = List.filled(languages.length, false);
      // print("languagesIdsForCompletingProfile : ${Provider.of<UserProvider>(context,listen: false).languagesIdsForCompletingProfile}");
      if (Provider.of<UserProvider>(context,listen: false).languagesIdsForCompletingProfile == null || Provider.of<UserProvider>(context,listen: false).languagesIdsForCompletingProfile.isEmpty) {
        for (int w=0; w < languages.length; w++) {
          for (var v = 0; v<userData.languages.length; v++) {
            if (languages[w].id == "${userData.languages[v]['id']}") {
              isSelected[w] = true;
              ids.add(languages[w].id);
            }
          }
        }
      }
      else{
        for (int w=0; w < languages.length; w++) {
          for (var v = 0; v<Provider.of<UserProvider>(context,listen: false).languagesIdsForCompletingProfile.length; v++) {
            if (languages[w].id == "${Provider.of<UserProvider>(context,listen: false).languagesIdsForCompletingProfile[v]}") {
              isSelected[w] = true;
              ids.add(languages[w].id);
            }
          }
        }
      }
    });
    // languages = Provider.of<UserProvider>(context,listen: false).languages;
    userData = Provider.of<UserProvider>(context,listen: false).userData;


       // isSelected = List.filled(languages.length, false);
       //
       //  for (int w=0; w < languages.length; w++) {
       //    for (var v = 0; v<userData.languages.length; v++) {
       //      if (languages[w].id == "${userData.languages[v]['id']}") {
       //        isSelected[w] = true;
       //        ids.add(languages[w].id);
       //      }
       //    }
       //  }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);


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

    languages.forEach((hospital) {
      if (hospital.name.toLowerCase().contains(text)) {
        setState(() {
          _searchResult.add(hospital);
        });
      }
    });

    setState(() {});
  }
  Map<String,dynamic> languagesDataToGoToCompetencies;

  bool _isUpdatingProfile= false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userDataProvider = Provider.of<UserProvider>(context);


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
                  IconButton(
                      icon: Icon(
                        passedData==null ? Icons.close:Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _isUpdatingProfile==true?(){}:(){
                        Provider.of<UserProvider>(context,listen: false).clearLanguagesForCompletingProfile();
                        Navigator.pop(context);
                        // isSelected.clear();
                      } ),
                  // const SizedBox(width: 5.0,),
                  // Provider.of<CallProvider>(context).isInACall ? returnToCallScreen(context) : const SizedBox()
                ],
              ),
              title: const Text("Languages",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                passedData==null ? const SizedBox() : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _isUpdatingProfile==true ? const SpinKitCircle(size: 25,color: Colors.white,) : InkWell(
                      onTap: () async {
                        setState(() {
                          _isUpdatingProfile = true;
                        });
                        await Provider.of<UserProvider>(context,
                            listen: false)
                            .updateProfile(context,
                          trustId: userData.trust['id'],
                          // employeeNumber: userData.employee_number,
                          userType: userData.roleType,
                          // minimumLevelId: userData.roleType == 2 ? userData.minAcceptedGrade == null ? null : userData.minAcceptedGrade['id'] : userData.minAcceptedBand == null ? null : userData.minAcceptedBand['id'],
                          // levelId: userData.roleType == 2 ? userData.grade == null ? null : userData.grade['id'] : userData.band == null ? null : userData.band['id'],
                          languages: ids

                        ).then((_) {
                          // AnalyticsManager.track('profile_languages_changed');
                          setState(() {
                            _isUpdatingProfile = false;
                          });
                        });
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                            color: languagesDataToGoToCompetencies == null ? Colors.black26:Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    )

                    ,
                  ),
                )
              ],
            ),
            body: userDataProvider.competenciesStage == UsersStage.DONE
                ?
            SizedBox(
              height: media.height,
              child: languagesWidget(context, media,
                  list: languages),
            )
                :
            userDataProvider.competenciesStage == UsersStage.LOADING
                ?
            SizedBox(
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
                    Provider.of<UserProvider>(context, listen: false).getCompetencies(
                      context: context,
                    ).then((value) {
                      languages = Provider.of<UserProvider>(context,listen: false).languages;
                      isSelected = List.filled(languages.length, false);

                      for (int w=0; w < languages.length; w++) {
                        for (var v = 0; v<userData.languages.length; v++) {
                          if (languages[w].id == "${userData.languages[v]['id']}") {
                            isSelected[w] = true;
                            ids.add(languages[w].id);
                          }
                        }
                      }
                    });
                    userData = Provider.of<UserProvider>(context,listen: false).userData;
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

  Widget languagesWidget(context, media, {list}) {
    return SizedBox(
      width: media.width,
      height: media.height,
      child: SizedBox(
        height: media.height * 0.7,
        child: list.isEmpty
            ? SizedBox(
          height: media.height,
          width: media.width,
          child: Center(child: Text('There are no Languages!',style: style2,textAlign: TextAlign.center,)),
        )
            : ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      "${list[i].name}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: style2,
                    ),
                    trailing: !isSelected[i]
                        ? const SizedBox(
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
                            languagesNames.add(list[i].name.toString());
                          }
                          else if(isSelected[i]==false){
                            ids.remove(list[i].id.toString());


                            languagesNames.remove(list[i].name.toString());
                          }
                          Provider.of<UserProvider>(context, listen: false).setLanguagesForCompletingProfile(ids);
                        });
                        languagesDataToGoToCompetencies={
                          "languagesIds" : ids,
                          "languagesNames" : languagesNames,
                          // "TrustId" : trustId
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


// class LanguagesWidget extends StatefulWidget {
//   List list;
//   List isSelected;
//   LanguagesWidget({this.list,this.isSelected});
//   @override
//   _LanguagesWidgetState createState() => _LanguagesWidgetState(list: list);
// }
//
// class _LanguagesWidgetState extends State<LanguagesWidget> {
//   List list;
//   List isSelected;
//   _LanguagesWidgetState({this.list,this.isSelected});
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context).size;
//     return Container(
//       width: media.width,
//       height: media.height,
//       child: Container(
//         height: media.height * 0.7,
//         child: list.isEmpty
//             ? Container(
//           height: media.height,
//           width: media.width,
//           child: Center(child: Text('There are no Languages!',style: style2,textAlign: TextAlign.center,)),
//         )
//             : ListView.builder(
//             shrinkWrap: true,
//             itemCount: list.length,
//             physics: AlwaysScrollableScrollPhysics(),
//             itemBuilder: (context, i) {
//               return Column(
//                 children: [
//                   ListTile(
//                     title: Text(
//                       "${list[i].name}",
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 2,
//                       style: style2,
//                     ),
//                     trailing: !isSelected[i]
//                         ? const SizedBox(
//                       width: 1.0,
//                     )
//                         : Icon(
//                       Icons.done,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     onTap: () {
//                       setState(() {
//                         isSelected[i]=!isSelected[i];
//                         if(isSelected[i]==true){
//                           ids.add(list[i].id.toString());
//                           languagesNames.add(list[i].name.toString());
//                         }
//                         else if(isSelected[i]==false){
//                           ids.remove(list[i].id.toString());
//
//
//                           languagesNames.remove(list[i].name.toString());
//                         }
//                         Provider.of<UserProvider>(context, listen: false).setLanguagesForCompletingProfile(ids);
//                       });
//                       languagesDataToGoToCompetencies={
//                         "languagesIds" : ids,
//                         "languagesNames" : languagesNames,
//                         // "TrustId" : trustId
//                       };
//                     },
//                   ),
//                   (i==list.length - 1) ? SizedBox(height: 60,):Divider(),
//                 ],
//               );
//             }
//           // }
//         ),
//       ),
//     );
//   }
// }
