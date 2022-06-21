import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/changeIndexPage.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/WebModel/WebChatScreen.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/WebModel/ListOfChats.dart';
import 'package:rightnurse/WebModel/Responsive.dart';
import 'package:rightnurse/WebModel/email_screen.dart';
import 'package:rightnurse/WebModel/list_of_emails.dart';
import 'package:rightnurse/WebModel/side_menu.dart';



class WebMainScreen extends StatelessWidget {
  static const routeName = '/WebMainScreen';

  const WebMainScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // It provide us the width and height
    final media = MediaQuery.of(context).size;
    final channelDetails = Provider.of<ChatProvider>(context);



    return Consumer<ChangeIndex>(
      builder: (context, changeIndex, child) {
        print(changeIndex.index);

        return Scaffold(
          body: Responsive(
            // Let's work on our mobile part
            mobile: changeIndex.index == 0 ? ListOfEmails() : ListOfChats(),
            tablet: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: changeIndex.index == 0 ? ListOfEmails() : ListOfChats(),
                ),
                Expanded(
                  flex: 9,
                  child:
                  Provider.of<ChatProvider>(context).passedChannelData == null || Provider.of<ChatProvider>(context).passedChannelData.isEmpty ?
                  // Provider.of<ChatProvider>(context).openedChannelName.isEmpty || Provider.of<ChatProvider>(context).openedChannelName == null ?
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('images/Computer-Phone.png',color: Theme.of(context).primaryColor,height: media.height*0.5,width: media.width *0.4,),
                            const SizedBox(height: kDefaultPadding,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text('Stay connected with your colleagues and chat freely on Ryalto web !',style: Theme.of(context).textTheme.button.copyWith(
                                color: kTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0,
                              ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                      :
                  MessagingScreen(passedData: channelDetails.passedChannelData,),
                ),
              ],
            ),
            desktop: Row(
              children: [
                // Once our width is less then 1300 then it start showing errors
                // Now there is no error if our width is less then 1340
                Expanded(
                  flex: media.width > 1340 ? 2 : 4,
                  child: SideMenu(),
                ),
                Expanded(
                  flex: media.width > 1340 ? 3 : 5,
                  child: changeIndex.index == 0 ? ListOfEmails() : ListOfChats(),
                ),
                Expanded(
                  flex: media.width > 1340 ? 8 : 10,
                  child: Provider.of<ChatProvider>(context).passedChannelData == null || Provider.of<ChatProvider>(context).passedChannelData.isEmpty
                      ?
                  Container(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('images/Computer-Phone.png',color: Theme.of(context).primaryColor,),
                          const SizedBox(height: kDefaultPadding,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Stay connected with your colleagues and chat freely on Ryalto web !',style: Theme.of(context).textTheme.button.copyWith(
                                color: kTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0
                            ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                      :
                  MessagingScreen(passedData: channelDetails.passedChannelData,),
                  // Provider.of<ChatProvider>(context).passedChannelData == null || Provider.of<ChatProvider>(context).passedChannelData.isEmpty
                  //     ?
                  // Container(
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Image.asset('images/Computer-Phone.png',color: Theme.of(context).primaryColor,),
                  //       const SizedBox(height: kDefaultPadding,),
                  //       Text('Stay connected with your colleagues and chat freely on Ryalto web !',style: Theme.of(context).textTheme.button.copyWith(
                  //         color: kTextColor,
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 20.0
                  //       ),)
                  //     ],
                  //   ),
                  // )
                  //     :
                  // MessagingScreen(passedData: channelDetails.passedChannelData,),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

