
// ignore_for_file: file_names, prefer_final_fields, prefer_if_null_operators, unnecessary_cast

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:path/path.dart' as p;
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'dart:html' as html;

class CreateNewGroup extends StatefulWidget{
  static const routeName = "/CreateNewGroup";

  @override
  _CreateNewGroupState createState() => _CreateNewGroupState();
}

class _CreateNewGroupState extends State<CreateNewGroup> {
  var _isInit = true;
  Map passedData = {};
  List<User> channelUsers = [];
  List<String> usersIds = [];
  String channelDisplayName;
  final TextEditingController _groupNameController = TextEditingController();
  var _imageFile;
  String imgName ;
  String imgPath ;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  String base64Image;
  bool allSelected = false;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;
      usersIds = passedData["userIds"];
      channelDisplayName = passedData["channel_display_name"];
      allSelected = passedData["all_selected"];
      channelUsers = allSelected ? Provider.of<DiscoveryProvider>(context, listen: false).discoveredUsers : passedData["users"];
      AnalyticsManager.track('messaging_new_group');
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  var _enableBorder = true;

  _textFieldBorder(){
    return _enableBorder ?
    OutlineInputBorder(
        borderSide: BorderSide(width: 2.0,color: Theme.of(context).primaryColor),
        borderRadius: textFieldBorderRadius) : null;
  }


  // *************************************************** IMG picker related *********************************************************


