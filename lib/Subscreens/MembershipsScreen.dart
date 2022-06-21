// ignore_for_file: file_names, prefer_typing_uninitialized_variables, prefer_final_fields

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/MembershipModel.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';


class MembershipsScreen extends StatefulWidget {
  static const String routeName = "/MembershipsScreen_Screen";

  const MembershipsScreen({Key key}) : super(key: key);

  @override
  _MembershipsScreenState createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {

  List isSelected = [];
  Map passedData = {};
  bool _isInit = true;
  int pageOffset = 0;
  var userTrustId;
  var trustIdToGetHospitals;
  final TextEditingController _searchController = TextEditingController();
  List<Membership> listOfMemberships = [];
  List<String> ids = [];
  List<String> membershipsNames = [];

  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false)
        .getMemberships(context:context,role_type: Provider.of<UserProvider>(context, listen: false).userData.roleType,countryCode: 'GB' )
        .then((_) {
      isSelected = List.filled(Provider.of<UserProvider>(context, listen: false).memberships.length, false);

      for (int w=0; w<Provider.of<UserProvider>(context, listen: false).memberships.length; w++) {
        for (var v = 0; v<Provider.of<UserProvider>(context, listen: false).userData.memberships.length; v++) {
          if (Provider.of<UserProvider>(context, listen: false).memberships[w].id == "${Provider.of<UserProvider>(context, listen: false).userData.memberships[v]['id']}") {
            isSelected[w] = true;
            ids.add(Provider.of<UserProvider>(context, listen: false).memberships[w].id);
          }
        }
      }
   });


    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      _isInit = false;
    }
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Membership> _searchResult = [];

  Map<String,List<String>> membershipsToGoToProfile;

  bool allSelected = false;

  bool _isUpdatingProfile=false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);
    final membershipsStage = userData.membershipsStage;


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
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              leadingWidth: 120,
              leading: Row(
                children: [
                  IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _isUpdatingProfile==true?(){}:() => Navigator.pop(context)),
                  // const SizedBox(width: 5.0,),
                  // Provider.of<CallProvider>(context).isInACall ? returnToCallScreen(context) : const SizedBox()
                ],
              ),
              title: const Text(
                'Membership',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                // passedData['screen_title'] == "Organisation"
                //     ?
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _isUpdatingProfile == true ? const SpinKitCircle(color: Colors.white,size: 25,):InkWell(
                      onTap: () async {
                        setState(() {
                          _isUpdatingProfile = true;
                        });
                        await Provider.of<UserProvider>(context,
                            listen: false)
                            .updateProfile(context,
                            // email: userData.userData.email,
                            // firstName:
                            // userData.userData.firstName,
                            // lastName: userData.userData.lastName,
                            trustId: userData.userData.trust['id'],
                            // phoneNumber: userData.userData.phone,
                            // employeeNumber: userData.userData.employee_number,
                            userType: userData.userData.roleType,
                            // hospitals: userData.userData.hospitals,
                            // minimumLevelId: userData.userData.roleType == 2 ? userData.userData.minAcceptedGrade == null ? null : userData.userData.minAcceptedGrade['id'] : userData.userData.minAcceptedBand == null ? null : userData.userData.minAcceptedBand['id'],
                            // levelId: userData.userData.roleType == 2 ? userData.userData.grade == null ? null : userData.userData.grade['id'] : userData.userData.band == null ? null : userData.userData.band['id'],
                            memberships: ids

                        ).then((_) {
                          setState(() {
                            _isUpdatingProfile = false;
                          });
                        });
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                            color: membershipsToGoToProfile == null ? Colors.black26:Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                //     :
                // SizedBox()
              ],
            ),
            body: membershipsStage == UsersStage.DONE
                ?
            SizedBox(
              height: media.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  _searchResult.isNotEmpty ? SizedBox(
                    height: media.height * 0.7,
                    child: membershipsListWidget(context, media,
                        list: _searchResult ),
                  )
                      :
                  SizedBox(
                    height: media.height * 0.7,
                    child: membershipsListWidget(context, media,
                        list: userData.memberships ),
                  ),
                ],
              ),
            )
                :
            membershipsStage == UsersStage.LOADING
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
            SizedBox(
              height: media.height,
              width: media.width,
              child: Center(
                child: InkWell(
                  onTap: (){
                    Provider.of<UserProvider>(context, listen: false)
                        .getMemberships(context:context,role_type: Provider.of<UserProvider>(context, listen: false).userData.roleType,countryCode: 'GB' )
                        .then((_) {
                      isSelected = List.filled(Provider.of<UserProvider>(context, listen: false).memberships.length, false);

                      for (int w=0; w<Provider.of<UserProvider>(context, listen: false).memberships.length; w++) {
                        for (var v = 0; v<Provider.of<UserProvider>(context, listen: false).userData.memberships.length; v++) {
                          if (Provider.of<UserProvider>(context, listen: false).memberships[w].id == "${Provider.of<UserProvider>(context, listen: false).userData.memberships[v]['id']}") {
                            isSelected[w] = true;
                            ids.add(Provider.of<UserProvider>(context, listen: false).memberships[w].id);
                          }
                        }
                      }
                    });
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

  Widget membershipsListWidget(context, media, {list}) {
    return SizedBox(
      width: media.width,
      height: media.height,
      child: SizedBox(
        height: media.height ,
        child: list.isEmpty
            ? SizedBox(
          height: media.height,
          width: media.width,
          child: Center(child: Text('There are no Memberships for this Trust in selected Country!',style: style2,textAlign: TextAlign.center,)),
        )
            : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(
                            "${list[i].name}",
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
                              isSelected[i]=!isSelected[i];
                              if(isSelected[i]==true){
                                ids.add(list[i].id.toString());
                                membershipsNames.add(list[i].name.toString());
                              }
                              else if(isSelected[i]==false){
                                ids.remove(list[i].id.toString());
                                membershipsNames.remove(list[i].name.toString());
                              }
                            });
                            membershipsToGoToProfile={
                              "MembershipsIds" : ids,
                              "MembershipsNames" : membershipsNames
                            };
                          },
                        ),
                        (i==list.length - 1) ? const SizedBox(height: 60,) : const Divider(),
                      ],
                    );
                  }
          // }
        ),
                ],
              ),
            ),
      ),
    );
  }
}
