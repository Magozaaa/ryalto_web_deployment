// ignore_for_file: file_names, unnecessary_string_interpolations

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';

class TimeSheetShiftDetails extends StatefulWidget {
  static const routeName = '/TimeSheetShiftDetails_Screen';

  const TimeSheetShiftDetails({Key key}) : super(key: key);

  @override
  _TimeSheetShiftDetailsState createState() => _TimeSheetShiftDetailsState();
}

class _TimeSheetShiftDetailsState extends State<TimeSheetShiftDetails> {

  bool _isSubmitting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AnalyticsManager.track('screen_timesheet');
    // print("lplpdlplpdldpdl ${Provider.of<ShiftsProvider>(context,listen: false).currentTimeSheetShit}");
    // Provider.of<ShiftsProvider>(context,listen: false).fetchTimeSheetDetails(context,timeSheetShiftId: Provider.of<ShiftsProvider>(context,listen: false).currentTimeSheetShit.id);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final timeSheetShift = Provider.of<ShiftsProvider>(context).currentTimeSheetShit;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (!kIsWeb) {
            if (Platform.isIOS) {
              if (details.primaryVelocity.compareTo(0) == 1) {
                Navigator.pop(context);
              }
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar:  AppBar(
            centerTitle: false,
            automaticallyImplyLeading: false,
            // leadingWidth: 30,
            elevation: 2.0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 27.0,
              ),
              onPressed: ()=> Navigator.pop(context),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TimeSheet"),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text("${timeSheetShift.id}",style: const TextStyle(fontSize: 14,color: Colors.white60),),
                ),
              ],
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    onTap: (){
                      showQueryCustomDialog(context);
                    },
                    child: const Text('Query',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  ),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: timeSheetCard(context,timeSheetDay: Provider.of<ShiftsProvider>(context,listen: false).currentTimeSheetShit),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10,),
                          const Text("Booked",style: TextStyle(color: Color(0xFF808080)),),
                          const SizedBox(height: 8,),
                          Wrap(
                            spacing: 15.0,
                            runSpacing: 15.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Start Time"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['booked_start_time']))}",
                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("End Time"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['booked_end_time']))}",
                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Break in minutes"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['booked_break_time']))}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['total_time']))}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),

                            ],
                          ),
                          const SizedBox(height: 40,),
                          const Text("Actual",style: TextStyle(color: Color(0xFF808080)),),
                          const SizedBox(height: 8,),
                          Wrap(
                            spacing: 15.0,
                            runSpacing: 15.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Start Time"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['actual_start_time']))}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("End Time"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['actual_end_time']))}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Break in minutes"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['actual_break_time']))}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total"),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("${DateFormat('HH:mm').format(timeStampToDateTime(timeSheetShift.provider['actual_total_time']))}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  ),
                                ],
                              ),

                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 10,),
                          Wrap(
                            spacing: 50.0,
                            runSpacing: 15.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Shift Type",style: TextStyle(color:  Color(0xFF808080)),),
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text("Standard",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  const Text("Assignment Code",style: TextStyle(color: Color(0xFF808080)),),
                                  Text("${timeSheetShift.provider['assignment_code']}",style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                                ],
                              ),
                              const SizedBox()

                            ],
                          ),
                          const SizedBox(height: 20,),
                          const Text("Organisation",style: TextStyle(color: Color(0xFF808080)),),
                          const SizedBox(height: 5,),
                          Text("${timeSheetShift.trust['name']}",style: const TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),

                        ],
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Align(
                      alignment: Alignment.center,
                      child: roundedButton(
                          context: context,
                          title: "Release",
                          buttonWidth: media.width * 0.45, buttonHeight: media.height * 0.04,
                          onClicked: () {
                            setState(() {
                              _isSubmitting = true;
                            });
                            Provider.of<ShiftsProvider>(context,listen:false).updateTimeSheet(context,message: null,timeSheetStatusId: MyApp.flavor == "staging" ? "74696686-d1d2-47fd-9d39-8d5a8b69bd7a" : "2872b822-1c28-4c9b-83ef-e25a44609e6a").then((_) {
                              setState(() {
                                _isSubmitting = false;
                              });
                            });

                          }),
                    ),
                    const SizedBox(height: 30,),

                  ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
