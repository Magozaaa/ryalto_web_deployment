// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class Password extends StatefulWidget{

  static const routName = "/Password_Screen";

  const Password({Key key}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {

  final _formKey = GlobalKey<FormState>();
  var _enableBorder = true;

  List<bool> _showPass;
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    _showPass = [false, false, false];

  }


  _textFieldBorder(){
    return _enableBorder ?
    OutlineInputBorder(
        borderSide: BorderSide(width: 2.0,color: Theme.of(context).primaryColor),
        borderRadius: textFieldBorderRadius) : null;
  }

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    super.dispose();
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
            appBar: screenAppBar(context, media, appbarTitle: const Text("Change password"), showLeadingPop: true, hideProfilePic: true,
                onBackPressed: ()=> Navigator.pop(context)),
            body: Align(
              alignment: AlignmentDirectional.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25.0,),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0,horizontal: 0),
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
                                  controller: _oldPasswordController,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      setState(() {
                                        _enableBorder = false;
                                      });
                                      return 'Enter your password';
                                    }
                                    return null;
                                  },
                                  obscureText: !_showPass[0],
                                  decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.only(bottom: _enableBorder == true ? 0.0: 15.0),
                                        icon: Icon(
                                          _showPass[0]
                                              ? Icons.visibility : Icons.visibility_off,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                        onPressed: (){
                                          setState(() {
                                            _showPass[0] = !_showPass[0];
                                          });
                                        },
                                      ),
                                      focusedBorder: _textFieldBorder(),
                                      contentPadding: EdgeInsets.only(
                                          bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                      border: _textFieldBorder(),
                                      hintText: "Old password",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontFamily: 'DIN')),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: SizedBox(
                                height: 40.0,
                                width: kIsWeb ? buttonWidth : null,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_showPass[1],
                                  validator: (text) {
                                    if (text == null || text.isEmpty || text.length < 10) {
                                      setState(() {
                                        _enableBorder = false;
                                      });
                                      return 'Password should have at least 10 characters';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.only(bottom: _enableBorder == true ? 0.0: 15.0),
                                        icon: Icon(
                                          _showPass[1]
                                              ? Icons.visibility : Icons.visibility_off,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                        onPressed: (){
                                          setState(() {
                                            _showPass[1] = !_showPass[1];
                                          });
                                        },
                                      ),
                                      focusedBorder:_textFieldBorder(),
                                      contentPadding: EdgeInsets.only(
                                          bottom:_enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                      border: _textFieldBorder(),
                                      hintText: "New password",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontFamily: 'DIN')),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: SizedBox(
                                height: 40.0,
                                width: kIsWeb ? buttonWidth : null,
                                child: TextFormField(
                                  obscureText: !_showPass[2],
                                  controller: _confirmPasswordController,
                                  validator: (text) {
                                    if(text != _passwordController.text || text == null || text.isEmpty){
                                      setState(() {
                                        _enableBorder = false;
                                      });
                                      return 'Passwords should match';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.only(bottom: _enableBorder == true ? 0.0: 15.0),
                                        icon: Icon(
                                          _showPass[2]
                                              ? Icons.visibility : Icons.visibility_off,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                        onPressed: (){
                                          setState(() {
                                            _showPass[2] = !_showPass[2];
                                          });
                                        },
                                      ),
                                      focusedBorder: _textFieldBorder(),
                                      contentPadding: EdgeInsets.only(
                                          bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                                      border:_textFieldBorder(),
                                      hintText: "Confirm new password",
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

                    const SizedBox(height: 10.0,),
                    _isSendingRequest ?
                    Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 40.0,
                      ),
                    ):
                    roundedButton(
                        context: context,
                        title: "Change Password",
                        buttonWidth: kIsWeb ? buttonWidth : null,
                        onClicked: (){
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _isSendingRequest = true;
                            });
                            Provider.of<UserProvider>(context, listen: false).changePassword(context,
                                oldPassword: _oldPasswordController.text, newPassword: _passwordController.text).then((_){
                                  setState(() {
                                    _isSendingRequest = false;
                                  });
                            });
                          }
                        })
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}