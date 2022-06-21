import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Chat/NewAnnouncement.dart';
import 'package:rightnurse/Subscreens/Directory/ListFilterSheet.dart';
import 'package:rightnurse/Subscreens/Directory/UserTypeFilterSheet.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:websafe_svg/websafe_svg.dart';

void showModalFilterSheet(BuildContext context, ScrollController singleChildScrollViewController, String searchText,{bool isAnnouncement = false, int defaultUserType, String groupId}) {
  final animationDuration = 175;
  final showResultsButtonHeight = 85.0;
  double userTypeSelectorLeft = 0.0;
  double languagesSelectorLeft = 0.0;
  double membershpsSelectorLeft = 0.0;
  double gradesSelectorLeft = 0.0;
  double skillsSelectorLeft = 0.0;
  double areasOfWorkSelectorLeft = 0.0;
  double specialtyPositionsSelectorLeft = 0.0;
  bool isShowingOptionsPanel = false;
  bool isMoreOptionsExpanded = false;
  double w = MediaQuery.of(context).size.width;
  double h = MediaQuery.of(context).size.height;
  int filterUserType = 0;
  String buttonText = 'No Results';
  Color buttonColor = Colors.grey;
  bool fetchingResult = true;
  int numberOfResults = 0;


  final discoveryProvider = Provider.of<DiscoveryProvider>(context, listen: false);

  Map<String, String> languagesMap = discoveryProvider.orderedLanguagesMap;
  Map<String, String> membershipsMap = discoveryProvider.orderedMembershipsMap;
  Map<String, String> gradesMap = discoveryProvider.orderedGradesMap;
  Map<String, String> bandsMap = discoveryProvider.orderedBandsMap;

  // set the active filters to the current filters
  discoveryProvider.copyFilterParametersToActiveFilterParameters();
  filterUserType =
      // Provider.of<UserProvider>(context, listen: false).userData.roleType;
  discoveryProvider.activeFilteringParameters.roleType;

  userTypeSelectorLeft = w;
  languagesSelectorLeft = w;
  membershpsSelectorLeft = w;
  gradesSelectorLeft = w;
  skillsSelectorLeft = w;
  areasOfWorkSelectorLeft = w;
  specialtyPositionsSelectorLeft = w;

  String fetchUserRoleText() {
    switch (filterUserType) {
      case 0:
        return 'Any';
      case 2:
        return 'Doctor';
      case 1:
        return 'Clinical';
      case 3:
        return 'Non-clinical';
    }
    return '';
  }

  String fetchLanguagesText() {
    String ret = '';
    if (discoveryProvider.activeFilteringParameters.languageIds.length > 0) {
      ret = '${discoveryProvider.activeFilteringParameters.languageIds.length} selected';
    } else {
      ret = 'Any';
    }

    return ret;
  }

  String fetchMembershipsText() {
    String ret = '';
    if (discoveryProvider.activeFilteringParameters.membershipIds.length > 0) {
      ret = '${discoveryProvider.activeFilteringParameters.membershipIds.length} selected';
    } else {
      ret = 'Any';
    }

    return ret;
  }

  String fetchAreasOfWorkText() {
    String ret = '';
    if (discoveryProvider.activeFilteringParameters.areasOfWorkIds.length > 0) {
      ret = '${discoveryProvider.activeFilteringParameters.areasOfWorkIds.length} selected';
    } else {
      ret = 'Any';
    }

    return ret;
  }

  String fetchSpecialtyText() {
    String ret = '';
    if (discoveryProvider.activeFilteringParameters.roleIds.length > 0) {
      ret = '${discoveryProvider.activeFilteringParameters.roleIds.length} selected';
    } else {
      ret = 'Any';
    }

    return ret;
  }

  String fetchSkillsText() {
    String ret = '';
    if (discoveryProvider.activeFilteringParameters.skillsIds.length > 0) {
      ret = '${discoveryProvider.activeFilteringParameters.skillsIds.length} selected';
    } else {
      ret = 'Any';
    }

    return ret;
  }

  String fetchGradesOrLevelsText() {
    String ret = 'Any';
    if (//discoveryProvider.activeFilteringParameters.roleType
    filterUserType == 2/*kUserTypeDoctor*/) {
      if (discoveryProvider.activeFilteringParameters.gradeIds.length > 0) {
        ret = '${discoveryProvider.activeFilteringParameters.gradeIds.length} selected';
      }
    } else {
      if (discoveryProvider.activeFilteringParameters.bandIds.length > 0) {
        ret = '${discoveryProvider.activeFilteringParameters.bandIds.length} selected';
      }
    }
    return ret;
  }

  String getGradeLevelText() {
    String ret = 'Grade';
    if (//discoveryProvider.activeFilteringParameters.roleType
    filterUserType != 2/*kUserTypeDoctor*/) {
      ret = 'Level';
    }

    return ret;
  }

  Future<void> updatedFilteredResults() async {
    final userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    final countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
    final userHospitalsIds = Provider.of<UserProvider>(context, listen: false).hospitalIds;
    final userMembershipsIds = Provider.of<UserProvider>(context, listen: false).membershipIds;
      await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
          pageOffset: 0,
          trustId: userTrustId,
          countryCode: countryCode,
          hospitalsIds: userHospitalsIds,
          membershipsIds: userMembershipsIds,
          initialLoad: false,
          defaultUserType: Provider.of<UserProvider>(context, listen: false).userData.roleType,
          useActiveFilters: true,
          groupId: groupId ?? "",
          searchText: searchText);

  }

  String getUpdateButtonText() {
    String text = '';
    buttonColor = Colors.white;
    if (numberOfResults > 1000) {
      text = '1000+ Results';
    } else if (numberOfResults > 100) {
      text = '100+ Results';
    } else if (numberOfResults > 1) {
      text = '$numberOfResults Results';
    } else if (numberOfResults == 1) {
      text = '$numberOfResults Result';
    } else {
      text = 'No Results';
      buttonColor = Colors.grey;
    }

    return text;
  }

  bool _isInit = true;

  // kIsWeb ? showAnimatedCustomDialog(
  //   context,
  //
  // )
  //     :

  if (kIsWeb) {
    showAnimatedCustomDialog(context,
        title: "Error", message: "responseMap",
      statefulBuilder: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        if(_isInit){
          updatedFilteredResults().then((_){
            setState(() {
              numberOfResults = discoveryProvider.activeFilterUserCount;
              buttonText = getUpdateButtonText();
              fetchingResult = false;
              _isInit = false;
            });
          });
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: AnimatedContainer(
              alignment: AlignmentDirectional.center,
              duration: Duration(milliseconds: animationDuration),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20)
              ),
              height: h * 0.55,
              width: w * 0.5,
              child: Stack(
                children: [
                  Container(
                    height: h ,
                    width: w ,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12.0),
                          ListTile(
                            leading: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                              color: Colors.blue,
                              iconSize: 32,
                            ),
                            title: Center(
                                child: Text(
                                  'Filter',
                                  style: Theme.of(context).textTheme.headline6,
                                )),
                            trailing: TextButton(
                              onPressed: () async {
                                setState(() {
                                  numberOfResults = 0;
                                  fetchingResult = true;
                                  discoveryProvider.resetActiveFilters(context);
                                  filterUserType = discoveryProvider.activeFilteringParameters.roleType;
                                });
                                await updatedFilteredResults();
                                setState(() {
                                  numberOfResults = discoveryProvider.activeFilterUserCount;
                                  buttonText = getUpdateButtonText();
                                  fetchingResult = false;
                                });
                              },
                              child: Text('Clear', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.blue)),
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: (animationDuration * 0.75).round()),
                            height: h ,
                            // color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 8.0),
                                  child: Text('Profession', style: Theme.of(context).textTheme.headline6),
                                ),
                                const SizedBox(height: 4.0),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 2.0),
                                    child: Scrollbar(
                                      controller: singleChildScrollViewController,
                                      thickness: 2,
                                      isAlwaysShown: isMoreOptionsExpanded,
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        controller: singleChildScrollViewController,
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Column(
                                            children: [
                                              // User type
                                              InkWell(
                                                onTap: fetchingResult
                                                    ? null
                                                    : () {
                                                  setState(() {
                                                    userTypeSelectorLeft = 0.0;
                                                    isShowingOptionsPanel = true;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      WebsafeSvg.asset(
                                                        "images/user-detail-filled.svg",
                                                        height: 25,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                      // SvgPicture.asset(
                                                      //   "images/user-detail-filled.svg",
                                                      //   color: Theme.of(context).primaryColor,
                                                      //   height: 25.0,
                                                      //   width: 25.0,
                                                      // ),
                                                      const SizedBox(width: 12.0),
                                                      Text('User type', style: Theme.of(context).textTheme.bodyText1),
                                                      const Spacer(),
                                                      Text(fetchUserRoleText(),
                                                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                              color: filterUserType == 0 ? Colors.grey : Colors.blue)),
                                                      const SizedBox(width: 6.0),
                                                      Icon(Icons.arrow_forward_ios, size: 16.0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Specialty
                                              Opacity(
                                                opacity: filterUserType == 0 ? 0.4 : 1.0,
                                                child: InkWell(
                                                  onTap: filterUserType == 0 || fetchingResult
                                                      ? null
                                                      : () {
                                                    setState(() {
                                                      specialtyPositionsSelectorLeft = 0.0;
                                                      isShowingOptionsPanel = true;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        WebsafeSvg.asset(
                                                          "images/role-filled.svg",
                                                          height: 25,
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                        // SvgPicture.asset(
                                                        //   "images/role-filled.svg",
                                                        //   color: Theme.of(context).primaryColor,
                                                        //   height: 25.0,
                                                        //   width: 25.0,
                                                        // ),
                                                        const SizedBox(width: 12.0),
                                                        Text(
                                                            filterUserType == 2
                                                                ? 'Specialty'
                                                                : 'Position',
                                                            style: Theme.of(context).textTheme.bodyText1),
                                                        const Spacer(),
                                                        Text(fetchSpecialtyText(),
                                                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                color: (fetchSpecialtyText() == 'Any')
                                                                    ? Colors.grey
                                                                    : Colors.blue)),
                                                        const SizedBox(width: 6.0),
                                                        Icon(Icons.arrow_forward_ios, size: 16.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Areas of work
                                              InkWell(
                                                onTap: fetchingResult
                                                    ? null
                                                    : () {
                                                  setState(() {
                                                    areasOfWorkSelectorLeft = 0.0;
                                                    isShowingOptionsPanel = true;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      WebsafeSvg.asset(
                                                        "images/area-of-work-filled.svg",
                                                        height: 25,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                      // SvgPicture.asset(
                                                      //   "images/area-of-work-filled.svg",
                                                      //   color: Theme.of(context).primaryColor,
                                                      //   height: 25.0,
                                                      //   width: 25.0,
                                                      // ),
                                                      const SizedBox(width: 12.0),
                                                      Text('Areas of work', style: Theme.of(context).textTheme.bodyText1),
                                                      const Spacer(),
                                                      Text(fetchAreasOfWorkText(),
                                                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                              color: (fetchAreasOfWorkText() == 'Any')
                                                                  ? Colors.grey
                                                                  : Colors.blue)),
                                                      const SizedBox(width: 6.0),
                                                      Icon(Icons.arrow_forward_ios, size: 16.0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Memberships
                                              Opacity(
                                                opacity: filterUserType == 0 ? 0.4 : 1.0,
                                                child: InkWell(
                                                  onTap: filterUserType == 0 || fetchingResult
                                                      ? null
                                                      : () {
                                                    setState(() {
                                                      membershpsSelectorLeft = 0.0;
                                                      isShowingOptionsPanel = true;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Transform.scale(
                                                          scale: 1.2,
                                                          child: WebsafeSvg.asset(
                                                            "images/membership-filled.svg",
                                                            height: 25,
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12.0),
                                                        Text('Memberships', style: Theme.of(context).textTheme.bodyText1),
                                                        const Spacer(),
                                                        Text(fetchMembershipsText(),
                                                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                color: (fetchMembershipsText() == 'Any')
                                                                    ? Colors.grey
                                                                    : Colors.blue)),
                                                        const SizedBox(width: 6.0),
                                                        Icon(Icons.arrow_forward_ios, size: 16.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2.0),
                                              const Divider(),
                                              const SizedBox(height: 8.0),
                                              Container(
                                                color: Colors.grey[200],
                                                child: GroovinExpansionTile(
                                                  onExpansionChanged: (bool expanded) {
                                                    if (expanded) {
                                                      singleChildScrollViewController.animateTo(
                                                          singleChildScrollViewController.position.maxScrollExtent + 64,
                                                          duration: Duration(milliseconds: 350),
                                                          curve: Curves.easeIn);
                                                    }
                                                    setState(() {
                                                      isMoreOptionsExpanded = expanded;
                                                    });
                                                  },
                                                  defaultTrailingIconColor: Theme.of(context).primaryColor,
                                                  title: Text('More Options',
                                                      style: TextStyle(color: Color(0xff616161), fontSize: 17.0)),
                                                  children: [
                                                    // grade
                                                    Container(
                                                      color: Colors.white,
                                                      child: Column(
                                                        children: [
                                                          Opacity(
                                                            opacity: filterUserType == 0 ? 0.4 : 1.0,
                                                            child: InkWell(
                                                              onTap: filterUserType == 0 || fetchingResult
                                                                  ? null
                                                                  : () {
                                                                setState(() {
                                                                  gradesSelectorLeft = 0.0;
                                                                  isShowingOptionsPanel = true;
                                                                });
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    WebsafeSvg.asset(
                                                                      "images/level-filled.svg",
                                                                      height: 25,
                                                                      color: Theme.of(context).primaryColor,
                                                                    ),
                                                                    // SvgPicture.asset(
                                                                    //   "images/level-filled.svg",
                                                                    //   color: Theme.of(context).primaryColor,
                                                                    //   height: 25.0,
                                                                    //   width: 25.0,
                                                                    // ),
                                                                    const SizedBox(width: 12.0),
                                                                    Text(getGradeLevelText(),
                                                                        style: Theme.of(context).textTheme.bodyText1),
                                                                    const Spacer(),
                                                                    Text(fetchGradesOrLevelsText(),
                                                                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                            color: (fetchGradesOrLevelsText() == 'Any')
                                                                                ? Colors.grey
                                                                                : Colors.blue)),
                                                                    const SizedBox(width: 6.0),
                                                                    Icon(Icons.arrow_forward_ios, size: 16.0),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const Divider(),
                                                        ],
                                                      ),
                                                    ),
                                                    // languages
                                                    Container(
                                                      color: Colors.white,
                                                      child: Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: fetchingResult
                                                                ? null
                                                                : () {
                                                              setState(() {
                                                                languagesSelectorLeft = 0.0;
                                                                isShowingOptionsPanel = true;
                                                              });
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  WebsafeSvg.asset(
                                                                    "images/language-filled.svg",
                                                                    height: 25,
                                                                    color: Theme.of(context).primaryColor,
                                                                  ),
                                                                  // SvgPicture.asset(
                                                                  //   "images/language-filled.svg",
                                                                  //   color: Theme.of(context).primaryColor,
                                                                  //   height: 25.0,
                                                                  //   width: 25.0,
                                                                  // ),
                                                                  const SizedBox(width: 12.0),
                                                                  Text('Languages',
                                                                      style: Theme.of(context).textTheme.bodyText1),
                                                                  const Spacer(),
                                                                  Text(fetchLanguagesText(),
                                                                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                          color: (fetchLanguagesText() == 'Any')
                                                                              ? Colors.grey
                                                                              : Colors.blue)),
                                                                  const SizedBox(width: 6.0),
                                                                  Icon(Icons.arrow_forward_ios, size: 16.0),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const Divider(),
                                                        ],
                                                      ),
                                                    ),
                                                    // skills
                                                    Container(
                                                      color: Colors.white,
                                                      child: Opacity(
                                                        opacity: filterUserType == 0 ? 0.4 : 1.0,
                                                        child: InkWell(
                                                          onTap: filterUserType == 0 || fetchingResult
                                                              ? null
                                                              : () {
                                                            setState(() {
                                                              skillsSelectorLeft = 0.0;
                                                              isShowingOptionsPanel = true;
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                WebsafeSvg.asset(
                                                                  "images/skills-filled.svg",
                                                                  height: 25,
                                                                  color: Theme.of(context).primaryColor,
                                                                ),
                                                                // SvgPicture.asset(
                                                                //   "images/skills-filled.svg",
                                                                //   color: Theme.of(context).primaryColor,
                                                                //   height: 25.0,
                                                                //   width: 25.0,
                                                                // ),
                                                                const SizedBox(width: 12.0),
                                                                Text('Skills', style: Theme.of(context).textTheme.bodyText1),
                                                                const Spacer(),
                                                                Text(fetchSkillsText(),
                                                                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                        color: (fetchSkillsText() == 'Any')
                                                                            ? Colors.grey
                                                                            : Colors.blue)),
                                                                const SizedBox(width: 6.0),
                                                                Icon(Icons.arrow_forward_ios, size: 16.0),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (isMoreOptionsExpanded)
                                                      Container(color: Colors.white, height: showResultsButtonHeight + 12.0),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // user type
                  AnimatedPositioned(
                    top: 0.0,
                    left: userTypeSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: UserTypeFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      fetchParentRole: () {
                        return filterUserType;
                      },
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          userTypeSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (int newUserRole) async {
                        setState(() {
                          numberOfResults = 0;
                          filterUserType = newUserRole;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        // reset filters global filters...
                        discoveryProvider.resetActiveFilteringParameters(context);
                        // save to "global" filters
                        discoveryProvider.activeFilteringParameters.roleType = filterUserType;
                        // now have to refetch memberships & competencies
                        final userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
                        final countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
                        await discoveryProvider.fetchAvailablePositions(context,
                            trustId: userTrustId, countryCode: countryCode, roleType: filterUserType, notify: false,profileUpdate: false);
                        await discoveryProvider.fetchAvailablePositions(context,
                            countryCode: countryCode, roleType: filterUserType, notify: false,profileUpdate: false);
                        await discoveryProvider.fetchMemberships(context,
                            countryCode: countryCode, roleType: filterUserType, notify: false);
                        await discoveryProvider.fetchGradesBandsLanguagesAndSkills(context,
                            trustId: userTrustId, countryCode: countryCode, roleType: filterUserType, notify: false);
                        // reset maps the maps with (potentially) new data...
                        setState(() {
                          languagesMap = discoveryProvider.orderedLanguagesMap;
                          membershipsMap = discoveryProvider.orderedMembershipsMap;
                          gradesMap = discoveryProvider.orderedGradesMap;
                          bandsMap = discoveryProvider.orderedBandsMap;
                        });
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          filterUserType = newUserRole;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // roles / specialty
                  AnimatedPositioned(
                    top: 0.0,
                    left: specialtyPositionsSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: //discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2 ? 'Specialty' : 'Position',
                      items: discoveryProvider.orderedAvailablePositionsMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.roleIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          specialtyPositionsSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.roleIds = newIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // areas of work
                  AnimatedPositioned(
                    top: 0.0,
                    left: areasOfWorkSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Areas of Work',
                      items: discoveryProvider.orderedAreasOfWorkMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.areasOfWorkIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          areasOfWorkSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.areasOfWorkIds = newIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // languages
                  AnimatedPositioned(
                    top: 0.0,
                    left: languagesSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Languages',
                      items: languagesMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.languageIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          languagesSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newLangueIdsList) async {
                        // save to "global" filters
                        discoveryProvider.activeFilteringParameters.languageIds = newLangueIdsList;
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // memberships
                  AnimatedPositioned(
                    top: 0.0,
                    left: membershpsSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Institutions',
                      items: membershipsMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.membershipIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          membershpsSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newnewMembershipIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.membershipIds = newnewMembershipIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // grades
                  AnimatedPositioned(
                    top: 0.0,
                    left: gradesSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle:
                      // discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2/*kUserTypeDoctor*/ ? 'Grades' : 'Level',
                      items:
                      // discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2/*kUserTypeDoctor*/ ? gradesMap : bandsMap,
                      currentItemFilters: //discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2/*kUserTypeDoctor*/
                          ? discoveryProvider.activeFilteringParameters.gradeIds
                          : discoveryProvider.activeFilteringParameters.bandIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          gradesSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        if (//discoveryProvider.activeFilteringParameters.roleType
                        filterUserType == 2/*kUserTypeDoctor*/) {
                          discoveryProvider.activeFilteringParameters.gradeIds = newIdsList;
                        } else {
                          discoveryProvider.activeFilteringParameters.bandIds = newIdsList;
                        }
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // skills
                  AnimatedPositioned(
                    top: 0.0,
                    left: skillsSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Skills',
                      items: discoveryProvider.orderedSkillsMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.skillsIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          skillsSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.skillsIds = newIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),

                  // bottom button
                  AnimatedPositioned(
                    duration: Duration(milliseconds: animationDuration),
                    bottom: isShowingOptionsPanel ? -85.0 : 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: showResultsButtonHeight,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 25.0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            buttonText == 'No Results' && fetchingResult ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 38,) :
                            roundedButton(
                              context: context,
                              title: buttonText,
                              onClicked: numberOfResults == 0
                                  ? (){
                                print("no of results ^&&&&&&&&&&&&&&&&&&& $numberOfResults");
                              }
                                  : () {
                                Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset();
                                Provider.of<DiscoveryProvider>(context, listen: false).copyActiveFilterParametersToFilterParameters();
                                Provider.of<DiscoveryProvider>(context, listen: false).copyFilteredResultsToResults();
                                Navigator.pop(context);

                                if(isAnnouncement){
                                  Navigator.pushNamed(context, NewAnnouncement.routeName);
                                }
                              },
                              titleColor: buttonColor,
                              buttonHeight: 50.0,
                            ),
                            if (fetchingResult)
                              Positioned(
                                  top: 10,
                                  right: 26,
                                  child: Container(
                                      width: 24, height: 24, child: SpinKitCircle(
                                    color: Theme.of(context).primaryColor,
                                    size: 45.0,
                                  ))),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      })
    );
  }

  else {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
        isScrollControlled: true,
        backgroundColor: Colors.white,
        enableDrag: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            if(_isInit){
              updatedFilteredResults().then((_){
                setState(() {
                  numberOfResults = discoveryProvider.activeFilterUserCount;
                  buttonText = getUpdateButtonText();
                  fetchingResult = false;
                  _isInit = false;
                });
              });
            }

            return AnimatedContainer(
              duration: Duration(milliseconds: animationDuration),
              height: h * 0.75,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12.0),
                      ListTile(
                        leading: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          color: Colors.blue,
                          iconSize: 32,
                        ),
                        title: Center(
                            child: Text(
                          'Filter',
                          style: Theme.of(context).textTheme.headline6,
                        )),
                        trailing: TextButton(
                          onPressed: () async {
                            setState(() {
                              numberOfResults = 0;
                              fetchingResult = true;
                              discoveryProvider.resetActiveFilters(context);
                              filterUserType = discoveryProvider.activeFilteringParameters.roleType;
                            });
                            await updatedFilteredResults();
                            setState(() {
                              numberOfResults = discoveryProvider.activeFilterUserCount;
                              buttonText = getUpdateButtonText();
                              fetchingResult = false;
                            });
                          },
                          child: Text('Clear', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.blue)),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: (animationDuration * 0.75).round()),
                        height: h * 0.525,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 8.0),
                              child: Text('Profession', style: Theme.of(context).textTheme.headline6),
                            ),
                            const SizedBox(height: 4.0),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 2.0),
                                child: Scrollbar(
                                  controller: singleChildScrollViewController,
                                  thickness: 2,
                                  isAlwaysShown: isMoreOptionsExpanded,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    controller: singleChildScrollViewController,
                                    child: Column(
                                      children: [
                                        // User type
                                        InkWell(
                                          onTap: fetchingResult
                                              ? null
                                              : () {
                                                  setState(() {
                                                    userTypeSelectorLeft = 0.0;
                                                    isShowingOptionsPanel = true;
                                                  });
                                                },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  "images/user-detail-filled.svg",
                                                  color: Theme.of(context).primaryColor,
                                                  height: 25.0,
                                                  width: 25.0,
                                                ),
                                                const SizedBox(width: 12.0),
                                                Text('User type', style: Theme.of(context).textTheme.bodyText1),
                                                const Spacer(),
                                                Text(fetchUserRoleText(),
                                                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                        color: filterUserType == 0 ? Colors.grey : Colors.blue)),
                                                const SizedBox(width: 6.0),
                                                Icon(Icons.arrow_forward_ios, size: 16.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Specialty
                                        Opacity(
                                          opacity: filterUserType == 0 ? 0.4 : 1.0,
                                          child: InkWell(
                                            onTap: filterUserType == 0 || fetchingResult
                                                ? null
                                                : () {
                                                    setState(() {
                                                      specialtyPositionsSelectorLeft = 0.0;
                                                      isShowingOptionsPanel = true;
                                                    });
                                                  },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    "images/role-filled.svg",
                                                    color: Theme.of(context).primaryColor,
                                                    height: 25.0,
                                                    width: 25.0,
                                                  ),
                                                  const SizedBox(width: 12.0),
                                                  Text(
                                                      filterUserType == 2
                                                          ? 'Specialty'
                                                          : 'Position',
                                                      style: Theme.of(context).textTheme.bodyText1),
                                                  const Spacer(),
                                                  Text(fetchSpecialtyText(),
                                                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                          color: (fetchSpecialtyText() == 'Any')
                                                              ? Colors.grey
                                                              : Colors.blue)),
                                                  const SizedBox(width: 6.0),
                                                  Icon(Icons.arrow_forward_ios, size: 16.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Areas of work
                                        InkWell(
                                          onTap: fetchingResult
                                              ? null
                                              : () {
                                                  setState(() {
                                                    areasOfWorkSelectorLeft = 0.0;
                                                    isShowingOptionsPanel = true;
                                                  });
                                                },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  "images/area-of-work-filled.svg",
                                                  color: Theme.of(context).primaryColor,
                                                  height: 25.0,
                                                  width: 25.0,
                                                ),
                                                const SizedBox(width: 12.0),
                                                Text('Areas of work', style: Theme.of(context).textTheme.bodyText1),
                                                const Spacer(),
                                                Text(fetchAreasOfWorkText(),
                                                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                        color: (fetchAreasOfWorkText() == 'Any')
                                                            ? Colors.grey
                                                            : Colors.blue)),
                                                const SizedBox(width: 6.0),
                                                Icon(Icons.arrow_forward_ios, size: 16.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Memberships
                                        Opacity(
                                          opacity: filterUserType == 0 ? 0.4 : 1.0,
                                          child: InkWell(
                                            onTap: filterUserType == 0 || fetchingResult
                                                ? null
                                                : () {
                                                    setState(() {
                                                      membershpsSelectorLeft = 0.0;
                                                      isShowingOptionsPanel = true;
                                                    });
                                                  },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Transform.scale(
                                                    scale: 1.2,
                                                    child: SvgPicture.asset(
                                                      "images/membership-filled.svg",
                                                      color: Theme.of(context).primaryColor,
                                                      height: 25.0,
                                                      width: 25.0,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12.0),
                                                  Text('Memberships', style: Theme.of(context).textTheme.bodyText1),
                                                  const Spacer(),
                                                  Text(fetchMembershipsText(),
                                                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                          color: (fetchMembershipsText() == 'Any')
                                                              ? Colors.grey
                                                              : Colors.blue)),
                                                  const SizedBox(width: 6.0),
                                                  Icon(Icons.arrow_forward_ios, size: 16.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        const Divider(),
                                        const SizedBox(height: 8.0),
                                        Container(
                                          color: Colors.grey[200],
                                          child: GroovinExpansionTile(
                                            onExpansionChanged: (bool expanded) {
                                              if (expanded) {
                                                singleChildScrollViewController.animateTo(
                                                    singleChildScrollViewController.position.maxScrollExtent + 64,
                                                    duration: Duration(milliseconds: 350),
                                                    curve: Curves.easeIn);
                                              }
                                              setState(() {
                                                isMoreOptionsExpanded = expanded;
                                              });
                                            },
                                            defaultTrailingIconColor: Theme.of(context).primaryColor,
                                            title: Text('More Options',
                                                style: TextStyle(color: Color(0xff616161), fontSize: 17.0)),
                                            children: [
                                              // grade
                                              Container(
                                                color: Colors.white,
                                                child: Column(
                                                  children: [
                                                    Opacity(
                                                      opacity: filterUserType == 0 ? 0.4 : 1.0,
                                                      child: InkWell(
                                                        onTap: filterUserType == 0 || fetchingResult
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                  gradesSelectorLeft = 0.0;
                                                                  isShowingOptionsPanel = true;
                                                                });
                                                              },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              SvgPicture.asset(
                                                                "images/level-filled.svg",
                                                                color: Theme.of(context).primaryColor,
                                                                height: 25.0,
                                                                width: 25.0,
                                                              ),
                                                              const SizedBox(width: 12.0),
                                                              Text(getGradeLevelText(),
                                                                  style: Theme.of(context).textTheme.bodyText1),
                                                              const Spacer(),
                                                              Text(fetchGradesOrLevelsText(),
                                                                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                      color: (fetchGradesOrLevelsText() == 'Any')
                                                                          ? Colors.grey
                                                                          : Colors.blue)),
                                                              const SizedBox(width: 6.0),
                                                              Icon(Icons.arrow_forward_ios, size: 16.0),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(),
                                                  ],
                                                ),
                                              ),
                                              // languages
                                              Container(
                                                color: Colors.white,
                                                child: Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: fetchingResult
                                                          ? null
                                                          : () {
                                                              setState(() {
                                                                languagesSelectorLeft = 0.0;
                                                                isShowingOptionsPanel = true;
                                                              });
                                                            },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "images/language-filled.svg",
                                                              color: Theme.of(context).primaryColor,
                                                              height: 25.0,
                                                              width: 25.0,
                                                            ),
                                                            const SizedBox(width: 12.0),
                                                            Text('Languages',
                                                                style: Theme.of(context).textTheme.bodyText1),
                                                            const Spacer(),
                                                            Text(fetchLanguagesText(),
                                                                style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                    color: (fetchLanguagesText() == 'Any')
                                                                        ? Colors.grey
                                                                        : Colors.blue)),
                                                            const SizedBox(width: 6.0),
                                                            Icon(Icons.arrow_forward_ios, size: 16.0),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(),
                                                  ],
                                                ),
                                              ),
                                              // skills
                                              Container(
                                                color: Colors.white,
                                                child: Opacity(
                                                  opacity: filterUserType == 0 ? 0.4 : 1.0,
                                                  child: InkWell(
                                                    onTap: filterUserType == 0 || fetchingResult
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              skillsSelectorLeft = 0.0;
                                                              isShowingOptionsPanel = true;
                                                            });
                                                          },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "images/skills-filled.svg",
                                                            color: Theme.of(context).primaryColor,
                                                            height: 25.0,
                                                            width: 25.0,
                                                          ),
                                                          const SizedBox(width: 12.0),
                                                          Text('Skills', style: Theme.of(context).textTheme.bodyText1),
                                                          const Spacer(),
                                                          Text(fetchSkillsText(),
                                                              style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                  color: (fetchSkillsText() == 'Any')
                                                                      ? Colors.grey
                                                                      : Colors.blue)),
                                                          const SizedBox(width: 6.0),
                                                          Icon(Icons.arrow_forward_ios, size: 16.0),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (isMoreOptionsExpanded)
                                                Container(color: Colors.white, height: showResultsButtonHeight + 12.0),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // user type
                  AnimatedPositioned(
                    top: 0.0,
                    left: userTypeSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: UserTypeFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      fetchParentRole: () {
                        return filterUserType;
                      },
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          userTypeSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (int newUserRole) async {
                        setState(() {
                          numberOfResults = 0;
                          filterUserType = newUserRole;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        // reset filters global filters...
                        discoveryProvider.resetActiveFilteringParameters(context);
                        // save to "global" filters
                        discoveryProvider.activeFilteringParameters.roleType = filterUserType;
                        // now have to refetch memberships & competencies
                        final userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
                        final countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
                        await discoveryProvider.fetchAvailablePositions(context,
                            trustId: userTrustId, countryCode: countryCode, roleType: filterUserType, notify: false,profileUpdate: false);
                        await discoveryProvider.fetchAvailablePositions(context,
                            countryCode: countryCode, roleType: filterUserType, notify: false,profileUpdate: false);
                        await discoveryProvider.fetchMemberships(context,
                            countryCode: countryCode, roleType: filterUserType, notify: false);
                        await discoveryProvider.fetchGradesBandsLanguagesAndSkills(context,
                            trustId: userTrustId, countryCode: countryCode, roleType: filterUserType, notify: false);
                        // reset maps the maps with (potentially) new data...
                        setState(() {
                          languagesMap = discoveryProvider.orderedLanguagesMap;
                          membershipsMap = discoveryProvider.orderedMembershipsMap;
                          gradesMap = discoveryProvider.orderedGradesMap;
                          bandsMap = discoveryProvider.orderedBandsMap;
                        });
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          filterUserType = newUserRole;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // roles / specialty
                  AnimatedPositioned(
                    top: 0.0,
                    left: specialtyPositionsSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      // height: h * 0.5,
                      sheetTitle: //discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2 ? 'Specialty' : 'Position',
                      items: discoveryProvider.orderedAvailablePositionsMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.roleIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          specialtyPositionsSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.roleIds = newIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // areas of work
                  AnimatedPositioned(
                    top: 0.0,
                    left: areasOfWorkSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Areas of Work',
                      items: discoveryProvider.orderedAreasOfWorkMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.areasOfWorkIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          areasOfWorkSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.areasOfWorkIds = newIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // languages
                  AnimatedPositioned(
                    top: 0.0,
                    left: languagesSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Languages',
                      items: languagesMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.languageIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          languagesSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newLangueIdsList) async {
                        // save to "global" filters
                        discoveryProvider.activeFilteringParameters.languageIds = newLangueIdsList;
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // memberships
                  AnimatedPositioned(
                    top: 0.0,
                    left: membershpsSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Institutions',
                      items: membershipsMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.membershipIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          membershpsSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newnewMembershipIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.membershipIds = newnewMembershipIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // grades
                  AnimatedPositioned(
                    top: 0.0,
                    left: gradesSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle:
                         // discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2/*kUserTypeDoctor*/ ? 'Grades' : 'Level',
                      items:
                         // discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2/*kUserTypeDoctor*/ ? gradesMap : bandsMap,
                      currentItemFilters: //discoveryProvider.activeFilteringParameters.roleType
                      filterUserType == 2/*kUserTypeDoctor*/
                          ? discoveryProvider.activeFilteringParameters.gradeIds
                          : discoveryProvider.activeFilteringParameters.bandIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          gradesSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        if (//discoveryProvider.activeFilteringParameters.roleType
                        filterUserType == 2/*kUserTypeDoctor*/) {
                          discoveryProvider.activeFilteringParameters.gradeIds = newIdsList;
                        } else {
                          discoveryProvider.activeFilteringParameters.bandIds = newIdsList;
                        }
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),
                  // skills
                  AnimatedPositioned(
                    top: 0.0,
                    left: skillsSelectorLeft,
                    duration: Duration(milliseconds: animationDuration),
                    child: ListFilterSheet(
                      width: w *0.5,
                      height: h * 0.5,
                      sheetTitle: 'Skills',
                      items: discoveryProvider.orderedSkillsMap,
                      currentItemFilters: discoveryProvider.activeFilteringParameters.skillsIds,
                      popSheetFunction: () {
                        setState(() {
                          isShowingOptionsPanel = false;
                          skillsSelectorLeft = w;
                        });
                      },
                      onDoneFunction: (List<String> newIdsList) async {
                        // save to "global" filters
                        setState(() {
                          numberOfResults = 0;
                          buttonText = getUpdateButtonText();
                          fetchingResult = true;
                        });
                        discoveryProvider.activeFilteringParameters.skillsIds = newIdsList;
                        await updatedFilteredResults();
                        setState(() {
                          numberOfResults = discoveryProvider.activeFilterUserCount;
                          buttonText = getUpdateButtonText();
                          buttonColor = Colors.white;
                          fetchingResult = false;
                        });
                      },
                    ),
                  ),

                  // bottom button
                  AnimatedPositioned(
                    duration: Duration(milliseconds: animationDuration),
                    bottom: isShowingOptionsPanel ? -85.0 : 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: showResultsButtonHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 25.0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            buttonText == 'No Results' && fetchingResult ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 38,) :
                            roundedButton(
                              context: context,
                              title: buttonText,
                              onClicked: numberOfResults == 0
                                  ? (){
                                print("no of results ^&&&&&&&&&&&&&&&&&&& $numberOfResults");
                              }
                                  : () {
                                Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset();
                                Provider.of<DiscoveryProvider>(context, listen: false).copyActiveFilterParametersToFilterParameters();
                                      Provider.of<DiscoveryProvider>(context, listen: false).copyFilteredResultsToResults();
                                      Navigator.pop(context);

                                      if(isAnnouncement){
                                        Navigator.pushNamed(context, NewAnnouncement.routeName);
                                      }
                                    },
                              titleColor: buttonColor,
                              buttonHeight: 50.0,
                            ),
                            if (fetchingResult)
                              Positioned(
                                  top: 10,
                                  right: 26,
                                  child: Container(
                                      width: 24, height: 24, child: SpinKitCircle(
                                    color: Theme.of(context).primaryColor,
                                    size: 45.0,
                                  ))),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
