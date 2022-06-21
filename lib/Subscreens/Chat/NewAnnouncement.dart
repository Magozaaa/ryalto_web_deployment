// ignore_for_file: file_names, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Directory/DirectoryFilter.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class NewAnnouncement extends StatefulWidget{

  static const String routeName = "/NewAnnouncement_Screen";

  const NewAnnouncement({Key key}) : super(key: key);

  @override
  _NewAnnouncementState createState() => _NewAnnouncementState();
}

class _NewAnnouncementState extends State<NewAnnouncement> {


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
  TextEditingController searchController;
  FocusNode searchFocusNode;
  ScrollController scScrollController;
  bool initialLoadDone = false;
  bool _isTextFieldEmpty = false;

  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = Container();

  RefreshController refreshController = RefreshController(initialRefresh: false);

  bool isSearchFieldVisible = false;

  final TextEditingController _announcementTextFieldController = TextEditingController();

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

    if (Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);

    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
    userHospitalsIds = Provider.of<UserProvider>(context, listen: false).hospitalIds;
    userMembershipsIds = Provider.of<UserProvider>(context, listen: false).membershipIds;
    defaultUserType = Provider.of<UserProvider>(context, listen: false).userData.roleType;

    newDiscovery();
    super.initState();
  }

  @override
  void dispose() {
    scScrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    searchInProgressTimer?.cancel();
    _announcementTextFieldController.dispose();
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
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<DiscoveryProvider>(context, listen: false).clearUsers();
    await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
        pageOffset: pageOffset,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: false,
        searchText: lastSearchText);
    refreshController.refreshCompleted();
  }

  Widget loader = const SizedBox();

  void _onLoading() async {
    setState(() {
      var lastItemBottomPadding = 8.0;
      bottomGapToShowLoadingMoreStatus = const SizedBox(
        height: 60.0,
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
        searchText: lastSearchText);
    if (mounted) {
      setState(() {
        var lastItemBottomPadding = 25.0;
        bottomGapToShowLoadingMoreStatus = Container(height: 35,);
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
        const SizedBox(
          height: 30.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.15),
          child: Center(
            child: Text(isNotVerifiedAccount ? "We need to verify your account before you can find your colleagues": "No matching profiles found.", textAlign: TextAlign.center, style: style1),
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

  Widget getUsersList(List<User> users, Size media, var userData) {
    return ScrollConfiguration(
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
          // itemCount: users.length,
          shrinkWrap: true,
          children: List.generate(users.length, (i) => Padding(
            padding: i == users.length - 1 ? EdgeInsets.only(bottom: lastItemBottomPadding) : const EdgeInsets.only(bottom: 0.0),
            child: GestureDetector(
              // don't allow screen change if loading data
              onTap: () => refreshController.isLoading
                  ? () {}
                  : ()async{
                // User user = await Provider.of<NewsProvider>(context,listen: false).fetchUserById(userId: users[i].id);
                Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": users[i].id});
              },
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(80.0),
                  child: Container(height: 40.0, width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(80.0),
                    ),
                    child: users[i].profilePic == null || users[i].profilePic.isEmpty ? Padding(
                      padding: const EdgeInsets.only(top:2.0),
                      child: Image.asset(i == 0 ? "images/group.png": i == 1 ? "images/announce.png" :
                      "images/person.png", fit: BoxFit.contain, color: Colors.white,),
                    ) : Image.network(
                        users[i].profilePic, fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SpinKitCubeGrid(color: Theme.of(context).primaryColor,size: 20,),
                          );
                        },
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
              ),
            ),
          ))..add(loader),
          // itemBuilder: (context, i) => Padding(
          //   padding: i == users.length - 1 ? EdgeInsets.only(bottom: lastItemBottomPadding) : const EdgeInsets.only(bottom: 0.0),
          //   child: GestureDetector(
          //     // don't allow screen change if loading data
          //     onTap: () => refreshController.isLoading
          //         ? () {}
          //         : ()async{
          //       // User user = await Provider.of<NewsProvider>(context,listen: false).fetchUserById(userId: users[i].id);
          //       Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": users[i].id});
          //     },
          //     child: ListTile(
          //       leading: ClipRRect(
          //         borderRadius: BorderRadius.circular(80.0),
          //         child: Container(height: 40.0, width: 40.0,
          //           decoration: BoxDecoration(
          //             color: Colors.blue[200],
          //             borderRadius: BorderRadius.circular(80.0),
          //           ),
          //           child: users[i].profilePic == null || users[i].profilePic.isEmpty ? Padding(
          //             padding: const EdgeInsets.only(top:2.0),
          //             child: Image.asset(i == 0 ? "images/group.png": i == 1 ? "images/announce.png" :
          //             "images/person.png", fit: BoxFit.contain, color: Colors.white,),
          //           ) : Image.network(
          //             users[i].profilePic, fit: BoxFit.cover,
          //               loadingBuilder: (BuildContext context, Widget child,
          //                   ImageChunkEvent loadingProgress) {
          //                 if (loadingProgress == null) return child;
          //                 return Padding(
          //                   padding: const EdgeInsets.all(8.0),
          //                   child: SpinKitCubeGrid(color: Theme.of(context).primaryColor,size: 20,),
          //                 );
          //               },
          //               errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
          //                 return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],fit: BoxFit.fill,);}
          //           ),
          //         ),
          //       ),
          //       title: Text(users[i].name.toString(), style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
          //       subtitle: Text(getJobRolesCommaSeparatedList(users[i].roles) == "" ? "${users[i].trust['name']}":
          //       "${getJobRolesCommaSeparatedList(users[i].roles)}\n${users[i].trust['name']}",
          //         maxLines: 3, overflow: TextOverflow.ellipsis,
          //         style: const TextStyle(color: Colors.grey, fontSize: 14.0),),
          //     ),
          //   ),
          // ),
        ),
      ),
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
          height: 48,
          padding: const EdgeInsets.only(top: 6.0, left: 12),
          child: Row(
            children: [
              Text('$numberOfResults ' + (numberOfResults == 1 ? 'result' : 'results'),
                  style: TextStyle(
                    color: Colors.grey[500],
                  )),
              const Spacer(),
              if (searchInProgress)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              if (searchInProgress) const SizedBox(width: 8),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
      //  if (anyFiltersSet)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 4.0,top: 8,bottom: 8),
                width: media.width,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () => showModalFilterSheet(context, scScrollController, lastSearchText, defaultUserType: Provider.of<UserProvider>(context,listen: false).userData.roleType),
                        child: Text('Edit', style: TextStyle(color: filterColor))),
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



  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserProvider>(context);
    final media = MediaQuery.of(context).size;
    final discoveryProvider = Provider.of<DiscoveryProvider>(context);
    List<User> users = discoveryProvider.discoveredUsers;

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
          appBar: screenAppBar(context, media, showLeadingPop: true,
              hideProfilePic: true, appbarTitle: const Text("New Announcement"),onBackPressed: () => Navigator.pop(context)),
          body: discoveryProvider.stage == DiscoveryStage.LOADING
              ? Center(
            child: SpinKitCircle(
              color: Theme.of(context).primaryColor,
              size: 45.0,
            ),
          )
              : discoveryProvider.stage == DiscoveryStage.ERROR
              ? Center(
            child: Text(discoveryProvider.errorMessage),
          )
              : (users.isEmpty && initialLoadDone)
              ? getEmptyResultsBody(media, false):
               userData.userData.verified == false ?
              getEmptyResultsBody(media, true)
              : Stack(
                children: [
                  Column(
            children: [
                  getResultCountAndFilters(media),
                  Flexible(
                    child: kIsWeb ? getUsersList(users, media, userData) : SmartRefresher(
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
                      child: getUsersList(users, media, userData),
                    ),
                  ),
                  bottomGapToShowLoadingMoreStatus,
            ],
          ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                blurRadius: 32,
                                color: const Color(0xFF087949).withOpacity(0.08),
                              ),
                            ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  maxLines: null,
                                  controller: _announcementTextFieldController,
                                  textCapitalization: TextCapitalization.sentences,
                                  cursorColor: Theme.of(context).primaryColor,
                                  onChanged: (val){
                                    if(val != "" && val != null){
                                      setState(() {
                                        _isTextFieldEmpty = true;
                                      });
                                    }else{
                                      setState(() {
                                        _isTextFieldEmpty = false;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Type your announcement here...",
                                    hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            IconButton(icon: Icon(Icons.send_outlined,
                              color: _isTextFieldEmpty ? Theme.of(context).primaryColor : Colors.grey[300],),
                                onPressed: _isTextFieldEmpty ?
                                    () async{
                                    await Provider.of<ChatProvider>(context, listen: false)
                                        .chatAnnouncement(context, userData: userData, discoveryProvider: discoveryProvider, announcementText: _announcementTextFieldController.text);
                                    _isTextFieldEmpty = false;
                                    _announcementTextFieldController.text = "";
                                    }
                                  :
                                null
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
        ),
      ),
    );
  }
}