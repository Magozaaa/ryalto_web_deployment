import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/TrustModel.dart';
import 'package:rightnurse/Models/countryModel.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/HospitalsScreen.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart' as commonWidgets;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';


class TrustsSearchScreen extends StatefulWidget {
  static const String routeName = "/TrustsSearch_Screen";

  @override
  _TrustsSearchScreenState createState() => _TrustsSearchScreenState();
}

class _TrustsSearchScreenState extends State<TrustsSearchScreen> {
  List isSelected = [];
  Map passedData = {};
  var _isInit = true;
  int pageOffset = 0;
  String countryCode = "GB";
  String countryName = "United Kingdom";
  var trustIdToBeChanged = '';
  Map<String, String> trustDataToGoToEditProfile = {};
  final TextEditingController _searchController = TextEditingController();
  // List<Trust> listOfTrusts = [];
  String _timezone = 'Unknown';
  List<String> _availableTimezones = <String>[];
  String currentTimeZone = 'GB';

  Future<void> _getTimeZone() async {
    currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    try {
      _timezone = await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {
      debugPrint('Could not get the local timezone');
    }
    try {
      _availableTimezones = await FlutterNativeTimezone.getAvailableTimezones();
      _availableTimezones.sort();
    } catch (e) {
      debugPrint('Could not get available timezones');
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool _isUpdatingProfile=false;
  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false)
        .getTrusts(context)
        .then((_) {
      // listOfTrusts = value;
      isSelected = List(Provider.of<UserProvider>(context, listen: false).trusts.length);
      if (Provider.of<UserProvider>(context, listen: false).userData !=null) {
        for (int i = 0; i < Provider.of<UserProvider>(context, listen: false).trusts.length; i++) {
          debugPrint(Provider.of<UserProvider>(context, listen: false).trusts.length.toString());
          // debugPrint(Provider.of<UserProvider>(context, listen: false).userData.trust['name'].toString());

          if (Provider.of<UserProvider>(context, listen: false).trusts[i].id == Provider.of<UserProvider>(context, listen: false).userData.trust['id']) {
            isSelected[i] = true;
          } else {
            isSelected[i] = false;
          }
        }
      }
      else{
        for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = false;
        }
      }
    });
    // Provider.of<UserProvider>(context, listen: false).getCountries();
    super.initState();
    // _getTimeZone();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Trust> _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.length = 15;
    print(text);
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    if (Provider.of<UserProvider>(context, listen: false).userData !=null) {
      for (int i = 0; i < Provider.of<UserProvider>(context, listen: false).trusts.length; i++) {
        if (Provider.of<UserProvider>(context, listen: false).trusts[i].name.toLowerCase().contains(text)) {
          _searchResult.add(Provider.of<UserProvider>(context, listen: false).trusts[i]);
        }
        // debugPrint(Provider.of<UserProvider>(context, listen: false).trusts.length.toString());
        // debugPrint(Provider.of<UserProvider>(context, listen: false).userData.trust['name'].toString());
        isSelected = List(_searchResult.length);

        for(int j = 0; j < _searchResult.length; j++){
          if (_searchResult[j].id == Provider.of<UserProvider>(context, listen: false).userData.trust['id']) {
            isSelected[j] = true;
          } else {
            isSelected[j] = false;
          }
        }
      }
    }
    else{
      for (int i = 0; i < Provider.of<UserProvider>(context, listen: false).trusts.length; i++) {
        print(Provider.of<UserProvider>(context, listen: false).trusts[i].name.toLowerCase().contains(text));
        print(Provider.of<UserProvider>(context, listen: false).trusts[i].name);
        if (Provider.of<UserProvider>(context, listen: false).trusts[i].name.toLowerCase().contains(text)) {
          _searchResult.add(Provider.of<UserProvider>(context, listen: false).trusts[i]);


        }
        print(Provider.of<UserProvider>(context, listen: false).trusts[i].name.toLowerCase().contains(text));

        // debugPrint(Provider.of<UserProvider>(context, listen: false).trusts.length.toString());
        // debugPrint(Provider.of<UserProvider>(context, listen: false).userData.trust['name'].toString());
          isSelected = List(_searchResult.length);
          for(int j =0; j<isSelected.length;j++){
            isSelected[j] = false;
          }

      }
      print(_searchResult);

    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);
    final List<CountryModel> countries = userData.countries;
    final trustsStage = userData.trustsStage;
    final countriesStage = userData.countriesStage;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              leadingWidth: 120,
              leading: Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _isUpdatingProfile == true ? (){}:() => Navigator.pop(
                            context,
                          )),
                ],
              ),
              title: Text(
                'Organisation',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                // passedData['screen_title'] == "Organisation"
                //     ?
                passedData['screen_content'] == 'AccountDetails' ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _isUpdatingProfile == true ? SpinKitCircle(size: 25,color: Colors.white,):InkWell(
                            onTap:
                            trustDataToGoToEditProfile == null
                                ? () {}
                                :
                                () async {
                                    // Navigator.pop(context,trustDataToGoToEditProfile);
                                  setState(() {
                                    _isUpdatingProfile = true;
                                  });
                                    await Provider.of<UserProvider>(context,
                                            listen: false)
                                        .updateProfile(context,
                                            email: userData.userData.email,
                                            firstName:
                                                userData.userData.firstName,
                                            lastName: userData.userData.lastName,
                                            trustId: trustIdToBeChanged,
                                            phoneNumber: userData.userData.phone,
                                        employeeNumber: userData.userData.employee_number,
                                        userType: userData.userData.roleType
                                    ).then((_) {
                                      setState(() {
                                        _isUpdatingProfile = false;
                                      });
                                    });
                                  },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                  color: trustDataToGoToEditProfile == null
                                      ? Colors.black26
                                      : Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ) : SizedBox()
                    // : SizedBox()
              ],
            ),
            body:
                trustsStage == UsersStage.LOADING ||
                        countriesStage == UsersStage.LOADING
                    ? Container(
                        height: media.height,
                        width: media.width,
                        child: Center(
                          child: SpinKitCircle(
                            color: Theme.of(context).primaryColor,
                            size: 45.0,
                          ),
                        ),
                      )
                    : trustsStage == UsersStage.DONE
                        ? Container(
                            height: media.height,
                            child: Stack(
                              children: [
                                SingleChildScrollView(
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Material(
                                        color: Colors.white,
                                        elevation: 7.0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 15.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: 40.0,
                                                child: Center(
                                                  child: Text(
                                                    "Where do you work?",
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 40.0,
                                                child: TextFormField(
                                                  controller: _searchController,
                                                  onChanged: (value) async {
                                                    if (value.length > 2) {
                                                      onSearchTextChanged(
                                                          value.toLowerCase());
                                                    } else {
                                                      setState(() {
                                                        _searchResult.clear();
                                                        // isSelected.clear();
                                                      });
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                      prefixIcon: Icon(
                                                        Icons.search,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: 2.0,
                                                              color: Theme.of(context)
                                                                  .primaryColor),
                                                          borderRadius:
                                                          textFieldBorderRadius),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 0.0,
                                                              left: 15.0,
                                                              right: 15.0),
                                                      border: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: 2.0,
                                                              color: Theme.of(context)
                                                                  .primaryColor),
                                                          borderRadius:
                                                          textFieldBorderRadius),
                                                      hintText: "Search",
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey,
                                                          fontFamily: 'DIN')),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: media.height*0.8,
                                        child: trustsListWidget(context, media,
                                            list: _searchResult,),
                                      ),
                                    ],
                                  ),
                                ),
                                passedData['screen_title'] == "Organisation"
                                    ? const SizedBox()
                                    :
                                passedData['screen_content'] == 'AccountDetails'
                                    ?
                                const SizedBox()
                                    :
                                Positioned(
                                        bottom: 0.0,
                                        left: 0.0,
                                        right: 0.0,
                                        child: Container(
                                          height: 125.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(30),
                                              topLeft: Radius.circular(30),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.grey.withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    countryCode != "GB"
                                                        ? SizedBox()
                                                        : Text(
                                                            "Not working in ",
                                                            textAlign:
                                                                TextAlign.center,
                                                            maxLines: 2,
                                                          ),
                                                    Text(
                                                      "$countryName",
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    countryCode != "GB"
                                                        ? SizedBox()
                                                        : Text(
                                                            "?",
                                                            textAlign:
                                                                TextAlign.center,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          40.0))),
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.white,
                                                      context: context,
                                                      builder: (context) {
                                                        return Stack(
                                                          children: [
                                                            Positioned(
                                                              top: 20,
                                                              right: 30,
                                                              child: InkWell(
                                                                  onTap: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child: Icon(Icons
                                                                      .close)),
                                                            ),
                                                            Container(
                                                              height:
                                                                  media.height *
                                                                      0.5,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        50.0,
                                                                    horizontal:
                                                                        15.0),
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: List.generate(
                                                                        countries
                                                                            .length,
                                                                        (index) {
                                                                      return Column(
                                                                        children: [
                                                                          InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              setState(() {
                                                                                countryCode = countries[index].code;
                                                                                countryName = countries[index].name;
                                                                              });
                                                                              Provider.of<UserProvider>(context, listen: false).getTrusts(context, countryCode: countryCode);
                                                                              Navigator.pop(context);
                                                                              AnalyticsManager.track('signup_country_changed');
                                                                                },
                                                                            child:
                                                                                Container(
                                                                              padding:
                                                                                  EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                                                              width:
                                                                                  media.width,
                                                                              child:
                                                                                  Text(countries[index].name),
                                                                            ),
                                                                          ),
                                                                          (index ==
                                                                                  countries.length - 1)
                                                                              ? SizedBox(
                                                                                  height: 20,
                                                                                )
                                                                              : Divider(
                                                                                  color: Colors.grey[500],
                                                                                )
                                                                        ],
                                                                      );
                                                                    }),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: Text(
                                                  "Tap here to change country",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15.0,
                                              ),
                                              commonWidgets.roundedButton(
                                                  context: context,
                                                  title: "Next",
                                                  buttonWidth: kIsWeb ? buttonWidth : media.width * 0.8,
                                                  color: isSelected.contains(true)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.grey[300],
                                                  titleColor:
                                                      isSelected.contains(true)
                                                          ? Colors.white
                                                          : Colors.grey,
                                                  onClicked: () {
                                                    Navigator.pushNamed(context,
                                                        HospitalsScreen.routeName,
                                                        arguments: {
                                                          "screen_title":
                                                              "Sign Up",
                                                          "trustId":
                                                              trustIdToBeChanged
                                                                  .toString(),
                                                          "screen_content":
                                                              'hospitals',
                                                          "countryCode":
                                                              countryCode,
                                                          "timezone":
                                                              currentTimeZone
                                                        });
                                                    AnalyticsManager.track('signup_trust_changed');
                                                  })
                                            ],
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          )
                        : Container(
                            height: media.height,
                            width: media.width,
                            child: Center(
                              child: InkWell(
                                onTap: (){
                                  Provider.of<UserProvider>(context, listen: false)
                                      .getTrusts(context)
                                      .then((_) {
                                    isSelected = List(Provider.of<UserProvider>(context, listen: false).trusts.length);
                                    if (Provider.of<UserProvider>(context, listen: false).userData !=null) {
                                      for (int i = 0; i < Provider.of<UserProvider>(context, listen: false).trusts.length; i++) {
                                        debugPrint(Provider.of<UserProvider>(context, listen: false).trusts.length.toString());
                                        if (Provider.of<UserProvider>(context, listen: false).trusts[i].id == Provider.of<UserProvider>(context, listen: false).userData.trust['id']) {
                                          isSelected[i] = true;
                                        } else {
                                          isSelected[i] = false;
                                        }
                                      }
                                    }
                                    else{
                                      for (int i = 0; i < isSelected.length; i++) {
                                        isSelected[i] = false;
                                      }
                                    }
                                  });
                                  Provider.of<UserProvider>(context, listen: false).getCountries();
                                  _getTimeZone();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Network Error retry? "),
                                    Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
                                  ],
                                ),
                              )
                            ),
                          )),
      ),
    );
  }

  Widget trustsListWidget(context, media, {List list}) {
    return Container(
      width: media.width,
      height: media.height,
      child: Container(
        height: media.height * 0.7,
        child: list.isEmpty
            ? Center(
                child: Text(
                  "Please type the name of your organisation ",
                  style: commonWidgets.style2,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          "${list[i].name}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: commonWidgets.style2,
                        ),
                        trailing: !isSelected[i]
                            ? Container(
                                width: 1.0,
                              )
                            : Icon(
                                Icons.done,
                                color: Theme.of(context).primaryColor,
                              ),
                        onTap: () {
                          if (passedData["screen_title"] == "Organisation" ||
                              passedData["screen_title"] == "Preferred Band" ||
                              passedData["screen_title"] == "Band" ||
                              passedData["screen_title"] == "Sign Up") {
                            setState(() {
                              for (int j = 0; j < isSelected.length; j++) {
                                isSelected[j] = false;
                              }
                              isSelected[i] = !isSelected[i];

                              trustIdToBeChanged = list[i].id;
                              trustDataToGoToEditProfile = {
                                'TrustName': list[i].name,
                                'TrustId': list[i].id
                              };
                            });
                          } else {
                            setState(() {
                              isSelected[i] = !isSelected[i];
                            });
                          }
                        },
                      ),
                      (i == list.length - 1)
                          ? SizedBox(
                              height: passedData['screen_content'] == 'AccountDetails' ? 60 : 250,
                            )
                          : Divider(),
                    ],
                  );
                }
                // }
                ),
      ),
    );
  }
}
