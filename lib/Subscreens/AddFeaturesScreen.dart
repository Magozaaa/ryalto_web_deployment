import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';

class AddFeaturesScreen extends StatefulWidget{

  static const String routeName = "/AddFeatures_Screen";

  @override
  _AddFeaturesScreenState createState() => _AddFeaturesScreenState();
}

class _AddFeaturesScreenState extends State<AddFeaturesScreen> {

  List isSelected = [];
  Map passedData = {};
  var _isInit = true;

  List<bool> _isExpanded = [];


  @override
  void didChangeDependencies() {
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;

      for(int i = 0; i <18; i++){
        isSelected.add(false);
      }

      for(int e= 0; e<8; e++){
        e == 0 ? _isExpanded.add(true):
        _isExpanded.add(false);
      }

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
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white,),
                    onPressed: ()=> Navigator.pop(context)),

                Text(passedData["screen_title"], style: TextStyle(color: Colors.white,
                    fontSize: 19.0, fontWeight: FontWeight.bold),),

                FlatButton(
                    onPressed: null,
                    child: Text("Done", style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                    ),)),
              ],
            ),
          ),
          body:
          ListView(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [

              passedData["screen_title"] == "Skills" ? Container() : Material(
                color: Colors.white,
                elevation: 7.0,
                child:  Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: passedData["screen_title"] == "Areas of Work" ?
                  Container(
                    height: 40.0,
                    child: Center(
                      child: Text("Please select your areas of work", maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0),),
                    ),
                  ) :
                  Container(
                    height: 40.0,
                    child: Center(
                      child: Text("What languages do you speak?", maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0),),
                    ),
                  )
                ),
              ),

              Container(
                height: media.height - 60,
                child: ListView.builder(
                  // shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: passedData["screen_title"] == "Areas of Work" ? 8:18,
                  itemBuilder: (context, i) =>
                  passedData["screen_title"] == "Areas of Work" ?
                  i == 7 ?  SizedBox(height: 130,):
                      expansionTileCard(
                        context: context,
                        title: "PORTSMOUTH MVC",
                        doExpansion: (_){
                          setState(() {
                            _isExpanded[i] = ! _isExpanded[i];
                          });
                        },
                        isExpanded: _isExpanded[i],
                        content: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: 9,
                              itemBuilder: (context, index) => i == 8 ?  SizedBox(height: 120,):
                                  ClipRRect(
                                    borderRadius: index == 8 ?
                                    BorderRadius.only(
                                        bottomLeft: Radius.circular(7),
                                        bottomRight: Radius.circular(7)): BorderRadius.circular(0.0),
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: Text("an Item", overflow: TextOverflow.ellipsis, maxLines: 2, style: style2,),
                                            trailing: !isSelected[index] ? Container(width: 1.0,) : Icon(Icons.done, color: Theme.of(context).primaryColor,),
                                            onTap: (){
                                                setState(() {
                                                  isSelected[index] = !isSelected[index];
                                                });

                                            },
                                          ),
                                          index == 8 ? Container(): Divider(),
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                        ]
                      ): i == 17 ? SizedBox(height: 130,):
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text("an Item $i", overflow: TextOverflow.ellipsis, maxLines: 2, style: style2,),
                            trailing: !isSelected[i] ? Container(width: 1.0,) : Icon(Icons.done, color: Theme.of(context).primaryColor,),
                            onTap: (){
                              if(passedData["screen_title"] == "Organization" || passedData["screen_title"] == "Preferred Band"
                                  || passedData["screen_title"] == "Band"){
                                setState(() {
                                  for(int j = 0; j <18; j++){
                                    isSelected[j] = false;
                                  }
                                  isSelected[i] = true;
                                });
                              }else{
                                setState(() {
                                  isSelected[i] = !isSelected[i];
                                });
                              }
                            },
                          ),
                          Divider(),
                        ],
                      ),


                ),
              ),


              SizedBox(height: 25.0,)
            ],
          )

      ),
    );
  }
}