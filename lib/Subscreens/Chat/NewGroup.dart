// ignore_for_file: file_names, prefer_typing_uninitialized_variables, curly_braces_in_flow_control_structures, prefer_if_null_operators

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Chat/CreateNewGroup.dart';
import 'package:rightnurse/Subscreens/Directory/DirectoryFilter.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';


class NewGroupScreen extends StatefulWidget{
  static const routeName = "/NewGroupScreen_Screen";

  const NewGroupScreen({Key key}) : super(key: key);

  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  List<User> selectedUsers = [];
  List<String> userIds = [];
  List<String> userNames = [];
  var _isInit = true;
  var passedData = {};
  bool _isSelectAllPressed = false;

  int pageOffset = 0;
  bool anyTextSearchDone = false;
  bool searchInProgress = false;

  bool inSearchPause = false;
  Timer searchInProgressTimer;
  String lastSearchText = '';
  String timerStartSearchText = '';
  var userTrustId;
  var countryCode;
  var userHospitalsIds;
  var userMembershipsIds;
  var defaultUserType;
  List<User> users = [];
  TextEditingController searchController;
  FocusNode searchFocusNode;
  ScrollController scScrollController;
  bool initialLoadDone = false;
  var lastItemBottomPadding = 20.0;
  bool isFromGroupDetails = false;
  String groupId = "";
  Widget bottomGapToShowLoadingMoreStatus = const SizedBox();
  final ScrollController _participantsListScrollController = ScrollController();
  final dataKey = GlobalKey();

  RefreshController refreshController = RefreshController(initialRefresh: false);

  bool isSearchFieldVisible = false;
  final int maximumResultsCount = 100;

