import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:webview_flutter/webview_flutter.dart';


class SurveysScreen extends StatefulWidget{

  static const routeName = "/SurveysScreen";

  @override
  _SurveysScreenState createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {

  WebViewController _controller;
  Widget loader;

  @override
  void initState() {
    loader = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            child: SpinKitWave(
              color: Colors.blue,
              size: 45.0,
            ),
          ),
        ],
      ),
    );
    if (!kIsWeb) {
      if (Platform.isAndroid)
        WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }



  @override
  Widget build(BuildContext context) {


    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: screenAppBar(context, media, showLeadingPop: true, hideProfilePic: true,
            appbarTitle: Image.asset("images/ryLogo.png", height: 35.0, color: Colors.white,),
            centerTitle: true,
            onBackPressed: ()=> Navigator.pop(context)),

        body: Stack(
          alignment: Alignment.center,
          children: [

            WebView(

              initialUrl: userData.userSurveyLink,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                _controller = controller;
              },

              onProgress: (int progress) {
                if(progress < 100){
                  setState(() {
                    loader = Center(
                      child: Container(
                        color: Colors.white,
                        height: media.height,
                        child: SpinKitWave(
                          color: Theme.of(context).primaryColor,
                          size: 45.0,
                        ),
                      ),
                    );
                  });
                }else{
                  setState(() {
                    loader = Container();
                  });
                }
              },
            ),

            loader,
          ],
        ),

      ),
    );
  }
}