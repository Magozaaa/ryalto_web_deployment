import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialSecond.dart';
import '../SettingsScreen.dart';

class TutorialFirst extends StatelessWidget{
  static const String routeName = "/Tutorial_First";

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;

    return  WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, SettingsScreen.routName);
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: media.height,
              width: media.width,
              color: Theme.of(context).primaryColor,
              child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 45.0),
                    child: Image.asset("images/img_logo.webp", width: media.width * 0.69, fit: BoxFit.cover,),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child:const Text("Welcome!", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom:25.0, left: media.width * 0.12, right: media.width * 0.12),
                    child: const Text("Create your profile, book shifts, communicate and help others.", maxLines: 3,
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0),),
                  )
                ],
              ),
            ),

            Positioned(
                bottom: 40.0,
                right: 40.0,
                child: GestureDetector(
                    onTap: ()=> Navigator.pushNamed(context, TutorialSecond.routeName),
                    child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)))
          ],
        ),
      ),
    );
  }

}