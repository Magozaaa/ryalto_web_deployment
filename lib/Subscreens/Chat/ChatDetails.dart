import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Subscreens/Chat/NewGroup.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class ChatDetails extends StatefulWidget{
  static const routeName = "/ChatDetails";

  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  var _isInit = true;
  Map passedData = {};
  var profilePicPath;
  var user;

  @override
  void didChangeDependencies() async{
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;
      profilePicPath = passedData["profile_pic"];
      user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: passedData["userId"]);
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: screenAppBar(context, media, appbarTitle: Text("Chat Details"), showLeadingPop: true,
        onBackPressed: ()=> Navigator.pop(context), hideProfilePic: true,
        bottomTabs: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.only(left:18.0, bottom: 20.0, top:15.0),
              child: GestureDetector(
                onTap: ()async{
                  if(passedData["type"] == "person")
                    Navigator.pushNamed(context, OtherUserProfile.routName,
                    arguments: {
                      "user_id": user.id
                    });
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(80.0),
                      child: Container(height: 60.0, width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(80.0),
                        ),
                        child: profilePicPath == null ? Padding(
                          padding: const EdgeInsets.only(top:2.0),
                          child: Image.asset("images/person.png", fit: BoxFit.contain, color: Colors.white,),
                        ) : Image.network(
                          profilePicPath,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                        },
                        ),
                      ),
                    ),
                    const SizedBox(width: 15.0,),
                    Text(passedData['name'], style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
            ),
            preferredSize: const Size.fromHeight(85.0))
        ),
        body: ListView(
          children: [
            const SizedBox(height: 10.0,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:12.0, vertical: 10.0),
              child: Text("People", style: TextStyle(color: Colors.grey[600], fontSize: 16.0),),
            ),

            Material(
              elevation: 5.0,
              color: Colors.white,
              child: ListTile(
                onTap: ()=> Navigator.pushNamed(context, NewGroupScreen.routeName,
                arguments: {
                  "contact":passedData["type"] == "person"? "JG":null,
                  "user": user,
                  "from" : "chatDetails"
                }),
                leading: Icon(Icons.group_add, color: Theme.of(context).primaryColor, size: 30.0,),
                title: Text("Create group", style: styleBlue),
              ),
            )
          ],
        ),
      ),
    );
  }
}