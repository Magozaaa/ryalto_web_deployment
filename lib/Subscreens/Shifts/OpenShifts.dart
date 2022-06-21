
// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Profile/MyAccountScreen.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftDetails.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftsUtils.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';


class OpenShifts extends StatefulWidget{
  const OpenShifts({Key key}) : super(key: key);




  @override
  _OpenShiftsState createState() => _OpenShiftsState();
}

class _OpenShiftsState extends State<OpenShifts> {

  int pageOffset = 0;
  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = const SizedBox();
  bool _isLoading = true;
  ShiftsProvider shiftsProvider;

  @override
  void initState() {
    shiftsProvider = Provider.of<ShiftsProvider>(context,listen: false);
    /// this condition was to prevent the reloading when i change tabs for NHSP if i got the Data once
    // if(Provider.of<UserProvider>(context,listen: false).userData.trust['system_type']['name'] == "nhsp_api" && shiftsProvider.openWeeks.isNotEmpty){
    //   _isLoading = false;
    // }else{
      shiftsProvider.fetchOffers(
          context,
          historyType: 0,
          createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(const Duration(days:1))) : "",
          startTime: shiftsProvider.startTime,
          endTime: shiftsProvider.endTime,
          wardIds: shiftsProvider.selectedAreasOfWorkIds,
          pageOffset: 0).then((_){
        _isLoading = false;
      });
    // }

    super.initState();
  }



  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    setState(() {
      _isLoading= true;
      pageOffset = 0;
    });
    Provider.of<ShiftsProvider>(context, listen: false).clearOpenWeeksWithOffers();
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<ShiftsProvider>(context, listen: false).fetchOffers(
        context,
        historyType: 0,
        createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(const Duration(days:1))) : "",
        startTime: shiftsProvider.startTime,
        endTime: shiftsProvider.endTime,
        wardIds: shiftsProvider.selectedAreasOfWorkIds,
        pageOffset: 0).then((_){
      setState(() {
        _isLoading= false;
      });
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    setState(() {
      lastItemBottomPadding = 8.0;
      bottomGapToShowLoadingMoreStatus = const SizedBox(height: 60.0,);
    });
    pageOffset += 7;
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<ShiftsProvider>(context, listen: false).fetchOffers(
        context,
        historyType: 0,
        createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(const Duration(days:1))) : "",
        startTime: shiftsProvider.startTime,
        endTime: shiftsProvider.endTime,
        wardIds: shiftsProvider.selectedAreasOfWorkIds,
        pageOffset: pageOffset
    ).then((_){
      if (mounted) {
        setState(() {
          _isLoading= false;
        });
      }
    });
    if(mounted){
      setState(() {
        lastItemBottomPadding = 25.0;
        bottomGapToShowLoadingMoreStatus = const SizedBox(height: 35.0,);
      });
      _refreshController.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final shiftsProvider = Provider.of<ShiftsProvider>(context);
    final ShiftsStage stage = Provider.of<ShiftsProvider>(context).openShiftsStage;

    return stage == ShiftsStage.LOADING || _isLoading ?
    SpinKitCircle(color: Theme.of(context).primaryColor,size: 50,)
        :
    stage == ShiftsStage.DONE && shiftsProvider.openWeeks.isNotEmpty
        ?
    Column(
      children: [
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            footer: CustomFooter(
              builder: (BuildContext context,LoadStatus mode){
                Widget body ;
                if(mode==LoadStatus.loading){
                  body =  const CupertinoActivityIndicator();
                }
                else if(mode == LoadStatus.failed){
                  body = const Text("Load Failed!Click retry!");
                }
                else if(mode == LoadStatus.canLoading){
                }
                else{
                  body = const Text("No more to load!");
                }
                return Center(child: body);
                //return Container();
              },
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: shiftsProvider.openWeeks.length+1, // count here is listLength +1 as the last element is the SizedBox
              itemBuilder: (context, i)=> i == shiftsProvider.openWeeks.length ? const SizedBox(height: 75.0,):
              expansionTileCard(
                  context: context,
                  color: const Color(0xFFF6F6F6),
                  title: "${formatStringTimeToDayAndMonth(stringTime: shiftsProvider.openWeeks[i].week_start.toString())}  -  ${formatStringTimeToDayAndMonth(stringTime: shiftsProvider.openWeeks[i].week_end.toString())}",
                  doExpansion: (_){

                  },
                  isExpanded: i == 0 ? true : false,

                  content: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: shiftsProvider.openWeeks[i].offers.length,
                      itemBuilder: (context, index) =>
                          ClipRRect(
                              borderRadius: index == shiftsProvider.openWeeks[i].offers.length-1
                                  ?
                              const BorderRadius.only(
                                  bottomLeft: Radius.circular(7),
                                  bottomRight: Radius.circular(7)
                              )
                                  :
                              BorderRadius.circular(0.0),
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                        onTap: (){
                                          Provider.of<ShiftsProvider>(context,listen: false).setCurrentOffer(shiftsProvider.openWeeks[i].offers[index]);
                                          Navigator.pushNamed(
                                              context,
                                              ShiftDetails.routeName,
                                              arguments: {
                                                "offer" : shiftsProvider.openWeeks[i].offers[index]
                                              });
                                        },
                                        child:
                                        shiftCard(
                                            context,
                                            offer: shiftsProvider.openWeeks[i].offers[index],
                                        )
                                    ),
                                    index == shiftsProvider.openWeeks[i].offers.length-1 ? const SizedBox() : const Divider()
                                  ],
                                ),
                              )),
                    ),
                  ]
              ),
            ),
          ),
        ),
        bottomGapToShowLoadingMoreStatus
      ],
    )
        :
    stage == ShiftsStage.DONE && shiftsProvider.openWeeks.isEmpty
        ?
    emptyShifts(context,media,'openShifts')
        :
    netWorkError(context, media, onRetry: (){
      setState(() {
        _isLoading = true;
      });
      shiftsProvider.fetchOffers(
          context,
          createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(const Duration(days:1))) : "",
          startTime: shiftsProvider.startTime,
          endTime: shiftsProvider.endTime,
          wardIds: shiftsProvider.selectedAreasOfWorkIds,
          historyType: 0,
          pageOffset: 0
      ).then((_){
        setState(() {
          _isLoading = false;
        });
      });
    });
  }
}
