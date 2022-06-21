import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialThrid.dart';


class TutorialSecond extends StatelessWidget{
  static const String routeName = "/Tutorial_Second";

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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Image.asset("images/j_smith.webp", width: 100, fit: BoxFit.cover,),
                  ),

                  const Text("Joanna Smith", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),),
                  const Text("RN Adult", style: TextStyle(color: Colors.white, fontSize: 16.0)),


                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Image.asset("images/j_smith_card.webp", width: media.width * 0.9, fit: BoxFit.cover,),
                  ),

                  const SizedBox(height: 50.0,),

                  Image.asset("images/name2.png", width: 40, height: 30, color: Colors.white, fit: BoxFit.cover,),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: const Text("Create your Profile", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom:25.0, left: media.width * 0.12, right: media.width * 0.12),
                    child: const Text("Add your skills, manage you preferences to find the best fitting shifts.", maxLines: 3,
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0),),
                  )
                ],
              ),
            ),

            Positioned(
                bottom: 40.0,
                right: 40.0,
                child: GestureDetector(
                    onTap: ()=> Navigator.pushNamed(context, TutorialThird.routeName),
                    child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)))
          ],
        ),
      ),
    );
  }

}