// ignore_for_file: file_names, unnecessary_const, prefer_final_fields, prefer_typing_uninitialized_variables, unnecessary_string_interpolations

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/RegisterPersonalInformation.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class SelectUserTypeScreen extends StatefulWidget {
  static const String routeName = "/SelectUserTypeScreen_Screen";

  const SelectUserTypeScreen({Key key}) : super(key: key);

  @override
  _SelectUserTypeScreenState createState() =>
      _SelectUserTypeScreenState();
}

class _SelectUserTypeScreenState
    extends State<SelectUserTypeScreen> {
  List isSelected = [];
  Map passedData = {};
  bool _isInit = true;
  bool _isSubmitting = false;
  List types=[];
  final _formKey = GlobalKey<FormState>();
  String userTypeId = '';
  var userRoleType;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      print(passedData);
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userProvider =  Provider.of<UserProvider>(context,listen: false);
    final userTypes = userProvider.userTypes;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context)),
          title: const Text(
            'User Type',
            style: TextStyle(
                color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.bold),
          ),
        ),
        body: SizedBox(
          height: media.height,
          width: media.width,
          child: SingleChildScrollView(
            child: userTypes.isEmpty || userTypes ==null
                ?
                SizedBox(
                  height: media.height,
                  width: media.width,
                  child: Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                      size: 45.0,
                    ),
                  ),
                )
            :
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(userTypes.length, (i) {
                      for (int i = 0; i < userTypes.length; i++) {
                        isSelected.add(false);
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              "${userTypes[i].name}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: style2,
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
                              setState(() {
                                for (int j = 0; j < userTypes.length; j++) {
                                  isSelected[j] = false;
                                }
                                isSelected[i] = true;
                                userTypeId = userTypes[i].id;
                                userRoleType = userTypes[i].role_type;
                              });
                            },
                          ),
                          (i==userTypes.length - 1) ? const SizedBox(height: 60,) : const Divider(),
                        ],
                      );
                    }),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _isSubmitting
                        ?
                    Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 45.0,
                      ),
                    )
                        :
                    roundedButton(
                        context: context,
                        title: "Continue",
                        buttonWidth: kIsWeb ? buttonWidth : media.width * 0.8,
                        color: isSelected.contains(true) ? Theme.of(context).primaryColor : Colors.grey[300],
                        titleColor: isSelected.contains(true) ? Colors.white : Colors.grey,
                        onClicked: isSelected.contains(true) ?() {
                          Navigator.pushNamed(
                              context, RegisterPersonalInformation.routeName,
                              arguments: {
                                "screen_title": "Sign Up",
                                "trustId":passedData['trustId'],
                                "hospitalsIds": passedData['hospitalsIds'],
                                "userTypeId" : userTypeId,
                                "timezone" : passedData['timezone'],
                                "userRoleType" : userRoleType,
                                "countryCode" : passedData['countryCode']
                              });

                        }:(){},)
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
