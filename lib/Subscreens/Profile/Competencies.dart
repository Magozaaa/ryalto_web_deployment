// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/AreaOfWork.dart';
import 'package:rightnurse/Subscreens/LevelsScreen.dart';
import 'package:rightnurse/Subscreens/Profile/RolesScreen.dart';
import 'package:rightnurse/Subscreens/LanguagesScreen.dart';
import 'package:rightnurse/Subscreens/SkillsScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:websafe_svg/websafe_svg.dart';


class Competencies extends StatefulWidget {
  const Competencies({Key key}) : super(key: key);

  @override
  _CompetenciesState createState() => _CompetenciesState();
}

class _CompetenciesState extends State<Competencies>
    with AutomaticKeepAliveClientMixin<Competencies> {
  @override
  bool get wantKeepAlive => true;


  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false).getCompetencies(
        context: context,
    );
    AnalyticsManager.track('screen_profile_edit_competencies');
    super.initState();
  }

  Map<String, dynamic> skillsFromMemberSkillsScreen;
  Map<String, dynamic> languagesFromMemberSkillsScreen;
  Map<String, dynamic> wardsFromAOWsScreen;
  Map<String, dynamic> rolesFromAOWsScreen;

  void _awaitReturnValueFromSkillsScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.pushNamed(context, SkillsScreen.routeName,
        arguments: {
          "screen_title": "Skills",
          "screen_content": "Skills",
          "trustId": null
        });
    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      skillsFromMemberSkillsScreen = result;
    });
  }

  void _awaitReturnValueFromLanguagesScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.pushNamed(context, LanguagesScreen.routeName,
        arguments: {
          "screen_title": "Languages",
          "screen_content": "Languages",
          "trustId": null
        });
    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      languagesFromMemberSkillsScreen = result;
    });
  }

  void _awaitReturnValueFromWardsScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.pushNamed(context, AreaOfWork.routeName,
        arguments: {
          "screen_title": "AreaOfWork",
          "screen_content": "AreaOfWork",
          "trustId": null
        });
    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      wardsFromAOWsScreen = result;
    });
  }

  void _awaitReturnValueFromRolesScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.pushNamed(context, RolesScreen.routeName,
        arguments: {
          "screen_title": "Roles",
          "screen_content": "Roles",
          "trustId": null
        });
    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      rolesFromAOWsScreen = result;
    });
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);

    return ListView(
      children: [
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 2.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Preferences",
                style: style1,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Material(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child:  InkWell(
                onTap: (userData.userData.roleType == 2 && userData.userData.grade != null) || (userData.userData.roleType != 2 && userData.userData.band != null) ?
                    () => Navigator.push(context, MaterialPageRoute(builder: (context)=>LevelsScreen(screen_title: Provider.of<UserProvider>(context, listen: false).userData.roleType == 2 ? "Minimum Accepted Grade" : "Minimum Accepted Level",section: "Bands",)))
                    :
                    null,
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 1.0),
                        child: WebsafeSvg.asset("images/min-level.svg", height: 25.0, width: 25.0,
                            color: (userData.userData.roleType == 2 && userData.userData.grade != null) || (userData.userData.roleType != 2 && userData.userData.band != null) ? Theme.of(context).primaryColor : Colors.grey)),
                    const SizedBox(
                      width: 12.0,
                    ),
                    Text(Provider.of<UserProvider>(context, listen: false).userData.roleType == 2 ?  "Min Accepted Grade" : "Min Accepted Level",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: (userData.userData.roleType == 2 && userData.userData.grade != null) || (userData.userData.roleType != 2 && userData.userData.band != null) ? style2 : style3),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        userData.userData.roleType == 2 && userData.userData.minAcceptedGrade == null
                            ? const SizedBox() :
                        userData.userData.roleType != 2 && userData.userData.minAcceptedBand == null
                            ? const SizedBox() :
                        Text(
                          "${userData.userData.roleType == 2 ?
                          userData.userData.minAcceptedGrade["name"] : userData.userData.minAcceptedBand["name"]}",
                          style: styleBlue2,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Icon( Icons.edit_rounded,
                          color: (userData.userData.roleType == 2 && userData.userData.grade != null) || (userData.userData.roleType != 2 && userData.userData.band != null) ? Theme.of(context).primaryColor : Colors.grey,
                          size: 20.0,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 2.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Work Details",
                style: style1,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Material(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
            elevation: 2.0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>LevelsScreen(screen_title: Provider.of<UserProvider>(context, listen: false).userData.roleType == 2 ? "Grade" : "Level" ,section: "Bands",))),
                    child: Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 1.0),
                            child: WebsafeSvg.asset("images/level-filled.svg", height: 25.0, width: 25.0,
                                color: Theme.of(context).primaryColor)),
                        const SizedBox(
                          width: 12.0,
                        ),
                        Text(Provider.of<UserProvider>(context, listen: false).userData.roleType == 2 ? "Grade" : "Level",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: style2),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            userData.userData.roleType == 2 && userData.userData.grade == null
                                ? const SizedBox() :
                            userData.userData.roleType != 2 && userData.userData.band == null
                                ? const SizedBox() :
                            Text(
                                    "${userData.userData.roleType == 2 ?
                                    userData.userData.grade["name"] : userData.userData.band["name"]}",
                                    style: styleBlue2,
                                  ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            Icon(
                              Icons.edit_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 20.0,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: userData.userData.wards.isEmpty? CrossAxisAlignment.center:CrossAxisAlignment.start,
                    children: [
                      WebsafeSvg.asset("images/area-of-work-filled.svg", height: 25.0, width: 25.0,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Areas of Work",
                              style: style2,
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: userData.userData.wards.isEmpty?0.0: 5.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: media.width*0.6,
                                      child: Wrap(
                                        children: userData.userData.wards
                                            .map((item) => Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor.withOpacity(0.6),
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(item["name"],
                                                        style: const TextStyle(
                                                            color: Colors.white)),
                                                  ],
                                                ),
                                              )),
                                        ))
                                            .toList()
                                            .cast<Widget>(),
                                      ),
                                    )
                                )),
                          ],
                        ),
                      ),
                      // Spacer(),
                      GestureDetector(
                          onTap: () {
                            _awaitReturnValueFromWardsScreen(context);
                            },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(),
                              // Text(" Add More", style: styleBlue2,),
                              Material(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.blue[200].withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 11.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(userData.userData.wards != null && userData.userData.wards.isNotEmpty ?"add more " : "add  ",
                                      style: TextStyle(color: Theme.of(context).primaryColor),),
                                      Icon(
                                        Icons.add,
                                        color: Theme.of(context).primaryColor,
                                        size: 20.0,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ))
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 2.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Others",
                style: style1,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Material(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
            elevation: 2.0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 1.0),
                          child: WebsafeSvg.asset("images/skills-filled.svg", height: 25.0, width: 25.0,
                              color: Theme.of(context).primaryColor)),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Skills",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: style2),
                            Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: media.width*0.6,
                                    child: Wrap(
                                      children: userData.userData.skills
                                          .map((item) => Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withOpacity(0.6),
                                              borderRadius:
                                              BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(6.0),
                                              child: Row(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                children: [
                                                  Text(item["name"],
                                                      style: const TextStyle(
                                                          color:
                                                          Colors.white)),

                                                ],
                                              ),
                                            )),
                                      ))
                                          .toList()
                                          .cast<Widget>(),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      // Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                            onTap: () {
                              _awaitReturnValueFromSkillsScreen(context);
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(12.0),
                              color: Colors.blue[200].withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 11.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(userData.userData.skills != null && userData.userData.skills.isNotEmpty ?"add more " : "add  ",
                                      style: TextStyle(color: Theme.of(context).primaryColor),),
                                    Icon(
                                      Icons.add,
                                      color: Theme.of(context).primaryColor,
                                      size: 20.0,
                                    )
                                  ],
                                ),
                              ),
                            )),
                      )
                    ],
                  ),

                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 1.0),
                          child: WebsafeSvg.asset("images/language-filled.svg", height: 25.0, width: 25.0,
                              color: Theme.of(context).primaryColor)),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Languages",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: style2),
                            Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: media.width*0.6,
                                    child: Wrap(
                                      children: userData.userData.languages
                                          .map((item) => Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withOpacity(0.6),
                                              borderRadius:
                                              BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(6.0),
                                              child: Row(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                children: [
                                                  Text(item["name"],
                                                      style: const TextStyle(
                                                          color:
                                                          Colors.white)),

                                                ],
                                              ),
                                            )),
                                      ))
                                          .toList()
                                          .cast<Widget>(),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            _awaitReturnValueFromLanguagesScreen(context);
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.blue[200].withOpacity(0.5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 11.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(userData.userData.languages != null && userData.userData.languages.isNotEmpty ?"add more " : "add  ",
                                    style: TextStyle(color: Theme.of(context).primaryColor),),
                                  Icon(
                                    Icons.add,
                                    color: Theme.of(context).primaryColor,
                                    size: 20.0,
                                  )
                                ],
                              ),
                            ),
                          )
                      )
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        needHelp(context)
      ],
    );
  }
}
