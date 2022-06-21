// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftDetails.dart';
import 'package:rightnurse/Subscreens/Shifts/TimeSheetShiftDetails.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class TimeSheetShifts extends StatefulWidget {
  const TimeSheetShifts({Key key}) : super(key: key);

  @override
  _TimeSheetShiftsState createState() => _TimeSheetShiftsState();
}

class _TimeSheetShiftsState extends State<TimeSheetShifts> {
  int pageOffset = 0;
  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = const SizedBox();
  bool _isLoading = true;
  ShiftsProvider shiftsProvider;

  @override
  void initState() {
    super.initState();
    shiftsProvider = Provider.of<ShiftsProvider>(context,listen: false);
    // since this screen will only show for NHSP users only there is no need to check if the user is NHSP or not
    if(shiftsProvider.timesheetdays.isNotEmpty){
      _isLoading = false;
    }else{
      shiftsProvider.fetchTimeSheets(
          context,
          endDate: dateToTimeStamp(date: DateTime.now()).seconds,
          startDate: dateToTimeStamp(date: DateTime(DateTime.now().year, DateTime.now().month-1, 1)).seconds,
          pageOffset: 0
      ).then((_){
        _isLoading = false;
      });
    }
  }


  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    setState(() {
      _isLoading= true;
      pageOffset = 0;
    });
    Provider.of<ShiftsProvider>(context, listen: false).clearTimesheetWeeksWithOffers();
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<ShiftsProvider>(context, listen: false).fetchTimeSheets(
        context,
        endDate: dateToTimeStamp(date: DateTime.now()).seconds,
        startDate: dateToTimeStamp(date: DateTime(DateTime.now().year, DateTime.now().month-1, 1)).seconds,
        pageOffset: 0
    ).then((_){
      setState(() {
        _isLoading= false;
      });
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final shiftsProvider = Provider.of<ShiftsProvider>(context);
    final ShiftsStage stage = Provider.of<ShiftsProvider>(context).timeSheetStage;

    return stage == ShiftsStage.LOADING || _isLoading
        ?
    SpinKitCircle(color: Theme.of(context).primaryColor,size: 50,)
        :
    stage == ShiftsStage.DONE && shiftsProvider.timesheetdays.isNotEmpty ?
    Column(
      children: [
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            // onLoading: _onLoading,
            footer: CustomFooter(
              builder: (BuildContext context,LoadStatus mode){
                Widget body ;
                // if(mode==LoadStatus.loading){
                //   body =  CupertinoActivityIndicator();
                // }
                // else
                  if(mode == LoadStatus.failed){
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
              shrinkWrap: true,
              itemCount: shiftsProvider.timesheetdays.length,
              itemBuilder: (context, i) =>
                  Padding(
                    padding: i == shiftsProvider.timesheetdays.length - 1 ?
                     EdgeInsets.only(bottom: lastItemBottomPadding):
                    const EdgeInsets.all(0.0),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          i == 0 ? const SizedBox(height: 5,) : const SizedBox(),
                          GestureDetector(
                              onTap: (){
                                Provider.of<ShiftsProvider>(context,listen: false).setCurrentTimeSheetShift(shiftsProvider.timesheetdays[i]);
                                Navigator.pushNamed(context, TimeSheetShiftDetails.routeName);},
                              child: timeSheetCard(context,timeSheetDay: shiftsProvider.timesheetdays[i])
                          ),
                          // i == shiftsProvider.timesheetdays.length-1 ? const SizedBox() : const Divider()
                          const Divider()
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ),
        bottomGapToShowLoadingMoreStatus
      ],
    )
        :
    stage == ShiftsStage.DONE && shiftsProvider.timesheetdays.isEmpty
        ?
    emptyShifts(context,media,'timeSheet')
        :
    netWorkError(context, media, onRetry: (){
      setState(() {
        _isLoading = true;
      });
      shiftsProvider.fetchTimeSheets(
          context,
          endDate: dateToTimeStamp(date: DateTime.now()).seconds,
          startDate: dateToTimeStamp(date: DateTime(DateTime.now().year, DateTime.now().month-1, 1)).seconds,
          pageOffset: 0
      ).then((_){
        setState(() {
          _isLoading = false;
        });
      });
    });
  }
}
