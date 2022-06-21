import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/ShiftModel.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Directory/ListFilterSheet.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/Shifts/NHSPLogin.dart';
import 'package:rightnurse/Subscreens/Shifts/DayOffers.dart';
import 'package:rightnurse/Subscreens/Shifts/OpenShifts.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftsUtils.dart';
import 'package:rightnurse/Subscreens/Shifts/TimeSheetDeclaration.dart';
import 'package:rightnurse/Subscreens/Shifts/TimeSheetShifts.dart';
import 'package:rightnurse/Subscreens/Shifts/UpcomingShifts.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';

class Shifts extends StatefulWidget{
  @override
  _ShiftsState createState() => _ShiftsState();
}

class _ShiftsState extends State<Shifts> with SingleTickerProviderStateMixin{

  final nhspLinkForShifts = "https://bank.nhsp.uk/login";
  TabController _tabController;

  // bool _isNewActive = false;

  // Map<int,dynamic> _shiftTypes = {
  //   0 : false,  // Early
  //   1 : false,  // Late
  //   2 : false   // Night
  // };
  //
  // String _startTime = '';
  // String _endTime='';


  DiscoveryProvider discoveryProvider;
  ShiftsProvider shiftsProvider;

  checkAcceptedTimeSheetDeclaration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Provider.of<ShiftsProvider>(context,listen: false).setAcceptedTimeSheetDeclaration(prefs.getBool("acceptedTimeSheetDeclaration"));
    print(prefs.getBool("acceptedTimeSheetDeclaration"));
  }


  @override
  void initState() {
    super.initState();
    if(Provider.of<UserProvider>(context, listen: false).userData == null)
      Provider.of<UserProvider>(context, listen: false).getUser(context);
    checkAcceptedTimeSheetDeclaration();
    discoveryProvider = Provider.of<DiscoveryProvider>(context, listen: false);
    shiftsProvider = Provider.of<ShiftsProvider>(context,listen: false);
    if (discoveryProvider.areasOfWork == null || discoveryProvider.areasOfWork.isEmpty) {
      discoveryProvider.fetchAreasOfWork(context,
          trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"], countryCode: Provider.of<UserProvider>(context, listen: false).userData.countryCode, hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds);
    }
    _tabController = TabController(vsync: this,
      length: Provider.of<UserProvider>(context, listen: false).userData.trust['system_type']['name'] == 'nhsp_api'
          && Provider.of<ShiftsProvider>(context, listen: false).isCalendarView == false
            ? 3 : 2, initialIndex: 0);

    _tabController.addListener(() {

      if(_tabController.indexIsChanging){
        shiftsProvider.setCurrentShiftType(_tabController.index);
        shiftsProvider.clearDayOffers();
      }
    });
    AnalyticsManager.track("screen_shift");
  }

  @override
  void dispose() {
    _tabController.dispose();
    // if (calendarTabController != null) {
    //   calendarTabController.dispose();
    // }
    super.dispose();
  }

  fetchData(){
    if (shiftsProvider.isCalendarView) {
      shiftsProvider.clearDayOffers();
      shiftsProvider.fetchCalendarDaysWithOffers(
          context,
          startDate: shiftsProvider.startDay,
          endDate: shiftsProvider.endDay,
          historyType: shiftsProvider.currentShiftType,
          createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",
          startTime: shiftsProvider.startTime,
          endTime: shiftsProvider.endTime,
          wardIds: shiftsProvider.selectedAreasOfWorkIds,
          sendFromCalendar: true
      );
    }
    else {
      Provider.of<ShiftsProvider>(context, listen: false).clearOpenWeeksWithOffers();
      // Provider.of<ShiftsProvider>(context, listen: false).clearUpComingWeeksWithOffers();

      Provider.of<ShiftsProvider>(context, listen: false).fetchOffers(
        context,
        historyType: 0,//shiftsProvider.currentShiftType,
        pageOffset: 0,
        createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",
        startTime: shiftsProvider.startTime,
        endTime: shiftsProvider.endTime,
        wardIds: shiftsProvider.selectedAreasOfWorkIds,

      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);


    return DefaultTabController(
      initialIndex: 0,
      length: userData.userData.trust['system_type']['name'] == 'nhsp_api' && Provider.of<ShiftsProvider>(context).isCalendarView == false
          ? 3 : 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: screenAppBar(context, media,
          isMainScreen: true,
          appbarTitle: Column(
            children: [
              Text(userData.userData == null ? "": "${userData.userData.trust["name"]}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Text("Shifts",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
              ),
            ]
        ),
          // here we are checking if the current user is NSH-Professionals or NHSP as both doesn't need to see filters button
          filterAction: (userData.userTrustId == "18928788-e701-4b8d-b810-431a20a7dca8" || userData.userTrustId == "6a5a61ee-a53c-4518-99bd-b900953b4dbe") || (userData.userData.trust['system_type']['name'] == 'nhsp_api') ? null : ()=>
              showModalBottomSheet(
            isDismissible: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
              isScrollControlled: true,
              backgroundColor: Colors.white,
              context: context,
              builder: (context) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return isWorkAreasVisibleInShiftsFilter
                          ? ListFilterSheet(
                            width: media.width,
                            height: media.height * 0.6,
                            sheetTitle: 'Areas of Work',
                            items: discoveryProvider.orderedAreasOfWorkMap,
                            currentItemFilters: shiftsProvider.selectedAreasOfWorkIds,
                            popSheetFunction: () {
                              setState(() {
                                isWorkAreasVisibleInShiftsFilter = false;
                              });
                            },
                            onDoneFunction: (List<String> newIdsList) async {
                              shiftsProvider.selectedAreasOfWorkIds = newIdsList;
                            },
                          )
                          : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: styleYellow,
                                  ),
                                ),
                                Text(
                                  "Shift Filter",
                                  style: style1,
                                ),
                                FlatButton(
                                  onPressed:(){
                                    shiftsProvider.setShouldUpdateCalendarData(true);
                                    Map<int,dynamic> selectedShiftTypes = {};

                                    shiftsProvider.shiftTypes.forEach((key, value) {
                                      if (value) {
                                        if (key == 0) {
                                          selectedShiftTypes[key] = {
                                            "startTime" : "02:00",
                                            "endTime" : "10:00"
                                          };
                                        }
                                        else if (key == 1){
                                          selectedShiftTypes[key] = {
                                            "startTime" : "10:00",
                                            "endTime" : "18:00"
                                          };
                                        }
                                        else{
                                          selectedShiftTypes[key] = {
                                            "startTime" : "18:00",
                                            "endTime" : "02:00"
                                          };
                                        }

                                      }
                                    });

                                    if(selectedShiftTypes.isNotEmpty){
                                      if (selectedShiftTypes.length==2) {
                                        if(selectedShiftTypes.containsKey(0) && selectedShiftTypes.containsKey(2)){
                                          shiftsProvider.startTime = selectedShiftTypes.values.last["startTime"];
                                          shiftsProvider.endTime = selectedShiftTypes.values.first["endTime"];
                                        }
                                        else{
                                          shiftsProvider.startTime = selectedShiftTypes.values.first["startTime"];
                                          shiftsProvider.endTime = selectedShiftTypes.values.last["endTime"];
                                        }
                                      }
                                      else{
                                        shiftsProvider.startTime = selectedShiftTypes.values.first["startTime"];
                                        shiftsProvider.endTime = selectedShiftTypes.values.last["endTime"];
                                      }
                                    }
                                    if (
                                    shiftsProvider.startTime != ''
                                        ||
                                        shiftsProvider.endTime != ''
                                        ||
                                        shiftsProvider.selectedAreasOfWorkIds.isNotEmpty
                                        ||
                                        shiftsProvider.isNewActive) {
                                      shiftsProvider.setIsResetFilterShown(show: true);
                                    }
                                    else{
                                      shiftsProvider.setIsResetFilterShown(show: false);
                                    }
                                    fetchData();

                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Apply",
                                    style: styleYellow,
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isWorkAreasVisibleInShiftsFilter = true;
                                  });
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset("images/area-of-work.svg", color: Theme.of(context).primaryColor,width: 25,),
                                    const SizedBox(
                                      width: 7.0,
                                    ),
                                    Text(
                                      "Areas of Work",
                                      style: style2,
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isWorkAreasVisibleInShiftsFilter = true;
                                            });
                                          },
                                          child: Text(
                                            shiftsProvider.selectedAreasOfWorkIds.isEmpty ? "Any" : "${shiftsProvider.selectedAreasOfWorkIds.length} selected",
                                            style: TextStyle(
                                                color: shiftsProvider.selectedAreasOfWorkIds.isEmpty ? Colors.grey : Theme.of(context).primaryColor,
                                                fontWeight: FontWeight.bold),
                                          )
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'images/shiftsOutLine.svg',
                                      color: Theme.of(context).primaryColor,
                                      width: 25,
                                    ),
                                    const SizedBox(
                                      width: 7.0,
                                    ),
                                    Text(
                                      "Shift Types",
                                      style: style2,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 3.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              shiftsProvider.shiftTypes[0] = !shiftsProvider.shiftTypes[0];
                                              if(shiftsProvider.shiftTypes[0] == false){
                                                shiftsProvider.startTime = '';
                                                shiftsProvider.endTime = '';
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: 35.0,
                                            width: 35.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: shiftsProvider.shiftTypes[0] == true ? 2.0 : 1.0,
                                                  color:  shiftsProvider.shiftTypes[0] == true ? Theme.of(context).primaryColor : Colors.grey[400]),
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Center(
                                                child: SvgPicture.asset("images/halfSun.svg",width: 24,)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              shiftsProvider.shiftTypes[1] = !shiftsProvider.shiftTypes[1];
                                              if(shiftsProvider.shiftTypes[1] == false){
                                                shiftsProvider.startTime = '';
                                                shiftsProvider.endTime = '';
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: 35.0,
                                            width: 35.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: shiftsProvider.shiftTypes[1] == true ? 2.0 : 1.0,
                                                  color:  shiftsProvider.shiftTypes[1] == true ? Theme.of(context).primaryColor: Colors.grey[400]),
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Center(
                                                child: SvgPicture.asset("images/sun.svg",width: 24,)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 5),
                                        child: GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              shiftsProvider.shiftTypes[2] = !shiftsProvider.shiftTypes[2];
                                              if(shiftsProvider.shiftTypes[2] == false){
                                                shiftsProvider.startTime = '';
                                                shiftsProvider.endTime = '';
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: 35.0,
                                            width: 35.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: shiftsProvider.shiftTypes[2] == true ? 2.0 : 1.0,
                                                  color: shiftsProvider.shiftTypes[2] == true ? Theme.of(context).primaryColor : Colors.grey[400]),
                                              borderRadius: BorderRadius.circular(50),
                                              color: Colors.transparent,
                                            ),
                                            child: Center(
                                                child: SvgPicture.asset("images/moon.svg",width: 20,)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // const Divider(),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.priority_high_rounded,
                            //         color: Colors.grey,
                            //       ),
                            //       SizedBox(
                            //         width: 7.0,
                            //       ),
                            //       Text(
                            //         "Top priority shifts only",
                            //         style: style2,
                            //       ),
                            //       Spacer(),
                            //       SizedBox(
                            //         height: 40,
                            //         // width: 100,
                            //         child: LiteRollingSwitch(
                            //           value: false,
                            //           colorOff: Colors.grey,
                            //           colorOn: Theme.of(context).primaryColor,
                            //           textOff: "OFF",
                            //           textOn: "ON",
                            //           iconOn: Icons.done,
                            //           iconOff: Icons.cancel,
                            //           textSize: 16.0,
                            //           onChanged: (bool value) {
                            //           },
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Theme.of(context).primaryColor,
                                    size: 26,
                                  ),
                                  const SizedBox(
                                    width: 7.0,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Newly added only",
                                        style: style2,
                                      ),
                                      const Text(
                                        "(within past 24 hours)",
                                        style: TextStyle(
                                            fontSize: 13.0, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    height: 40,
                                    // width: 100,
                                    child: FlutterSwitch(
                                      height: 30,
                                      width: 60,
                                      showOnOff: true,
                                      activeText: '',
                                      inactiveText: '',
                                      // activeTextColor: Colors.black,
                                      // inactiveTextColor: Colors.blue[50],
                                      inactiveColor: Colors.black38,
                                      value: shiftsProvider.isNewActive,
                                      onToggle:(val){
                                        setState(() {
                                          shiftsProvider.isNewActive = val;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            )
                          ],
                        ),
                      );
                    });
              }),
          // here we are checking if the current user is NSH-Professionals or NHSP as both doesn't need to see filters or calendar buttons
          calendarAction: (userData.userTrustId == "18928788-e701-4b8d-b810-431a20a7dca8" || userData.userTrustId == "6a5a61ee-a53c-4518-99bd-b900953b4dbe") || (userData.userData.trust['system_type']['name'] == 'nhsp_api' && (userData.userData.nhsp_staff_id == null || userData.userData.nhsp_staff_id.isEmpty)) ? null : (){
            // if(_tabController.index != null && _tabController.index == 2){
            //   _tabController.animateTo(1);
            // }
            Provider.of<ShiftsProvider>(context, listen: false).changeShiftsView();

          },
          showLeadingPop: false,
          elevation: 0.0,
          bottomTabs:userData.userData.trust['system_type']['name'] == 'nhsp_api' && (userData.userData.nhsp_staff_id == null || userData.userData.nhsp_staff_id.isEmpty) ? null : PreferredSize(
              child: Column(
                children: [
                  // Provider.of<ShiftsProvider>(context,).isCalendarView ?
                  // CalendarTabBar() :
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: const BoxDecoration(color:Colors.white,borderRadius: const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5))),
                    isScrollable: userData.userData.nhsp_staff_id != null && userData.userData.nhsp_staff_id.isNotEmpty ? false : false,
                    tabs: List<Widget>.generate(userData.userData.nhsp_staff_id != null && userData.userData.nhsp_staff_id.isNotEmpty ? 3 : 2, (int index){
                      return  Tab(
                        child: Padding(
                        padding: userData.userData.nhsp_staff_id != null && userData.userData.nhsp_staff_id.isNotEmpty ? const EdgeInsets.all(0) : EdgeInsets.only(top:3.0, left: media.width * .1, right: media.width * .1),
                        child: Text(index == 0 ? "OPEN" : index == 1 ? "UPCOMING" : "TIMESHEET",
                          softWrap: true,
                          style: userData.userData.nhsp_staff_id != null && userData.userData.nhsp_staff_id.isNotEmpty
                              ?
                          TextStyle(
                            fontSize: media.width < 350 ? 12 : 14,
                            fontWeight: FontWeight.bold,)
                              :
                          TextStyle(
                              fontSize: media.width*0.03,
                              fontWeight: FontWeight.bold,) ,),
                      ),);
                    }),
                  ),
                  shiftsProvider.isResetFilterShown ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    width: media.width,
                    height: 35,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // shiftsProvider.startTime != '' && shiftsProvider.startTime != '' ?
                        Row(
                          children: [
                            Image.asset(
                              "images/filter.png",
                              color: Colors.grey,
                              height: 18.0,
                              width: 18.0,
                            ),
                            const SizedBox(width: 4,),
                            shiftsProvider.isNewActive ? Text('New | ',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),) : const SizedBox(),
                            shiftsProvider.selectedAreasOfWorkIds.isNotEmpty ? Text("${shiftsProvider.selectedAreasOfWorkIds.length} Areas | ",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),) : const SizedBox(),
                            shiftsProvider.startTime == "02:00" || (shiftsProvider.startTime == "18:00" && shiftsProvider.endTime == "10:00")? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: SvgPicture.asset("images/halfSun.svg",width: 20,),
                            ) : const SizedBox(),
                            shiftsProvider.startTime == "10:00" || (shiftsProvider.startTime == "02:00" && shiftsProvider.endTime == "18:00") ||(shiftsProvider.startTime == shiftsProvider.endTime && (shiftsProvider.startTime != '' && shiftsProvider.startTime != '')) ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: SvgPicture.asset("images/sun.svg",width: 20,),
                            ):const SizedBox(),
                            shiftsProvider.startTime == "18:00" || (shiftsProvider.startTime == "18:00" && shiftsProvider.endTime == "02:00") || (shiftsProvider.startTime == "10:00" && shiftsProvider.endTime == "02:00") || (shiftsProvider.startTime == "18:00" && shiftsProvider.endTime == "10:00") || (shiftsProvider.startTime == shiftsProvider.endTime && (shiftsProvider.startTime != '' && shiftsProvider.startTime != '')) ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: SvgPicture.asset("images/moon.svg",width: 16,),
                            ) : const SizedBox(),
                          ],
                        ),
                        //     :
                        // const SizedBox(),
                        InkWell(
                          onTap: (){
                            shiftsProvider.setIsResetFilterShown(show: false);
                            shiftsProvider.setShouldUpdateCalendarData(true);
                            fetchData();
                          },
                          child: Text('Reset',style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor,fontSize: 16),),
                        ),
                      ],
                    ),
                  )
                      :
                  const SizedBox(),
                ],
              ),
              preferredSize: Size.fromHeight(shiftsProvider.isResetFilterShown ? 95.0 :60.0)
          ),
        ),
        // here we are checking if the current user is NSH-Professionals
        body: userData.userTrustId == "18928788-e701-4b8d-b810-431a20a7dca8" || userData.userTrustId == "6a5a61ee-a53c-4518-99bd-b900953b4dbe"
            ?
        // this is the View for NHS-Professionals
        Container(
          height: media.height,
          width: media.width,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text("Please click on the link below to access your shifts"),
              const SizedBox(height: 60,),
              InkWell(
                  onTap: ()async{
                    if (await canLaunch(nhspLinkForShifts)) {
                      await launch(nhspLinkForShifts,
                        forceSafariVC: true,
                        forceWebView: true,
                        enableJavaScript: true,
                      );
                    }else{
                      debugPrint("Couldn't launch url");
                    }
                  },
                  child: Text("$nhspLinkForShifts",style: TextStyle(color: Theme.of(context).primaryColor,decoration: TextDecoration.underline),)
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: needHelp(context),
              ),
              // const SizedBox(height: 100,)
            ],
          ),
        )
            :
        // here we are checking if the current user is NHSP && doesn't have a value for the NHSP_staff_id yet
        userData.userData.trust['system_type']['name'] == 'nhsp_api' && (userData.userData.nhsp_staff_id == null || userData.userData.nhsp_staff_id.isEmpty)
            ?
        NHSPLogin()
            :
        Provider.of<ShiftsProvider>(context,listen: false).isCalendarView
            ?
        TabBarView(
          controller: _tabController,
          children: userData.userData.trust['system_type']['name'] == 'nhsp_api' ?
          <Widget>[
            CalenderView(startDate: dateToTimeStamp(date: DateTime.now()).seconds,endDate: dateToTimeStamp(date: DateTime(kToday.year, kToday.month + 1, 0)).seconds,historyType: "0",),
            CalenderView(startDate: dateToTimeStamp(date: DateTime.now()).seconds,endDate: dateToTimeStamp(date: DateTime(kToday.year, kToday.month + 1, 0)).seconds,historyType: "1",),
            Container(
              color: Colors.white,
              child: Center(
                child: Wrap(
                  children: [
                    Text("This tab is available for the list ",
                      style: styleGrey,),
                     Padding(
                       padding: const EdgeInsets.only(top: 1.0),
                       child: SvgPicture.asset(
                        "images/list-view-filled.svg",
                        color: Colors.grey,
                        width: 14,
                    ),
                     ),
                    Text(" display only !",
                      style: styleGrey,),
                  ],
                ),
              ),
            )
          ]:
          <Widget>[
            CalenderView(startDate: dateToTimeStamp(date: DateTime.now()).seconds,endDate: dateToTimeStamp(date: DateTime(kToday.year, kToday.month + 1, 0)).seconds,historyType: "0",),
            CalenderView(startDate: dateToTimeStamp(date: DateTime.now()).seconds,endDate: dateToTimeStamp(date: DateTime(kToday.year, kToday.month + 1, 0)).seconds,historyType: "1",),
          ]
        )
            :
        TabBarView(
          controller: _tabController,
          children:
          // here we are checking if the current user is NHSP or not
          userData.userData.trust['system_type']['name'] == 'nhsp_api' /*&& (userData.userData.nhsp_staff_id != null && userData.userData.nhsp_staff_id.isNotEmpty)*/
              ?
          <Widget>[

            OpenShifts(),
            UpcomingShifts(),
            // here we check if the user has accepted the declaration to view time_sheet or not
            Provider.of<ShiftsProvider>(context,listen: false).acceptedTimeSheetDeclaration != null && Provider.of<ShiftsProvider>(context, listen: false).acceptedTimeSheetDeclaration == true ?
            TimeSheetShifts() : TimSheetDeclaration(),

          ]
              :
          <Widget>[
            OpenShifts(),
            UpcomingShifts(),
          ],

        ),

      ),
    );
  }


}

