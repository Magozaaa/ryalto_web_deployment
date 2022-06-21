// ignore_for_file: file_names, prefer_typing_uninitialized_variables, curly_braces_in_flow_control_structures, prefer_if_null_operators, unnecessary_string_interpolations

import 'dart:async';
import 'dart:io';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Models/ChannelModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/Subscreens/Chat/NewGroup.dart';
import 'package:rightnurse/Subscreens/Directory/DirectoryFilter.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:expandable/expandable.dart';


class ContactsScreen extends StatefulWidget{
  static const routeName = "/Contacts_Screen";

  const ContactsScreen({Key key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with SingleTickerProviderStateMixin {

  int pageOffset = 0;
  bool anyTextSearchDone = false;
  bool searchInProgress = false;

  ExpandableController controller = ExpandableController(initialExpanded: false);
  bool isGroupListExpanded=false;
  bool inSearchPause = false;
  Timer searchInProgressTimer;
  String lastSearchText = '';
  String timerStartSearchText = '';
  var passedData = {};
  var _isInit = true;
  var userTrustId;
  var countryCode;
  var userHospitalsIds;
  var userMembershipsIds;
  var defaultUserType;
  TextEditingController searchController;
  FocusNode searchFocusNode;
  ScrollController scScrollController;
  bool initialLoadDone = false;
  bool isNavigating = false;

  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = const SizedBox();

  RefreshController refreshController = RefreshController(initialRefresh: false);

  bool isSearchFieldVisible = false;

  @override
  void didChangeDependencies() {
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;
      if (passedData != null) {
        Provider.of<ChatProvider>(context,listen: false).fetchGroupChannelsOnly(context).then((_){
          groupChannels = Provider.of<ChatProvider>(context,listen: false).groupChannelsInContactsScreen;
        });
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  List<ChannelModel> groupChannels=[];

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
    // we only pass Data in case the user is sharing an article and we only call the below request in this case


    newDiscovery();
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
              Text(passedData != null ? '${'$numberOfResults '} ${numberOfResults == 1 ? 'Contact' : 'Contacts'}' : '$numberOfResults ' + (numberOfResults == 1 ? 'result' : 'results'),
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
        searchText: lastSearchText);
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    print('onloadinggggggggggg');
    setState(() {
      lastItemBottomPadding = 8.0;
      bottomGapToShowLoadingMoreStatus = const SizedBox(height: 60.0,);
      loader = const CupertinoActivityIndicator();
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
        lastItemBottomPadding = 25.0;
        bottomGapToShowLoadingMoreStatus = const SizedBox(height: 0,);
        loader = const SizedBox();
      });
      if (!kIsWeb) {
        refreshController.loadComplete();
      }
    }
  }

  Widget loader = const SizedBox();

  void cancelActions() {
    isSearchFieldVisible = false;
    searchController.text = '';
    lastSearchText = '';
  }


  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final discoveryProvider = Provider.of<DiscoveryProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final userData = Provider.of<UserProvider>(context);

    List<User> users = discoveryProvider.discoveredUsers;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: screenAppBar(context, media, appbarTitle: const Text("Contacts"),
        hideProfilePic: true, showLeadingPop: true,
            filterAction: users.isEmpty && initialLoadDone ? () => showModalFilterSheet(
                context,
                scScrollController,
                lastSearchText,
                defaultUserType: userData.userData.roleType): null,
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
                    cursorColor: Theme.of(context).primaryColor,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    decoration: InputDecoration(
                        prefixIcon: Transform.scale(
                          scale: 0.6,
                          child: Image.asset(
                            'images/search.png',
                            color: Theme.of(context).primaryColor,
                            width: 20,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(bottom: 0.0, left: 15.0, right: 15.0,top: 6),
                        border: InputBorder.none,
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'DIN')),
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
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  )),
            )
          ],
        ),
        preferredSize: const Size.fromHeight(60.0),
      ),
        ),

       body: (discoveryProvider.stage == DiscoveryStage.LOADING && !searchInProgress ) //|| isNavigating
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
           : users.isEmpty && initialLoadDone
           ? getEmptyResultsBody(media)
           : Column(
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
                       onTap: /*()=> !initialLoadDone ? null :*/ () => showModalFilterSheet(context, scScrollController, lastSearchText, defaultUserType: userData.userData.roleType),
                       child: Text("Add Filters", style: styleBlue,)),

                   GestureDetector(
                       onTap: ()=> Navigator.pushNamed(context, NewGroupScreen.routeName,
                       arguments: passedData != null ? {
                         "from" : "contacts",
                         "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                         "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                         "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                         "isArticleFavourite" :  passedData['isArticleFavourite'],
                         "articleCommentsCount" : passedData['articleCommentsCount'],
                         "articleId" : passedData['articleId'],
                       } : {"from" : "contacts"}),
                       child: Text("New Group", style: styleBlue,)),

                 ],
               ),
             ),
           ),

           getResultCountAndFilters(media),

           Expanded(
             flex: 1,
             child: Stack(
               children: [
                 kIsWeb ? ScrollConfiguration(
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
                       shrinkWrap: true,

                       // physics: const AlwaysScrollableScrollPhysics(),
                       children: [
                         // passedData==null
                         //     ?
                         // SizedBox()
                         //     :
                         // Padding(
                         //   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                         //   child: Container(
                         //     color: Colors.grey[200],
                         //     width: media.width,
                         //     padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                         //     child: Text('Groups',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                         //   ),
                         // ),
                         passedData==null
                             ?
                         const SizedBox()
                             :
                         ExpandablePanel(
                           controller: controller,
                           theme: const ExpandableThemeData(
                               iconPadding: EdgeInsets.only(top: 5,right: 10),
                               headerAlignment: ExpandablePanelHeaderAlignment.center,
                               tapHeaderToExpand: true,
                               hasIcon: false,
                               useInkWell: true

                           ),
                           header: Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                             child: InkWell(
                               onTap: (){
                                 controller.toggle();
                                 setState(() {
                                   isGroupListExpanded = !isGroupListExpanded;
                                 });

                                 // if (!isGroupListExpanded) {
                                 //   controller.expanded;
                                 // }
                                 // else{
                                 //   controller.toggle();
                                 // }
                               },
                               child: Container(
                                 color: Colors.grey[200],
                                 width: media.width,
                                 padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text('${groupChannels.length > 1 ? "${groupChannels.length} Groups" : "${groupChannels.length} Group"}',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                                     Icon(!isGroupListExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,color: Theme.of(context).primaryColor,)
                                   ],
                                 ),
                               ),
                             ),
                           ),
                           collapsed: const SizedBox(),
                           expanded: Column(
                             children: List.generate(groupChannels.length, (i) => Column(
                               children: [
                                 GestureDetector(
                                   onTap: () async {
                                     var myChannel = groupChannels.firstWhere((ch) => ch.name == groupChannels[i].name);//channelDetails.pubnub.channel('${channelDetails.channels[i].name}');
                                     PaginatedChannelHistory history = chatProvider.pubnub.channel('${groupChannels[i].name}').history(chunkSize: 100);
                                     Provider.of<ChatProvider>(context,listen: false).setPassedData({
                                       "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                                       history,
                                       "channel": myChannel,
                                       "channel_name": groupChannels[i].name,
                                       "pn": chatProvider.pubnub,
                                       "private_chat_user":  null,

                                       // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                                       //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                                       // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                                       // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,

                                       "type": groupChannels[i].channelType == "inbox" ? "announcement": "group",
                                       "current_user_id": userData.userData.id,
                                       "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                       "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                       "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                       "isArticleFavourite" : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                       "articleCommentsCount" : passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                       "articleId" : passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                     });
                                     if (!kIsWeb) {
                                       await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                                         "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                                         history,
                                         "channel": myChannel,
                                         "channel_name": groupChannels[i].name,
                                         "pn": chatProvider.pubnub,
                                         "private_chat_user":  null,

                                         // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                                         //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                                         // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                                         // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,

                                         "type": groupChannels[i].channelType == "inbox" ? "announcement": "group",
                                         "current_user_id": userData.userData.id,
                                         "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                         "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                         "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                         "isArticleFavourite" : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                         "articleCommentsCount" : passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                         "articleId" : passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                       });
                                     }
                                     // Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                                     //   usersIds: [users[i].id, userData.userData.id],
                                     //   channelType: "private",
                                     //   channelDisplayName: users[i].name,
                                     //   articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                     //   articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                     //   articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                     //   isArticleFavourite : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                     //   articleCommentsCount: passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                     //   articleId: passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                     // );
                                   },
                                   child: ListTile(
                                     leading: ClipRRect(
                                       borderRadius: BorderRadius.circular(80.0),
                                       child: Container(height: 40.0, width: 40.0,
                                         decoration: BoxDecoration(
                                           color: Colors.blue[200],
                                           borderRadius: BorderRadius.circular(80.0),
                                         ),
                                         child: groupChannels[i].channelImage == null || groupChannels[i].channelImage.length == 0 ? Padding(
                                           padding: const EdgeInsets.only(top:2.0),
                                           child: Image.asset("images/group.png", fit: BoxFit.contain, color: Colors.white,),
                                         ) : Image.network(
                                           groupChannels[i].channelImage,
                                           fit: BoxFit.cover,
                                           errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                             return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                           },
                                         ),
                                       ),
                                     ),
                                     title: Text(groupChannels[i].displayName == null || groupChannels[i].displayName == "" ? "Group channel":"${groupChannels[i].displayName}", style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                   ),
                                 ),
                                 const Divider()
                               ],
                             )),
                           ),
                           // builder: (context,){
                           //
                           // },
                           // tapHeaderToExpand: true,
                           // hasIcon: true,
                         )
                         // ExpandChild(
                         //   arrowColor: Colors.red,
                         //   arrowSize: 40,
                         //   expandArrowStyle: ExpandArrowStyle.both,
                         //   icon: Icons.cake,
                         //   hintTextStyle: TextStyle(fontSize: 16,color: Colors.red),
                         //   collapsedHint: 'show ${groupChannels.length > 1 ? "Groups" : "Group"}',
                         //   expandedHint: 'hide ${groupChannels.length > 1 ? "Groups" : "Group"}',
                         //   child: Column(
                         //     children: List.generate(groupChannels.length, (i) => Column(
                         //       children: [
                         //         GestureDetector(
                         //           onTap: () async {
                         //             var myChannel = groupChannels.firstWhere((ch) => ch.name == groupChannels[i].name);//channelDetails.pubnub.channel('${channelDetails.channels[i].name}');
                         //             PaginatedChannelHistory history = Provider.of<ChatProvider>(context,listen: false).pubnub.channel('${groupChannels[i].name}').history(chunkSize: 100);
                         //
                         //             await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                         //               "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                         //               history,
                         //               "channel": myChannel,
                         //               "channel_name": groupChannels[i].name,
                         //               "pn":Provider.of<ChatProvider>(context,listen: false).pubnub,
                         //               "private_chat_user":  null,
                         //
                         //               // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                         //               //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                         //               // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                         //               // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,
                         //
                         //               "type": groupChannels[i].channelType == "inbox" ? "announcement": "group",
                         //               "current_user_id": userData.userData.id,
                         //               "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                         //               "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                         //               "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                         //               "isArticleFavourite" : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                         //               "articleCommentsCount" : passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                         //               "articleId" : passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                         //             });
                         //             // Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                         //             //   usersIds: [users[i].id, userData.userData.id],
                         //             //   channelType: "private",
                         //             //   channelDisplayName: users[i].name,
                         //             //   articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                         //             //   articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                         //             //   articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                         //             //   isArticleFavourite : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                         //             //   articleCommentsCount: passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                         //             //   articleId: passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                         //             // );
                         //           },
                         //           child: ListTile(
                         //             leading: ClipRRect(
                         //               borderRadius: BorderRadius.circular(80.0),
                         //               child: Container(height: 40.0, width: 40.0,
                         //                 decoration: BoxDecoration(
                         //                   color: Colors.blue[200],
                         //                   borderRadius: BorderRadius.circular(80.0),
                         //                 ),
                         //                 child: groupChannels[i].channelImage == null || groupChannels[i].channelImage.length == 0 ? Padding(
                         //                   padding: const EdgeInsets.only(top:2.0),
                         //                   child: Image.asset(i == 0 ? "images/group.png": i == 1 ? "images/announce.png" :
                         //                   "images/person.png", fit: BoxFit.contain, color: Colors.white,),
                         //                 ) : Image.network(groupChannels[i].channelImage, fit: BoxFit.cover,errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                         //                   return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                         //                 },),
                         //               ),
                         //             ),
                         //             title: Text(groupChannels[i].displayName == null || groupChannels[i].displayName == "" ? "Group channel":"${groupChannels[i].displayName}", style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                         //           ),
                         //         ),
                         //         const Divider()
                         //       ],
                         //     )),
                         //   ),
                         //   indicatorBuilder:
                         //       (context,
                         //       showRepliesFunction,
                         //       isOpened) {
                         //     return isOpened
                         //         ? Padding(
                         //       padding: EdgeInsets.only(
                         //           top: 5,
                         //           right: 10),
                         //       child: Align(
                         //           alignment: Alignment.centerRight,
                         //           child: InkWell(
                         //               onTap: showRepliesFunction,
                         //               child: Row(
                         //                 mainAxisSize: MainAxisSize.min,
                         //                 children: [
                         //                   Text('hide ${groupChannels.length > 1 ? "Groups" : "Group"}',
                         //                     style: TextStyle(
                         //                       color: Theme.of(context).primaryColor,
                         //                     ),
                         //                   ),
                         //                   const SizedBox(width: 3,),
                         //                   Icon(
                         //                     Icons.keyboard_arrow_up,
                         //                     color: Theme.of(context).primaryColor,
                         //                     size: 16,
                         //                   )
                         //                 ],
                         //               ))),
                         //     )
                         //         : Padding(
                         //       padding: const EdgeInsets.only(
                         //           top: 5,
                         //           right: 10),
                         //       child: Align(
                         //           alignment: Alignment.centerRight,
                         //           child: InkWell(
                         //               onTap: showRepliesFunction,
                         //               child: Row(
                         //                 mainAxisSize: MainAxisSize.min,
                         //                 children: [
                         //                   Text('${groupChannels.length} ${groupChannels.length > 1 ? "Groups" : "Group"}',
                         //                     style: TextStyle(
                         //                       color: Theme.of(context).primaryColor,
                         //                     ),
                         //                   ),
                         //                   const SizedBox(width: 3,),
                         //                   Icon(
                         //                     Icons.keyboard_arrow_down,
                         //                     color: Theme.of(context).primaryColor,
                         //                     size: 16,
                         //                   )
                         //                 ],
                         //               ))),
                         //     );
                         //   },
                         // )
                         ,

                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                           child: Container(
                             color: Colors.grey[200],
                             width: media.width,
                             padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                             child: Text('Contacts',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                           ),
                         ),
                         ScrollConfiguration(
                           behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                             PointerDeviceKind.touch,
                             PointerDeviceKind.mouse,
                           },
                               overscroll: true),
                           child: ListView(
                             shrinkWrap: true,
                             physics: const AlwaysScrollableScrollPhysics(),
                             children: List.generate(users.length, (i) => Padding(
                               padding: i == users.length - 1 ? EdgeInsets.only(bottom: kIsWeb ? 0 : lastItemBottomPadding) :  const EdgeInsets.all(0.0),
                               child: Column(
                                 children: [
                                   GestureDetector(
                                     onTap: () {
                                       if (mounted) {
                                         setState(() {
                                           isNavigating = true;
                                         });
                                       }
                                       if(Provider.of<ChatProvider>(context, listen: false).openedChannelName != null && Provider.of<ChatProvider>(context, listen: false).openedChannelName.isNotEmpty){
                                         Provider.of<ChatProvider>(context, listen: false).resetChatChannelHistory();
                                         // Provider.of<ChatProvider>(context, listen: false).setChatChannelHistory(null);
                                       }
                                       chatProvider.createNewChannel(context,
                                         usersIds: [users[i].id, userData.userData.id],
                                         privateChatUser: users[i],
                                         channelType: "private",
                                         channelDisplayName: users[i].name,
                                         articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                         articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                         articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                         isArticleFavourite : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                         articleCommentsCount: passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                         articleId: passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                       ).then((_){
                                         if(mounted)
                                           setState(() {
                                             isNavigating = false;
                                           });
                                       });
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
                                             users[i].profilePic,
                                             fit: BoxFit.cover,
                                             errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                               return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                             },
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
                                   const Divider()
                                 ],
                               ),
                             ))..add(loader),
                           )

                           // ListView.builder(
                           //     physics: const AlwaysScrollableScrollPhysics(),
                           //     shrinkWrap: true,
                           //     itemCount: users.length,
                           //     itemBuilder: (context, i) =>
                           //         Padding(
                           //           padding: i == users.length - 1 ? EdgeInsets.only(bottom: lastItemBottomPadding) :  const EdgeInsets.all(0.0),
                           //           child: Column(
                           //             children: [
                           //               GestureDetector(
                           //                 onTap: () {
                           //                   if (mounted) {
                           //                     setState(() {
                           //                       isNavigating = true;
                           //                     });
                           //                   }
                           //                   if(Provider.of<ChatProvider>(context, listen: false).openedChannelName != null && Provider.of<ChatProvider>(context, listen: false).openedChannelName.isNotEmpty){
                           //                     Provider.of<ChatProvider>(context, listen: false).resetChatChannelHistory();
                           //                     // Provider.of<ChatProvider>(context, listen: false).setChatChannelHistory(null);
                           //                   }
                           //                   chatProvider.createNewChannel(context,
                           //                     usersIds: [users[i].id, userData.userData.id],
                           //                     privateChatUser: users[i],
                           //                     channelType: "private",
                           //                     channelDisplayName: users[i].name,
                           //                     articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                           //                     articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                           //                     articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                           //                     isArticleFavourite : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                           //                     articleCommentsCount: passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                           //                     articleId: passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                           //                   ).then((_){
                           //                     if(mounted)
                           //                       setState(() {
                           //                         isNavigating = false;
                           //                       });
                           //                   });
                           //                 },
                           //                 child: ListTile(
                           //                   leading: ClipRRect(
                           //                     borderRadius: BorderRadius.circular(80.0),
                           //                     child: Container(height: 40.0, width: 40.0,
                           //                       decoration: BoxDecoration(
                           //                         color: Colors.blue[200],
                           //                         borderRadius: BorderRadius.circular(80.0),
                           //                       ),
                           //                       child: users[i].profilePic == null || users[i].profilePic.isEmpty ? Padding(
                           //                         padding: const EdgeInsets.only(top:2.0),
                           //                         child: Image.asset(i == 0 ? "images/group.png": i == 1 ? "images/announce.png" :
                           //                         "images/person.png", fit: BoxFit.contain, color: Colors.white,),
                           //                       ) : Image.network(
                           //                         users[i].profilePic,
                           //                         fit: BoxFit.cover,
                           //                         errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                           //                           return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                           //                         },
                           //                       ),
                           //                     ),
                           //                   ),
                           //                   title: Text(users[i].name.toString(), style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                           //                   subtitle: Text(getJobRolesCommaSeparatedList(users[i].roles) == "" ? "${users[i].trust['name']}":
                           //                   "${getJobRolesCommaSeparatedList(users[i].roles)}\n${users[i].trust['name']}",
                           //                     maxLines: 3, overflow: TextOverflow.ellipsis,
                           //                     style: const TextStyle(color: Colors.grey, fontSize: 14.0),),
                           //                 ),
                           //               ),
                           //               const Divider()
                           //             ],
                           //           ),
                           //         )
                           // ),
                         ),
                       ],
                     ),
                   ),
                 ) : SmartRefresher(
                   enablePullDown: true,
                   enablePullUp: true,
                   controller: refreshController,
                   onRefresh: _onRefresh,
                   onLoading: _onLoading,
                   physics: const AlwaysScrollableScrollPhysics(),
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
                   child:
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
                         shrinkWrap: true,

                         // physics: const AlwaysScrollableScrollPhysics(),
                         children: [
                           // passedData==null
                           //     ?
                           // SizedBox()
                           //     :
                           // Padding(
                           //   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                           //   child: Container(
                           //     color: Colors.grey[200],
                           //     width: media.width,
                           //     padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                           //     child: Text('Groups',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                           //   ),
                           // ),
                           passedData==null
                               ?
                           const SizedBox()
                               :
                           ExpandablePanel(
                             controller: controller,
                             theme: const ExpandableThemeData(
                               iconPadding: EdgeInsets.only(top: 5,right: 10),
                               headerAlignment: ExpandablePanelHeaderAlignment.center,
                               tapHeaderToExpand: true,
                               hasIcon: false,
                               useInkWell: true

                             ),
                             header: Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                               child: InkWell(
                                 onTap: (){
                                   controller.toggle();
                                   setState(() {
                                     isGroupListExpanded = !isGroupListExpanded;
                                   });

                                   // if (!isGroupListExpanded) {
                                   //   controller.expanded;
                                   // }
                                   // else{
                                   //   controller.toggle();
                                   // }
                                 },
                                 child: Container(
                                   color: Colors.grey[200],
                                   width: media.width,
                                   padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: [
                                       Text('${groupChannels.length > 1 ? "${groupChannels.length} Groups" : "${groupChannels.length} Group"}',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                                       Icon(!isGroupListExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,color: Theme.of(context).primaryColor,)
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                             collapsed: const SizedBox(),
                             expanded: Column(
                               children: List.generate(groupChannels.length, (i) => Column(
                                 children: [
                                   GestureDetector(
                                     onTap: () async {
                                       var myChannel = groupChannels.firstWhere((ch) => ch.name == groupChannels[i].name);//channelDetails.pubnub.channel('${channelDetails.channels[i].name}');
                                       PaginatedChannelHistory history = chatProvider.pubnub.channel('${groupChannels[i].name}').history(chunkSize: 100);
                                       Provider.of<ChatProvider>(context,listen: false).setPassedData({
                                         "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                                         history,
                                         "channel": myChannel,
                                         "channel_name": groupChannels[i].name,
                                         "pn": chatProvider.pubnub,
                                         "private_chat_user":  null,

                                         // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                                         //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                                         // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                                         // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,

                                         "type": groupChannels[i].channelType == "inbox" ? "announcement": "group",
                                         "current_user_id": userData.userData.id,
                                         "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                         "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                         "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                         "isArticleFavourite" : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                         "articleCommentsCount" : passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                         "articleId" : passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                       });
                                       if (!kIsWeb) {
                                         await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                                           "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                                           history,
                                           "channel": myChannel,
                                           "channel_name": groupChannels[i].name,
                                           "pn": chatProvider.pubnub,
                                           "private_chat_user":  null,

                                           // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                                           //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                                           // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                                           // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,

                                           "type": groupChannels[i].channelType == "inbox" ? "announcement": "group",
                                           "current_user_id": userData.userData.id,
                                           "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                           "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                           "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                           "isArticleFavourite" : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                           "articleCommentsCount" : passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                           "articleId" : passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                         });
                                       }
                                       // Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                                       //   usersIds: [users[i].id, userData.userData.id],
                                       //   channelType: "private",
                                       //   channelDisplayName: users[i].name,
                                       //   articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                       //   articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                       //   articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                       //   isArticleFavourite : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                       //   articleCommentsCount: passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                       //   articleId: passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                       // );
                                     },
                                     child: ListTile(
                                       leading: ClipRRect(
                                         borderRadius: BorderRadius.circular(80.0),
                                         child: Container(height: 40.0, width: 40.0,
                                           decoration: BoxDecoration(
                                             color: Colors.blue[200],
                                             borderRadius: BorderRadius.circular(80.0),
                                           ),
                                           child: groupChannels[i].channelImage == null || groupChannels[i].channelImage.length == 0 ? Padding(
                                             padding: const EdgeInsets.only(top:2.0),
                                             child: Image.asset("images/group.png", fit: BoxFit.contain, color: Colors.white,),
                                           ) : Image.network(
                                             groupChannels[i].channelImage,
                                             fit: BoxFit.cover,
                                             errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                             return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                           },
                                           ),
                                         ),
                                       ),
                                       title: Text(groupChannels[i].displayName == null || groupChannels[i].displayName == "" ? "Group channel":"${groupChannels[i].displayName}", style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                     ),
                                   ),
                                   const Divider()
                                 ],
                               )),
                             ),
                             // builder: (context,){
                             //
                             // },
                             // tapHeaderToExpand: true,
                             // hasIcon: true,
                           )
                           // ExpandChild(
                           //   arrowColor: Colors.red,
                           //   arrowSize: 40,
                           //   expandArrowStyle: ExpandArrowStyle.both,
                           //   icon: Icons.cake,
                           //   hintTextStyle: TextStyle(fontSize: 16,color: Colors.red),
                           //   collapsedHint: 'show ${groupChannels.length > 1 ? "Groups" : "Group"}',
                           //   expandedHint: 'hide ${groupChannels.length > 1 ? "Groups" : "Group"}',
                           //   child: Column(
                           //     children: List.generate(groupChannels.length, (i) => Column(
                           //       children: [
                           //         GestureDetector(
                           //           onTap: () async {
                           //             var myChannel = groupChannels.firstWhere((ch) => ch.name == groupChannels[i].name);//channelDetails.pubnub.channel('${channelDetails.channels[i].name}');
                           //             PaginatedChannelHistory history = Provider.of<ChatProvider>(context,listen: false).pubnub.channel('${groupChannels[i].name}').history(chunkSize: 100);
                           //
                           //             await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                           //               "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                           //               history,
                           //               "channel": myChannel,
                           //               "channel_name": groupChannels[i].name,
                           //               "pn":Provider.of<ChatProvider>(context,listen: false).pubnub,
                           //               "private_chat_user":  null,
                           //
                           //               // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                           //               //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                           //               // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                           //               // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,
                           //
                           //               "type": groupChannels[i].channelType == "inbox" ? "announcement": "group",
                           //               "current_user_id": userData.userData.id,
                           //               "articleUrl" : passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                           //               "articleThumbnail" : passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                           //               "articleTitle" : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                           //               "isArticleFavourite" : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                           //               "articleCommentsCount" : passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                           //               "articleId" : passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                           //             });
                           //             // Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                           //             //   usersIds: [users[i].id, userData.userData.id],
                           //             //   channelType: "private",
                           //             //   channelDisplayName: users[i].name,
                           //             //   articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                           //             //   articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                           //             //   articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                           //             //   isArticleFavourite : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                           //             //   articleCommentsCount: passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                           //             //   articleId: passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                           //             // );
                           //           },
                           //           child: ListTile(
                           //             leading: ClipRRect(
                           //               borderRadius: BorderRadius.circular(80.0),
                           //               child: Container(height: 40.0, width: 40.0,
                           //                 decoration: BoxDecoration(
                           //                   color: Colors.blue[200],
                           //                   borderRadius: BorderRadius.circular(80.0),
                           //                 ),
                           //                 child: groupChannels[i].channelImage == null || groupChannels[i].channelImage.length == 0 ? Padding(
                           //                   padding: const EdgeInsets.only(top:2.0),
                           //                   child: Image.asset(i == 0 ? "images/group.png": i == 1 ? "images/announce.png" :
                           //                   "images/person.png", fit: BoxFit.contain, color: Colors.white,),
                           //                 ) : Image.network(groupChannels[i].channelImage, fit: BoxFit.cover,errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                           //                   return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                           //                 },),
                           //               ),
                           //             ),
                           //             title: Text(groupChannels[i].displayName == null || groupChannels[i].displayName == "" ? "Group channel":"${groupChannels[i].displayName}", style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                           //           ),
                           //         ),
                           //         const Divider()
                           //       ],
                           //     )),
                           //   ),
                           //   indicatorBuilder:
                           //       (context,
                           //       showRepliesFunction,
                           //       isOpened) {
                           //     return isOpened
                           //         ? Padding(
                           //       padding: EdgeInsets.only(
                           //           top: 5,
                           //           right: 10),
                           //       child: Align(
                           //           alignment: Alignment.centerRight,
                           //           child: InkWell(
                           //               onTap: showRepliesFunction,
                           //               child: Row(
                           //                 mainAxisSize: MainAxisSize.min,
                           //                 children: [
                           //                   Text('hide ${groupChannels.length > 1 ? "Groups" : "Group"}',
                           //                     style: TextStyle(
                           //                       color: Theme.of(context).primaryColor,
                           //                     ),
                           //                   ),
                           //                   const SizedBox(width: 3,),
                           //                   Icon(
                           //                     Icons.keyboard_arrow_up,
                           //                     color: Theme.of(context).primaryColor,
                           //                     size: 16,
                           //                   )
                           //                 ],
                           //               ))),
                           //     )
                           //         : Padding(
                           //       padding: const EdgeInsets.only(
                           //           top: 5,
                           //           right: 10),
                           //       child: Align(
                           //           alignment: Alignment.centerRight,
                           //           child: InkWell(
                           //               onTap: showRepliesFunction,
                           //               child: Row(
                           //                 mainAxisSize: MainAxisSize.min,
                           //                 children: [
                           //                   Text('${groupChannels.length} ${groupChannels.length > 1 ? "Groups" : "Group"}',
                           //                     style: TextStyle(
                           //                       color: Theme.of(context).primaryColor,
                           //                     ),
                           //                   ),
                           //                   const SizedBox(width: 3,),
                           //                   Icon(
                           //                     Icons.keyboard_arrow_down,
                           //                     color: Theme.of(context).primaryColor,
                           //                     size: 16,
                           //                   )
                           //                 ],
                           //               ))),
                           //     );
                           //   },
                           // )
                           ,

                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                             child: Container(
                               color: Colors.grey[200],
                               width: media.width,
                               padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                               child: Text('Contacts',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                             ),
                           ),
                           ScrollConfiguration(
                             behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                               PointerDeviceKind.touch,
                               PointerDeviceKind.mouse,
                             },overscroll: true),
                             child: ListView.builder(
                                 physics: const AlwaysScrollableScrollPhysics(),
                                 shrinkWrap: true,
                                 itemCount: users.length,
                                 itemBuilder: (context, i) =>
                                     Padding(
                                       padding: i == users.length - 1 ? EdgeInsets.only(bottom: lastItemBottomPadding) :  const EdgeInsets.all(0.0),
                                       child: Column(
                                         children: [
                                           GestureDetector(
                                             onTap: () {
                                               if (mounted) {
                                                 setState(() {
                                                   isNavigating = true;
                                                 });
                                               }
                                               if(Provider.of<ChatProvider>(context, listen: false).openedChannelName != null && Provider.of<ChatProvider>(context, listen: false).openedChannelName.isNotEmpty){
                                                 Provider.of<ChatProvider>(context, listen: false).resetChatChannelHistory();
                                                 // Provider.of<ChatProvider>(context, listen: false).setChatChannelHistory(null);
                                               }
                                               chatProvider.createNewChannel(context,
                                                   usersIds: [users[i].id, userData.userData.id],
                                                   privateChatUser: users[i],
                                                   channelType: "private",
                                                   channelDisplayName: users[i].name,
                                                  articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                                                  articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                                                  articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                                                    isArticleFavourite : passedData != null ? passedData['isArticleFavourite'] == null ? false : passedData['isArticleFavourite']:null,
                                                  articleCommentsCount: passedData != null ? passedData['articleCommentsCount'] == null ? null : passedData['articleCommentsCount'] : null,
                                                 articleId: passedData != null ? passedData['articleId']==null ? null : passedData['articleId'] : null ,
                                               ).then((_){
                                                 if(mounted)
                                                 setState(() {
                                                   isNavigating = false;
                                                 });
                                               });
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
                                                     users[i].profilePic,
                                                     fit: BoxFit.cover,
                                                     errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                     return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                                   },
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
                                           const Divider()
                                         ],
                                       ),
                                     )
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
                 isNavigating ?
                 Center(
                   child: SpinKitCircle(
                     color: Theme.of(context).primaryColor,
                     size: 45.0,
                   ),
                 ): const SizedBox()
               ],
             ),
           ),
           bottomGapToShowLoadingMoreStatus,
         ],
       ),
      ),
    );
  }
}