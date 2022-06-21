// ignore_for_file: file_names, must_call_super

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/HospitalsScreen.dart';
import 'package:rightnurse/Subscreens/MembershipsScreen.dart';
import 'package:rightnurse/Subscreens/Profile/RolesScreen.dart';
import 'package:rightnurse/Subscreens/SearchScreen.dart';
import 'package:rightnurse/Subscreens/TrustsSearchScreen.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:path/path.dart' as p;
import 'dart:html' as html;

import 'package:websafe_svg/websafe_svg.dart';

class AccountDetails extends StatefulWidget {
  @override
  _AccountDetailsState createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails>
    with AutomaticKeepAliveClientMixin<AccountDetails> {
  @override
  bool get wantKeepAlive => true;

  bool hasProfilePic = false;
  final _formKey = GlobalKey<FormState>();
  var _enableBorder = true;
  PickedFile _imageFile;
  String imgName;
  String imgPath;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();

  String base64Image;

  _textFieldBorder() {
    return _enableBorder
        ? OutlineInputBorder(
            borderSide:
                BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
            borderRadius: textFieldBorderRadius)
        : null;
  }

  final TextEditingController _firstNameEditor = TextEditingController();
  final TextEditingController _lastNameEditor = TextEditingController();
  final TextEditingController _emailEditor = TextEditingController();
  final TextEditingController _phoneEditor = TextEditingController();
  final TextEditingController _employeeNoEditor = TextEditingController();

  @override
  void dispose() {
    _firstNameEditor.dispose();
    _lastNameEditor.dispose();
    _emailEditor.dispose();
    _phoneEditor.dispose();
    _employeeNoEditor.dispose();
    super.dispose();
  }

  Map<String, String> trustDataFromTrusts;
  Map<String, List<String>> hospitalsDataFromTrusts;
  Map<String, dynamic> membershipsFromMembershipsScreen;
  Map<String, dynamic> rolesFromRulesScreen;

  void _awaitReturnValueFromTrustsScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.pushNamed(
        context, TrustsSearchScreen.routeName, arguments: {
      "screen_title": "Organisation",
      "screen_content": "AccountDetails",
      "trustId": null
    });

    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      trustDataFromTrusts = result;
    });
  }

  @override
  void initState() {
    AnalyticsManager.track('screen_profile_edit_account_detail');
  }

  void _awaitReturnValueFromHospitalsScreen(
      BuildContext context, trustId) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.pushNamed(context, HospitalsScreen.routeName,
        arguments: {
          "screen_title": "Sites",
          "trustId": trustDataFromTrusts == null
              ? trustId
              : trustDataFromTrusts['TrustId'],
          "screen_content": 'hospitals',
        });

    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      hospitalsDataFromTrusts = result;
    });
  }

  void _awaitReturnValueFromRolesScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.pushNamed(context, RolesScreen.routeName,
        arguments: {
          "screen_title": "Roles",
          "screen_content": "Roles",
          "trustId": null
        });

    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      rolesFromRulesScreen = result;
    });
  }

  void _awaitReturnValueFromMembershipsScreen(BuildContext context,
      {trustId, roleType}) async {
    // start the SecondScreen and wait for it to finish with a result

    final result = await Navigator.pushNamed(
        context, MembershipsScreen.routeName,
        arguments: {
          "screen_title": "MemberShips",
          "trustId": trustDataFromTrusts == null
              ? trustId
              : trustDataFromTrusts['TrustId'],
          "screen_content": 'hospitals',
          // "countryCode" : countryCode,
          // "timezone" : currentTimeZone
        });

    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      membershipsFromMembershipsScreen = result;
    });
  }


  bool _isResendingEmail = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _resendVerificationEmail() async {
    setState(() {
      _isResendingEmail = true;
    });
    await Provider.of<UserProvider>(context, listen: false)
        .resendEmailVerification(
            context: context,
            scaffoldKey: _scaffoldKey,
            email: Provider.of<UserProvider>(context, listen: false)
                .userData
                .email)
        .then((value) {
      setState(() {
        _isResendingEmail = false;
      });
    });
  }
  final _pickedImages = <Image>[];

  Image fromWebPicker ;

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String base64String(Uint8List data) {
    return base64Encode(data);
  }


  Future<void> _pickImage() async {
    var mediaData = await ImagePickerWeb.getImageInfo;
    html.File mediaFile = html.File(mediaData.data, mediaData.fileName,);
    if (mediaFile != null) {
      setState(() {
        imgName = mediaFile.name;
        // fromWebPicker = mediaData.data;
        fromWebPicker = Image.memory(
          mediaData.data,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
            return Image.asset('images/errorImage.png', height: 70,);
          },);
      });

      base64Image = base64Encode(mediaData.data);
      Provider.of<UserProvider>(context,listen: false).setEditProfileData(profilePic: base64Image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: userData.userData == null ? const SizedBox() : GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: media.height * 0.015,
                ),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () async  {
                      if (!kIsWeb) {
                        showAttachImgBottomSheet(
                            context: context,
                            onCameraImg: () async {
                              try {
                                final pickedFile = await _picker.getImage(
                                  source: ImageSource.camera,
                                  imageQuality: 90,
                                  maxHeight: 500,
                                  maxWidth: 500,
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    _imageFile = pickedFile;
                                    imgName = p.basename(pickedFile.path);
                                    imgPath = pickedFile.path as String;
                                  });
                                  List<int> imageBytes =
                                  await _imageFile.readAsBytes();
                                  base64Image = base64Encode(imageBytes);
                                  userData.setEditProfileData(
                                      profilePic: base64Image);
                                }
                              } catch (e) {
                                setState(() {
                                  _pickImageError = e;
                                });
                              }
                            },
                            onGalleryImg: () async {
                              try {
                                final pickedFile = await _picker.getImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 500,
                                  maxHeight: 500,
                                  imageQuality: 90,
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    _imageFile = pickedFile;
                                    imgName = p.basename(pickedFile.path);
                                    imgPath = pickedFile.path as String;
                                  });
                                  List<int> imageBytes =
                                  await _imageFile.readAsBytes();
                                  base64Image = base64Encode(imageBytes);
                                  userData.setEditProfileData(
                                      profilePic: base64Image);
                                }
                              } catch (e) {
                                setState(() {
                                  _pickImageError = e;
                                });
                              }
                            });
                      }
                      else{
                        _pickImage();
                        // Image fromPicker = await ImagePickerWeb.getImageAsWidget();
                        // Uint8List bytesFromPicker = await ImagePickerWeb.getImageAsBytes();

                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: Container(
                        height: 110.0,
                        width: 110.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            userData.userData.profilePic == null ||
                                userData.userData.profilePic == ""
                                ? Image.asset(
                              "images/person.png",
                              fit: BoxFit.cover,
                              height: 110.0,
                              width: 110.0,
                            )
                                : _imageFile != null
                                ? Image.file(
                              File(_imageFile.path),
                              fit: BoxFit.cover,
                            )
                                :
                            fromWebPicker != null ? Image(image: fromWebPicker.image,fit: BoxFit.cover,)
                                :
                            Image.network(
                              userData.userData.profilePic,
                              fit: BoxFit.cover,
                              height: 110.0,
                              width: 110.0,
                              errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                return WebsafeSvg.asset('images/missingImage.svg',color: Colors.grey[400],);
                              },
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add_a_photo_rounded,
                                  color: !hasProfilePic
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                  size: 40.0,
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                userData.userData.verified
                    ?
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WebsafeSvg.asset(
                          'images/verified-filled.svg',
                          color: Theme.of(context).primaryColor,
                          width: 25,
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Text(
                          "Profile Verified",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
                    :
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        showAnimatedCustomDialog(context,
                            title: "What is a verified Profile ?",
                            message:
                            "Getting your profile verified is the easiest way to get shifts through Ryalto. We'll verify your profile and professional skills and share the feedback with you. Simple and transparent.",
                            buttonText: "Ask Support",
                            cancelButtonTitle: "Ok", onClicked: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, HelpAndSupport.routName);
                            });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WebsafeSvg.asset(
                            'images/alert-filled.svg',
                            width: 25,
                            color: const Color(0xFFFFC306),
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            "Profile Verification Pending",
                            style: style7,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Details",
                        style: style1,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Material(
                        elevation: 7.0,
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  child: TextFormField(
                                    controller: _firstNameEditor,
                                    onChanged: (val) {
                                      if (val != "" || val != null) {
                                        userData.setEditProfileData(
                                            firstName: val,
                                            lastName: _lastNameEditor.text ??
                                                userData.userData.lastName,
                                            email: _emailEditor.text ??
                                                userData.userData.email,
                                            phoneNumber: _phoneEditor.text ??
                                                userData.userData.phone,
                                            employeeNumber: _employeeNoEditor
                                                .text ??
                                                userData.userData.employee_number,
                                            profilePic: base64Image);
                                        // _formKey.currentState.save();
                                      }
                                      // else {
                                      //   userData.setEditProfileData(
                                      //     firstName: null,
                                      //   );
                                      // }
                                    },
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Transform.scale(
                                              scale: 0.6,
                                              child: WebsafeSvg.asset("images/user-detail-filled.svg",
                                                  height: 20,
                                                  width: 20,
                                                  color:
                                                  Theme.of(context).primaryColor),
                                            ),

                                          ),
                                        ),
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true
                                                ? 0.0
                                                : 15.0,
                                            left: 15.0,
                                            right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText:
                                        userData.userData.firstName,
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  child: TextFormField(
                                    controller: _lastNameEditor,
                                    onChanged: (val) {
                                      if (val != "" || val != null) {
                                        userData.setEditProfileData(
                                            lastName: val,
                                            firstName: _firstNameEditor.text ??
                                                userData.userData.firstName,
                                            email: _emailEditor.text ??
                                                userData.userData.email,
                                            phoneNumber: _phoneEditor.text ??
                                                userData.userData.phone,
                                            employeeNumber: _employeeNoEditor
                                                .text ??
                                                userData.userData.employee_number,
                                            profilePic: base64Image);
                                      }
                                      // else {
                                      //   userData.setEditProfileData(
                                      //     lastName: null,
                                      //   );
                                      // }
                                    },
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Transform.scale(
                                              scale: 0.6,
                                              child: WebsafeSvg.asset("images/user-detail-filled.svg",
                                                  height: 20,
                                                  width: 20,
                                                  color:
                                                  Theme.of(context).primaryColor),
                                            ),
                                          ),
                                        ),
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true
                                                ? 0.0
                                                : 15.0,
                                            left: 15.0,
                                            right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText: userData.userData.lastName,
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  child: TextFormField(
                                    controller: _emailEditor,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (val) {
                                      if (val != "" || val != null) {
                                        userData.setEditProfileData(
                                            email: val,
                                            firstName: _firstNameEditor.text ??
                                                userData.userData.firstName,
                                            lastName: _lastNameEditor.text ??
                                                userData.userData.lastName,
                                            phoneNumber: _phoneEditor.text ??
                                                userData.userData.phone,
                                            employeeNumber: _employeeNoEditor
                                                .text ??
                                                userData.userData.employee_number,
                                            profilePic: base64Image);

                                        _formKey.currentState.save();
                                      }
                                      // else {
                                      //   userData.setEditProfileData(
                                      //     email: null,
                                      //   );
                                      // }
                                    },
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Required';
                                      } else if (text.contains("@") == false) {
                                        return 'Invalid Email';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        suffixIcon: userData
                                            .userData.emailVerified
                                            ? Transform.scale(
                                          scale: 0.6,
                                          child: WebsafeSvg.asset("images/verified-filled.svg",
                                              height: 20,
                                              width: 20,
                                              color:
                                              Theme.of(context).primaryColor),
                                        )
                                            : InkWell(
                                            onTap: () {
                                              AnalyticsManager.track('profile_verification_ask_support');
                                              showAnimatedCustomDialog(
                                                  context,
                                                  title:
                                                  "Confirm your email address",
                                                  message:
                                                  "An email has been sent to your email address. Confirm your address from the mail to make sure you'll receive all new requests and offer updates right away.",
                                                  buttonText: "RESEND EMAIL",
                                                  cancelButtonTitle: "Ok",
                                                  onClicked: () {
                                                    _resendVerificationEmail();
                                                    Navigator.pop(context);
                                                  });
                                            },
                                            child: Transform.scale(
                                              scale: 0.6,
                                              child: WebsafeSvg.asset(
                                                'images/alert-filled.svg',
                                                width: 15,
                                                color: const Color(0xFFFFC306),
                                              ),
                                            )),
                                        prefixIcon: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                          child: Transform.scale(
                                            scale: 0.6,
                                            child: WebsafeSvg.asset("images/email-filled.svg",
                                                height: 20,
                                                width: 20,
                                                color:
                                                Theme.of(context).primaryColor),
                                          ),
                                        ),
                                        ),
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true
                                                ? 0.0
                                                : 15.0,
                                            left: 15.0,
                                            right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText: userData.userData.email,
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                                child: SizedBox(
                                  height: 40.0,
                                  child: TextFormField(
                                    controller: _phoneEditor,
                                    onChanged: (val) {
                                      if (val != "" || val != null) {
                                        userData.setEditProfileData(
                                            phoneNumber: val,
                                            firstName: _firstNameEditor.text ??
                                                userData.userData.firstName,
                                            lastName: _lastNameEditor.text ??
                                                userData.userData.lastName,
                                            email: _emailEditor.text ??
                                                userData.userData.email,
                                            employeeNumber: _employeeNoEditor
                                                .text ??
                                                userData.userData.employee_number,
                                            profilePic: base64Image);

                                        _formKey.currentState.save();
                                      }
                                      // else {
                                      //   userData.setEditProfileData(
                                      //     phoneNumber: null,
                                      //   );
                                      // }
                                    },
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        setState(() {
                                          _enableBorder = false;
                                        });
                                        return 'Provide a valid phone number';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Transform.scale(
                                              scale: 0.5,
                                              child: WebsafeSvg.asset(
                                                "images/call-filled.svg",
                                                color:
                                                Theme.of(context).primaryColor,
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                        ),
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true
                                                ? 0.0
                                                : 15.0,
                                            left: 15.0,
                                            right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText: userData.userData.phone == ""
                                            ? "Phone No with country code"
                                            : userData.userData.phone,
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 22.0,
                      ),
                      Text(
                        "Work Details",
                        style: style1,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Material(
                        elevation: 7.0,
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 7.0),
                                child: ListTile(
                                  onTap: () =>
                                      _awaitReturnValueFromTrustsScreen(context),
                                  leading: WebsafeSvg.asset(
                                    'images/organisation-filled.svg',
                                    color: Theme.of(context).primaryColor,
                                    width: 25,
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Organisation",
                                        /// need to check conditions and values
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      Text(
                                        "${userData.userData.trust["name"]}",
                                        overflow: TextOverflow.ellipsis,
                                        style: style2,
                                      )
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded,size: 16,),
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: ListTile(
                                  onTap: () =>
                                      _awaitReturnValueFromHospitalsScreen(
                                          context, userData.userData.trust['id']),
                                  leading: WebsafeSvg.asset("images/site-filled.svg",
                                      height: 25.0,
                                      width: 25.0,
                                      color: Theme.of(context).primaryColor),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Sites",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      userData.userData.hospitals.isNotEmpty
                                          ? Padding(
                                        padding:
                                        const EdgeInsets.only(top: 3.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: userData.userData.hospitals == null || userData.userData.hospitals.isEmpty ? Text('Not set',style: TextStyle(color: Colors.grey[600],fontSize: 14),) : Wrap(
                                            spacing: 5.0,
                                            runSpacing: 5.0,
                                            children: userData
                                                .userData.hospitals
                                                .map((item) => Container(
                                                decoration:
                                                BoxDecoration(
                                                  color: Theme.of(
                                                      context)
                                                      .primaryColor
                                                      .withOpacity(0.6),
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      8.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(6.0),
                                                  child: Text(
                                                    "${item["name"]}",
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    style: style5,
                                                  ),
                                                )))
                                                .toList()
                                                .cast<Widget>(),
                                          ),
                                        ),
                                      )
                                          : const Text('-'),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded,size: 16,),
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: ListTile(
                                  onTap: () {
                                    _awaitReturnValueFromRolesScreen(context);
                                  },
                                  leading: WebsafeSvg.asset("images/role-filled.svg",
                                      height: 25.0,
                                      width: 26.0,
                                      color: Theme.of(context).primaryColor),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData.userData.roleType.toString() ==
                                            "2"
                                            ? "Specialities"
                                            : "Positions",
                                        style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: userData.userData.roles == null || userData.userData.roles.isEmpty ? Text('Not set',style: TextStyle(color: Colors.grey[600],fontSize: 14),) : Wrap(
                                            spacing: 5.0,
                                            runSpacing: 5.0,
                                            children: userData.userData.roles
                                                .map((item) => Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.6),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      8.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.all(
                                                      6.0),
                                                  child: Text(
                                                    "${item["name"]}",
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: style5,
                                                  ),
                                                )))
                                                .toList()
                                                .cast<Widget>(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded,size: 16,),
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: ListTile(
                                  onTap: () =>
                                      _awaitReturnValueFromMembershipsScreen(
                                          context),
                                  leading: WebsafeSvg.asset("images/membership-filled.svg",
                                      height: 30.0,
                                      width: 28.0,
                                      color: Theme.of(context).primaryColor),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Memberships",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      userData.userData.memberships == null || userData.userData.memberships.isNotEmpty
                                          ? Padding(
                                        padding:
                                        const EdgeInsets.only(top: 3.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Wrap(
                                            spacing: 5.0,
                                            runSpacing: 5.0,
                                            children: userData
                                                .userData.memberships
                                                .map((item) => Container(
                                                decoration:
                                                BoxDecoration(
                                                  color: Theme.of(
                                                      context)
                                                      .primaryColor
                                                      .withOpacity(0.6),
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      8.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(6.0),
                                                  child: Text(
                                                    "${item["name"]}",
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    style: style5,
                                                  ),
                                                )))
                                                .toList()
                                                .cast<Widget>(),
                                          ),
                                        ),
                                      )
                                          : Text('Not set',style: TextStyle(color: Colors.grey[600],fontSize: 14),)
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded,size: 16,),
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 25.0, top: 7.0),
                                child: SizedBox(
                                  height: 40.0,
                                  child: TextFormField(
                                    controller: _employeeNoEditor,
                                    onChanged: (val) {
                                      if (val != "" || val != null) {
                                        userData.setEditProfileData(
                                            employeeNumber: val,
                                            firstName: _firstNameEditor.text ??
                                                userData.userData.firstName,
                                            lastName: _lastNameEditor.text ??
                                                userData.userData.lastName,
                                            email: _emailEditor.text ??
                                                userData.userData.email,
                                            phoneNumber: _phoneEditor.text ??
                                                userData.userData.phone,
                                            profilePic: base64Image);

                                        _formKey.currentState.save();
                                      }
                                      // else {
                                      //   userData.setEditProfileData(
                                      //     employeeNumber: null,
                                      //   );
                                      // }
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Transform.scale(
                                              scale: 0.7,
                                              child: WebsafeSvg.asset(
                                                "images/employee-number-filled.svg",
                                                color:
                                                Theme.of(context).primaryColor,
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                        ),
                                        focusedBorder: _textFieldBorder(),
                                        contentPadding: EdgeInsets.only(
                                            bottom: _enableBorder == true
                                                ? 0.0
                                                : 15.0,
                                            left: 15.0,
                                            right: 15.0),
                                        border: _textFieldBorder(),
                                        hintText: userData.userData
                                            .employee_number ==
                                            "" ||
                                            userData.userData
                                                .employee_number ==
                                                null
                                            ? "Employee Number"
                                            : userData.userData.employee_number,
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontFamily: 'DIN')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Center(child: needHelp(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
