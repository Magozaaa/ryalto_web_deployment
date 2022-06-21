// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/ShiftModel.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftDetails.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class DayOffers extends StatefulWidget {
  static const routeName = "/DayOffers_Screen";

  const DayOffers({Key key}) : super(key: key);

  @override
  _DayOffersState createState() => _DayOffersState();
}

class _DayOffersState extends State<DayOffers> {

  // CalendarDay calendarDay;


  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
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
          appBar: screenAppBar(
              context,
              media,
              centerTitle: true,
              appbarTitle: Text("Shifts for ${formatStringTimeToDayMonthAndTime(stringTime: Provider.of<ShiftsProvider>(context).currentCalendarDay.date)}"),
              showLeadingPop: true,
              hideProfilePic: true,
              onBackPressed: ()=> Navigator.pop(context),
            bottomTabs: PreferredSize(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          Provider.of<ShiftsProvider>(context,listen: false).setPreviousCalendarDay();
                          // setState(() {
                          //
                          // });
                        },
                          child: Text("Prev day",style: style15,)
                      ),
                      InkWell(
                        onTap: (){
                          Provider.of<ShiftsProvider>(context,listen: false).setNextCalendarDay();
                        },
                          child: Text("Next day",style: style15,)
                      ),
                    ],
                  ),
                ),
                preferredSize: const Size.fromHeight(40),
            )
          ),
          body:  Provider.of<ShiftsProvider>(context, listen: false).currentCalendarDay.offers.isEmpty
              ? emptyShiftsForDayOffers(context,media)
              : ListView.builder(
            shrinkWrap: true,
            itemCount: Provider.of<ShiftsProvider>(context,listen: false).currentCalendarDay.offers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: index == Provider.of<ShiftsProvider>(context,listen: false).currentCalendarDay.offers.length - 1 ?
                const EdgeInsets.only(bottom: 20.0):
                const EdgeInsets.all(0.0),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      GestureDetector(
                          onTap: (){
                            Provider.of<ShiftsProvider>(context,listen: false).setCurrentOffer(Provider.of<ShiftsProvider>(context,listen: false).currentCalendarDay.offers[index]);
                            Navigator.pushNamed(
                                context,
                                ShiftDetails.routeName,
                                arguments: {
                                  "offer" : Provider.of<ShiftsProvider>(context,listen: false).currentCalendarDay.offers[index]
                                });
                          },
                          child:
                          shiftCard(
                            context,
                            offer: Provider.of<ShiftsProvider>(context).currentCalendarDay.offers[index],
                          )
                      ),
                      index == Provider.of<ShiftsProvider>(context).currentCalendarDay.offers.length-1 ? const SizedBox() : const Divider()
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
