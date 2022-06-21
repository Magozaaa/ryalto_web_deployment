// ignore_for_file: file_names, unused_field, prefer_typing_uninitialized_variables, prefer_final_fields, curly_braces_in_flow_control_structures, unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Chat/Contacts.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/Subscreens/Directory/DirectoryFilter.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Subscreens/SplashScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';
import 'package:skeleton_text/skeleton_text.dart';


class ChatScreen extends StatefulWidget {
  static const String routeName = '/ChatScreen_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}



class _ChatScreenState extends State<ChatScreen> {

  PaginatedChannelHistory history;
  var _isUpdatingChannels = false;


  bool inSearchPause = false;
  int pageOffset = 0;
  bool anyTextSearchDone = false;
  bool searchInProgress = false;
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
  bool isSearchFieldVisible = false;
  bool _isLoadingInitialChannels = false;

  Widget bottomGapToShowLoadingMoreStatus = Container();
  var lastItemBottomPadding = 25.0;

  // RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    scScrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    searchInProgressTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {

    if(Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);

    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    countryCode = Provider.of<UserProvider>(context, listen: false).userData.countryCode;
    userHospitalsIds = Provider.of<UserProvider>(context, listen: false).hospitalIds;
    userMembershipsIds = Provider.of<UserProvider>(context, listen: false).membershipIds;
    defaultUserType = Provider.of<UserProvider>(context, listen: false).userData.roleType;



    if(Provider.of<ChatProvider>(context, listen: false).myKeyset == null &&
        Provider.of<ChatProvider>(context, listen: false).crateNewAuthKeyStage == ChatStage.DONE){
      Provider.of<ChatProvider>(context, listen: false).intializingKeyset(Keyset(
          subscribeKey: pnSubscribeKey,
          publishKey: pnPublishKey,
          authKey: Provider.of<ChatProvider>(context, listen: false).userAuthKey,
          uuid: UUID(Provider.of<UserProvider>(context, listen: false).userData.id)));
    }


    if(Provider.of<ChatProvider>(context, listen: false).pubnub == null &&
        Provider.of<ChatProvider>(context, listen: false).crateNewAuthKeyStage == ChatStage.DONE){
      Provider.of<ChatProvider>(context, listen: false).intializingPubnub(PubNub(defaultKeyset: Provider.of<ChatProvider>(context, listen: false).myKeyset));
    }