class CalenderView extends StatefulWidget {
  int startDate;
  int endDate;
  String historyType;
  CalenderView({this.startDate,this.endDate,this.historyType});
  @override
  _CalenderViewState createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  DateTime _currentDay = DateTime.now();
  DateTime _today = DateTime.now();
  DateTime _selectedDay;

  CalendarFormat _calendarFormat = CalendarFormat.month;


  List<Offer> _getEventsForDay(DateTime day) {
    return Provider.of<ShiftsProvider>(context,listen: false).dayOffers[day] ?? [];
  }
  bool _loadingData = true;
  bool _isCurrentMonthChanged = false;

  Map<DateTime, List<Event>> eventsMap = {};
  
  ShiftsProvider shiftsProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    shiftsProvider = Provider.of<ShiftsProvider>(context,listen: false);

    Provider.of<ShiftsProvider>(context,listen: false).fetchCalendarDaysWithOffers(
      context,
      startDate: widget.startDate,
      endDate: widget.endDate,
      historyType: int.parse(widget.historyType),
      wardIds: shiftsProvider.selectedAreasOfWorkIds,
      endTime: shiftsProvider.endTime,
      startTime: shiftsProvider.startTime,
      createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",
      sendFromCalendar: true,
      shouldUpdate: shiftsProvider.shouldUpDateCalendarData
    ).then((_) {
      _loadingData = false ;
    });

  }


  @override
  Widget build(BuildContext context) {
    ShiftsStage stage = Provider.of<ShiftsProvider>(context).stage;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10.0),
            child: TableCalendar(
              currentDay: _currentDay,
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _today,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Week',
                CalendarFormat.twoWeeks: 'Month',
                CalendarFormat.week: '2 weeks',
              },
              eventLoader: stage == ShiftsStage.LOADING ? null : _getEventsForDay, // for badge under day
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.

                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.

                return isSameDay(_selectedDay, day);
              },
              onFormatChanged: (format){
                if (_calendarFormat == CalendarFormat.month) {
                  setState(() {
                    _calendarFormat = CalendarFormat.twoWeeks;
                  });
                }
                else if ( _calendarFormat == CalendarFormat.twoWeeks){
                  setState(() {
                    _calendarFormat = CalendarFormat.week;
                  });
                }
                else if (_calendarFormat == CalendarFormat.week){
                  setState(() {
                    _calendarFormat = CalendarFormat.month;
                  });
                }
              },

              onCalendarCreated: (controller){
                // Provider.of<ShiftsProvider>(context,listen: false).fetchCalendarDaysWithOffers(context,startDate: widget.startDate,endDate: widget.endDate,historyType: widget.historyType);
              },

              onPageChanged: (DateTime day){
                // to save current page in Calendar when page changed .
                _today = day;


                    if(kFirstDay.month == _today.month){
                      setState(() {
                        _loadingData = true;
                        _isCurrentMonthChanged = false;
                      });
                    }
                    else{
                      setState(() {
                        _loadingData = true;
                        _isCurrentMonthChanged = true;
                      });
                    }

                if (day.month == kToday.month) {
                  Provider.of<ShiftsProvider>(context,listen: false).setStartDay(dateToTimeStamp(date: DateTime(kToday.year, kToday.month, 1)).seconds);
                }
                else{
                  Provider.of<ShiftsProvider>(context,listen: false).setStartDay(dateToTimeStamp(date: DateTime(day.year, day.month, 1)).seconds);
                }

                Provider.of<ShiftsProvider>(context,listen: false).setEndDay(dateToTimeStamp(date: DateTime(day.year, day.month + 1, 0)).seconds);

                  Provider.of<ShiftsProvider>(context,listen: false).fetchCalendarDaysWithOffers(
                      context,
                      startDate: shiftsProvider.startDay,
                      endDate: shiftsProvider.endDay,
                      historyType: //calendarTabController.index,
                      shiftsProvider.currentShiftType,
                      wardIds: shiftsProvider.selectedAreasOfWorkIds,
                      endTime: shiftsProvider.endTime,
                      startTime: shiftsProvider.startTime,
                      createdSince: shiftsProvider.isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",
                      sendFromCalendar: true
                  ).then((_) {
                   setState(() {
                     _loadingData = false;
                   });
                  });
              },

              onDaySelected: (selectedDay, focusedDay) {

                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                }
                if (stage == ShiftsStage.DONE) {
                  shiftsProvider.setCurrentCalendarDay(selectedDay: selectedDay);
                    if(shiftsProvider.currentCalendarDay != null){
                      Navigator.pushNamed(context, DayOffers.routeName);
                    }
                  // Navigator.pushNamed(context, DayOffers.routeName);
                }

              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              daysOfWeekHeight: 35,
              daysOfWeekStyle: DaysOfWeekStyle(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30)
                  ),
                  weekdayStyle: TextStyle(
                      color: Theme.of(context).primaryColor
                  ),
                  weekendStyle: TextStyle(
                    color: Theme.of(context).primaryColor
                  ),
              ),
              // calendarController: _calendarController,
              // simpleSwipeConfig: ,
              calendarStyle: CalendarStyle(
                selectedTextStyle: TextStyle(color: secondColor),

                todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15)
                ),
                selectedDecoration: BoxDecoration(
                    color: secondColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15)
                ),
                defaultDecoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15)
                ),
                holidayDecoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15)
                ),
                weekendDecoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15)
                ),
                rangeEndDecoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15)
                ),
                outsideDecoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15)
                ),
                disabledDecoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15)
                ),
                markerSize: 15.0,
                markerDecoration: BoxDecoration(),
                isTodayHighlighted: true,
              ),
              rowHeight: 60,
              calendarBuilders: CalendarBuilders<Offer>(
                defaultBuilder: (context,day1,day2){
                  return stage == ShiftsStage.LOADING || shiftsProvider.isRetrtyFetchingOffersForCalendar ?
                  Shimmer.fromColors(
                    baseColor: Colors.black87,
                    highlightColor: Colors.grey[300],
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.all(6.0),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        // color: Theme.of(context).primaryColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${day1.day}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                      :
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(6.0),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      // color: Theme.of(context).primaryColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${day1.day}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
                  dowBuilder: (context,day){
                  return Center(
                    child: ExcludeSemantics(
                      child: Text(
                        "${DateFormat.E("en_US").format(day)}",
                        style: TextStyle(
                            color: !_isCurrentMonthChanged && DateFormat.E("en_US").format(_today) == DateFormat.E("en_US").format(day) ? Theme.of(context).primaryColor : Colors.black87,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  );
                  },
                  markerBuilder: (context,day,offers){
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: offers.length > 0 ? Colors.red : Colors.transparent,
                        ),
                        child: offers.length > 0 ? Center(child: Text('${offers.length}',style: TextStyle(fontSize: 11,color: Colors.white),)) : const SizedBox(),
                      ),
                    );
                  }
              ),



            ),
          ),
          const SizedBox(height: 100.0,)
        ],
      ),
    );
  }
}

