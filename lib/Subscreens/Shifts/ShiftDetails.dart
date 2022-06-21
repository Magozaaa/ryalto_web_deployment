
// ignore_for_file: file_names

import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/ShiftModel.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';

class ShiftDetails extends StatefulWidget{
  static const routeName = '/ShiftDetails_Screen';

  const ShiftDetails({Key key}) : super(key: key);

  @override
  _ShiftDetailsState createState() => _ShiftDetailsState();
}

class _ShiftDetailsState extends State<ShiftDetails> {

  bool _isInit = true;
  bool isDay = false;
  bool _isLoadingCurrentOffer = false;
  var monthDay;
  var weekDay;
  Offer offer;

  CancellationReason selectedReason;

  String cancelableuntil;

  @override
  void initState() {

    if(Provider.of<ShiftsProvider>(context,listen: false).currentOffer == null){
      _isLoadingCurrentOffer = true;
      Provider.of<ShiftsProvider>(context,listen: false).fetchOfferById(context).then((_) {
        offer = Provider.of<ShiftsProvider>(context,listen: false).currentOffer;
        if (mounted) {
          setState(() {
            _isLoadingCurrentOffer = false;
          });
        }
        Provider.of<ShiftsProvider>(context,listen: false).fetchCancellationReasons(context, hospitalId: offer.hospital.id);
        cancelableuntil = "${offer.cancellableUntil - offer.startDate}";
        event = Event(
          title: offer.ward.name,
          description: 'Ryalto shift event',
          location: '${Provider.of<UserProvider>(context,listen: false).userData.trust["name"]}, ${offer.hospital.name}',
          startDate: timeStampToDateTime(offer.startDate),
          endDate: timeStampToDateTime(offer.endDate),
          iosParams: const IOSParams(
            reminder: Duration(/* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
          ),
          androidParams: const AndroidParams(
            emailInvites: [], // on Android, you can add invite emails to your event.
          ),
        );
      });

    } else{
      offer = Provider.of<ShiftsProvider>(context,listen: false).currentOffer;
      Provider.of<ShiftsProvider>(context,listen: false).fetchCancellationReasons(context, hospitalId: offer.hospital.id);
      cancelableuntil = "${offer.cancellableUntil - offer.startDate}";
      event = Event(
        title: offer.ward.name,
        description: 'Ryalto shift event',
        location: '${Provider.of<UserProvider>(context,listen: false).userData.trust["name"]}, ${offer.hospital.name}',
        startDate: timeStampToDateTime(offer.startDate),
        endDate: timeStampToDateTime(offer.endDate),
        iosParams: const IOSParams(
          reminder: Duration(/* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
        ),
        androidParams: const AndroidParams(
          emailInvites: [], // on Android, you can add invite emails to your event.
        ),
      );

    }
    // print(offer.id);

    AnalyticsManager.track('shift_offer_opened');


    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_isInit){
      // offer = passedData["offer"];
      // offer = Provider.of<ShiftsProvider>(context,listen: false).currentOffer;

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  bool _isExpanded = true;
  bool isUpdatingOfferStatus = false;
  String profilePicPath;


  Event event ;


  _showAcceptShiftBottomSheet({BuildContext context,Function onConfirm, Offer offer,media}){
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                    borderRadius: BorderRadius.circular(15.0),
                    elevation: 5.0,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "Confirm Shift",
                              style: TextStyle(color: Colors.grey[800], fontSize: 18.0,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF6FE),
                                // color: offer.shift_type.value == 0 ? const Color(0xFFFDF5D7) : offer.shift_type.value == 1 ? const Color(0xFFFFEBD6) : const Color(0xFFEEF6FE)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: offer.shiftType.value == 0
                                        ? SvgPicture.asset("images/sun.svg",width: 24,)
                                        : offer.shiftType.value == 1
                                        ? SvgPicture.asset("images/halfSun.svg",width: 24,)
                                        : SvgPicture.asset("images/moon.svg",width: 20,),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      "${formatStringTimeToWeekDay(stringTime: readTimestamp(offer.startDate))} - ${formatStringTimeToDayMonthAndYear(stringTime: readTimestamp(offer.startDate))}",
                                      style: TextStyle(color: Colors.grey[800], fontSize: 18.0),
                                    ),
                                  ),
                                  Text(
                                    "${convertTimestampToHoursAndMinutes(offer.startDate)}  -  ${convertTimestampToHoursAndMinutes(offer.endDate)}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 13.0),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Align(
                          alignment: Alignment.center,
                          child: Text(offer.hospital.name,style: TextStyle(color: Colors.grey[600],fontSize: 14,fontWeight: FontWeight.bold),),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(offer.ward.name,style: TextStyle(color: Colors.grey[900],fontSize: 16,fontWeight: FontWeight.bold),),
                        ),
                        const SizedBox(height: 6,),
                        const Align(alignment: AlignmentDirectional.centerStart,child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("Requirements",style: TextStyle(fontWeight: FontWeight.bold),),
                        )),
                        const SizedBox(height: 10,),
                        offer.roles!= null && offer.roles.isNotEmpty ?  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:4.0, right: 7.0),
                                child: SvgPicture.asset("images/role.svg",
                                    height: 25.0,
                                    width: 26.0,
                                    color: greyColor),
                              ),
                              const SizedBox(width: 5.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(offer.user.roleType.toString() ==
                                      "2"
                                      ? "Specialities"
                                      :"Positions", style: TextStyle(color: Colors.grey[60], fontSize: 15.0),),
                                  Container(
                                    width: media.width*0.6,
                                    child: Wrap(
                                      children: List.generate(offer.roles.length, (index) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                                color: secondColor
                                            ),
                                          ),
                                          child: Text(offer.roles[index].name),
                                        ),
                                      )),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ) : const SizedBox(),
                        offer.roles!= null && offer.roles.isNotEmpty ? const Divider() : const SizedBox(),
                        offer.offerLevel != null ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 5.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:4.0, right: 7.0),
                                child: SvgPicture.asset("images/min-level.svg", color: greyColor,width: 24,),
                              ),
                              const SizedBox(width: 5.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Level", style: TextStyle(color: Colors.grey[60], fontSize: 15.0),),
                                  Text(offer.offerLevel.name , style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0),),
                                ],
                              )
                            ],
                          ),
                        ) : const SizedBox(),

                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 5,bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap:() {
                                  Navigator.pop(context);
                                },
                                child: Material(
                                  elevation: 4.0,
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFFffff),
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(color: Theme.of(context).primaryColor)
                                    ),
                                    child: Text('Cancel',style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: (){
                                  onConfirm();
                                },
                                child: Material(
                                  elevation: 4.0,
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                            color: Theme.of(context).primaryColor
                                        )
                                    ),
                                    child: const Text('Confirm',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                ),
                const SizedBox(height: 20.0,),
              ],
            ),
          );
        });
  }

  _showCancelShiftBottomSheet({BuildContext context, Offer offer,media, onCancel()}){
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (contextBuilder, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
              child: GestureDetector(
                onTap: (){
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                        borderRadius: BorderRadius.circular(15.0),
                        elevation: 5.0,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "Shift Cancellation",
                                  style: TextStyle(color: Colors.grey[800], fontSize: 18.0,fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEEF6FE),
                                    // color: offer.shift_type.value == 0 ? const Color(0xFFFDF5D7) : offer.shift_type.value == 1 ? const Color(0xFFFFEBD6) : const Color(0xFFEEF6FE)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5),
                                        child: offer.shiftType.value == 0
                                            ? SvgPicture.asset("images/sun.svg",width: 24,)
                                            : offer.shiftType.value == 1
                                            ? SvgPicture.asset("images/halfSun.svg",width: 24,)
                                            : SvgPicture.asset("images/moon.svg",width: 20,),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          "${formatStringTimeToWeekDay(stringTime: readTimestamp(offer.startDate))} - ${formatStringTimeToDayMonthAndYear(stringTime: readTimestamp(offer.startDate))}",
                                          style: TextStyle(color: Colors.grey[800], fontSize: 18.0),
                                        ),
                                      ),
                                      Text(
                                        "${convertTimestampToHoursAndMinutes(offer.startDate)}  -  ${convertTimestampToHoursAndMinutes(offer.endDate)}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 13.0),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(offer.hospital.name,style: TextStyle(color: Colors.grey[600],fontSize: 14,fontWeight: FontWeight.bold),),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(offer.ward.name,style: TextStyle(color: Colors.grey[900],fontSize: 16,fontWeight: FontWeight.bold),),
                            ),

                            const SizedBox(height: 5,),

                            // here we will add a drop down menu to view cancel reasons
                            // and if the GET cancellation_options request retrieves an Empty list show empty sized Box
                            Provider.of<ShiftsProvider>(context,listen: false).cancellationReasons.isNotEmpty ?
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 20),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    hint: Text(
                                      selectedReason == null ? 'Select reason !' : selectedReason.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: selectedReason == null ? Colors.grey : Colors.grey[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    items: Provider.of<ShiftsProvider>(context,listen: false).cancellationReasons.isNotEmpty ? Provider.of<ShiftsProvider>(context,listen: false).cancellationReasons
                                        .map((item) =>
                                        DropdownMenuItem<CancellationReason>(
                                          value: item,
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              // color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                        .toList():[],
                                    value: selectedReason,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedReason = value;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                    ),
                                    iconSize: 14,
                                    iconEnabledColor: Theme.of(context).primaryColor,
                                    iconDisabledColor: Colors.grey,
                                    buttonHeight: 50,
                                    // buttonWidth: 160,
                                    buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                    buttonDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      // border: Border.all(
                                      //   color: Colors.black26,
                                      // ),
                                      color: Colors.white,
                                    ),
                                    buttonElevation: 1,
                                    itemHeight: 40,
                                    itemPadding: const EdgeInsets.only(left: 14, right: 14,bottom: 10),
                                    dropdownMaxHeight: 120,
                                    // dropdownWidth: 200,
                                    dropdownPadding: null,
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    dropdownElevation: 8,
                                    dropdownWidth: media.width*0.8,
                                    scrollbarRadius: const Radius.circular(40),

                                    scrollbarThickness: 6,
                                    scrollbarAlwaysShow: true,
                                    offset: const Offset(5, 10),
                                  ),
                                ),
                              ),
                            )
                                :const SizedBox(),

                            const SizedBox(height: 15,),

                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.only(top: 5,bottom: 15),
                              child: isUpdatingOfferStatus ?
                              SpinKitCircle(color: Theme.of(context).primaryColor,size: 30,):
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap:() {
                                      setState((){
                                        selectedReason = null;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(40),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 20),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFFffff),
                                            borderRadius: BorderRadius.circular(40),
                                            border: Border.all(color: Theme.of(context).primaryColor)
                                        ),
                                        child: Text('Back',style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: selectedReason == null ? null : (){
                                      setState((){
                                        isUpdatingOfferStatus = true;
                                      });
                                      Provider.of<ShiftsProvider>(context, listen: false).updateOfferStatus(context,
                                        offerId: offer.id,
                                        offerStatusId: MyApp.flavor == "staging" ? stagingOffersStatuses[4][0] : productionOffersStatuses[4][0],
                                        cancellationOptionId: selectedReason.id,
                                        message: selectedReason.name ?? "",
                                      ).then((_) {
                                        Navigator.pop(context);

                                        if(Provider.of<ShiftsProvider>(context, listen: false).isCalendarView == false){
                                          // here i am sending a request to update upcoming & open tabs after cancel update
                                          Provider.of<ShiftsProvider>(context, listen: false).fetchOffers(
                                              context,
                                              pageOffset: 0,
                                              wardIds: Provider.of<ShiftsProvider>(context,listen: false).selectedAreasOfWorkIds,
                                              endTime: Provider.of<ShiftsProvider>(context,listen: false).endTime,
                                              startTime: Provider.of<ShiftsProvider>(context,listen: false).startTime,
                                              createdSince: Provider.of<ShiftsProvider>(context,listen: false).isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",
                                              historyType: 0
                                          );
                                          Provider.of<ShiftsProvider>(context, listen: false).fetchOffers(
                                              context,
                                              pageOffset: 0,
                                              wardIds: Provider.of<ShiftsProvider>(context,listen: false).selectedAreasOfWorkIds,
                                              endTime: Provider.of<ShiftsProvider>(context,listen: false).endTime,
                                              startTime: Provider.of<ShiftsProvider>(context,listen: false).startTime,
                                              createdSince: Provider.of<ShiftsProvider>(context,listen: false).isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",
                                              historyType: 1);
                                        }else{
                                          /// commented this one out since there is only one list to hold both open & upcoming calendar offers
                                          // Provider.of<ShiftsProvider>(context,listen: false).fetchCalendarDaysWithOffers(
                                          //     context,
                                          //     startDate: Provider.of<ShiftsProvider>(context,listen: false).startDay,
                                          //     endDate: Provider.of<ShiftsProvider>(context,listen: false).endDay,
                                          //     historyType: "0",
                                          // );
                                          Provider.of<ShiftsProvider>(context,listen: false).fetchCalendarDaysWithOffers(
                                              context,
                                              startDate: Provider.of<ShiftsProvider>(context,listen: false).startDay,
                                              endDate: Provider.of<ShiftsProvider>(context,listen: false).endDay,
                                              wardIds: Provider.of<ShiftsProvider>(context,listen: false).selectedAreasOfWorkIds,
                                              endTime: Provider.of<ShiftsProvider>(context,listen: false).endTime,
                                              startTime: Provider.of<ShiftsProvider>(context,listen: false).startTime,
                                              createdSince: Provider.of<ShiftsProvider>(context,listen: false).isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",

                                              historyType: 1
                                          );
                                        }
                                        setState(() {
                                          selectedReason = null;
                                          isUpdatingOfferStatus = false;
                                        });
                                        // here we call onCancel to setState to refresh the cancel offer status after the cancel action
                                        onCancel();
                                      });
                                    },
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(40),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 20),
                                        decoration: BoxDecoration(
                                            color: selectedReason == null ? Colors.grey : Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(40),
                                            border: Border.all(
                                                color: selectedReason == null ? Colors.grey : Theme.of(context).primaryColor
                                            )
                                        ),
                                        child: const Text('Cancel Shift',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                    ),
                    const SizedBox(height: 20.0,),
                  ],
                ),
              ),
            );
          });
        });
  }

  _showShiftsBottomSheet({BuildContext context}){
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:10.0),
                        child: GestureDetector(
                            onTap: (){
                              Navigator.popAndPushNamed(context, HelpAndSupport.routName);
                              AnalyticsManager.track('shift_detail_ask_support');
                            },
                            child: Text("Ask Support", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 23.0,),)),
                      ),
                      dateToTimeStamp(date: DateTime.now()).seconds < offer.cancellableUntil && (offer.offerStatus.value == 8 || offer.offerStatus.value == 1)
                          ? const Divider() :
                      const SizedBox(),

                      dateToTimeStamp(date: DateTime.now()).seconds < offer.cancellableUntil && (offer.offerStatus.value == 8 || offer.offerStatus.value == 1)
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical:10.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                            _showCancelShiftBottomSheet(context: context, media: MediaQuery.of(context).size, offer: offer,
                                onCancel: () async{
                                  // here we call setState to refresh the cancel offer status after the cancel action
                                  if(mounted){
                                    setState((){});
                                  }
                                });
                          },
                          child: Text("Cancel shift", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 23.0,)),),
                      ) :
                      const SizedBox(),

                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:10.0),
                        child: GestureDetector(
                          onTap: ()=> Navigator.pop(context),
                          child: Text("Cancel", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 23.0,)),),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0,),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final offerDetails = Provider.of<ShiftsProvider>(context,listen: false);
    final userData = Provider.of<UserProvider>(context).userData;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        offerDetails.clearCurrentOffer();
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (!kIsWeb) {
            if (Platform.isIOS) {
              if (details.primaryVelocity.compareTo(0) == 1) {
                Navigator.pop(context);
                offerDetails.clearCurrentOffer();
              }
            }
          }
        },
        child: Scaffold(
          appBar: screenAppBar(context, media,
          showLeadingPop: true,
          hideProfilePic: true,
          onBackPressed: (){
            Navigator.pop(context);
            offerDetails.clearCurrentOffer();
          },
          menuAction: () {
            _showShiftsBottomSheet(context: context);
          },
          appbarTitle: Text("Shift Details"),
            elevation: 2.0
          ),

          body: _isLoadingCurrentOffer ? Center(child: SpinKitCircle(color: Theme.of(context).primaryColor,size:45)) : Stack(
            children: [
              ListView(
                children: [
                  Material(
                      elevation: 0.0,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              shiftCard(
                                context,
                                offer: offer,
                              )
                            ],
                          ),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300])),
                        ),
                      )
                  ),
                  Container(
                    width: media.width,
                    height: 35,
                    child: Center(child: Text(offer.offerStatus.value == 8 ? "Awaiting Approval" : offer.offerStatus.name,style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w600),)),
                    decoration: BoxDecoration(
                        color: offer.offerStatus.value == 0 ? Theme.of(context).primaryColor
                            : offer.offerStatus.value == 1 ? const Color(0xFF008000).withOpacity(0.6)
                            : offer.offerStatus.value == 2 ? const Color(0xFFFF0000)
                            : offer.offerStatus.value == 3 ? const Color(0xFFFF0000)
                            : offer.offerStatus.value == 4 ? const Color(0xFFFF0000)
                            : offer.offerStatus.value == 5 ? Theme.of(context).primaryColor.withOpacity(0.4)
                            : offer.offerStatus.value == 6 && offer.offerStatus.name != "In Progress" ? const Color(0xFFFF0000)
                            : offer.offerStatus.name == "In Progress" ? Theme.of(context).primaryColor.withOpacity(0.4)
                            : offer.offerStatus.value == 7 ? const Color(0xFF008000).withOpacity(0.6)
                            : offer.offerStatus.value == 8 ? const Color(0xFFff9c01).withOpacity(0.7)
                            : offer.offerStatus.value == 9 ? const Color(0xFFFF0000)
                            : offer.offerStatus.value == 10 ? const Color(0xFFFF0000)
                            : Theme.of(context).primaryColor.withOpacity(0.4)
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:10.0),
                    child: Material(
                      elevation: 2.0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          child: GroovinExpansionTile(
                            initiallyExpanded: _isExpanded,
                            onExpansionChanged: (value){
                              setState(() {
                                _isExpanded = value;
                              });
                            },
                            defaultTrailingIconColor: Theme.of(context).primaryColor,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                offer.bankAdmin == null ? const SizedBox() : Text("posted by : ${offer.bankAdmin.name}", maxLines: 2,style: TextStyle(color: Colors.grey[700], fontSize: 13.0),),
                                const SizedBox(height: 2.0,),
                                Text(convertTimeStampToHumanDate(offer.createdAt), maxLines: 2,style: TextStyle(color: Colors.grey[700], fontSize: 13.0),),
                                const SizedBox(height: 6.0,),
                              ],
                            ),
                            children: [
                              offer.roles == null && offer.roles.isEmpty && offer.offerLevel == null ?
                              const SizedBox():
                              const Align(alignment: AlignmentDirectional.centerStart,child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Text("Requirements",style: TextStyle(fontWeight: FontWeight.bold),),
                              )),
                              const SizedBox(height: 10,),
                              offer.roles!= null && offer.roles.isNotEmpty ?  Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:4.0, right: 7.0),
                                      child: SvgPicture.asset("images/role.svg",
                                          height: 25.0,
                                          width: 26.0,
                                          color: greyColor),
                                    ),
                                    const SizedBox(width: 5.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(userData.trust['system_type']['name'] != 'nhsp_api' && offer.user.roleType.toString() ==
                                            "2"
                                            ? "Specialities"
                                            :"Positions", style: TextStyle(color: Colors.grey[60], fontSize: 15.0),),
                                        Container(
                                          width: media.width*0.7,
                                          child: Wrap(
                                            children: List.generate(offer.roles.length, (index) => Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: secondColor
                                                  ),
                                                ),
                                                child: Text(offer.roles[index].name),
                                              ),
                                            )),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ) : const SizedBox(),
                              offer.roles!= null && offer.roles.isNotEmpty ? const Divider() : const SizedBox(),
                              offer.offerLevel != null ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 5.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:4.0, right: 7.0),
                                      child: SvgPicture.asset("images/min-level.svg", color: greyColor,width: 24,),
                                    ),
                                    SizedBox(width: 5.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Level", style: TextStyle(color: Colors.grey[60], fontSize: 15.0),),
                                        Text(offer.offerLevel.name , style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0),),
                                      ],
                                    )
                                  ],
                                ),
                              ) : const SizedBox(),
                              offer.offerLevel != null ? const Divider() : const SizedBox(),
                              offer.skills != null && offer.skills.isNotEmpty ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:4.0, right: 7.0),
                                      child: SvgPicture.asset("images/skills.svg",
                                          height: 25.0,
                                          width: 26.0,
                                          color: greyColor),
                                    ),
                                    const SizedBox(width: 5.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Skills", style: TextStyle(color: Colors.grey[60], fontSize: 15.0),),
                                        Container(
                                          width: media.width*0.7,
                                          child: Wrap(
                                            children: List.generate(offer.skills.length, (index) => Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: secondColor
                                                  ),
                                                ),
                                                child: Text(offer.skills[index].name),
                                              ),
                                            )),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ) : const SizedBox(),
                              offer.skills != null && offer.skills.isNotEmpty ? const Divider() : const SizedBox(),
                              offer.languages != null && offer.languages.isNotEmpty ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:4.0, right: 7.0),
                                      child: SvgPicture.asset("images/language.svg",
                                          height: 25.0,
                                          width: 26.0,
                                          color: greyColor),
                                    ),
                                    const SizedBox(width: 5.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Languages", style: TextStyle(color: Colors.grey[60], fontSize: 15.0),),
                                        Container(
                                          width: media.width*0.7,
                                          child: Wrap(
                                            children: List.generate(offer.languages.length, (index) => Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: secondColor
                                                  ),
                                                ),
                                                child: Text(offer.languages[index].name),
                                              ),
                                            )),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ) : const SizedBox(),
                              offer.languages != null && offer.languages.isNotEmpty ? const Divider() : const SizedBox() ,
                              offer.notes != null ? const Align(alignment: AlignmentDirectional.centerStart,child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text("Notes",style: TextStyle(fontWeight: FontWeight.bold),),
                              )) : const SizedBox(),
                              offer.notes != null ?  Align(alignment: AlignmentDirectional.centerStart,child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 3),
                                child: Text("${offer.notes}",style: TextStyle(fontWeight: FontWeight.w400,height: 1.5),),
                              )) : const SizedBox(),
                              offer.notes != null ? const SizedBox(height: 10,) : const SizedBox()
                            ],
                          ),

                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 170,)
                ],
              ),

              offer.offerStatus.value == 0 ? Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height: 75.0,
                    padding: const EdgeInsets.only(bottom: 10,top:10,right: 40,left: 40 ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 6,
                          blurRadius: 7,
                          offset: const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: isUpdatingOfferStatus ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 30,) : InkWell(
                      onTap: (){
                        _showAcceptShiftBottomSheet(
                            context: context,
                            offer: offer,
                            media: media,
                            onConfirm: () async{
                              setState(() {
                                isUpdatingOfferStatus = true;
                              });
                              if(offer.bookingType == "bid"){
                                offerDetails.updateOfferStatus(context,
                                  offerId: offer.id,
                                  offerStatusId: MyApp.flavor == "staging" ? stagingOffersStatuses[8][0] : productionOffersStatuses[8][0],
                                ).then((_) {
                                  setState(() {
                                    isUpdatingOfferStatus = false;
                                  });
                                });
                              }else{
                                offerDetails.updateOfferStatus(context,
                                  offerId: offer.id,
                                  offerStatusId: MyApp.flavor == "staging" ? stagingOffersStatuses[1][0] : productionOffersStatuses[1][0],
                                ).then((_) {
                                  // here i am only updating the open tab since that we need to make this shift disappear from this tab only and it will show up on the upcoming once loaded
                                  if (Provider.of<ShiftsProvider>(context, listen: false).isCalendarView == false) {
                                    Provider.of<ShiftsProvider>(context, listen: false).fetchOffers(context,pageOffset: 0, historyType: 0);
                                  }else{
                                    Provider.of<ShiftsProvider>(context,listen: false).fetchCalendarDaysWithOffers(
                                        context,
                                        startDate: Provider.of<ShiftsProvider>(context,listen: false).startDay,
                                        endDate: Provider.of<ShiftsProvider>(context,listen: false).endDay,
                                        wardIds: Provider.of<ShiftsProvider>(context,listen: false).selectedAreasOfWorkIds,
                                        endTime: Provider.of<ShiftsProvider>(context,listen: false).endTime,
                                        startTime: Provider.of<ShiftsProvider>(context,listen: false).startTime,
                                        createdSince: Provider.of<ShiftsProvider>(context,listen: false).isNewActive ? DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days:1))) : "",
                                        historyType: 0
                                    );
                                  }
                                  setState(() {
                                    isUpdatingOfferStatus = false;
                                  });
                                });
                              }
                              Navigator.pop(context);
                            });
                      },
                      child:  Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          width: media.width*0.6,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Theme.of(context).primaryColor)
                          ),
                          // Request for BID offers and Accept for normal offers
                          child: Text(offer.bookingType == "bid" ? "Request" : 'Accept',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                        ),
                      ),
                    ),
                  )) : const SizedBox(),

              offer.offerStatus.value == 1
                  ? Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Material(
                    elevation: 6.0,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          alignment: AlignmentDirectional.center,
                          color: const Color(0xFFff9c01).withOpacity(0.7),
                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          child: Text(timeStampToDateTime(offer.startDate).difference(timeStampToDateTime(offer.cancellableUntil)).inHours > 0 ? "You are allowed to cancel it ${timeStampToDateTime(offer.startDate).difference(timeStampToDateTime(offer.cancellableUntil)).inHours} hours prior shift start. After that, please contact the Organisation directly to cancel the shift." : "You are allowed to cancel it at any time prior shift start. After that, please contact the Organisation directly to cancel the shift.",style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
                        ),
                        // const Divider(),
                        InkWell(
                          onTap: (){
                            Add2Calendar.addEvent2Cal(event);
                          },
                          child: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset("images/shiftsOutLine.png",width: 20,color: Theme.of(context).primaryColor,),
                                const SizedBox(width: 5,),
                                Text("Add to Device Calendar",style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.w600),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}