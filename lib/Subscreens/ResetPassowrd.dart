// ignore_for_file: file_names, prefer_const_constructors_in_immutables

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class ResetPassword extends StatefulWidget{

  static const routName = "/ResetPassword_Screen";

  ResetPassword({Key key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final _formKey = GlobalKey<FormState>();
  var _enableBorder = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }



  _textFieldBorder(){
    return _enableBorder ?
    OutlineInputBorder(
        borderSide: BorderSide(width: 2.0,color: Theme.of(context).primaryColor),
        borderRadius: textFieldBorderRadius) : null;
  }



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
            backgroundColor: Colors.white,
            appBar: screenAppBar(context, media, appbarTitle: const Text("Reset Password"), showLeadingPop: true, hideProfilePic: true,
                onBackPressed: ()=> Navigator.pop(context)),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Material(
                    color: Colors.white,
                    elevation: 7,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                      child: SizedBox(
                        height: 40.0,
                        child: Center(
                          child: Text("We will send you an email to reset your password", maxLines: 3,
                            overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0),),
                        ),
                      ),
                    ),
                  ),


                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: media.width * 0.07),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: SizedBox(
                              height: 40.0,
                              width: kIsWeb ? buttonWidth : null,
                              child: TextFormField(
                                controller: _emailController,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    setState(() {
                                      _enableBorder = false;
                                    });
                                    return 'Required';
                                  }else if(text.contains("@") == false){
                                    setState(() {
                                      _enableBorder = false;
                                    });
                                    return 'Invalid Email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    focusedBorder: _textFieldBorder(),
                                    contentPadding: EdgeInsets.only(
                                        bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                    border:_textFieldBorder(),
                                    hintText: "Email",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        )),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 2.0,),

                  _isLoading ? Center(
                    child: SpinKitCircle(color: Theme.of(context).primaryColor,size: 40,),
                  ):
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 0 : media.width * 0.07),
                    child: roundedButton(context: context, title: "Reset Password",
                        buttonWidth: 400,
                        onClicked: (){
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            Provider.of<UserProvider>(context,listen: false).resetPassword(context,
                            email: _emailController.text).then((_){
                              setState(() {
                                _isLoading = false;
                              });
                            });
                          }
                        }),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}