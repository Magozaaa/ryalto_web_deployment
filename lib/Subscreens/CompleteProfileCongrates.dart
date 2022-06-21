import 'package:flutter/material.dart';
import 'package:rightnurse/Subscreens/Profile/MyAccountScreen.dart';

class Congrats extends StatefulWidget {
  static const String routeName = "/Congrats_Screen";

  @override
  _CongratsState createState() => _CongratsState();
}

class _CongratsState extends State<Congrats> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: media.height,
            width: media.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/img_logo.webp",
                    width: media.width * 0.65,
                  ),
                  SizedBox(
                    height: media.height * 0.15,
                  ),
                  Text(
                    'Thank You!',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                  SizedBox(
                    height: media.height * 0.02,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Thank you for completing your profile, tou now have access to shift booking, the discover tool & more!',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: media.height * 0.02,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: (){
                  Navigator.pushNamed(context, MyAccountsScreen.routName);
                },
                child: Container(
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
