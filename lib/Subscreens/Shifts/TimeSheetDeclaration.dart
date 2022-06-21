import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class TimSheetDeclaration extends StatefulWidget {
  @override
  _TimSheetDeclarationState createState() => _TimSheetDeclarationState();
}

class _TimSheetDeclarationState extends State<TimSheetDeclaration> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15,),
            Image.asset("images/warning.png",width: 25,),
            const SizedBox(height: 15,),
            Text("Timesheet Declaration",style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
            const SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Text("I declare that the information I have released for"
                "payment is correct and complete and I have not claimed"
                "elsewhere for these hours/shifts.\n\n\n"
                "I understand that if I knowingly provide false information"
                "this may result in disciplinary action and I may be liable"
                "for prosecution and civil recovery proceedings.\n\n\n"
                "I consent to the disclosure of information relating to"
                "bookings to and by the Organisation, NHS Professionals"
               " and NHS Protect for the purpose of verification of this"
               " claim and the investigation, prevention, detection and"
                "prosecution of Fraud.",style: TextStyle(color: Color(0xFF0a0a0a)),textAlign: TextAlign.center,),
            ),
            const SizedBox(height: 25,),
            roundedButton(
                context: context,
                title: "Accept",
                buttonWidth: media.width * 0.5, buttonHeight: media.height * 0.045,
                onClicked: () {
                  Provider.of<ShiftsProvider>(context,listen: false).setAcceptedTimeSheetDeclaration(true);
                }),
            const SizedBox(height: 75,),

          ],
        ),
      ),
    );
  }
}
