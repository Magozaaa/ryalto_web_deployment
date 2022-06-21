// ignore_for_file: missing_return

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    Key key,
    @required this.mobile,
    @required this.tablet,
    @required this.desktop,
  }) : super(key: key);

// This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop helep us later
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
          MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // If our width is more than 1100 then we consider it a desktop
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          if(Provider.of<ChatProvider>(context, listen: false).openedChannelName != null && Provider.of<ChatProvider>(context, listen: false).openedChannelName.isNotEmpty){
            Provider.of<ChatProvider>(context, listen: false).resetChatChannelHistory();
            // Provider.of<ChatProvider>(context, listen: false).setChatChannelHistory(null);
          }
          return desktop;
        }
        // If width it less then 1100 and more then 650 we consider it as tablet
        else if (constraints.maxWidth >= 650) {
          if(Provider.of<ChatProvider>(context, listen: false).openedChannelName != null && Provider.of<ChatProvider>(context, listen: false).openedChannelName.isNotEmpty){
            Provider.of<ChatProvider>(context, listen: false).resetChatChannelHistory();
            // Provider.of<ChatProvider>(context, listen: false).setChatChannelHistory(null);
          }
          return tablet;
        }
        // Or less then that we called it mobile
        else {
          if(Provider.of<ChatProvider>(context, listen: false).openedChannelName != null && Provider.of<ChatProvider>(context, listen: false).openedChannelName.isNotEmpty){
            Provider.of<ChatProvider>(context, listen: false).resetChatChannelHistory();
            // Provider.of<ChatProvider>(context, listen: false).setChatChannelHistory(null);
          }
          return mobile;
        }
      },
    );
  }
}