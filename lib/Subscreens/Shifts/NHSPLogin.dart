// ignore_for_file: file_names, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:url_launcher/url_launcher.dart';

class NHSPLogin extends StatefulWidget {
  @override
  _NHSPLoginState createState() => _NHSPLoginState();
}

class _NHSPLoginState extends State<NHSPLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _enableBorder = true;
  bool _isLoading = false;
  List<bool> _showPass;

  _textFieldBorder() {
    return _enableBorder
        ? OutlineInputBorder(
        borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
        borderRadius: textFieldBorderRadius)
        : null;
  }

  _launchURL(context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showAlertDialog(context, content: "", alertTitle: const Text("404 !!"));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _showPass = [false];
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                child: Image.asset("images/img_nhsp_logo.webp"),
              ),
              const Text("Please enter your NHSP login details \n(you'll only need to do this once)",textAlign: TextAlign.center,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
                child: SizedBox(
                  height: 40.0,
                  child: TextFormField(
                    controller: _usernameController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        setState(() {
                          _enableBorder = false;
                        });
                        return 'Required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        focusedBorder: _textFieldBorder(),
                        contentPadding: EdgeInsets.only(
                            bottom: _enableBorder == true ? 0.0 : 15.0, left: 15.0, right: 15.0),
                        border: _textFieldBorder(),
                        hintText: "Username",
                        hintStyle: const TextStyle(color: Colors.grey,)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 20),
                child: SizedBox(
                  height: 40.0,
                  child: TextFormField(
                    controller: _passwordController,
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
                          padding: EdgeInsets.only(bottom: _enableBorder == true ? 0.0 : 15.0),
                          icon: Icon(
                            _showPass[0] ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPass[0] = !_showPass[0];
                            });
                          },
                        ),
                        focusedBorder: _textFieldBorder(),
                        contentPadding: EdgeInsets.only(
                            bottom: _enableBorder == true ? 0.0 : 15.0, left: 15.0, right: 15.0),
                        border: _textFieldBorder(),
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.grey,)),
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              InkWell(
                onTap: (){
                  _launchURL(context,"https://bookings.nhsprofessionals.nhs.uk/pwdmgt/ForgottenPasswordEntryPoint1.aspx?AspxAutoDet[…]nhs.uk/logout.asp&showHeaders=true&loadinframe=false");
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Center(
                    child: GestureDetector(
                        child: Text(
                          "Forgot your password?",
                          style: styleBlue,
                        )),
                  ),
                ),
              ),
              _isLoading
                  ? Center(
                  child: SpinKitCircle(
                    color: Theme.of(context).primaryColor,
                    size: 40.0,
                  ))
                  : roundedButton(
                  context: context,
                  title: "Log In",
                  buttonWidth: media.width * 0.6, buttonHeight: media.height * 0.055,
                  onClicked: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      Provider.of<UserProvider>(context, listen: false).nhspLoginToUpdateNhspStaffId(context,
                          username: _usernameController.text,
                          password: _passwordController.text)
                          .then((_) {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                      //Navigator.pushNamed(context, NavigationHome.routName);
                    }
                  }),
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0,top: 20),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _launchURL(context,"https://login.microsoftonline.com/nhsponline.onmicrosoft.com/oauth2/v2.0/authorize?p=b2c_1a_nhsp_signinorsignuploa1&client_id=49952daf-6e76-46ff-8473-21aca31ea417&redirect_uri=https%3A%2F%2Fjoinbank.nhsp.uk%2F&response_mode=form_post&response_type=id_token&scope=openid&state=OpenIdConnect.AuthenticationProperties%3DQSHFzbJ5WaHOuMlRv_J8wNd7La8IS3qfvozoTvsEr1Q9HlSRmOi3JSe5uuTMOeoWhaKAoQLVyBNQEwCfxfVlk_sR4EQw1e5qEl8pWob6iyGyfZDSv6Y2I4nyKsjo6eWwBg2b3w4Q5muJ05Ym4TZ-Hw54jqqKnFRaK6nucqMN3l86GS9gIpTSTv1b9ZjKLTV6E8Q0fy89w02fNWRxMyAq_VaMZYeerESTuHL-IrSgu7PJWKfMzPq4w88Oecq-UZbAb-IOi4j-vnyXDtvlmD6oPN_5TzE&nonce=637818272010583820.NjMzOWZjMGYtMmFiMC00NjRjLTg2ZGQtMjQyNWNkNzc1NDI2ZmU3MGI3ODItN2MzYy00YWViLTgzZTMtMjlmZDYyOGVlOTNi");
                    },
                      child: RichText(
                        text: TextSpan(
                          text: "Not registered on the bank yet?  ",
                          style: styleGrey,
                          children: [
                            TextSpan(
                              text: "Click here",
                              style: styleBlue
                            )
                          ]
                        ),
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("By logging in, you are happy for Ryalto to process your booked shifts through the NHSP system",textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[500]),),
              ),
              const SizedBox(height: 85,),

            ],
          ),
        ),
      ),
    );
  }
}
