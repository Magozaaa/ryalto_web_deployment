import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/ChannelModel.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/WebModel/Chat.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:rightnurse/WebModel/Email.dart';
import 'package:rightnurse/WebModel/extensions.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:websafe_svg/websafe_svg.dart';


class ChatCard extends StatelessWidget {
  const ChatCard({
    Key key,
    this.isActive = true,
    this.channel,
    this.press,
    this.time,
    this.lastMessage,
  }) : super(key: key);

  final bool isActive;
  final ChannelModel channel;
  final VoidCallback press;
  final String time;
  final String lastMessage;

  @override
  Widget build(BuildContext context) {
    //  Here the shadow is not showing properly
    final channelDetails = Provider.of<ChatProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
      child: InkWell(
        onTap: press,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive ? kPrimaryColor : kBgDarkColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Container(
                      //   width: 40,
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //       shape:BoxShape.circle,
                      //       image: DecorationImage(
                      //           image: NetworkImage((channel.channelType == "private" || channel.channelType == "person") && channelDetails.channelUsers[channel.name] != null
                      //               ? channelDetails.channelUsers[channel.name][0].profilePic : ),
                      //           fit: BoxFit.cover
                      //       )
                      //   ),
                      // ),
                      SizedBox(
                        width: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80.0),
                          child: Container(height: 40.0, width: 40.0,
                            decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(75.0),
                                border: Border.all(width: 0.8,color: const Color(0xFFEEEEEE))
                            ),
                            child: channel.channelImage == null
                                ?
                            (channel.channelType == "private" || channel.channelType == "person") && channelDetails.channelUsers[channel.name] != null
                                ?
                            Image.network(channelDetails.channelUsers[channel.name][0].profilePic, fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                return Image.asset('images/person.png',color: Colors.white,);
                              },) :
                            Image.asset(channel.channelType == "group" ? "images/group.png"
                                : channel.channelType == "inbox" ? "images/announce.png" :
                            "images/person.png", fit: BoxFit.fill, color: Colors.white,)
                                :
                            ClipRRect(
                              borderRadius: BorderRadius.circular(75.0),
                              child: Image.network(channel.channelImage, fit: BoxFit.cover,errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                              },),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: kDefaultPadding / 2),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                channel.channelType == "group" && (channel.displayName == null || channel.displayName == "") ?
                                channelDetails.channelUsers[channel.name] == null && channel.channelType != "inbox" ? "Conversation with 0 users" :"Group channel":
                                channel.channelType == "inbox" ? "Announcement":
                                (channel.channelType == "private" || channel.channelType == "person") && channelDetails.channelUsers[channel.name] != null ? channelDetails.channelUsers[channel.name][0].name :
                                channel.displayName??"Chat",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: channelDetails.doesChannelHasNewMsg[channel.name] == true
                                // ||
                                // (channelDetails.channels[i].lastMsgAt ?? 0) > (channelDetails.lastMsgTimeForEachChannelLocally[channelDetails.channels[i].name] ?? (channelDetails.channels[i].lastMsgAt ?? 0))

                                    ? styleBlue : style2,),
                              channelDetails.loadingLastMsgs == ChatStage.LOADING ?
                              SkeletonAnimation(
                                  child: const Text("Loading.....", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 14.0),))
                                  :
                              Text(lastMessage,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: isActive
                                // ||
                                // (channelDetails.channels[i].lastMsgAt ?? 0) > (channelDetails.lastMsgTimeForEachChannelLocally[channelDetails.channels[i].name] ?? (channelDetails.channels[i].lastMsgAt ?? 0))
                                    ? Colors.white : Colors.grey, fontSize: 14.0),),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          // if (channelDetails.doesChannelHasNewMsg[channel.name] == true)
                            // Container(
                            //   height: 12,
                            //   width: 12,
                            //   decoration: BoxDecoration(
                            //     shape: BoxShape.circle,
                            //     color: kBadgeColor,
                            //   ),
                            // ),
                          // SpinKitPulse(
                          //   color:
                          //   kBadgeColor,
                          //   size: 15,
                          // ),

                          const SizedBox(height: 55),
                          Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Text(
                              time,
                              style: Theme.of(context).textTheme.caption.copyWith(
                                // color: isActive ? Colors.white70 : null,
                              ),
                            ),
                          ),


                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: kDefaultPadding / 2),
                ],
              ),
            ).addNeumorphism(
              blurRadius: 15,
              borderRadius: 15,
              offset: Offset(5, 5),
              topShadowColor: Colors.white60,
              bottomShadowColor: Color(0xFF234395).withOpacity(0.15),
            ),
            if (channelDetails.doesChannelHasNewMsg[channel.name] == true)
              Positioned(
                right: 9,
                top: 9,
                child: SpinKitPulse(
                  color:
                  kBadgeColor,
                  size: 15,
                )
                //     .addNeumorphism(
                //   blurRadius: 4,
                //   borderRadius: 8,
                //   offset: Offset(2, 2),
                // ),
              ),
            if (channelDetails.doesChannelHasNewMsg[channel.name] == true)
              Positioned(
                right: 8,
                top: 8,
                child: SpinKitPulse(
                  color:
                  kBadgeColor,
                  size: 17,
                )
                //     .addNeumorphism(
                //   blurRadius: 4,
                //   borderRadius: 8,
                //   offset: Offset(2, 2),
                // ),
              ),
          ],
        ),
      ),
    );
  }
}