  @override
  void initState() {
    scScrollController = ScrollController();
    searchController = TextEditingController();
    if (Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);
    /*
    searchController.addListener(() {
      if (lastSearchText != searchController.text) {
        lastSearchText = searchController.text;
        if (!inSearchPause && searchInProgress == false) {
          inSearchPause = true;
          Timer(const Duration(milliseconds: 450), () {
            if (mounted) {
              inSearchPause = false;
              setState(() {
                searchInProgress = true;
              });
              // make a new request for results as each character typed
              newDiscovery();
              anyTextSearchDone = true;
            }
          });
        }
        if (!inSearchPause && searchInProgressTimer == null) {
          // have to start a timer to do a search again when previous search has finished
          timerStartSearchText = lastSearchText;
          searchInProgressTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
            if (mounted) {
              if (searchInProgress == false && timerStartSearchText != lastSearchText) {
                searchInProgressTimer?.cancel();
                searchInProgressTimer = null;
                setState(() {
                  searchInProgress = true;
                });
                newDiscovery();
              } else {
                searchInProgressTimer?.cancel();
                searchInProgressTimer = null;
                newDiscovery();
              }
            } else {
              searchInProgressTimer?.cancel();
              searchInProgressTimer = null;
            }
          });
        }
      }
    });
    searchFocusNode = FocusNode();


    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
    userHospitalsIds = Provider.of<UserProvider>(context, listen: false).hospitalIds;
    userMembershipsIds = Provider.of<UserProvider>(context, listen: false).membershipIds;
    defaultUserType = Provider.of<UserProvider>(context, listen: false).userData.roleType;
    newDiscovery();
    */
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;


     if(passedData["from"] == "chatDetails") {
       users.add(passedData["user"]);

       userNames.add(passedData["user"].name);
       userIds.add(passedData["user"].id);
       selectedUsers.add(passedData["user"]);
     }
     if(passedData["from"] == "groupDetails"){
       isFromGroupDetails = true;
       groupId = passedData["group_id"];
     }

      searchController.addListener(() {
        if (lastSearchText != searchController.text) {
          lastSearchText = searchController.text;
          if (!inSearchPause && searchInProgress == false) {
            inSearchPause = true;
            Timer(const Duration(milliseconds: 450), () {
              if (mounted) {
                inSearchPause = false;
                setState(() {
                  searchInProgress = true;
                });
                // make a new request for results as each character typed
                newDiscovery();
                anyTextSearchDone = true;
              }
            });
          }
          if (!inSearchPause && searchInProgressTimer == null) {
            // have to start a timer to do a search again when previous search has finished
            timerStartSearchText = lastSearchText;
            searchInProgressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
              if (mounted) {
                if (searchInProgress == false && timerStartSearchText != lastSearchText) {
                  searchInProgressTimer?.cancel();
                  searchInProgressTimer = null;
                  setState(() {
                    searchInProgress = true;
                  });
                  newDiscovery();
                } else {
                  searchInProgressTimer?.cancel();
                  searchInProgressTimer = null;
                  newDiscovery();
                }
              } else {
                searchInProgressTimer?.cancel();
                searchInProgressTimer = null;
              }
            });
          }
        }
      });
      searchFocusNode = FocusNode();


      userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
      countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
      userHospitalsIds = Provider.of<UserProvider>(context, listen: false).hospitalIds;
      userMembershipsIds = Provider.of<UserProvider>(context, listen: false).membershipIds;
      defaultUserType = Provider.of<UserProvider>(context, listen: false).userData.roleType;
      newDiscovery();


      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scScrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    searchInProgressTimer?.cancel();
    // Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset();
    super.dispose();
  }

  Future<void> initialLoad() async{
    final discoveryProvider = Provider.of<DiscoveryProvider>(context, listen: false);

    discoveryProvider.clearUsers();

    discoveryProvider.fetchAvailablePositions(context, trustId: userTrustId, countryCode: countryCode, roleType: defaultUserType,profileUpdate: false);

    discoveryProvider.fetchAreasOfWork(context,
        trustId: userTrustId, countryCode: countryCode, hospitalsIds: userHospitalsIds);

    discoveryProvider.fetchMemberships(context, countryCode: countryCode, roleType: defaultUserType);

    discoveryProvider.fetchGradesBandsLanguagesAndSkills(context,
        trustId: userTrustId, countryCode: countryCode, roleType: defaultUserType);


    discoveryProvider.fetchUsers(context,
        pageOffset: pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: true,
        groupId: isFromGroupDetails ? groupId : "",
        defaultUserType: Provider.of<UserProvider>(context, listen: false).userData.roleType,
        searchText: lastSearchText);

    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        initialLoadDone = true;
      });
    });
  }

  void newDiscovery() async {
    pageOffset = 0;
    if (!initialLoadDone) {
      // don't await calls for initial load
      initialLoad().then((_) =>  Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset());
      return;
    }
    if (!searchInProgress) {
      Provider.of<DiscoveryProvider>(context, listen: false).clearUsers();
    }

    // some of this data is cached, so will not be re-fetched on
    // subsequent runs
    if (!isSearchFieldVisible) {
      final discoveryProvider = Provider.of<DiscoveryProvider>(context, listen: false);
      await discoveryProvider.fetchAreasOfWork(context,
          trustId: userTrustId, countryCode: countryCode, hospitalsIds: userHospitalsIds);

      await discoveryProvider.fetchMemberships(context,
          countryCode: countryCode, roleType: discoveryProvider.activeFilteringParameters.roleType);

      await discoveryProvider.fetchGradesBandsLanguagesAndSkills(context,
          trustId: userTrustId,
          countryCode: countryCode,
          roleType: discoveryProvider.activeFilteringParameters.roleType);
    }

    await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
        pageOffset: pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: true,
        groupId: isFromGroupDetails ? groupId : "",
        defaultUserType: Provider.of<UserProvider>(context, listen: false).userData.roleType,
        searchText: lastSearchText);

    setState(() {
      searchInProgress = false;
      initialLoadDone = true;
    });
    Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset();
  }

  Widget getEmptyResultsBody(Size screenSize) {
    return ListView(
      children: [
        SizedBox(
          height: screenSize.height * 0.22,
        ),
        Image.asset(
          "images/placeholderNoresultBlue.png",
          height: 200.0,
          width: 200.0,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 30.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.15),
          child: Center(
            child: Text("No matching profiles found.", textAlign: TextAlign.center, style: style1),
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.12),
          child: Center(
              child: Text(
                "Try broadening your search requirements.",
                textAlign: TextAlign.center,
                style: style3,
              )),
        ),
        const SizedBox(
          height: 120.0,
        ),
      ],
    );
  }

  Widget getFilterItemTextWidget(String itemLabel) {
    Widget ret = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(itemLabel, style: const TextStyle(color: Colors.white)));
    if (itemLabel.contains(DiscoveryProvider.kDiscoveryFilterNumberPrefix)) {
      final Color filterColor = Theme.of(context).accentColor;
      // need a row with circle containing count...
      final String withoutFilterNumberPrefix =
      itemLabel.substring(DiscoveryProvider.kDiscoveryFilterNumberPrefix.length);
      final String numberOfItems = withoutFilterNumberPrefix.substring(
          0, withoutFilterNumberPrefix.indexOf(DiscoveryProvider.kDiscoveryFilterNumberSeparator));
      final labelString = withoutFilterNumberPrefix.substring(
          withoutFilterNumberPrefix.indexOf(DiscoveryProvider.kDiscoveryFilterNumberSeparator) +
              DiscoveryProvider.kDiscoveryFilterNumberSeparator.length);

      Widget row = Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child:Row(
            children: [
              Text(labelString, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 4),
              Container(
                  height: 22.0,
                  width: 22.0,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(numberOfItems, style: TextStyle(color: filterColor, fontSize: 12.0), textAlign: TextAlign.center,),
                  ))),
            ],
          ));
      return row;
    }
    return ret;
  }

  Widget getResultCountAndFilters(Size media, users) {
    final directoryProvider = Provider.of<DiscoveryProvider>(context, listen: false);
    final int numberOfResults = directoryProvider.userCount;
    final bool anyFiltersSet = directoryProvider.anyFiltersSet();
    final List<String> filterNames = directoryProvider.getFilterNames();
    final Color filterColor = Theme.of(context).accentColor;

    List<Widget> filters = [];

    if (anyFiltersSet) {
      filters.addAll(filterNames
          .map((item) => Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Container(
            decoration: BoxDecoration(color: filterColor, borderRadius: const BorderRadius.all(Radius.circular(6))),
            padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
            child: getFilterItemTextWidget(item)),
      ))
          .toList());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: media.width,
          height: selectedUsers.isNotEmpty ? 32 : 36,
          padding: selectedUsers.isNotEmpty ? const EdgeInsets.only(top: 0.0, left: 12) : const EdgeInsets.only(top: 5.0, left: 12),
          child: Row(
            children: [
              selectedUsers.isNotEmpty && _isSelectAllPressed == false ? Text('${selectedUsers.length} selected of ',
                  style: TextStyle(
                    color: Colors.grey[500],
                  )) : const SizedBox(),
              Text('$numberOfResults ' + (numberOfResults == 1 ? 'result' : 'results'),
                  style: TextStyle(
                    color: Colors.grey[500],
                  )),
              const Spacer(),
              //if (
              searchInProgress ?
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  ),
                ):
              passedData["from"] == "groupDetails" ?
              Container():
              numberOfResults == null ||  numberOfResults == 0 ?
              const SizedBox():
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                      onTap: numberOfResults > maximumResultsCount ?
                      (){
                        showAnimatedCustomDialog(context, message: "Maximum number of participants exceeded - 100 person limit. You can send a message to all users via an announcement 📣 if required");
                      }
                      : (){
                        setState(() {
                          _isSelectAllPressed = !_isSelectAllPressed;
                        });
                      },
                      child: Text("Select All", style: numberOfResults > maximumResultsCount ? const TextStyle(color: Colors.grey, fontSize: 16.0, fontWeight: FontWeight.bold) : styleBlue,)),
                ),
              // if (searchInProgress) const SizedBox(width: 8),


            ],
          ),
        ),

        const Divider(height: 1, thickness: 1),
        if (anyFiltersSet)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 4.0,bottom: 8,top: 8),
                width: media.width,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          directoryProvider.resetFilters(context);
                          initialLoadDone = false;
                          newDiscovery();
                        },
                        child: Text('Reset filter', style: TextStyle(color: filterColor))),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: filters),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
            ],
          )
      ],
    );
  }

  void _onRefresh() async {
    pageOffset = 0;
    Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset();
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<DiscoveryProvider>(context, listen: false).clearUsers();

    await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
        pageOffset: pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: false,
        groupId: isFromGroupDetails ? groupId : "",
        searchText: lastSearchText);
    refreshController.refreshCompleted();
  }

  Widget loader = const SizedBox();

  void _onLoading() async {
    setState(() {
      lastItemBottomPadding = 8.0;
      bottomGapToShowLoadingMoreStatus = const SizedBox(
        height: 40.0,
      );
      loader = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: const CupertinoActivityIndicator(),
      );
    });
    Provider.of<DiscoveryProvider>(context, listen: false).increaseNextOffset();
    await Future.delayed(const Duration(milliseconds: 1000));

    await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
        pageOffset: Provider.of<DiscoveryProvider>(context, listen: false).pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: false,
        groupId: isFromGroupDetails ? groupId : "",
        searchText: lastSearchText);
    if (mounted) {
      setState(() {
        lastItemBottomPadding = 15.0;
        bottomGapToShowLoadingMoreStatus = const SizedBox();
        loader = const SizedBox();

      });
      refreshController.loadComplete();
    }
  }

  void cancelActions() {
    isSearchFieldVisible = false;
    searchController.text = '';
    lastSearchText = '';
  }


  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final discoveryProvider = Provider.of<DiscoveryProvider>(context);
    List<User> users = discoveryProvider.discoveredUsers;
    final userData = Provider.of<UserProvider>(context);
    final channelDetails = Provider.of<ChatProvider>(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: screenAppBar(
          context,
          media,
          appbarTitle: Text(passedData["from"] == "groupDetails" ? "Add Participant" : "New Group"),
            hideProfilePic: true, showLeadingPop: true,
            onBackPressed: ()=> Navigator.pop(context),
            searchAction: !initialLoadDone
                ? null
                : () {
              if (!isSearchFieldVisible) {
                searchFocusNode.requestFocus();
                isSearchFieldVisible = true;
              } else {
                cancelActions();
              }
              setState(() {});
            },
            bottomTabs: !isSearchFieldVisible
                ? null : PreferredSize(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: Container(
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: textFieldBorderRadius,
                          color: Colors.white,
                        ),
                        child: TextField(
                          style: TextStyle(color: Theme.of(context).primaryColor),
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Transform.scale(
                                scale: 0.6,
                                child: Image.asset(
                                  'images/search.png',
                                  color: Theme.of(context).primaryColor,
                                  width: 20,
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(bottom: 0.0, left: 15.0, right: 15.0,top: 6),
                              hintText: "Search...",
                              hintStyle:  TextStyle(color: Colors.grey[400],)),
                          controller: searchController,
                          focusNode: searchFocusNode,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9.0),
                    child: GestureDetector(
                        onTap: () {
                          cancelActions();
                          setState(() {});
                        },
                        child: const Text("Cancel", style: TextStyle(fontSize: 16.0, color: Colors.white),)),
                  )
                ],
              ),
              preferredSize: const Size.fromHeight(60.0),
            ),
        ),

        body: Column(
              children: [
                Material(
                  elevation: 1.0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 15.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () => showModalFilterSheet(context, scScrollController, lastSearchText, defaultUserType: userData.userData.roleType, groupId: groupId),
                            child: Text("Add Filters", style: styleBlue,)),

                        GestureDetector(
                            onTap:
                            selectedUsers.length > maximumResultsCount ? (){
                              showAnimatedCustomDialog(context, message: "Maximum number of participants exceeded - 100 person limit. You can send a message to all users via an announcement 📣 if required");
                            }:
                            selectedUsers.isNotEmpty || _isSelectAllPressed ?
                                () async{
                              if(passedData["from"] == "groupDetails"){
                                channelDetails.updateChatChannel(context,channelId: channelDetails.currentChannel.id,
                                    groupDisplayName: channelDetails.currentChannel.displayName,
                                    groupImage: null,
                                    userIdsToAdd: userIds, channelName: channelDetails.currentChannel.name);
                                Navigator.pop(context);
                              }else{
                                userIds.add(userData.userData.id);
                                Navigator.pushNamed(context, CreateNewGroup.routeName,
                                    arguments: {
                                      "all_selected": _isSelectAllPressed,
                                      "users": selectedUsers,
                                      "userIds": userIds,
                                      "channel_display_name": "New group",//userNames.isEmpty ? "${Provider.of<DiscoveryProvider>(context, listen: false).userCount+1} users group" : userNames.toString().replaceAll("[", "").replaceAll("]", ""),
                                      "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                      "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                      "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                      "isArticleFavourite" :  passedData != null ? passedData['isArticleFavourite'] != null ? passedData['isArticleFavourite'] : null : null,
                                      "articleCommentsCount" : passedData != null ? passedData['articleCommentsCount'] != null ? passedData['articleCommentsCount'] : null : null,
                                      "articleId" : passedData != null ? passedData['articleId'] != null ? passedData['articleId'] : null :null,
                                    });
                              }

                            }: null,
                            child: Text(passedData["from"] == "groupDetails" ? "Add participant" : "Create Group", style: selectedUsers.isNotEmpty || _isSelectAllPressed ? styleBlue :
                            const TextStyle(color: Colors.grey, fontSize: 16.0, fontWeight: FontWeight.bold), )),

                      ],
                    ),
                  ),
                ),

                _isSelectAllPressed == true ?

                Padding(
                  padding: const EdgeInsets.only(top:12.0, bottom: 8.0, left: 8.0, right: 8.0),
                  child: Text("All users selected",
                    style: styleBlue,),
                ):

                // create selected members of group
                selectedUsers.isEmpty ? const SizedBox():
                Container(
                  height: 80,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                    ListView(
                      controller: _participantsListScrollController,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: selectedUsers.take(selectedUsers.length).map((item) => Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 10.0,right: item.id == selectedUsers.last.id ? 10 : 0 ),
                        child: SizedBox(
                          key: item.id == selectedUsers.last.id ? dataKey : null,
                          width: 50.0,
                          height: kIsWeb ? 110.0 : null,

                          child:
                          // selectedUsers.indexOf(item) == 14 ?
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 12.0, left: 2.0),
                          //   child: Text("+${selectedUsers.length - 14} more"),
                          // )
                          //     :
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(80.0),
                                    child: Container(height: kIsWeb ? 50.0 : 40.0, width: kIsWeb ? 50.0 : 40.0,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[200],
                                        borderRadius: BorderRadius.circular(80.0),
                                      ),
                                      child:  item.profilePic == null || item.profilePic.isEmpty ? Padding(
                                        padding: const EdgeInsets.only(top:2.0),
                                        child: Image.asset("images/person.png", fit: BoxFit.contain, color: Colors.white,),
                                      )
                                          :
                                      Image.network(
                                        item.profilePic,
                                        fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                            return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],fit: BoxFit.fill,);}
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0.0,
                                      right: 0.0,
                                      child: GestureDetector(
                                        onTap: (){
                                          setState(() {
                                           // _selectedContacts.remove(item);
                                            userIds.remove(item.id);
                                            userNames.remove(item.name);
                                            selectedUsers.remove(selectedUsers.firstWhere((element) => element.id == item.id));
                                          });
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.circular(50.0),
                                            ),
                                            height: 15.0, width: 15.0,
                                            child: const Center(child: Icon(Icons.cancel_outlined, color: Colors.white, size: 15.0,))),
                                      )
                                  )
                                ],
                              ),
                              const SizedBox(height: 4.0,),
                              Flexible(
                                child: Text(item.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),),
                              )
                            ],
                          ),
                        ),
                      )).toList().cast<Widget>(),
                    ),
                  ),
                ),


                selectedUsers.isNotEmpty ?
                const Divider(): const SizedBox(),

                getResultCountAndFilters(media, users),

                // discoveryProvider.userCount > maximumResultsCount ?
                // Text("Maximum number of participants exceeded - 100 person limit. You can send a message to all users via an announcement :mega: if required")
                //     : const SizedBox(),

                Expanded(
                  flex: 8,
                  child: kIsWeb
                      ?
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },),
                    child: NotificationListener<ScrollNotification>(
                      // ignore: missing_return
                      onNotification: (scrollNotification){
                        // if (scrollNotification is ScrollStartNotification) {
                        //   _onStartScroll(scrollNotification.metrics);
                        // } else if (scrollNotification is ScrollUpdateNotification) {
                        //   _onUpdateScroll(scrollNotification.metrics);
                        // } else if (scrollNotification is ScrollEndNotification) {
                        //   _onEndScroll(scrollNotification.metrics);
                        // }
                        if (kIsWeb) {
                          if (scrollNotification is ScrollStartNotification) {
                            // stop playing
                          }else if(scrollNotification is ScrollEndNotification){
                            print("vbvbvbbvbvbcc ${scrollNotification.metrics.maxScrollExtent}");
                            print("njnjnjjnjnjjn ${scrollNotification.metrics.pixels}");
                            if(scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                              _onLoading();
                            } // resume playing
                          }
                        }
                        // if (scrollNotification is ScrollEndNotification) {
                        //   print(channelsScrollController.position.pixels);
                        // }
                      },
                      child: ListView(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          children: List.generate(users.length, (i) => Padding(
                            padding: i == users.length-1 ? EdgeInsets.only(bottom: kIsWeb ? 0 : lastItemBottomPadding) : const EdgeInsets.only(bottom:0.0),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: _isSelectAllPressed == true ? null : (){
                                    if(!userNames.contains(users[i].name) && !userIds.contains(users[i].id)){
                                      setState(() {
                                        userNames.add(users[i].name);
                                        userIds.add(users[i].id);
                                        selectedUsers.add(users[i]);
                                      });
                                    }else{
                                      setState(() {
                                        userNames.remove(users[i].name);
                                        userIds.remove(users[i].id);
                                        selectedUsers.remove(selectedUsers.firstWhere((element) => element.id == users[i].id));
                                      });
                                    }

                                    if (selectedUsers.length > 1 ) {
                                      setState(() {
                                        WidgetsBinding.instance.addPostFrameCallback(
                                                (_) => Scrollable.ensureVisible(dataKey.currentContext));
                                      });
                                    }
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(80.0),
                                    child: Container(height: 40.0, width: 40.0,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[200],
                                        borderRadius: BorderRadius.circular(80.0),
                                      ),
                                      child:users[i].profilePic == null || users[i].profilePic.isEmpty ? Padding(
                                        padding: const EdgeInsets.only(top:2.0),
                                        child: Image.asset("images/person.png", fit: BoxFit.contain, color: Colors.white,),
                                      )
                                          :
                                      Image.network(
                                          users[i].profilePic,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                            return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],fit: BoxFit.fill,);}
                                      ),
                                    ),
                                  ),
                                  title: Text(users[i].name.toString(), style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                  subtitle: Text(getJobRolesCommaSeparatedList(users[i].roles) == "" ? "${users[i].trust['name']}":
                                  "${getJobRolesCommaSeparatedList(users[i].roles)}\n${users[i].trust['name']}",
                                    maxLines: 3, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey, fontSize: 14.0),),

                                  trailing: userIds.contains(users[i].id) || _isSelectAllPressed ?
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                      height: 25.0, width: 25.0,
                                      child: const Center(child: Icon(Icons.done, color: Colors.white, size: 20.0,))):
                                  Container(
                                    height: 25.0,
                                    width: 25.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                  ),
                                ),
                                const Divider()
                              ],
                            ),
                          ))..add(loader),
                          // itemCount: users.length,
                          // itemBuilder: (context, i) =>

                      ),
                    ),
                  )
                      : SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    controller: refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                        Widget body;
                        if (mode == LoadStatus.loading) {
                          body = const CupertinoActivityIndicator();
                        } else if (mode == LoadStatus.failed) {
                          body = const Text("Load Failed!Click retry!");
                        } else if (mode == LoadStatus.canLoading) {
                        } else {
                          body = const Text("No more to load!");
                        }
                        return Center(child: body);
                      },
                    ),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, i) =>
                            Padding(
                              padding: i == users.length-1 ? EdgeInsets.only(bottom: lastItemBottomPadding) : const EdgeInsets.only(bottom:0.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    onTap: _isSelectAllPressed == true ? null : (){
                                      if(!userNames.contains(users[i].name) && !userIds.contains(users[i].id)){
                                        setState(() {
                                          userNames.add(users[i].name);
                                          userIds.add(users[i].id);
                                          selectedUsers.add(users[i]);
                                        });
                                      }else{
                                        setState(() {
                                          userNames.remove(users[i].name);
                                          userIds.remove(users[i].id);
                                          selectedUsers.remove(selectedUsers.firstWhere((element) => element.id == users[i].id));
                                        });
                                      }

                                      if (selectedUsers.length > 1 ) {
                                        setState(() {
                                          WidgetsBinding.instance.addPostFrameCallback(
                                                  (_) => Scrollable.ensureVisible(dataKey.currentContext));
                                        });
                                      }
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(80.0),
                                      child: Container(height: 40.0, width: 40.0,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[200],
                                          borderRadius: BorderRadius.circular(80.0),
                                        ),
                                        child:users[i].profilePic == null || users[i].profilePic.isEmpty ? Padding(
                                          padding: const EdgeInsets.only(top:2.0),
                                          child: Image.asset("images/person.png", fit: BoxFit.contain, color: Colors.white,),
                                        )
                                            :
                                        Image.network(
                                          users[i].profilePic,
                                          fit: BoxFit.cover,
                                            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                              return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],fit: BoxFit.fill,);}
                                        ),
                                      ),
                                    ),
                                    title: Text(users[i].name.toString(), style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                    subtitle: Text(getJobRolesCommaSeparatedList(users[i].roles) == "" ? "${users[i].trust['name']}":
                                    "${getJobRolesCommaSeparatedList(users[i].roles)}\n${users[i].trust['name']}",
                                      maxLines: 3, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey, fontSize: 14.0),),

                                    trailing: userIds.contains(users[i].id) || _isSelectAllPressed ?
                                    Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(50.0),
                                        ),
                                        height: 25.0, width: 25.0,
                                        child: const Center(child: Icon(Icons.done, color: Colors.white, size: 20.0,))):
                                    Container(
                                      height: 25.0,
                                      width: 25.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                    ),
                                  ),
                                  const Divider()
                                ],
                              ),
                            )
                    ),
                  ),
                ),
                // bottomGapToShowLoadingMoreStatus,
              ],
            ),

      ),
    );
  }
}