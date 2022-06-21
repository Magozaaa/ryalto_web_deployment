import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import '../SettingsScreen.dart';

class TutorialFourth extends StatelessWidget{
  static const String routeName = "/Tutorial_Four";

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;

    return  WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
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

                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left:10.0),
                        child: Image.asset("images/chatOne.webp", width: media.width * 0.8, fit: BoxFit.cover,),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right:10.0, top: 10.0),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset('images/chatOutline.svg', width: media.width * 0.8, height: 100, fit: BoxFit.cover,)),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left:10.0),
                        child: Image.asset("images/chatThree.webp", width: media.width * 0.8, fit: BoxFit.cover,),
                      )),


                  const SizedBox(height: 50.0,),

                  Image.asset("images/chatIcon.png", width: 40, height: 30, color: Colors.white, fit: BoxFit.cover,),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: const Text("Chat", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom:25.0, left: media.width * 0.14, right: media.width * 0.14),
                    child: const Text("Communicate with colleagues and staff easily.", maxLines: 3,
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0),),
                  )
                ],
              ),
            ),

            Positioned(
                bottom: 40.0,
                right: 40.0,
                child: GestureDetector(
                    onTap: ()
                    {Navigator.pushNamed(context, SettingsScreen.routName);
                    AnalyticsManager.track('settings_tutorial_complete');
                    },
                    child: const Text("Start", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)))
          ],
        ),
      ),
    );
  }

}