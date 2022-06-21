import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Directory/DirectoryFilter.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';



class Directory extends StatefulWidget {
  @override
  _DirectoryState createState() => _DirectoryState();
}

class _DirectoryState extends State<Directory> with AutomaticKeepAliveClientMixin {
  int pageOffset = 0;
  bool anyTextSearchDone = false;
  bool searchInProgress = false;
 
  bool inSearchPause = false;
  Timer searchInProgressTimer;
  String lastSearchText = '';
  String timerStartSearchText = '';
  var userTrustId;
  var countryCode;
  var defaultUserType;
  var userHospitalsIds;
  var userMembershipsIds;
  List<User> users = [];
  TextEditingController searchController;
  FocusNode searchFocusNode;
  ScrollController scScrollController;
  bool initialLoadDone = false;
  Widget bottomGapToShowLoadingMoreStatus = Container();

  RefreshController refreshController = RefreshController(initialRefresh: false);

  bool isSearchFieldVisible = false;

  @override
  void initState() {
    scScrollController = ScrollController();
    searchController = TextEditingController();
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

    if (Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);

    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
    defaultUserType = Provider.of<UserProvider>(context, listen: false).userData.roleType;
    userHospitalsIds = Provider.of<UserProvider>(context, listen: false).hospitalIds;
    userMembershipsIds = Provider.of<UserProvider>(context, listen: false).membershipIds;

    newDiscovery();
    AnalyticsManager.track('screen_directory');
    super.initState();
  }

  @override
  void dispose() {
    scScrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    searchInProgressTimer?.cancel();
    super.dispose();
  }

