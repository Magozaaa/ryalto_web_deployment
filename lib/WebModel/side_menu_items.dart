import 'package:flutter/material.dart';
import 'package:rightnurse/WebModel/Constants.dart';
import 'package:websafe_svg/websafe_svg.dart';



class SideMenuItem extends StatelessWidget {
  const SideMenuItem({
    Key key,
    this.isActive,
    this.isHover = false,
    this.itemCount,
    this.showBorder = true,
    @required this.iconSrc,
    @required this.title,
    @required this.press,
  }) : super(key: key);

  final bool isActive, isHover, showBorder;
  final int itemCount;
  final String iconSrc, title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: InkWell(
        onTap: press,
        child: Row(
          children: [
            (isActive || isHover)
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Icon(Icons.arrow_forward_ios_outlined,size: 14,color: Theme.of(context).primaryColor,),
                )
                : const SizedBox(width: 15),
            SizedBox(width: kDefaultPadding / 4),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(bottom: 15, right: 5),
                decoration: showBorder
                    ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFDFE2EF)),
                  ),
                )
                    : null,
                child: Row(
                  children: [
                    WebsafeSvg.asset(
                      iconSrc,
                      height: 30,
                      color: (isActive || isHover) ? kPrimaryColor : kGrayColor,
                    ),
                    SizedBox(width: kDefaultPadding * 0.75),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.button.copyWith(
                        color:
                        (isActive || isHover) ? kTextColor : kGrayColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Spacer(),

                    // if (itemCount != null) CounterBadge(count: itemCount)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}