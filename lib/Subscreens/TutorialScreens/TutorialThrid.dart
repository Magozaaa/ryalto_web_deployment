import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialFourth.dart';


class TutorialThird extends StatelessWidget{
  static const String routeName = "/Tutorial_Third";

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

                  Image.asset("images/accidentCard.webp", width: media.width * 0.82, height:75.0, fit: BoxFit.cover,),
                  Material(
                      elevation: 3.0,
                      color: Colors.transparent,
                      child: Image.asset("images/surgeryCard.webp", width: media.width * 0.96, height:74.0, fit: BoxFit.cover,)),
                  Image.asset("images/accidentCardMorning.webp", width: media.width * 0.82,height: 75.0, fit: BoxFit.cover,),


                  const SizedBox(height: 50.0,),

                  SvgPicture.asset('images/shiftsOutLine.svg', width: 40, height: 30, color: Colors.white, fit: BoxFit.cover,),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: const Text("Book Shifts", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom:25.0, left: media.width * 0.14, right: media.width * 0.14),
                    child: const Text("Find and book the latest available shifts.", maxLines: 3,
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0),),
                  )
                ],
              ),
            ),

            Positioned(
                bottom: 40.0,
                right: 40.0,
                child: GestureDetector(
                    onTap: ()=> Navigator.pushNamed(context, TutorialFourth.routeName),
                    child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)))
          ],
        ),
      ),
    );
  }

}