  Future<void> initialLoad() async {
    final discoveryProvider = Provider.of<DiscoveryProvider>(context, listen: false);

    discoveryProvider.clearUsers();

    discoveryProvider.fetchAvailablePositions(context, trustId: userTrustId, countryCode: countryCode, roleType: defaultUserType,profileUpdate: false);

    discoveryProvider.fetchAreasOfWork(context,
        trustId: userTrustId, countryCode: countryCode, hospitalsIds: userHospitalsIds);

    discoveryProvider.fetchMemberships(context, countryCode: countryCode, roleType: defaultUserType);

    discoveryProvider.fetchGradesBandsLanguagesAndSkills(context,
        trustId: userTrustId, countryCode: countryCode, roleType: defaultUserType);

    await discoveryProvider.fetchUsers(context,
        pageOffset: pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        defaultUserType: defaultUserType,
        initialLoad: true,
        searchText: lastSearchText);

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          initialLoadDone = true;
        });
      }
    });

  }

  void newDiscovery() async {
    pageOffset = 0;
    if (!initialLoadDone) {
      // don't await calls for initial load
      initialLoad().then((_) {
        if (mounted) {
          Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset();
        }
      });
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
        defaultUserType: Provider.of<UserProvider>(context, listen: false).userData.roleType,
        searchText: lastSearchText);
    setState(() {
      searchInProgress = false;
      initialLoadDone = true;
    });
  }

  void _onRefresh() async {
    pageOffset = 0;
    Provider.of<DiscoveryProvider>(context, listen: false).resettingOffset();
    await Future.delayed(Duration(milliseconds: 1000));
    Provider.of<DiscoveryProvider>(context, listen: false).clearUsers();
    await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
        pageOffset: Provider.of<DiscoveryProvider>(context, listen: false).pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: false,
        searchText: lastSearchText);
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      bottomGapToShowLoadingMoreStatus = SizedBox(
        height: 60.0,
      );
    });
    // pageOffset += Provider.of<DiscoveryProvider>(context, listen: false).discoveryProviderPageSize;
    Provider.of<DiscoveryProvider>(context, listen: false).increaseNextOffset();
    await Future.delayed(Duration(milliseconds: 1000));
    await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
        pageOffset:Provider.of<DiscoveryProvider>(context, listen: false).pageOffset,
        //pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: false,
        searchText: lastSearchText);
    if (mounted) {
      setState(() {
        bottomGapToShowLoadingMoreStatus = Container(height: 35.0,);
      });
      refreshController.loadComplete();
    }
  }

  void cancelActions() {
    isSearchFieldVisible = false;
    searchController.text = '';
    lastSearchText = '';
  }

  Widget getEmptyResultsBody(Size screenSize, bool isNotVerifiedAccount) {
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
        SizedBox(
          height: 30.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.15),
          child: Center(
            child: Text(isNotVerifiedAccount ? "We need to verify your account before you can find your colleagues": "No matching profiles found.", textAlign: TextAlign.center, style: style1),
          ),
        ),
        SizedBox(
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

  Widget getUsersList(List<User> users, Size media, var userData) {
    return ListView.builder(
      itemCount: users.length,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, i) => Padding(
        padding: i == users.length - 1 ? const EdgeInsets.only(bottom: 25.0) : const EdgeInsets.only(bottom: 0.0),
        child: InkWell(
          // don't allow screen change if loading data
          onTap: ()async{
            Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": users[i].id});
          },
          child: directoryUserCard(
            context: context,
              name: users[i].name,
              job: getJobRolesCommaSeparatedList(users[i].roles),
              trust: users[i].trust['name'],
              profilePicPath:
                  users[i].profilePic == null || users[i].profilePic.length == 0 ? null : users[i].profilePic,
              workArea: (users[i].wards == null || users[i].wards.isEmpty)
                  ? null
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: media.width*0.6,
                        child: Wrap(
                          children: users[i].wards.length <= 3 ? users[i].wards
                              .map((item) => Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          // color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: Color(0xFFFFC306))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(item["name"], style: TextStyle(color: Color(0xFF333333),fontSize: 12)),
                                        )),
                                  ))
                              .toList()
                              .cast<Widget>() :
                                 users[i].wards.take(3)
                                .map((item) => Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Color(0xFFFFC306))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(users[i].wards.indexOf(item) == 2 ? "+${users[i].wards.length-2} more": item["name"], style: TextStyle(color: Color(0xFF333333),fontSize: 12)),
                                  )),
                                )).toList().cast<Widget>(),
                        ),
                      ),
                    ),
              buttonList: [
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: Provider.of<CallProvider>(context).isInCall ? null :
                      ()async {
                    if(await Permission.microphone.isGranted == true){
                      final callProvider = Provider.of<CallProvider>(context, listen: false);
                      callProvider.initiateTwilioCall(context, callToUser: users[i]);
                    }
                    else{
                      await Permission.microphone.request().then((value) {
                        final callProvider = Provider.of<CallProvider>(context, listen: false);
                        callProvider.initiateTwilioCall(context, callToUser: users[i]);
                      });
                    }
                    AnalyticsManager.track('discovery_profile_call');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SvgPicture.asset(
                      "images/call.svg",
                      color: Provider.of<CallProvider>(context).isInCall ? Colors.grey :
                      Theme.of(context).primaryColor,
                      width: 25,
                    ),
                  ),
                ),
                VerticalDivider(
                  width: 2.0,
                  thickness: 2.0,
                ),
                InkWell(
                  // splashColor: Colors.transparent,
                  onTap: ()async{

                      Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                      usersIds: [users[i].id, userData.userData.id],
                      channelType: "private",
                      channelDisplayName: users[i].name,
                      );
                      AnalyticsManager.track('discovery_profile_chat');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SvgPicture.asset(
                      "images/chatOutline.svg",
                      color: Theme.of(context).primaryColor,
                      width: 25,
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }

  Widget getFilterItemTextWidget(String itemLabel) {
    Widget ret = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(itemLabel, style: TextStyle(color: Colors.white)));
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
              Text(labelString, style: TextStyle(color: Colors.white)),
              const SizedBox(width: 4),
              Container(
                  height: 22.0,
                  width: 22.0,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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

  Widget getResultCountAndFilters(Size media) {
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
            decoration: BoxDecoration(color: filterColor, borderRadius: BorderRadius.all(Radius.circular(6))),
            padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
            child: getFilterItemTextWidget(item)),
      ))
          .toList());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: media.width,
          height: 48,
          padding: const EdgeInsets.only(top: 6.0, left: 12),
          child: Row(
            children: [
              Text('$numberOfResults ' + (numberOfResults == 1 ? 'result' : 'results'),
                  style: TextStyle(
                    color: Colors.grey[500],
                  )),
              Spacer(),
              if (searchInProgress)
                Container(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              if (searchInProgress) const SizedBox(width: 8),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1),
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
              Divider(height: 1, thickness: 1),
            ],
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userData = Provider.of<UserProvider>(context);
    final media = MediaQuery.of(context).size;
    final discoveryProvider = Provider.of<DiscoveryProvider>(context);
    List<User> users = discoveryProvider.discoveredUsers;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: screenAppBar(
          context,
          media,
          isMainScreen: true,
          appbarTitle: Column(
              children: [
                Text(userData.userData == null ? "": "${userData.userData.trust["name"]}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: const Text("Directory",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                ),
              ]
          ),
          filterAction: !initialLoadDone ? null : () => showModalFilterSheet(
              context,
              scScrollController,
              lastSearchText,
              defaultUserType: userData.userData.roleType),
          showLeadingPop: false,
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
              ? null
              : PreferredSize(
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
                              cursorColor: Theme.of(context).primaryColor,
                              style: TextStyle(color: Theme.of(context).primaryColor),
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
                                contentPadding: EdgeInsets.only(bottom: 0.0, left: 15.0, right: 15.0,top: 6),
                                // focusedBorder: OutlineInputBorder(
                                //       borderSide: BorderSide(width: 2.0, color: Colors.white),
                                //       borderRadius: textFieldBorderRadius),
                                //   enabledBorder: OutlineInputBorder(
                                //       borderSide: BorderSide(width: 2.0, color: Colors.grey),
                                //       borderRadius: textFieldBorderRadius),
                                  hintText: "Search...",
                                  hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'DIN'),
                              ),
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
                            child: Text(
                              "Cancel",
                              style: TextStyle(fontSize: 16.0, color: Colors.white),
                            )),
                      )
                    ],
                  ),
                  preferredSize: Size.fromHeight(60.0),
                ),
        ),
        body: discoveryProvider.stage == DiscoveryStage.LOADING && !searchInProgress
            ? Center(
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 45.0,
                ),
              )
            : discoveryProvider.stage == DiscoveryStage.ERROR
                ? Center(
                    child: InkWell(
                      onTap: (){
                        _onRefresh();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Network Error retry? "),
                          Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
                        ],
                      ),
                    ),
                  )
                : (users.isEmpty && initialLoadDone)
                    ? getEmptyResultsBody(media, false):
                userData.userData.verified == false ?
                getEmptyResultsBody(media, true)
                    : Column(
                        children: [
                          Container(color:Colors.white,child: getResultCountAndFilters(media)),
                          Expanded(
                            child: SmartRefresher(
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
                                    body = Padding(
                                      padding: const EdgeInsets.only(bottom: 40),
                                      child: const Text("No more to load!"),
                                    );
                                  }
                                  return Center(child: body);
                                },
                              ),
                              child: getUsersList(users, media, userData),
                            ),
                          ),
                          bottomGapToShowLoadingMoreStatus,
                        ],
                      ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
