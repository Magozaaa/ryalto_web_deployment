
// ignore_for_file: file_names, unnecessary_string_interpolations, unnecessary_cast

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Chat/NewGroup.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';
import 'dart:html' as html;

class GroupDetails extends StatefulWidget{
  static const routeName = "/GroupDetails";

  const GroupDetails({Key key}) : super(key: key);

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  var _isInit = true;
  Map passedData = {};
  var profilePicPath;
  int pageOffset=0;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      searchForParticipantByName();
    });
    searchFocusNode = FocusNode();
  } //Channel channel;



  var _imageFile;
  String imgName ;
  String imgPath ;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  String base64Image;
  bool _editGroupName = false;
  var _enableBorder = true;
  bool isBottomWidgetShown = true;

  TextEditingController _editGroupDisplayNameController ;
  ScrollController _scrollController ;
  TextEditingController searchController;
  FocusNode searchFocusNode;

  @override
  void didChangeDependencies() {
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;
      Provider.of<ChatProvider>(context, listen: false).fetchParticipantsForChannel(channelId: passedData["channel_id"], offset: 0);
      Provider.of<ChatProvider>(context, listen: false).fetchChannelByName(channelName: passedData["channel_name"]).then((_) {
        _editGroupDisplayNameController =  TextEditingController(text: Provider.of<ChatProvider>(context, listen: false).currentChannel.displayName);
      });
      _scrollController = ScrollController();
      _scrollController.addListener(listen);
      // channel = passedData["channel"];
      _isInit = false;

    }
    super.didChangeDependencies();
  }


  searchForParticipantByName()async{
    if(searchController.text.length>2){
      Provider.of<ChatProvider>(context,listen: false).searchForParticipantByNameInGroupChannel(channelId: passedData["channel_id"],searchKey: searchController.text,offset: 0);
      //
    }
    else{
      Provider.of<ChatProvider>(context,listen: false).clearGroupChannelParticipantsForSearch();
      // print(Provider.of<ChatProvider>(context,listen: false).groupChannelParticipantsForSearch);

    }
  }

  listen(){
    final direction = _scrollController.position.userScrollDirection;

    if(_scrollController.position.pixels<=50){
      _showBottomWidget();
    }
    else{
      _hideBottomWidget();
    }
  }

  _showBottomWidget(){
    if (!isBottomWidgetShown) {
      setState(() {
        isBottomWidgetShown = true;
      });
    }
  }

  _hideBottomWidget(){
    if (isBottomWidgetShown) {
      setState(() {
        isBottomWidgetShown = false;
      });
    }
  }

  _textFieldBorder(){
    return _enableBorder ?
    OutlineInputBorder(
        borderSide: const BorderSide(width: 2.0,color: Colors.white),
        borderRadius: textFieldBorderRadius) : null;
  }


  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    pageOffset = 0;
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<ChatProvider>(context, listen: false).clearGroupChannelParticipants();
    await Provider.of<ChatProvider>(context, listen: false).fetchParticipantsForChannel(channelId: passedData["channel_id"], offset: 0);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    pageOffset +=10;
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<ChatProvider>(context, listen: false).fetchParticipantsForChannel(channelId: passedData["channel_id"], offset: pageOffset);
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _editGroupDisplayNameController.dispose();
    _scrollController.removeListener(listen);
    searchController.dispose();
    super.dispose();
  }

  bool isSearchFieldVisible = false;

  void cancelActions() {
    isSearchFieldVisible = false;
    searchController.text = '';
  }
  // Image fromWebPicker ;


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
    final channelDetails = Provider.of<ChatProvider>(context);
    final userData = Provider.of<UserProvider>(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details){
          if (!kIsWeb) {
            if (Platform.isIOS) {
              if (details.primaryVelocity.compareTo(0) == 1) {
                Navigator.pop(context);
              }
            }
          }
        },
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: NestedScrollView(
            controller: _scrollController,

            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  pinned: true,
                  floating: true,
                  leading: IconButton(
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 27.0,),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    _editGroupName || _imageFile != null ? InkWell(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text('Save',style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                          ),
                        ),
                      ),
                      onTap:  _imageFile != null || _editGroupName ? (){
                        channelDetails.updateChatChannel(context,channelId: channelDetails.currentChannel.id,
                            groupDisplayName: _editGroupDisplayNameController.text??channelDetails.currentChannel.displayName,
                            groupImage: base64Image,
                            channelName: channelDetails.currentChannel.name);
                        setState(() {
                          _imageFile = null;
                          _editGroupName = false;
                        });
                      }:null,
                    ) : const SizedBox(),
                    _editGroupName ? const SizedBox()
                        :
                    IconButton(onPressed: () {
                      if (!isSearchFieldVisible) {
                        searchFocusNode.requestFocus();
                        isSearchFieldVisible = true;
                      } else {
                        cancelActions();
                      }
                      setState(() {});
                    },
                        icon: Image.asset(
                          'images/search.png',
                          color: Colors.white,
                          width: 25,
                          )
                    )

                  ],
                  leadingWidth: 40,
                  expandedHeight: _editGroupName && !kIsWeb ? 80 : _editGroupName && kIsWeb ? 120 : 220,
                  collapsedHeight: isSearchFieldVisible ? 140 : null,
                  title: _editGroupName ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: textFieldBorderRadius,
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: _editGroupDisplayNameController,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: _textFieldBorder(),
                          enabledBorder: _textFieldBorder(),
                          contentPadding: EdgeInsets.only(
                              bottom: _enableBorder == true ? 0.0: 15.0, left: 15.0, right: 15.0),
                        ),
                      ),
                    ),
                  ) : const SizedBox(),
                  automaticallyImplyLeading: false,
                  titleSpacing: 5,
                  flexibleSpace: channelDetails.loadingChannelDataStage == ChatStage.LOADING ?
                  const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 25.0,
                      ))
                      :
                  !_editGroupName
                      ?
                  FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    titlePadding: const EdgeInsets.only(left: 20,bottom: 0,right: 35),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18,left: 20),
                          child: Row(
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: Text(channelDetails.currentChannel.displayName??passedData['name']/*passedData['name']*/,
                                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)),

                                    channelDetails.currentChannel.adminId != userData.userData.id ? const SizedBox():
                                    const SizedBox(width: 7.0,),

                                    channelDetails.currentChannel.adminId != userData.userData.id ? const SizedBox():
                                    isSearchFieldVisible
                                        ?
                                    const SizedBox()
                                        :
                                    GestureDetector(
                                        onTap: channelDetails.currentChannel.adminId != userData.userData.id ? null : (){
                                      setState(() {
                                        _editGroupName = true;
                                      });
                                    },
                                        child: const Icon(Icons.edit, color: Colors.white,size: 20,))
                                  ],
                                ),
                              ),
                              const SizedBox(width: 7.0,)
                            ],
                          ),
                        ),
                        isSearchFieldVisible
                            ?
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                child: Container(
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    borderRadius: textFieldBorderRadius,
                                    color: Colors.white,
                                  ),
                                  child: TextField(
                                    cursorColor: Theme.of(context).primaryColor,
                                    style: TextStyle(color: Theme.of(context).primaryColor),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Transform.scale(
                                        scale: 0.6,
                                        child: Image.asset(
                                          'images/search.png',
                                          color: Theme.of(context).primaryColor,
                                          width: 20,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.only(bottom: 0.0, left: 15.0, right: 15.0,top: 6),
                                      hintText: "Search...",
                                      hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'DIN'),
                                    ),
                                    controller: searchController,
                                    focusNode: searchFocusNode,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9.0),
                              child: GestureDetector(
                                  onTap: () {
                                    cancelActions();
                                    setState(() {});
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                                  )),
                            )
                          ],
                        )
                            :
                        const SizedBox()
                      ],
                    ),
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: channelDetails.currentChannel.channelImage == null && _imageFile == null
                              ?
                          Padding(
                            padding: const EdgeInsets.only(top:2.0),
                            child: Image.asset("${Provider.of<UserProvider>(context,listen: false).currentAppBackground}", fit: BoxFit.cover, color: Colors.white,height: 25,),
                          )
                              :
                          _imageFile != null
                              ?
                          kIsWeb ? _imageFile : Image.file(File(_imageFile.path), fit: BoxFit.cover,)
                              :
                          Image.network(
                            channelDetails.currentChannel.channelImage,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                            return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                          },
                          ),
                        ),
                        Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black87],
                                  )
                              ),
                            )
                        ),
                        /*channelDetails.currentChannel.channelImage == null &&*/
                        _imageFile == null && channelDetails.currentChannel.adminId == userData.userData.id && !isSearchFieldVisible
                            ?
                        Positioned.fill(
                            child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: InkWell(
                                    onTap: channelDetails.currentChannel.adminId == userData.userData.id ? (){
                                      if (!kIsWeb) {
                                        showAttachImgBottomSheet(
                                            isFromGroupDetails: channelDetails.currentChannel.channelImage == null || channelDetails.currentChannel.channelImage.isEmpty  ? false : true,
                                            removeGroupPhoto: () {
                                              channelDetails.updateChatChannel(
                                                  context,
                                                  channelId: channelDetails.currentChannel.id,
                                                  groupDisplayName: channelDetails.currentChannel.displayName,
                                                  groupImage: "",
                                                  channelName: channelDetails.currentChannel.name);
                                              // Navigator.pop(context);
                                            },
                                            context: context,
                                            onCameraImg: ()async{
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
                                              },
                                            onGalleryImg: ()async{
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
                                    } : null,
                                    child: const Icon(
                                      Icons.add_a_photo_rounded,
                                      color: Colors.white,
                                      size: 40.0,
                                    ),
                                  ),
                                )
                            )
                        )
                            :
                        const SizedBox()
                      ],
                    ),
                  )
                      :
                  FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    titlePadding: const EdgeInsets.only(left: 0,bottom: 10,top: 10,right: 10),

                    title: isSearchFieldVisible
                        ?
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            child: Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: textFieldBorderRadius,
                                color: Colors.white,
                              ),
                              child: TextField(
                                cursorColor: Theme.of(context).primaryColor,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Transform.scale(
                                    scale: 0.6,
                                    child: Image.asset(
                                      'images/search.png',
                                      color: Theme.of(context).primaryColor,
                                      width: 20,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(bottom: 0.0, left: 15.0, right: 15.0,top: 6),
                                  hintText: "Search...",
                                  hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'DIN'),
                                ),
                                controller: searchController,
                                focusNode: searchFocusNode,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9.0),
                          child: GestureDetector(
                              onTap: () {
                                cancelActions();
                                setState(() {});
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontSize: 16.0, color: Colors.white),
                              )),
                        )
                      ],
                    )
                        :
                    const SizedBox(),
                    background: GestureDetector(
                      onTap: channelDetails.currentChannel.adminId == userData.userData.id ? (){
                        showAttachImgBottomSheet(
                            isFromGroupDetails: channelDetails.currentChannel.channelImage == null || channelDetails.currentChannel.channelImage.isEmpty ? false : true,
                            removeGroupPhoto: () {
                              channelDetails.updateChatChannel(
                                  context,
                                  channelId: channelDetails.currentChannel.id,
                                  groupDisplayName: channelDetails.currentChannel.displayName,
                                  groupImage: "",
                                  channelName: channelDetails.currentChannel.name);
                              // Navigator.pop(context);
                            },
                            context: context,
                            onCameraImg: ()async{
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
                              },
                            onGalleryImg: ()async{
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
                      } : null,
                      child: Stack(
                        children: [
                          Positioned.fill(child: channelDetails.currentChannel.channelImage == null && _imageFile == null
                              ?
                          Padding(
                            padding: const EdgeInsets.only(top:2.0),
                            child: Image.asset("${Provider.of<UserProvider>(context,listen: false).currentAppBackground}", fit: BoxFit.cover, color: Colors.white,height: 25,),
                          )
                              :
                          _imageFile != null
                              ?
                          Image.file(File(_imageFile.path), fit: BoxFit.cover,)
                              :
                          Image.network(
                            channelDetails.currentChannel.channelImage,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                            return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                          },
                          ),
                          ),
                          Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black87],
                                    )
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: channelDetails.loadingChannelDataStage == ChatStage.LOADING ?
            Center(
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 45.0,
                ))
                :
            SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              footer: CustomFooter(
                builder: (BuildContext context,LoadStatus mode){
                  Widget body ;
                  if(mode==LoadStatus.loading){
                    body =  const CupertinoActivityIndicator();
                  }
                  else if(mode == LoadStatus.failed){
                    body = const Text("Load Failed!Click retry!");
                  }
                  else if(mode == LoadStatus.canLoading){
                  }
                  else{
                    body = const Text("No more to load!");
                  }
                  return Center(child: body);
                  //return Container();
                },
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(left:12.0, bottom: 0.0, top:18.0),
                          child: Text("${channelDetails.currentChannel.memberCount} Participants", style: style1,),
                        ),
                        const Divider(thickness: 3.0,),

                        Container(
                            // height: media.height*0.7,
                            // height:  channelDetails.currentChannel.adminId == userData.userData.id ? media.height * 0.5 : media.height * 0.52,
                            child: channelDetails.loadingChannelParticipantsStage == ChatStage.LOADING ?
                            Center(
                                child: SpinKitCircle(
                                  color: Theme.of(context).primaryColor,
                                  size: 35.0,
                                )):
                            ListView(
                              shrinkWrap: true,
                              // controller: _scrollController,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: channelDetails.groupChannelParticipants.length<8 ? 40:0),
                              children: channelDetails.groupChannelParticipantsForSearch.isNotEmpty
                                  ?
                              List.generate(channelDetails.groupChannelParticipantsForSearch.length, (i) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // i == 0 ? Divider(thickness: 3.0,):Container(),
                                  Slidable(
                                    actionPane: const SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.18,
                                    secondaryActions: channelDetails.currentChannel.adminId == userData.userData.id && channelDetails.currentChannel.adminId != channelDetails.groupChannelParticipantsForSearch[i].id ?
                                    <Widget>[
                                      IconSlideAction(
                                        caption: 'Remove',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: (){
                                          showAnimatedCustomDialog(context, title: "Remove this person?", message: "They won't be able to continue chatting with this group.",
                                              buttonText: "Remove", cancelButtonTitle: "Cancel", onClicked: () {
                                                channelDetails.updateChatChannel(context,channelId: channelDetails.currentChannel.id,
                                                    groupDisplayName: channelDetails.currentChannel.displayName,
                                                    groupImage: null,
                                                    usersIdsToRemove: [channelDetails.groupChannelParticipantsForSearch[i].id], channelName: channelDetails.currentChannel.name);
                                                Navigator.pop(context);
                                              });
                                        },
                                      ),
                                    ]: null,
                                    child: GestureDetector(
                                      // onTap: ()=>  Navigator.pushNamed(context, OtherUserProfile.routName,
                                      //     arguments: {
                                      //       "user": channelDetails.currentChannel.participant[i]
                                      //     }),
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(80.0),
                                          child: Container(height: 40.0, width: 40.0,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[200],
                                              borderRadius: BorderRadius.circular(80.0),
                                            ),
                                            child: channelDetails.groupChannelParticipantsForSearch[i].profilePic == null ? Padding(
                                              padding: const EdgeInsets.only(top:2.0),
                                              child: Image.asset("images/person.png", fit: BoxFit.contain, color: Colors.white,),
                                            ) : Image.network(
                                              channelDetails.groupChannelParticipantsForSearch[i].profilePic,
                                              fit: BoxFit.cover,
                                              errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                              return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                            },),
                                          ),
                                        ),

                                        title: Text(channelDetails.groupChannelParticipantsForSearch[i].id == userData.userData.id ? "You" :
                                        channelDetails.groupChannelParticipantsForSearch[i].name, style: style2,),

                                        subtitle: Text(channelDetails.groupChannelParticipantsForSearch[i].roles.isEmpty ? "${channelDetails.groupChannelParticipantsForSearch[i].trust["name"]}":
                                        "${getJobRolesCommaSeparatedList(channelDetails.groupChannelParticipantsForSearch[i].roles)}\n${channelDetails.groupChannelParticipantsForSearch[i].trust["name"]}",
                                          maxLines: 3, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.grey, fontSize: 14.0),),

                                        trailing: channelDetails.currentChannel.adminId == channelDetails.groupChannelParticipantsForSearch[i].id ?
                                        Material(
                                            borderRadius: BorderRadius.circular(7.0),
                                            color: Theme.of(context).primaryColor,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                              child: Text("Group Admin",
                                                style:TextStyle(color: Colors.white, fontSize: 12.0),),
                                            )): null,
                                      ),
                                    ),
                                  ),
                                  Divider(thickness: i == channelDetails.groupChannelParticipantsForSearch.length-1 ? 3.0:1.0,)
                                ],
                              ))
                                  :
                              List.generate(channelDetails.groupChannelParticipants.length, (i) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // i == 0 ? Divider(thickness: 3.0,):Container(),
                                  Slidable(
                                    actionPane: const SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.18,
                                    secondaryActions: channelDetails.currentChannel.adminId == userData.userData.id && channelDetails.currentChannel.adminId != channelDetails.groupChannelParticipants[i].id ?
                                    <Widget>[
                                      IconSlideAction(
                                        caption: 'Remove',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: (){
                                          showAnimatedCustomDialog(context, title: "Remove this person?", message: "They won't be able to continue chatting with this group.",
                                              buttonText: "Remove", cancelButtonTitle: "Cancel", onClicked: () {
                                                channelDetails.updateChatChannel(context,channelId: channelDetails.currentChannel.id,
                                                    groupDisplayName: channelDetails.currentChannel.displayName,
                                                    groupImage: null,
                                                    usersIdsToRemove: [channelDetails.groupChannelParticipants[i].id], channelName: channelDetails.currentChannel.name);
                                                Navigator.pop(context);
                                              });
                                        },
                                      ),
                                    ]: null,
                                    child: GestureDetector(
                                      // onTap: ()=>  Navigator.pushNamed(context, OtherUserProfile.routName,
                                      //     arguments: {
                                      //       "user": channelDetails.currentChannel.participant[i]
                                      //     }),
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(80.0),
                                          child: Container(height: 40.0, width: 40.0,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[200],
                                              borderRadius: BorderRadius.circular(80.0),
                                            ),
                                            child: channelDetails.groupChannelParticipants[i].profilePic == null ? Padding(
                                              padding: const EdgeInsets.only(top:2.0),
                                              child: Image.asset("images/person.png", fit: BoxFit.contain, color: Colors.white,),
                                            ) : Image.network(
                                              channelDetails.groupChannelParticipants[i].profilePic,
                                              fit: BoxFit.cover,
                                              errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                              return SvgPicture.asset('images/missingImage.svg',color: Colors.grey[400],);
                                            },
                                            ),
                                          ),
                                        ),

                                        title: Text(channelDetails.groupChannelParticipants[i].id == userData.userData.id ? "You" :
                                        channelDetails.groupChannelParticipants[i].name, style: style2,),

                                        subtitle: Text(channelDetails.groupChannelParticipants[i].roles.isEmpty ? "${channelDetails.groupChannelParticipants[i].trust["name"]}":
                                        "${getJobRolesCommaSeparatedList(channelDetails.groupChannelParticipants[i].roles)}\n${channelDetails.groupChannelParticipants[i].trust["name"]}",
                                          maxLines: 3, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.grey, fontSize: 14.0),),

                                        trailing: channelDetails.currentChannel.adminId == channelDetails.groupChannelParticipants[i].id ?
                                        Material(
                                            borderRadius: BorderRadius.circular(7.0),
                                            color: Theme.of(context).primaryColor,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                              child: Text("Group Admin",
                                                style:TextStyle(color: Colors.white, fontSize: 12.0),),
                                            )): null,
                                      ),
                                    ),
                                  ),
                                  Divider(thickness: i == channelDetails.groupChannelParticipants.length-1 ? 3.0:1.0,)
                                ],
                              ))
                              ,
                            )
                        ),

                        // SizedBox(height: media.height*0.2,)

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          extendBody: true,
          bottomNavigationBar: channelDetails.currentChannel != null
              ?
          AnimatedContainer(
            height: isBottomWidgetShown ? channelDetails.currentChannel.adminId == userData.userData.id ? 150 : 100:0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(40),
                topLeft: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            duration: const Duration(milliseconds: 100),
            child: Wrap(
              children: [
                isBottomWidgetShown ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:12.0, bottom: 0.0, top:10.0),
                      child: Text("Options", style: style1,),
                    ),
                    channelDetails.currentChannel.adminId == userData.userData.id ?
                    const Divider() : const SizedBox (),
                    channelDetails.currentChannel.adminId == userData.userData.id ?
                    SizedBox(
                      height: 40,
                      child: ListTile(
                        minVerticalPadding: 0.0,

                        contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                        onTap: ()=> Navigator.pushNamed(context, NewGroupScreen.routeName,
                            arguments: {
                              "contact":null,
                              "group_id": channelDetails.currentChannel.id,
                              "from" : "groupDetails"
                            }),
                        leading: Icon(Icons.group_add, color: Theme.of(context).primaryColor, size: 30.0,),
                        title: Text("Add Participant", style: styleBlue),
                      ),
                    )
                        :
                    const SizedBox(),
                    // Divider(),
                    SizedBox(
                      height: 40,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                        onTap: () async{
                          showAnimatedCustomDialog(context, title: "Leave group?", message: "Once you leave a group you won't receive any messages and won't be able to see old messages.",
                              buttonText: "Leave", cancelButtonTitle: "Cancel", onClicked: (){
                                channelDetails.leaveChat(context, channelId: channelDetails.currentChannel.id)
                                    .then((_) async{
                                  Provider.of<ChatProvider>(context, listen: false).clearChannels();
                                  await Provider.of<ChatProvider>(context, listen: false).fetchGroupChannels(context);
                                  Provider.of<ChatProvider>(context, listen: false).fetchHistoryForChannels(Provider.of<ChatProvider>(context, listen: false).userAuthKey);
                                  Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName));

                                  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>NavigationHome()), (route) => false);
                                });
                              });
                        },
                        leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red, size: 30.0,),
                        title: const Text("Exit Group", style: TextStyle(color: Colors.red, fontSize: 18.0, fontWeight: FontWeight.bold),),
                      ),
                    ),
                    // Divider(),
                    const SizedBox(height: 45.0,)
                  ],
                ) : const SizedBox()
              ],
            ),)
              :
          const SizedBox(),
        ),
      ),
    );
  }
}