    if(Provider.of<ChatProvider>(context, listen: false).channels.isEmpty /*&&Provider.of<ChatProvider>(context, listen: false).stage != ChatStage.LOADING*/){
      _isLoadingInitialChannels = true;
      Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_){
        /// this one will run for first time after user logs-In or Signs up and it can't be init load as users won't notified anyway while they are not logged in
        /// -----later on will add the InIt load here too when we save the last time user went to background on logout
        /// for each user at backend so it doesn't get cleared when user logs out as its saved locally for now -------///
        Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, isFromNewChatTab: true).then((_) {
          Provider.of<ChatProvider>(context, listen: false).registerForChatPushNotifications(Provider.of<UserProvider>(context, listen: false).deviceToken);
          Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey).then((_){
            if(mounted)
              setState(() {
                _isLoadingInitialChannels = false;
              });
          });
        });
      });
    }

    if(Provider.of<ChatProvider>(context, listen: false).channels.isNotEmpty){
      if(mounted)
        setState(() {
          _isLoadingInitialChannels = false;
        });
    }



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




    newDiscovery();

    super.initState();

    // if(Provider.of<ChatProvider>(context, listen: false).channelsHistory.isEmpty)
    // loadChannelsHistory();
  }


  void initialLoad() {
    final discoveryProvider = Provider.of<DiscoveryProvider>(context, listen: false);

    discoveryProvider.clearUsers();

    discoveryProvider.fetchAvailablePositions(context, trustId: userTrustId, countryCode: countryCode, roleType: defaultUserType,profileUpdate:false);

    discoveryProvider.fetchAreasOfWork(context,
        trustId: userTrustId, countryCode: countryCode, hospitalsIds: userHospitalsIds);

    discoveryProvider.fetchMemberships(context, countryCode: countryCode, roleType: defaultUserType);

    discoveryProvider.fetchGradesBandsLanguagesAndSkills(context,
        trustId: userTrustId, countryCode: countryCode, roleType: defaultUserType);

    discoveryProvider.fetchUsers(context,
        pageOffset: 0,
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
    if (!initialLoadDone) {
      // don't await calls for initial load
      initialLoad();
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
        pageOffset: 0,
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

  void _onRefresh({bool isOnDelete= false}) async {
    setState(() {
      pageOffset = 0;
      _isLoadingInitialChannels = true;
    });
    Provider.of<DiscoveryProvider>(context, listen: false).clearUsers();

    if(isOnDelete == false)
      await Future.delayed(const Duration(milliseconds: 1000));

    await Provider.of<DiscoveryProvider>(context, listen: false).fetchUsers(context,
        pageOffset: 0,
        trustId: userTrustId,
        countryCode: countryCode,
        hospitalsIds: userHospitalsIds,
        membershipsIds: userMembershipsIds,
        initialLoad: false,
        searchText: lastSearchText);

    Provider.of<ChatProvider>(context, listen: false).clearChannels();
    Provider.of<ChatProvider>(context, listen: false).createNewAuthKey(context).then((_){
      Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, offset: 0).then((_){
        Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
        setState(() {
          _isLoadingInitialChannels = false;
        });
      });
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      bottomGapToShowLoadingMoreStatus = const SizedBox(height: 35.0,);
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    // here page offset will always increase by 1 regardless the limit !!
    pageOffset += 1;
    Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context, offset: pageOffset).then((_){
      Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
      if (mounted) {
        setState(() {
          lastItemBottomPadding = 2.0;
          bottomGapToShowLoadingMoreStatus = const SizedBox(height: 40.0,);
        });
        _refreshController.loadComplete();
      }
    });

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


  /// ************************************** if we faced any error due to channel.histroy.last == null (no element) un comment this section ******************

  // @override
  // void didChangeDependencies() async {
  //   if(_isInit){
  //
  //     Provider.of<ChatProvider>(context).channels.forEach((element) {
  //       if(element.channelType == "private"){
  //         Provider.of<ChatProvider>(context, listen: false).fetchUserById(context, userIds: element.participantIds, channelName: element.name);
  //       }
  //     });
  //
  //     _isInit = false;
  //   }
  //   super.didChangeDependencies();
  //
  // }

  /// **********************************************************************************************************************************************



  RefreshController _refreshController = RefreshController(initialRefresh: true,initialLoadStatus: LoadStatus.loading);



  // loadChannelsHistory() async{
  //   setState(() {
  //     _isLoadingchannelsHistory = true;
  //   });
  //     for(int i=0; i<Provider.of<ChatProvider>(context, listen: false).channels.length; i++){
  //     var myChannel = Provider.of<ChatProvider>(context, listen: false).pubnub.channel(Provider.of<ChatProvider>(context, listen: false).channels[i].name);
  //     PaginatedChannelHistory chHistory = myChannel.history(chunkSize: 100);
  //     await chHistory.more();
  //     Provider.of<ChatProvider>(context, listen: false).channelsHistory[Provider.of<ChatProvider>(context, listen: false).channels[i].name] = chHistory;
  //
  //     }
  //   setState(() {
  //     _isLoadingchannelsHistory = false;
  //   });
  // }

  showSubtitleForChannels(int i,{channel}) {
    final channelDetails = Provider.of<ChatProvider>(context);
    final userData = Provider.of<UserProvider>(context);
    String subTitle = "";

    // if the channel has no messages yet
    if(channelDetails.channelsLastMessage[channelDetails.channels[i].name] != null || channelDetails.newMessages[channelDetails.channels[i].name] != null){

      // if there aren't New messages yet
      if (channelDetails.newMessages[channelDetails.channels[i].name] == null && channelDetails.channelsLastMessage[channelDetails.channels[i].name] != null) {

        if(channelDetails.channels[i].channelType == "inbox"){
          Map<String, dynamic> announcementSenderInfo = {};
          String gettingFullLongBase64String(String text) {
            String res = "";
            final pattern =
            RegExp('.{1,800}'); // 800 is the size of each chunk
            pattern.allMatches(text).forEach((match) => res += match.group(0));
            return res;
          }
          List<int> listOfInts = base64Decode(
              gettingFullLongBase64String("${channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["content"]}"));
          announcementSenderInfo = json.decode(utf8.decode(listOfInts));
          subTitle = "${announcementSenderInfo["entity"]["entity"]["text"]}";
        }

        // this condition to see if the msg sent from Flutter version or not
        if (channelDetails.channelsLastMessage[channelDetails.channels[i].name].runtimeType.toString() != "int" && channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"].toString().contains("createdAt")) {

          // if msg sent from Flutter && sent by me/current_user
          if(channelDetails.channelsLastMessage[channelDetails.channels[i].name] != null){
            if (channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["user"]["uid"].toString() ==
                userData.userData.id) {
              subTitle =
              "You: ${channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["text"] == "" ?
              "Image"
                  :
              channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["customProperties"].toString().contains("isArticle")
                  ?
              "sent an article"
                  :
              channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["text"]
              }";
            }
            // the current user is not the message sender !!!!!!
            else {
              subTitle = "${channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["user"]["name"]}: "
                  "${channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["text"] == "" ?
              "Image"
                  :
              channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["customProperties"].toString().contains("isArticle")
                  ?
              "sent an article"
                  :
              channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["text"]}";
            }
          }

        }

        // adding system messages
        else if(channelDetails.channelsLastMessage[channelDetails.channels[i].name].runtimeType.toString() != "int" && channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"].toString().contains("uid") == false
            && channelDetails.channels[i].channelType != "inbox"){
          Map<String, dynamic> systemMsgInfo = {};
          String gettingFullLongBase64String(String text) {
            String res = "";
            final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
            pattern.allMatches(text).forEach((match) => res += match.group(0));
            return res;
          }
          List<int> listOfInts = base64Decode(
              gettingFullLongBase64String("${channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["content"]}"));
          systemMsgInfo = json.decode(utf8.decode(listOfInts));
          // participants_removed system message
          if(systemMsgInfo["type"] == "participants_removed"){
            subTitle = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : "Admin"} removed ${systemMsgInfo["entity"]["participant_names"].toString().replaceAll("[", "").replaceAll("]", "")}";}
          // participants_added system message
          if(systemMsgInfo["type"] == "participants_added"){
            subTitle = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : "Admin"} added ${systemMsgInfo["entity"]["participant_names"].toString().replaceAll("[", "").replaceAll("]", "")}";
          }
          // group_created system message
          if(systemMsgInfo["type"] == "group_created"){
            subTitle = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : systemMsgInfo["entity"]["sender_name"]} created group";
          }
          // left_group system message
          if(systemMsgInfo["type"] == "left_group"){
            subTitle = "${systemMsgInfo["entity"]["sender_name"]} left chat";
          }
        }

        // this means msg is sent from Kotlin or Swift
        else {
          // if the conversation is 1-to-1 chat
          if (channelDetails.channelsLastMessage[channelDetails.channels[i].name].runtimeType.toString() != "int" && channelDetails.channels[i].channelType == "person") {
            // if MSG is sent by me/current_user
            if (channelDetails.channelsLastMessage[channelDetails.channels[i]
                .name][0]["message"]["pn_gcm"]["data"]["title"] ==
                userData.userData.name) {
              subTitle = "You: ${channelDetails.channelsLastMessage[channelDetails
                  .channels[i].name][0]["message"]["pn_gcm"]["data"]["body"] == ""
                  ?
              "Image"
                  :
              channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["customProperties"].toString().contains("isArticle")
                  ?
              "sent an article"
                  :
              channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["pn_gcm"]["data"]["body"]}";
            } else {
              // if MSG isn't sent by me/current_user
              subTitle =
              "${channelDetails.channelsLastMessage[channelDetails.channels[i]
                  .name][0]["message"]["pn_gcm"]["data"]["text"]}";
            }
          }
          else /*if(channelDetails.channels[i].channelType == "inbox")*/{
            if (channelDetails.channelsLastMessage[channelDetails.channels[i].name].runtimeType.toString() != "int" && channelDetails.channelsLastMessage[channelDetails.channels[i]
                .name][0]["message"]["pn_gcm"].toString().contains("data")) {
              // if the conversation is group_chat
              if (channelDetails.channelsLastMessage[channelDetails.channels[i]
                  .name][0]["message"]["pn_gcm"]["data"]["subtitle"] ==
                  userData.userData.name) {
                subTitle =
                "You: ${channelDetails.channelsLastMessage[channelDetails
                    .channels[i].name][0]["message"]["pn_gcm"]["data"]["body"]}";
              } else {
                subTitle =
                "${channelDetails.channelsLastMessage[channelDetails.channels[i]
                    .name][0]["message"]["pn_gcm"]["data"]["text"]}";
              }
            }
          }
        }

      }

      // if there are new messages !!!
      else if(channelDetails.newMessages[channelDetails.channels[i].name] != null){

        if(channelDetails.channels[i].channelType == "inbox"){
          // Map<String, dynamic> announcementSenderInfo = {};
          // String gettingFullLongBase64String(String text) {
          //   String res = "";
          //   final pattern =
          //   RegExp('.{1,800}'); // 800 is the size of each chunk
          //   pattern.allMatches(text).forEach((match) => res += match.group(0));
          //   return res;
          // }
          // debugPrint("heeeye &&&&&&&&&&&&${channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["text"]}");
          // List<int> listOfInts = base64Decode(
          //     gettingFullLongBase64String("${channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["text"]}"));
          // announcementSenderInfo = json.decode(utf8.decode(listOfInts));
          subTitle = channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["text"];//"${announcementSenderInfo["entity"]["entity"]["text"]}";
        }


        // if new MSG is sent from Flutter
        if (channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"].toString().contains("isArticle")) {
          // if the new MSG is sent by me
          if (channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["senderId"].toString() == userData.userData.id) {
            subTitle =
            "You: ${
                channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["isArticle"] == true
                    ?
                "sent an article" :
                channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["body"] == "" ?
                "Image" :
                channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["body"]}";
          }
          // other user sent the message
          else {
            subTitle = channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["isArticle"] == true ?
            "${channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["title"]}: Sent an article" :

            "${channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["body"] == "" ?
            "${channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["title"]}: Image" : channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"]["data"]["text"]}";
          }
        }

        // New MSG is sent from Kotlin or Swift
        else {
          // if the conversation is 1-to-1 chat
          if (channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"].toString().contains("isArticle") == false && channelDetails.channels[i].channelType == "person"){

            // if MSG is sent by me/current_user
            if (channelDetails.newMessages[channelDetails.channels[i].name].payload["pn_gcm"]["data"]["title"] == userData.userData.name) {
              subTitle = "You: ${
              /*channelDetails.newMessages[channelDetails.channels[i].name].payload["pn_gcm"]["data"]["body"] == ""
                  ?
              "Image"
                  :
              channelDetails.newMessages[channelDetails.channels[i].name].payload['customProperties'].toString().contains('isArticle') == true
                  ?
              "sent an article"
                  :*/
                  channelDetails.newMessages[channelDetails.channels[i].name].payload["pn_gcm"]["data"]["body"]}";
            } else {
              // if MSG isn't sent by me/current_user
              subTitle =
              "${channelDetails.newMessages[channelDetails.channels[i].name].payload["pn_gcm"]["data"]["text"]}";
            }
          }
          /// System messages
          else if(channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"].toString().contains("isArticle") == false && channelDetails.channels[i].channelType != "inbox"){
            Map<String, dynamic> systemMsgInfo = {};
            String gettingFullLongBase64String(String text) {
              String res = "";
              final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
              pattern.allMatches(text).forEach((match) => res += match.group(0));
              return res;
            }
            List<int> listOfInts = base64Decode(
                gettingFullLongBase64String("${channelDetails.newMessages[channelDetails.channels[i].name]['content']}"));
            systemMsgInfo = json.decode(utf8.decode(listOfInts));

            // participants_removed system message
            if(systemMsgInfo["type"] == "participants_removed"){
              subTitle = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : "Admin"} removed ${systemMsgInfo["entity"]["participant_names"].toString().replaceAll("[", "").replaceAll("]", "")}";}
            // participants_added system message
            if(systemMsgInfo["type"] == "participants_added"){
              subTitle = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : "Admin"} added ${systemMsgInfo["entity"]["participant_names"].toString().replaceAll("[", "").replaceAll("]", "")}";
            }
            // group_created system message
            if(systemMsgInfo["type"] == "group_created"){
              subTitle = "${systemMsgInfo["sender_id"] == Provider.of<UserProvider>(context, listen: false).userData.id ? "You" : systemMsgInfo["entity"]["sender_name"]} created group";
            }
            // left_group system message
            if(systemMsgInfo["type"] == "left_group"){
              subTitle = "${systemMsgInfo["entity"]["sender_name"]} left chat";
            }
          }

          else if(channelDetails.newMessages[channelDetails.channels[i].name]["pn_gcm"].toString().contains("isArticle") == false && channelDetails.channels[i].channelType == "group"){
            if (channelDetails.newMessages[channelDetails.channels[i].name]
                .payload["pn_gcm"]["data"]["subtitle"] ==
                userData.userData.name) {
              subTitle =
              "You: ${
              /*channelDetails.newMessages[channelDetails.channels[i].name].payload["pn_gcm"]["data"]["body"] == ""
                  ?
              "Image"
                  :
              channelDetails.newMessages[channelDetails.channels[i].name].payload['customProperties'].toString().contains('isArticle')==true
                  ?
              "sent an article"
                  :*/
                  channelDetails.newMessages[channelDetails.channels[i].name].payload["pn_gcm"]["data"]["body"]}";
            } else {
              // if MSG isn't sent by me/current_user
              subTitle =
              "${channelDetails.newMessages[channelDetails.channels[i].name].payload["pn_gcm"]["data"]["text"]}";
            }
          }

          else {
            // if its an announcement !!!
          }
        }
      }
    }
    return subTitle;
  }

  showTimetokenForLastMessage(int i) {
    final channelDetails = Provider.of<ChatProvider>(context);
    String timeToken = "";
    if(channelDetails.channels[i].createdAt != null){
      channelDetails.channels[i].updatedAt != null ?
      "${DateFormat('E ''HH:mm').format(DateTime.fromMillisecondsSinceEpoch(channelDetails.channels[i].updatedAt))}" :
      "${DateFormat('E ''HH:mm').format(DateTime.fromMillisecondsSinceEpoch(channelDetails.channels[i].createdAt))}";
    }


    // if the channel has no messages yet
    if(channelDetails.channelsLastMessage[channelDetails.channels[i].name] != null || channelDetails.newMessages[channelDetails.channels[i].name] != null){

      // if there aren't New messages yet
      if (channelDetails.newMessages[channelDetails.channels[i].name] == null && channelDetails.channelsLastMessage[channelDetails.channels[i].name] != null) {

        // MSG is sent from Flutter version
        if (channelDetails.channelsLastMessage[channelDetails.channels[i].name].runtimeType.toString() != "int"
            && channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"].toString().contains("createdAt")) {

          timeToken = "${DateFormat('E ''HH:mm').format(DateTime.fromMillisecondsSinceEpoch(channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["message"]["createdAt"]))}";

        }
        // MSG is sent from NativeKotlin or Swift
        else if(channelDetails.channelsLastMessage[channelDetails.channels[i].name].runtimeType.toString() != "int") {

          timeToken = "${DateFormat('E ''HH:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(channelDetails.channelsLastMessage[channelDetails.channels[i].name][0]["timetoken"].toString().substring(0, 13))))}";

        }
      }
      // if there are new messages !!!
      else {
        // if new MSG is sent from Flutter
        if (channelDetails.newMessagesCreatedAt[channelDetails.channels[i].name].payload.toString().contains("createdAt")) {

          timeToken = "${DateFormat('E ''HH:mm').format(DateTime.fromMillisecondsSinceEpoch(channelDetails.newMessagesCreatedAt[channelDetails.channels[i].name].payload["createdAt"]))}";

        }
        // New MSG is sent from Kotlin or Swift
        else {
          timeToken = "${DateFormat('E ''HH:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(channelDetails.newMessagesCreatedAt[channelDetails.channels[i].name].timetoken.toString().substring(0, 13))))}";
        }
      }
    }

    return timeToken;
  }


  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final channelDetails = Provider.of<ChatProvider>(context);
    // final discoveryProvider = Provider.of<DiscoveryProvider>(context);
    final userData = Provider.of<UserProvider>(context);

    // final myKeyset = Keyset(
    //     subscribeKey: pnSubscribeKey,
    //     publishKey: pnPublishKey,
    //     authKey: channelDetails.userAuthKey,
    //     uuid: UUID(userData.userData.id));
    // final pubnub = PubNub(defaultKeyset: myKeyset);


    return Scaffold(
        backgroundColor: Colors.white,
        appBar: screenAppBar(context, media,
            isMainScreen: true,
            appbarTitle: Column(
                children: [
                  Text(userData.userData == null ? "": "${userData.userData.trust["name"]}",style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400),),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text("Chat",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                  ),
                ]
            ),
            announcementAction: userData.userData.headUser && userData.userData.verified ? ()async {
              showModalFilterSheet(context, scScrollController, lastSearchText, isAnnouncement: true, defaultUserType: userData.userData.roleType);
              // await channelDetails.chatAnnouncement(context, userData: userData, discoveryProvider: discoveryProvider);
              AnalyticsManager.track('messaging_new_announcement');
            } : null,
            createChatAction: userData.userData.verified ? ()=> Navigator.pushNamed(context, ContactsScreen.routeName) : null,
            showLeadingPop: false),

        body:
        // channelDetails.stage == ChatStage.LOADING || channelDetails.loadingLastMsgs == ChatStage.LOADING  /*|| _isUpdatingChannels */?
        // Center(
        //   child: SpinKitCircle(
        //     color: Theme.of(context).primaryColor,
        //     size: 45.0,
        //   ),
        // )
        //     :
        // channelDetails.stage == ChatStage.DONE && channelDetails.loadingLastMsgs == ChatStage.DONE && userData.userData.verified ?
        Column(
          children: [
            channelDetails.crateNewAuthKeyStage == ChatStage.LOADING
                ?
            Container(
              height:5,
              margin: const EdgeInsets.all(0),
              child: LinearProgressIndicator(
                backgroundColor: const Color(0xFFebf5fe),
                color: Theme.of(context).primaryColor,
                minHeight: 2,
              ),
            )
                :
            const SizedBox(),
            Expanded(
              child: SmartRefresher(
                physics: const AlwaysScrollableScrollPhysics(),
                enablePullDown: true,
                enablePullUp: true,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading:
                // MyApp.flavor == "staging" ?
                _onLoading,
                // : null,
                footer: CustomFooter(
                  builder: (BuildContext context,LoadStatus mode){
                    Widget body ;
                    print('kokokokokokoko ${_refreshController.footerStatus}');
                    if(mode==LoadStatus.loading){
                      body = const CupertinoActivityIndicator();
                    }
                    else if(mode == LoadStatus.failed){
                      body = Padding(
                        padding: const EdgeInsets.only(bottom: 60.0),
                        child: Center(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                _isLoadingInitialChannels = true;
                              });
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
                        ),
                      );
                    }
                    else if(mode == LoadStatus.canLoading){
                    }
                    else{
                      body = const Padding(
                        padding: EdgeInsets.only(bottom: 40.0),
                        child: Text("No more to load!"),
                      );
                    }
                    return Center(child: body);
                    //return Container();
                  },
                ),
                child:
                // channelDetails.stage == ChatStage.LOADING || channelDetails.loadingLastMsgs == ChatStage.LOADING  /*|| _isUpdatingChannels */?
                _isLoadingInitialChannels /*|| channelDetails.shouldShowLoaderInChatTab*/ ?
                Center(
                  child: SpinKitCircle(
                    color: Theme.of(context).primaryColor,
                    size: 45.0,
                  ),
                )
                    :
                channelDetails.stage == ChatStage.ERROR
                    ?
                Center(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          _isLoadingInitialChannels = true;
                        });
                        _onRefresh();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Network Error retry? "),
                          Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
                        ],
                      ),
                    )
                )
                    :
                userData.userData.verified == false ?
                Center(child: Column(mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Your messages", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),),
                    const SizedBox(height: 15.0,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: media.width * 0.12),
                      child: Center(
                          child: Text("Once your profile is verified you'll be able to chat with colleagues. If you need help feel free to contact our support team.",
                            textAlign: TextAlign.center,
                            style: style3,)
                      ),
                    ),
                    needHelp(context,type: 'chat'),
                    const SizedBox(height: 25.0,)
                  ],),):
                ListView.builder(
                    itemCount: channelDetails.channels.length,
                    // reverse: true,
                    itemBuilder: (context, i)=>
                        Padding(
                          padding: i == channelDetails.channels.length - 1 ? EdgeInsets.only(bottom: lastItemBottomPadding) : const EdgeInsets.only(bottom: 0.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async{
                                  var myChannel = channelDetails.channels.firstWhere((ch) => ch.name == channelDetails.channels[i].name);//channelDetails.pubnub.channel('${channelDetails.channels[i].name}');
                                  history = channelDetails.pubnub.channel('${channelDetails.channels[i].name}').history(chunkSize: 60);
                                  channelDetails.setCurrentChannel(myChannel);
                                  // if(history.messages == null)
                                  // await history.more();


                                  if(channelDetails.channels[i].channelType == "inbox"){
                                    await channelDetails.fetchChannelByName(channelName: channelDetails.channels[i].name);
                                  }


                                  if(history.messages != null){
                                    if (channelDetails.doesChannelHasNewMsg[channelDetails.channels[i].name] != null) {
                                      channelDetails.setNewMSGforChannelToNull(channelDetails.channels[i].name);
                                    }
                                    channelDetails.clearPassedData();
                                    channelDetails.setPassedData({
                                      "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                                      history,
                                      "channel": myChannel,
                                      "channel_name": channelDetails.channels[i].name,
                                      "pn":channelDetails.pubnub,
                                      "private_chat_user": (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") ? channelDetails.channelUsers[channelDetails.channels[i].name][0] : null,

                                      // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                                      //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                                      // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                                      // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,

                                      "type": channelDetails.channels[i].channelType == "group" ? "group":
                                      channelDetails.channels[i].channelType == "inbox" ? "announcement": "person",
                                      "current_user_id": userData.userData.id,
                                      "sender_name": null,
                                      "channel_id": channelDetails.channels[i].id
                                    });
                                    // await Navigator.pushNamed(context, MessagingScreen.routeName, arguments: {
                                    //   "conversation_messages": //channelDetails.channelsHistory[channelDetails.channels[i].name],
                                    //   history,
                                    //   "channel": myChannel,
                                    //   "channel_name": channelDetails.channels[i].name,
                                    //   "pn":channelDetails.pubnub,
                                    //   "private_chat_user": (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") ? channelDetails.channelUsers[channelDetails.channels[i].name][0] : null,
                                    //
                                    //   // "chat_title": channelDetails.channelUsers[channelDetails.channels[i].name] == null ? "Conversation with 0 users" : channelDetails.channels[i].channelType == "group" &&
                                    //   //     (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ? "Group channel":
                                    //   // (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name??"private chat":
                                    //   // channelDetails.channels[i].channelType == "inbox" ? "Announcement" : channelDetails.channels[i].displayName,
                                    //
                                    //   "type": channelDetails.channels[i].channelType == "group" ? "group":
                                    //   channelDetails.channels[i].channelType == "inbox" ? "announcement": "person",
                                    //   "current_user_id": userData.userData.id,
                                    //   "sender_name": null,
                                    //   "channel_id": channelDetails.channels[i].id
                                    // });
                                    if (channelDetails.channels[i].channelType == "group") {
                                      AnalyticsManager.track('messaging_group_opened');
                                    }
                                    else if (channelDetails.channels[i].channelType == "private"){
                                      AnalyticsManager.track('messaging_individual_opened');
                                    }
                                    else if (channelDetails.channels[i].channelType == "inbox"){
                                      AnalyticsManager.track('announcement_read');
                                    }

                                    // channelDetails.setNewMSGforChannelToNull(channelDetails.channels[i].name);
                                    // setState(() {
                                    //   _doesChannelHasNewMsg[channelDetails.channels[i].name] = null;
                                    // });

                                  }

                                },
                                child: Slidable(
                                  actionPane: const SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.18,
                                  secondaryActions: channelDetails.channels[i].channelType == "inbox" ? null : <Widget>[
                                    IconSlideAction(
                                      caption: 'Delete',
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () {
                                        showAnimatedCustomDialog(context, title: "Leave this channel?", message: "Once you leave this channel you won't receive any messages and won't be able to see old messages.",
                                            buttonText: "Leave", cancelButtonTitle: "Cancel", onClicked: () {
                                              channelDetails.leaveChat(context, channelId: channelDetails.channels[i].id)
                                                  .then((_) {
                                                _onRefresh(isOnDelete: true);
                                              });
                                              Navigator.pop(context);
                                            });
                                      },
                                    ),
                                  ],
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(80.0),
                                      child: Container(height: 40.0, width: 40.0,
                                        decoration: BoxDecoration(
                                            color: Colors.blue[200],
                                            borderRadius: BorderRadius.circular(75.0),
                                            border: Border.all(width: 0.8,color: const Color(0xFFEEEEEE))
                                        ),
                                        child: channelDetails.channels[i].channelImage == null
                                            ?
                                        (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null
                                            ?
                                        Image.network(channelDetails.channelUsers[channelDetails.channels[i].name][0].profilePic, fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                            return Image.asset('images/person.png',color: Colors.white,);
                                          },) :
                                        Image.asset(channelDetails.channels[i].channelType == "group" ? "images/group.png"
                                            : channelDetails.channels[i].channelType == "inbox" ? "images/announce.png" :
                                        "images/person.png", fit: BoxFit.fill, color: Colors.white,)
                                            :
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(75.0),
                                          child: Image.network(channelDetails.channels[i].channelImage, fit: BoxFit.cover,errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                            return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                          },),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      channelDetails.channels[i].channelType == "group" && (channelDetails.channels[i].displayName == null || channelDetails.channels[i].displayName == "") ?
                                      channelDetails.channelUsers[channelDetails.channels[i].name] == null && channelDetails.channels[i].channelType != "inbox" ? "Conversation with 0 users" :"Group channel":
                                      channelDetails.channels[i].channelType == "inbox" ? "Announcement":
                                      (channelDetails.channels[i].channelType == "private" || channelDetails.channels[i].channelType == "person") && channelDetails.channelUsers[channelDetails.channels[i].name] != null ? channelDetails.channelUsers[channelDetails.channels[i].name][0].name :
                                      channelDetails.channels[i].displayName??"Chat",
                                      style: channelDetails.doesChannelHasNewMsg[channelDetails.channels[i].name] == true
                                      // ||
                                      // (channelDetails.channels[i].lastMsgAt ?? 0) > (channelDetails.lastMsgTimeForEachChannelLocally[channelDetails.channels[i].name] ?? (channelDetails.channels[i].lastMsgAt ?? 0))

                                          ? styleBlue : style2, maxLines: 1, overflow: TextOverflow.ellipsis,),

                                    subtitle: channelDetails.loadingLastMsgs == ChatStage.LOADING ?
                                    SkeletonAnimation(
                                        child: const Text("Loading.....", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 14.0),)):
                                    Text(showSubtitleForChannels(i),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(color: channelDetails.doesChannelHasNewMsg[channelDetails.channels[i].name] == true
                                      // ||
                                      // (channelDetails.channels[i].lastMsgAt ?? 0) > (channelDetails.lastMsgTimeForEachChannelLocally[channelDetails.channels[i].name] ?? (channelDetails.channels[i].lastMsgAt ?? 0))
                                          ? Colors.black : Colors.grey, fontSize: 14.0),),

                                    trailing:
                                    SizedBox(
                                      width: 80.0,
                                      child: Column(mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Text(showTimetokenForLastMessage(i),

                                              style: TextStyle(fontSize: 12.0, color: channelDetails.doesChannelHasNewMsg[channelDetails.channels[i].name] == null
                                              // ||
                                              // (channelDetails.channels[i].lastMsgAt ?? 0) > (channelDetails.lastMsgTimeForEachChannelLocally[channelDetails.channels[i].name] ?? (channelDetails.channels[i].lastMsgAt ?? 0))
                                                  ? Colors.grey : Theme.of(context).primaryColor)),

                                          channelDetails.doesChannelHasNewMsg[channelDetails.channels[i].name] == true
                                          // ||
                                          // (channelDetails.channels[i].lastMsgAt ?? 0) > (channelDetails.lastMsgTimeForEachChannelLocally[channelDetails.channels[i].name] ?? (channelDetails.channels[i].lastMsgAt ?? 0))
                                              ? const SizedBox(height: 10.0,) :
                                          const SizedBox(),

                                          channelDetails.doesChannelHasNewMsg[channelDetails.channels[i].name] == true
                                          // ||
                                          // (channelDetails.channels[i].lastMsgAt ?? 0) > (channelDetails.lastMsgTimeForEachChannelLocally[channelDetails.channels[i].name] ?? (channelDetails.channels[i].lastMsgAt ?? 0))
                                              ?
                                          Container(height: 12.0, width: 12.0,
                                            decoration: BoxDecoration(
                                                borderRadius: textFieldBorderRadius,
                                                color: Theme.of(context).primaryColor
                                            ),) : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal:
                                    20.0),
                                    dense:true,


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
            bottomGapToShowLoadingMoreStatus
          ],
        )
      //     :
      // channelDetails.stage == ChatStage.ERROR
      //     ?
      // Center(
      //   child: InkWell(
      //     onTap: (){
      //       setState(() {
      //         _isLoadingInitialChannels = true;
      //       });
      //       _onRefresh();
      //     },
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         const Text("Network Error retry? "),
      //         Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
      //       ],
      //     ),
      //   )
      // )
      //     :
      // userData.userData.verified == false ?
      // Center(child: Column(mainAxisSize: MainAxisSize.min,
      //   children: [
      //     const Text("Your messages", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),),
      //     const SizedBox(height: 15.0,),
      //     Padding(
      //       padding: EdgeInsets.symmetric(horizontal: media.width * 0.12),
      //       child: Center(
      //           child: Text("Once your profile is verified you'll be able to chat with colleagues. If you need help feel free to contact our support team.",
      //             textAlign: TextAlign.center,
      //             style: style3,)
      //       ),
      //     ),
      //     needHelp(context),
      //     const SizedBox(height: 25.0,)
      //   ],),)
      //     :
      // Center(
      //   child: SpinKitCircle(
      //     color: Theme.of(context).primaryColor,
      //     size: 45.0,
      //   ),
      // ),
    );
  }

}