  Future<void> _pickImage() async {
    var mediaData = await ImagePickerWeb.getImageInfo;
    html.File mediaFile = html.File(mediaData.data, mediaData.fileName,);
    if (mediaFile != null) {
      setState(() {
        imgName = mediaFile.name;
        // fromWebPicker = mediaData.data;
        _imageFile = Image.memory(
          mediaData.data,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
            return Image.asset('images/errorImage.png', height: 70,);
          },);
      });

      base64Image = base64Encode(mediaData.data);
    }
  }



  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    final directoryProvider = Provider.of<DiscoveryProvider>(context, listen: false);
    final int numberOfResults = directoryProvider.userCount;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (Platform.isIOS) {
            if (details.primaryVelocity.compareTo(0) == 1) {
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(
          appBar: screenAppBar(
              context,
              media,
              appbarTitle: const Text("New Group"), showLeadingPop: true,
              onBackPressed: ()=> Navigator.pop(context), hideProfilePic: true,
              textButtonTitle: "Create",
              isTextButtonLoading: isLoading,
              textButton: (){
              if(allSelected){
                if (mounted) {
                  setState(() {
                    isLoading = true;
                  });
                }
                Provider.of<ChatProvider>(context, listen: false).createNewGroupChatWithSelectAll(context,
                  channelType: "group",
                  discoveryProvider: directoryProvider,
                  userData: Provider.of<UserProvider>(context, listen: false),
                  groupImg: _imageFile != null ? base64Image : null,
                  channelDisplayName: _groupNameController.text == null || _groupNameController.text == "" ?
                  channelDisplayName : _groupNameController.text,
                  articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                  articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                  articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                  isArticleFavourite :  passedData != null ? passedData['isArticleFavourite'] != null ? passedData['isArticleFavourite'] : null : null,
                  articleCommentsCount:  passedData != null ? passedData['articleCommentsCount'] != null ? passedData['articleCommentsCount'] : null : null,
                  articleId:  passedData != null ? passedData['articleId'] != null ? passedData['articleId'] : null : null,
                );
              }else{
                if (mounted) {
                  setState(() {
                    isLoading = true;
                  });
                }
                Provider.of<ChatProvider>(context, listen: false).createNewChannel(context,
                  usersIds: usersIds,
                  channelType: "group",
                  groupImg: _imageFile != null ? base64Image : null,
                  channelDisplayName: _groupNameController.text == null || _groupNameController.text == "" ?
                  channelDisplayName : _groupNameController.text,
                  articleUrl: passedData != null ? passedData['articleUrl'] != null ? passedData['articleUrl'] : null : null,
                  articleThumbnail: passedData != null ? passedData['articleThumbnail'] != null ? passedData['articleThumbnail'] : null : null,
                  articleTitle : passedData != null ? passedData['articleTitle'] != null ? passedData['articleTitle'] : null : null,
                  isArticleFavourite :  passedData != null ? passedData['isArticleFavourite'] != null ? passedData['isArticleFavourite'] : null : null,
                  articleCommentsCount:  passedData != null ? passedData['articleCommentsCount'] != null ? passedData['articleCommentsCount'] : null : null,
                  articleId:  passedData != null ? passedData['articleId'] != null ? passedData['articleId'] : null : null,
                );
              }
            }
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12.0,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:()async{
                          if (!kIsWeb) {
                            showAttachImgBottomSheet(context: context,
                                onCameraImg: ()async{
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  try {
                                    final pickedFile = await _picker.getImage(source: ImageSource.camera,
                                      imageQuality: 90,
                                      maxHeight: 500,
                                      maxWidth: 500,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        _imageFile = pickedFile;
                                        imgName = p.basename(pickedFile.path);
                                        imgPath = pickedFile.path;
                                      });
                                      List<int> imageBytes = await _imageFile.readAsBytes();
                                      base64Image = base64Encode(imageBytes);
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _pickImageError = e;
                                    });
                                  }                           },
                                onGalleryImg: ()async{
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  try {
                                    final pickedFile = await _picker.getImage(source: ImageSource.gallery,
                                      maxWidth: 500,
                                      maxHeight: 500,
                                      imageQuality: 90,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        _imageFile = pickedFile;
                                        imgName = p.basename(pickedFile.path);
                                        imgPath = pickedFile.path as String;
                                      });
                                      List<int> imageBytes = await _imageFile.readAsBytes();
                                      base64Image = base64Encode(imageBytes);
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _pickImageError = e;
                                    });
                                  }
                                }
                            );
                          }
                          else{
                            _pickImage();
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blue[200]
                            ),
                            child: _imageFile == null
                                ?
                            const Center(
                              child: Icon(Icons.add_a_photo_rounded, color:
                              Colors.white, size: 25.0,),
                            )
                                :
                            kIsWeb ? _imageFile : Image.file(File(_imageFile.path), fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15.0,),
                      Flexible(
                        child: TextField(
                          controller: _groupNameController,
                          decoration: InputDecoration(
                              focusedBorder: _textFieldBorder(),
                              contentPadding: EdgeInsets.only(
                                  bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                              border: _textFieldBorder(),
                              hintText: "Group subject or name...",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'DIN')),
                        ),
                      ),
                    ],
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.only(left:12.0, bottom: 0.0, top:18.0),
                  child: Text("${allSelected ? numberOfResults : channelUsers.length} Users", style: style1,),
                ),
                channelUsers.isEmpty && allSelected == false ?
                Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                      size: 45.0,
                    )):
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: channelUsers.length,
                    itemBuilder: (context, i)=>
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            i == 0 ? const Divider(thickness: 3.0,):Container(),
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(80.0),
                                child: Container(height: 40.0, width: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[200],
                                    borderRadius: BorderRadius.circular(80.0),
                                  ),
                                  child: channelUsers[i].profilePic == null || channelUsers[i].profilePic.isEmpty ? Padding(
                                    padding: const EdgeInsets.only(top:2.0),
                                    child: Image.asset(i == 0 ? "images/group.png": i == 1 ? "images/announce.png" :
                                    "images/person.png", fit: BoxFit.contain, color: Colors.white,),
                                  ) : Image.network(
                                    channelUsers[i].profilePic,
                                    fit: BoxFit.cover,errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                    return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                  },),
                                ),
                              ),
                              title: Text(channelUsers[i].name.toString(), style: style2, maxLines: 1, overflow: TextOverflow.ellipsis,),
                              subtitle: Text(channelUsers[i].trust == null || channelUsers[i].trust.isEmpty ? "" : getJobRolesCommaSeparatedList(channelUsers[i].roles) == "" ? "${channelUsers[i].trust['name']}":
                              "${getJobRolesCommaSeparatedList(channelUsers[i].roles)}\n${channelUsers[i].trust['name']}",
                                maxLines: 3, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey, fontSize: 14.0),),
                            ),
                             Divider(thickness: i==channelUsers.length-1 ? 3.0:1.0,)
                          ],
                        )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}