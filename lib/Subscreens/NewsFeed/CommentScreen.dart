// ignore_for_file: file_names, avoid_function_literals_in_foreach_calls, sized_box_for_whitespace, missing_required_param, unnecessary_string_interpolations

import 'dart:io';
import 'dart:ui';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Models/CommentModel.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Screens/navigationHome.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';



class CommentScreen extends StatefulWidget {
  static const routeName = '/CommentScreen';

  const CommentScreen({Key key}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentEditingController = TextEditingController();
  FocusNode commentFieldNode = FocusNode();
  bool _isCommentTextFieldEmpty = true;

  bool _isInit = true;
  Map passedData = {};
  int pageOffset = 0;
  static const String deletingComment = "Deleting comment?";
  static const String delete = "Delete";
  static const String cancel = "Cancel";
  static const String areYouSure = "Are you sure you want to delete this comment?";
  var lastItemBottomPadding = 20.0;
  Comment commentToBeReplied;
  Widget bottomGapToShowLoadingMoreStatus = Container();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String editedComment;
  bool _isSavingEditComment = false;
  bool isLoading=true;
  bool isPostingComment=false;
  @override
  void initState() {
    commentFieldNode.addListener(() {});
    super.initState();
    FToast().init(context);
  }
  showRepliesFunction(bool isOpened) {
    setState(() {
      isOpened = !isOpened;
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      passedData = ModalRoute.of(context).settings.arguments;
      Provider.of<NewsProvider>(context, listen: false)
          .fetchCommentsForNewsObject(context, passedData["id"].toString(),
              pageOffset: 0).then((_) {
                setState(() {
                  isLoading = false;
                });

      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _onRefresh() async {
    pageOffset = 0;
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<NewsProvider>(context, listen: false)
        .fetchCommentsForNewsObject(context, passedData["id"],
            pageOffset: pageOffset).then((_) {
      setState(() {
        isLoading = false;
        isPostingComment=false;
      });
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      lastItemBottomPadding = 8.0;
      bottomGapToShowLoadingMoreStatus = const SizedBox(
        height: 60.0,
      );
    });
    pageOffset += 25;
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<NewsProvider>(context, listen: false)
        .fetchCommentsForNewsObject(context, passedData["id"],
            pageOffset: pageOffset);
    if (mounted) {
      setState(() {
        lastItemBottomPadding = 25.0;
        bottomGapToShowLoadingMoreStatus = Container();
      });
      _refreshController.loadComplete();
    }
  }

  @override
  void dispose() {
    commentEditingController.dispose();
    commentFieldNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context);
    final commentData = Provider.of<NewsProvider>(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onHorizontalDragEnd: (DragEndDetails details){
          if (Platform.isIOS) {
            if (details.primaryVelocity.compareTo(0) == 1) {
              Navigator.pushReplacementNamed(context, NavigationHome.routeName);
            }
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          appBar: screenAppBar(context, media,
              appbarTitle: const Text("Comments"),
              onBackPressed: () => Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routeName)),
              hideProfilePic: true,
              showLeadingPop: true),
          body: Stack(
            children: [
              isLoading
                  ? Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 45.0,
                      ),
                    )
                  : commentData.commentsStage == NewsStage.DONE && commentData.commentList.isEmpty
                      ? Container(
                          width: media.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 40.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Be the first to comment",
                                  style: style2,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        )
                      : commentData.commentsStage == NewsStage.ERROR
                          ? Container(
                              width: media.width,
                              height: media.height,
                              child: Center(
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _onRefresh();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Network Error retry? "),
                                      Icon(Icons.refresh,color: Theme.of(context).primaryColor,)
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: editedComment == null ? media.height * 0.08 : 0),
                                    child: SmartRefresher(
                                      enablePullDown: true,
                                      enablePullUp: true,
                                      controller: _refreshController,
                                      onRefresh: _onRefresh,
                                      onLoading: _onLoading,
                                      footer: CustomFooter(
                                        builder: (BuildContext context,
                                            LoadStatus mode) {
                                          Widget body;
                                          if (mode == LoadStatus.loading) {
                                            body = const CupertinoActivityIndicator();
                                          } else if (mode ==
                                              LoadStatus.failed) {
                                            body = const Text(
                                                "Load Failed!Click retry!");
                                          } else if (mode ==
                                              LoadStatus.canLoading) {
                                          } else {
                                            body = const Text("No more to load!");
                                          }
                                          return Center(child: body);
                                          //return Container();
                                        },
                                      ),
                                      child: ListView.builder(
                                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                          itemCount:
                                              commentData.commentList.length,
                                          itemBuilder: (context, i) {
                                            Set<String> commentsReactionIcons={};
                                            String initialCommentReaction = '';
                                            int currentUserReactionId;
                                            String reactType = '';
                                            if (commentData.commentList[i].reactions != null) {
                                              if (commentData.commentList[i].reactions.isNotEmpty) {
                                                commentData.commentList[i].reactions.forEach((element) {
                                                  commentsReactionIcons.add(element.reaction_type);
                                                  if(element.user['api_service_id'] == userData.userData.id){
                                                    initialCommentReaction = element.reaction_type;
                                                    currentUserReactionId = element.id;

                                                  }

                                                });
                                              }
                                            }
                                            // SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
                                            return Padding(
                                              padding: i == commentData.commentList.length - 1 ?
                                              EdgeInsets.only(bottom: lastItemBottomPadding)
                                                  :
                                              const EdgeInsets.only(bottom: 0.0),
                                              child: InkWell(
                                                onLongPress: commentData.commentList[i].user['api_service_id'] == userData.userData.id
                                                    ? () {
                                                        showCommentsBottomSheet(
                                                            context: context,
                                                            onDelete: () async {

                                                              showAnimatedCustomDialog(
                                                                  context,
                                                                  title: deletingComment,
                                                                  message: areYouSure,
                                                                  buttonText: delete,
                                                                  cancelButtonTitle: cancel,
                                                                  onClicked: () {
                                                                    setState(() {
                                                                      isPostingComment=true;
                                                                    });
                                                                    Provider.of<NewsProvider>(context, listen: false).deleteComment(context: context,
                                                                        postId: passedData["id"],
                                                                        commentId: commentData.commentList[i].id).then((_) {
                                                                      Provider.of<NewsProvider>(context,listen: false).fetchCommentsForNewsObject(context, passedData["id"], pageOffset: 0).then((_) {
                                                                        setState(() {
                                                                          isPostingComment=false;
                                                                        });
                                                                      });

                                                                    });
                                                                    Navigator.pop(context);
                                                                  });

                                                            },
                                                            onEdit: () {
                                                              // To make sure that we are only editing the comment we are after
                                                              for (int j = 0; j < commentData.commentList[i].replies.length; j++) {
                                                                commentData.commentList[i].replies[j].editing = false;
                                                              }
                                                              for (int j = 0; j < commentData.commentList.length; j++) {
                                                                commentData.commentList[j].editing = false;
                                                                commentData.commentList[j].canReply = false;
                                                              }
                                                              setState(() {
                                                                editedComment = commentData.commentList[i].body;
                                                                commentData.commentList[i].editing = true;
                                                              });
                                                            });}
                                                    : () {},
                                                child: commentCard(
                                                    context,
                                                  reactionsButton: ReactionButtonToggle<String>(
                                                    onReactionChanged:
                                                        (reaction, index) {

                                                      if(reaction == null){
                                                        reactType = initialCommentReaction == null ? "like" : '';

                                                      }
                                                      // else {
                                                        else if(reaction == "like"){
                                                          reactType = "like";
                                                        }
                                                        else if(reaction == "support"){
                                                          reactType = "support";
                                                        }
                                                        else if(reaction == "insightful"){
                                                          reactType = "insightful";
                                                        }
                                                        else if(reaction == "celeberate"){
                                                          reactType = "celeberate";
                                                        }
                                                        if (reactType != '') {
                                                          Provider.of<NewsProvider>(context,listen: false).reactComment(context,postId:passedData["id"],commentId: commentData.commentList[i].id,reactionType: reactType ).then((_) {
                                                            Provider.of<NewsProvider>(context,listen: false).fetchCommentsForNewsObject(context,passedData["id"],pageOffset: 0);
                                                          });
                                                        }
                                                      // }
                                                      if(currentUserReactionId != null && reactType == '' ){
                                                        Provider.of<NewsProvider>(context,listen: false).deleteReactionForComment(context,postId:passedData["id"],commentId: commentData.commentList[i].id,reactionId: currentUserReactionId ).then((_) {
                                                          Provider.of<NewsProvider>(context,listen: false).fetchCommentsForNewsObject(context,passedData["id"],pageOffset: 0).then((_) {
                                                            initialCommentReaction = '';
                                                            currentUserReactionId=null;
                                                          });
                                                        });
                                                      }

                                                    },
                                                    // boxAlignment: Alignment.topCenter,
                                                    boxPosition: Position.TOP,
                                                    boxRadius: 8.0,
                                                    itemScale: 0.3,
                                                    boxPadding: const EdgeInsets.symmetric(
                                                        vertical: 8, horizontal: 10),
                                                    // boxItemsSpacing: 20.0,
                                                    reactions: <Reaction<String>>[
                                                      Reaction<String>(
                                                          previewIcon: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                            child: SvgPicture.asset(
                                                              'images/like-active.svg',
                                                              // color: Colors.grey[900],
                                                              width: 22,
                                                              height: 22,
                                                            ),
                                                          ),
                                                          icon: SvgPicture.asset(
                                                            'images/like-active.svg',
                                                            // color: Colors.grey[900],
                                                            width: 22,
                                                            height: 22,
                                                          ),
                                                          id: 1,
                                                        value: "like"
                                                      ),
                                                      Reaction<String>(
                                                          previewIcon: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                            child: SvgPicture.asset(
                                                              'images/support-active.svg',
                                                              // color: Colors.grey[900],
                                                              width: 22,
                                                              height: 22,
                                                            ),
                                                          ),
                                                          icon: SvgPicture.asset(
                                                            'images/support-active.svg',
                                                            // color: Colors.grey[900],
                                                            width: 22,
                                                            height: 22,
                                                          ),
                                                          id: 2,
                                                        value: "support"
                                                      ),
                                                      Reaction<String>(
                                                          previewIcon: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                            child: SvgPicture.asset(
                                                              'images/insightful-active.svg',
                                                              // color: Colors.grey[900],
                                                              width: 22,
                                                              height: 22,
                                                            ),
                                                          ),
                                                          icon: SvgPicture.asset(
                                                            'images/insightful-active.svg',
                                                            // color: Colors.grey[900],
                                                            width: 22,
                                                            height: 22,
                                                          ),
                                                          id: 3,
                                                        value: "insightful"
                                                      ),
                                                      Reaction<String>(
                                                          previewIcon: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                            child: SvgPicture.asset(
                                                              'images/celeberate-active.svg',
                                                              // color: Colors.grey[900],
                                                              width: 22,
                                                              height: 22,
                                                            ),
                                                          ),
                                                          icon: SvgPicture.asset(
                                                            'images/celeberate-active.svg',
                                                            // color: Colors.grey[900],
                                                            width: 22,
                                                            height: 22,
                                                          ),
                                                          id: 4,
                                                        value:"celeberate"
                                                      ),
                                                    ],
                                                    initialReaction: initialCommentReaction == ''
                                                        ?
                                                    Reaction<String>(
                                                        icon: SvgPicture.asset(
                                                          'images/like.svg',
                                                          // color: Colors.grey[900],
                                                          width: 22,
                                                          height: 22,
                                                          color: Colors.grey[700],
                                                        ),
                                                        id: 0
                                                    )
                                                        :
                                                    Reaction<String>(
                                                      value: initialCommentReaction,
                                                        icon: SvgPicture.asset(
                                                          'images/$initialCommentReaction-active.svg',
                                                          width: 22,
                                                          height: 22,
                                                        ),
                                                        id: initialCommentReaction == "like" ? 1 : initialCommentReaction == "support" ? 2 : initialCommentReaction == 'insightful' ? 3 :initialCommentReaction == "celeberate" ? 4 : 0
                                                    ),
                                                    selectedReaction: reactType != ''
                                                        ?
                                                    Reaction<String>(
                                                        icon: SvgPicture.asset(
                                                          'images/like-active.svg',
                                                          // color: Colors.grey[900],
                                                          width: 22,
                                                          height: 22,
                                                          // color: Colors.grey[700],
                                                        ),
                                                        id: 1,
                                                      value: "like"
                                                    )
                                                        :
                                                    initialCommentReaction != ""
                                                        ?
                                                    Reaction<String>(
                                                        icon: SvgPicture.asset(
                                                          'images/like.svg',
                                                          // color: Colors.grey[900],
                                                          width: 22,
                                                          height: 22,
                                                          color: Colors.grey[700],
                                                        ),
                                                        id: 0
                                                    )
                                                        :
                                                    initialCommentReaction == ""
                                                        ?
                                                    Reaction<String>(
                                                        icon: SvgPicture.asset(
                                                          'images/like-active.svg',
                                                          // color: Colors.grey[900],
                                                          width: 22,
                                                          height: 22,
                                                          // color: Colors.grey[700],
                                                        ),
                                                        id: 1,
                                                        value: "like"
                                                    )
                                                        :
                                                    Reaction<String>(
                                                        icon: SvgPicture.asset(
                                                          'images/like.svg',
                                                          // color: Colors.grey[900],
                                                          width: 22,
                                                          height: 22,
                                                          color: Colors.grey[700],
                                                        ),
                                                        id: 0
                                                    ),
                                                  ),
                                                  postId: passedData["id"],
                                                  reactionId: currentUserReactionId == null && initialCommentReaction == null ? null : currentUserReactionId,
                                                  commentId: commentData.commentList[i].id,
                                                  reactionsCount: commentData.commentList[i].reactions != null ? commentData.commentList[i].reactions.isNotEmpty ? "${commentData.commentList[i].reactions.length}" : "" : "" ,
                                                  reactions: commentData.commentList[i].reactions != null ? commentData.commentList[i].reactions.isNotEmpty
                                                      ?
                                                  InkWell(
                                                    onTap: (){
                                                      showReactionsBottomSheet(
                                                          context: context,
                                                        tabBarItems: commentsReactionIcons.length+1,
                                                        content: Container(
                                                          height: media.height*0.5,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 30),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  height: 30,
                                                                  child: TabBar(
                                                                      // indicatorWeight: 20,
                                                                      isScrollable: true,
                                                                      // controller: controller,
                                                                      labelColor: const Color(0xFF808080),
                                                                      unselectedLabelColor: const Color(0xFF808080),
                                                                      indicatorSize: TabBarIndicatorSize.label,
                                                                      indicatorWeight: 0,
                                                                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),
                                                                      labelPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
                                                                      indicator: BoxDecoration(
                                                                          color: const Color(0xFFEEF6FE),
                                                                          // border: Border.all(color: Color(0xFFE2E2E2)),
                                                                          borderRadius: BorderRadius.circular(20)
                                                                      ),
                                                                      tabs: List.generate(commentsReactionIcons.length+1, (index) {

                                                                        Map<String,int> reactionsCounters={};
                                                                        commentsReactionIcons.forEach((element) {
                                                                          int counter =0;
                                                                          for(int j =0; j<commentData.commentList[i].reactions.length;j++){
                                                                            if(element == commentData.commentList[i].reactions[j].reaction_type){
                                                                              counter++;
                                                                              reactionsCounters['$element']=counter;

                                                                            }
                                                                          }

                                                                        });
                                                                        return Tab(
                                                                          child: Container(
                                                                            height: 40,
                                                                            // width: index==0 ? null : media.width*0.12,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.transparent,
                                                                                border: Border.all(color: const Color(0xFFE2E2E2)),
                                                                                borderRadius: BorderRadius.circular(20)
                                                                            ),
                                                                            child: Center(child: index==0 ? Text('All ${commentData.commentList[i].reactions.length}')
                                                                                :
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                SvgPicture.asset('images/${commentsReactionIcons.toList()[index-1]}-active.svg',height: 18,width: 18,),
                                                                                const SizedBox(width: 5,),
                                                                                Text(commentData.commentList[i].reactions != null ? commentData.commentList[i].reactions.isNotEmpty ? "${reactionsCounters['${commentsReactionIcons.toList()[index-1]}']}": "" : "" ),
                                                                              ],
                                                                            )
                                                                            ),
                                                                          ),
                                                                        );
                                                                      })),
                                                                ),
                                                                const Divider(color: Color(0xFFEEEEEE),),
                                                                Expanded(
                                                                  child: SizedBox(
                                                                      height: media.height*0.4,
                                                                      child: TabBarView(
                                                                        children: List.generate(commentsReactionIcons.length+1, (idxx) {
                                                                          List<String> reactionsForCommentsFilteredByType=['all'];
                                                                          commentsReactionIcons.forEach((element) { reactionsForCommentsFilteredByType.add(element);});
                                                                          return MediaQuery.removePadding(
                                                                              context: context,
                                                                              removeTop: true,
                                                                              child: ListView(
                                                                                children: idxx == 0 ? List.generate(commentData.commentList[i].reactions.length, (indx) {
                                                                                  return InkWell(
                                                                                    onTap: ()async{

                                                                                      if (userData.userData.id != commentData.commentList[i].reactions[indx].user['api_service_id']) {
                                                                                        // User user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: commentData.commentList[i].reactions[indx].user['api_service_id']);
                                                                                        Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": commentData.commentList[i].reactions[indx].user['api_service_id']});
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      width: media.width,
                                                                                      padding: EdgeInsets.symmetric(horizontal: media.width*0.1),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: 30,
                                                                                                    height: 30,
                                                                                                    decoration: BoxDecoration(
                                                                                                        shape:BoxShape.circle,
                                                                                                        image: DecorationImage(
                                                                                                            image: NetworkImage('${commentData.commentList[i].reactions[indx].user['profile_image']}'),
                                                                                                            fit: BoxFit.cover
                                                                                                        )
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(width: 8,),
                                                                                                  Text(userData.userData.id.toString() == commentData.commentList[i].reactions[indx].user['api_service_id'].toString() ? "You" : '${commentData.commentList[i].reactions[indx].user['name']}'),
                                                                                                ],
                                                                                              ),
                                                                                              SvgPicture.asset("images/${commentData.commentList[i].reactions[indx].reaction_type}-active.svg",width: 18,height: 18,)

                                                                                            ],
                                                                                          ),
                                                                                          indx == commentData.commentList[i].reactions.length-1 ? const SizedBox() : const Divider(
                                                                                            color: Color(0xFFEEEEEE),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                }
                                                                                ) : List.generate(commentData.commentList[i].reactions.length, (indx) {


                                                                                  return commentData.commentList[i].reactions[indx].reaction_type == reactionsForCommentsFilteredByType[idxx] ? InkWell(
                                                                                    onTap: ()async{

                                                                                      if (userData.userData.id != commentData.commentList[i].reactions[indx].user['api_service_id']) {
                                                                                        // User user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: commentData.commentList[i].reactions[indx].user['api_service_id']);
                                                                                        Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": commentData.commentList[i].reactions[indx].user['api_service_id']});
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      width: media.width,
                                                                                      padding: EdgeInsets.symmetric(horizontal: media.width*0.1),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: 30,
                                                                                                    height: 30,
                                                                                                    decoration: BoxDecoration(
                                                                                                        shape:BoxShape.circle,
                                                                                                        image: DecorationImage(
                                                                                                            image: NetworkImage('${commentData.commentList[i].reactions[indx].user['profile_image']}'),
                                                                                                            fit: BoxFit.cover
                                                                                                        )
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(width: 8,),
                                                                                                  Text(userData.userData.id.toString() == commentData.commentList[i].reactions[indx].user['api_service_id'].toString() ? "You" : '${commentData.commentList[i].reactions[indx].user['name']}'),
                                                                                                ],
                                                                                              ),
                                                                                              SvgPicture.asset("images/${commentData.commentList[i].reactions[indx].reaction_type}-active.svg",width: 18,height: 18,)

                                                                                            ],
                                                                                          ),
                                                                                          indx == commentData.commentList[i].reactions.length-1 ? const SizedBox() : const Divider(
                                                                                            color: Color(0xFFEEEEEE),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ) : const SizedBox();
                                                                                },
                                                                                ),
                                                                              ));
                                                                        },
                                                                        ),
                                                                      )
                                                                  )
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      );
                                                    },
                                                    child: RowSuper(
                                                      children: List.generate(commentsReactionIcons.length, (index) {

                                                        return Material(
                                                          borderRadius: BorderRadius.circular(100),
                                                          child: Container(
                                                            width: 22,
                                                            height: 22,
                                                            padding: const EdgeInsets.only(left: 4,right: 4,bottom: 5,top: 3),
                                                            child: SvgPicture.asset(
                                                              'images/${commentsReactionIcons.toList()[index]}-active.svg',
                                                              // color: Colors.grey[900],
                                                              width: 20,
                                                              height: 20,
                                                            ),
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.white,
                                                                border: Border.all(color: Colors.grey[300])
                                                            ),
                                                          ),
                                                          elevation: 2,
                                                        );
                                                      }),
                                                      outerDistance: 2.0,
                                                      innerDistance: -8.0,
                                                      invert: true,
                                                      alignment: Alignment.center,
                                                      separator: Container(),
                                                      separatorOnTop: true,
                                                      fitHorizontally: true,
                                                      shrinkLimit: 1.0,
                                                      mainAxisSize: MainAxisSize.min,
                                                    ),
                                                  )
                                                      :
                                                  const SizedBox()
                                                      :
                                                  const SizedBox(),
                                                    // onReact: (){
                                                    //   setState(() {
                                                    //
                                                    //   });
                                                    //   // Provider.of<NewsProvider>(context,listen: false).reactComment(context,postId:passedData["id"],commentId: commentData.commentList[i].id,reactionType: 'insightful' );
                                                    // },
                                                  // initialReaction: initialCommentReaction == '' ? null : Reaction(
                                                  //   icon: SvgPicture.asset(
                                                  //     'images/${initialCommentReaction}-active.svg',
                                                  //     width: 22,
                                                  //     height: 22,
                                                  //   ),
                                                  //   id: initialCommentReaction == "like" ? 1 : initialCommentReaction == "support" ? 2 : initialCommentReaction == 'insightful' ? 3 :initialCommentReaction == "celeberate" ? 4 : 0
                                                  // ),
                                                    isSubmittingCommentAlteration: _isSavingEditComment,
                                                    isMe: commentData.commentList[i].user['api_service_id'] == userData.userData.id,
                                                    commentBody: commentData.commentList[i].body,
                                                    isEditing: commentData.commentList[i].editing,
                                                    onProfilePicClicked: commentData.commentList[i].user['api_service_id'] == userData.userData.id
                                                            ? null
                                                            : () async {
                                                                // User user = await commentData.fetchUserById(
                                                                // userId: commentData.commentList[i].user['api_service_id']);
                                                                Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {
                                                                      "user_id": commentData.commentList[i].user['api_service_id'],
                                                                    });
                                                              },
                                                    onReplyComment: () {
                                                      setState(() {
                                                        commentToBeReplied = commentData.commentList[i];
                                                      });
                                                      commentFieldNode.requestFocus();
                                                    },
                                                    onSaveEditingComment: editedComment == null ? () {} : () async {
                                                      setState(() {
                                                        _isSavingEditComment = true;
                                                      });
                                                      Provider.of<NewsProvider>(context, listen: false).editComment(
                                                          context: context,
                                                          postId: passedData["id"],
                                                          commentId: commentData.commentList[i].id, commentBody: editedComment).then((_) {
                                                                  Provider.of<NewsProvider>(context, listen: false).fetchCommentsForNewsObject(
                                                                          context,
                                                                          passedData["id"],
                                                                          pageOffset: 0
                                                                  ).then((_) {
                                                                        setState(() {
                                                                          editedComment = null;
                                                                          _isSavingEditComment = false;
                                                                        });
                                                                  });
                                                                });
                                                              },
                                                    onCancelEditingComment: () {
                                                      commentData.commentList.forEach((element) {
                                                        element.canReply = true;
                                                      });
                                                      setState(() {
                                                        editedComment = null;

                                                        commentData
                                                            .commentList[i]
                                                            .editing = false;
                                                      });
                                                    },
                                                    commentEditor: TextFormField(
                                                      autofocus: true,
                                                      initialValue: commentData.commentList[i].body,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          editedComment = value;
                                                        });
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                      ),
                                                      cursorColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[900]),
                                                    ),
                                                    commentDate: commentData.commentList[i].updatedAt,
                                                    userProfilePic: commentData.commentList[i].user['api_service_id'] == userData.userData.id
                                                        ? "${userData.userData.profilePic}"
                                                        : commentData.commentList[i].user['api_service_id'] != userData.userData.id &&
                                                                commentData.commentList[i].user['profile_image'] == null
                                                            ? 'https://www.nicepng.com/png/full/556-5566636_helen-romero-person-headshot-silhouette.png'
                                                            : commentData
                                                                .commentList[i]
                                                                .user['profile_image'],
                                                    userName: commentData.commentList[i].user['api_service_id'] == userData.userData.id
                                                        ? "${userData.userData.name}"
                                                        : commentData.commentList[i].user['api_service_id'] != userData.userData.id && commentData.commentList[i].user['name'] == null
                                                            ? 'User'
                                                            : "${commentData.commentList[i].user['name']}",
                                                    canReply: commentData.commentList[i].canReply,
                                                    replies: commentData.commentList[i].replies == null
                                                        ? const SizedBox()
                                                        : commentData.commentList[i].replies.isEmpty
                                                            ?
                                                    const SizedBox()
                                                            :
                                                    ExpandChild(
                                                                child: Column(
                                                                  children: List.generate(commentData.commentList[i].replies.length, (index) {
                                                                    Set<String> reactionIcons={};
                                                                    String initialReplyReaction = '';
                                                                    int currentUserReactionIdForReply;
                                                                    String replyRactType = '';
                                                                    if (commentData.commentList[i].replies[index].reactions != null) {
                                                                      if (commentData.commentList[i].replies[index].reactions.isNotEmpty) {
                                                                        commentData.commentList[i].replies[index].reactions.forEach((element) {
                                                                          reactionIcons.add(element.reaction_type);

                                                                          if (element.user['api_service_id'] == userData.userData.id) {

                                                                            initialReplyReaction = element.reaction_type;
                                                                            currentUserReactionIdForReply = element.id;
                                                                          }
                                                                        });
                                                                      }
                                                                    }

                                                                    // Comment.fromJson(commentData.commentList[i].replies[index]);

                                                                    return GestureDetector(
                                                                      onLongPress: commentData
                                                                          .commentList[i]
                                                                          .replies[index].userId ==
                                                                          userData.userData.id
                                                                          ? () {

                                                                        showCommentsBottomSheet(
                                                                            context: context,
                                                                            onDelete: () async {
                                                                              showAnimatedCustomDialog(
                                                                                  context,
                                                                                  title: deletingComment,
                                                                                  message: areYouSure,
                                                                                  buttonText: delete,
                                                                                  cancelButtonTitle: cancel,
                                                                                  onClicked: () {
                                                                                    setState(() {
                                                                                      isPostingComment=true;
                                                                                    });
                                                                                    Provider.of<NewsProvider>(context, listen: false)
                                                                                        .deleteComment(context: context, postId: passedData["id"],
                                                                                        commentId: commentData.commentList[i].replies[index].id)
                                                                                        .then((_) {
                                                                                      Provider.of<NewsProvider>(context, listen: false)
                                                                                          .fetchCommentsForNewsObject(context,
                                                                                          passedData["id"], pageOffset: 0).then((_) {
                                                                                        setState(() {
                                                                                          isPostingComment=false;
                                                                                        });
                                                                                      });

                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                  });
                                                                            },
                                                                            onEdit: () {
                                                                              // To make sure that we are only editing the reply we are after
                                                                              for (int j = 0; j < commentData.commentList[i].replies.length; j++) {
                                                                                commentData.commentList[i].replies[j].editing = false;
                                                                              }
                                                                              for (int j = 0; j < commentData.commentList.length; j++) {
                                                                                commentData.commentList[j].editing = false;
                                                                                commentData.commentList[j].canReply = false;
                                                                              }
                                                                              setState(() {
                                                                                        editedComment = commentData.commentList[i].replies[index].body;
                                                                                    commentData.commentList[i].replies[index].editing = true;
                                                                                  }
                                                                              );

                                                                            });
                                                                      }
                                                                          : () {},
                                                                      child: replyCard(
                                                                        context,
                                                                        reactionsButton: ReactionButtonToggle<String>(
                                                                          onReactionChanged:
                                                                              (String reaction,bool isChecked) {

                                                                            if(reaction == null){
                                                                              replyRactType = initialReplyReaction == null ? "like" : '';

                                                                            }
                                                                            // else {
                                                                            else if(reaction == "like"){
                                                                              replyRactType = "like";
                                                                            }
                                                                            else if(reaction == "support"){
                                                                              replyRactType = "support";
                                                                            }
                                                                            else if(reaction == "insightful"){
                                                                              replyRactType = "insightful";
                                                                            }
                                                                            else if(reaction == "celeberate"){
                                                                              replyRactType = "celeberate";
                                                                            }

                                                                            if (replyRactType != '') {
                                                                              Provider.of<NewsProvider>(context,listen: false).reactComment(context,postId:passedData["id"],commentId: commentData.commentList[i].replies[index].id,reactionType: replyRactType ).then((_) {
                                                                                // initialCommentReaction = '';
                                                                                // currentUserReactionId=null;
                                                                                Provider.of<NewsProvider>(context,listen: false).fetchCommentsForNewsObject(context,passedData["id"],pageOffset: 0);

                                                                              });
                                                                            }
                                                                            // }
                                                                            if(initialReplyReaction != null && replyRactType == '' ){
                                                                              Provider.of<NewsProvider>(context,listen: false).deleteReactionForComment(
                                                                                  context,
                                                                                  postId:passedData["id"],
                                                                                  commentId: commentData.commentList[i].replies[index].id,
                                                                                  reactionId: currentUserReactionIdForReply
                                                                              ).then((_) {
                                                                                Provider.of<NewsProvider>(context,listen: false).fetchCommentsForNewsObject(context,passedData["id"],pageOffset: 0).then((_) {
                                                                                  currentUserReactionIdForReply=null;
                                                                                  initialReplyReaction = '';
                                                                                });
                                                                              });
                                                                            }
                                                                          },
                                                                          // boxAlignment: Alignment.topCenter,
                                                                          boxPosition: Position.TOP,
                                                                          boxRadius: 8.0,
                                                                          itemScale: 0.3,
                                                                          boxPadding: const EdgeInsets.symmetric(
                                                                              vertical: 8, horizontal: 10),
                                                                          // boxItemsSpacing: 20.0,
                                                                          reactions: <Reaction<String>>[
                                                                            Reaction<String>(
                                                                                previewIcon: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                                                  child: SvgPicture.asset(
                                                                                    'images/like-active.svg',
                                                                                    // color: Colors.grey[900],
                                                                                    width: 22,
                                                                                    height: 22,
                                                                                  ),
                                                                                ),
                                                                                icon: SvgPicture.asset(
                                                                                  'images/like-active.svg',
                                                                                  // color: Colors.grey[900],
                                                                                  width: 22,
                                                                                  height: 22,
                                                                                ),
                                                                                id: 1,
                                                                                value: "like"
                                                                            ),
                                                                            Reaction<String>(
                                                                                previewIcon: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                                                  child: SvgPicture.asset(
                                                                                    'images/support-active.svg',
                                                                                    // color: Colors.grey[900],
                                                                                    width: 22,
                                                                                    height: 22,
                                                                                  ),
                                                                                ),
                                                                                icon: SvgPicture.asset(
                                                                                  'images/support-active.svg',
                                                                                  // color: Colors.grey[900],
                                                                                  width: 22,
                                                                                  height: 22,
                                                                                ),
                                                                                id: 2,
                                                                                value: "support"
                                                                            ),
                                                                            Reaction<String>(
                                                                                previewIcon: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                                                  child: SvgPicture.asset(
                                                                                    'images/insightful-active.svg',
                                                                                    // color: Colors.grey[900],
                                                                                    width: 22,
                                                                                    height: 22,
                                                                                  ),
                                                                                ),
                                                                                icon: SvgPicture.asset(
                                                                                  'images/insightful-active.svg',
                                                                                  // color: Colors.grey[900],
                                                                                  width: 22,
                                                                                  height: 22,
                                                                                ),
                                                                                id: 3,
                                                                                value: "insightful"
                                                                            ),
                                                                            Reaction<String>(
                                                                                previewIcon: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                                                                                  child: SvgPicture.asset(
                                                                                    'images/celeberate-active.svg',
                                                                                    // color: Colors.grey[900],
                                                                                    width: 22,
                                                                                    height: 22,
                                                                                  ),
                                                                                ),
                                                                                icon: SvgPicture.asset(
                                                                                  'images/celeberate-active.svg',
                                                                                  // color: Colors.grey[900],
                                                                                  width: 22,
                                                                                  height: 22,
                                                                                ),
                                                                                id: 4,
                                                                                value:"celeberate"
                                                                            ),
                                                                          ],
                                                                          initialReaction: initialReplyReaction == ''
                                                                              ?
                                                                          Reaction<String>(
                                                                              icon: SvgPicture.asset(
                                                                                'images/like.svg',
                                                                                // color: Colors.grey[900],
                                                                                width: 22,
                                                                                height: 22,
                                                                                color: Colors.grey[700],
                                                                              ),
                                                                              id: 0,

                                                                          )
                                                                              :
                                                                          Reaction<String>(
                                                                            value: initialReplyReaction,
                                                                              icon: SvgPicture.asset(
                                                                                'images/$initialReplyReaction-active.svg',
                                                                                width: 22,
                                                                                height: 22,
                                                                              ),
                                                                              id: initialReplyReaction == "like" ? 1 : initialReplyReaction == "support" ? 2 : initialReplyReaction == 'insightful' ? 3 :initialReplyReaction == "celeberate" ? 4 : 0
                                                                          ),
                                                                          selectedReaction: replyRactType == '' && initialReplyReaction == '' ?  Reaction<String>(
                                                                              icon: SvgPicture.asset(
                                                                                'images/like-active.svg',
                                                                                // color: Colors.grey[900],
                                                                                width: 22,
                                                                                height: 22,
                                                                                // color: Colors.grey[700],
                                                                              ),
                                                                              id: 1,
                                                                              value: "like"
                                                                          )
                                                                              :
                                                                          Reaction<String>(
                                                                              icon: SvgPicture.asset(
                                                                                'images/like.svg',
                                                                                // color: Colors.grey[900],
                                                                                width: 22,
                                                                                height: 22,
                                                                                color: Colors.grey[700],
                                                                              ),
                                                                              id: 0
                                                                          ),
                                                                        ),
                                                                        reactionsCount: commentData.commentList[i].replies[index].reactions != null ? commentData.commentList[i].replies[index].reactions.isNotEmpty ? "${commentData.commentList[i].replies[index].reactions.length}" : "" : "" ,
                                                                        reactions: commentData.commentList[i].replies[index].reactions != null ? commentData.commentList[i].replies[index].reactions.isNotEmpty?
                                                                        InkWell(
                                                                          onTap: (){
                                                                            showReactionsBottomSheet(
                                                                                context: context,
                                                                                tabBarItems: reactionIcons.length+1,
                                                                                content: Container(
                                                                                  height: media.height*0.5,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 30),
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: 30,
                                                                                          child: TabBar(
                                                                                            // indicatorWeight: 20,
                                                                                              isScrollable: true,
                                                                                              // controller: controller,
                                                                                              labelColor: const Color(0xFF808080),
                                                                                              unselectedLabelColor: const Color(0xFF808080),
                                                                                              indicatorSize: TabBarIndicatorSize.label,
                                                                                              indicatorWeight: 0,
                                                                                              indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),
                                                                                              labelPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
                                                                                              indicator: BoxDecoration(
                                                                                                  color: const Color(0xFFEEF6FE),
                                                                                                  // border: Border.all(color: Color(0xFFE2E2E2)),
                                                                                                  borderRadius: BorderRadius.circular(20)
                                                                                              ),
                                                                                              tabs: List.generate(reactionIcons.length+1, (idx) {
                                                                                                Map<String,int> reactionsRepliesCounters={};
                                                                                                reactionIcons.forEach((element) {
                                                                                                  int counter =0;
                                                                                                  for(int j =0; j<commentData.commentList[i].replies[index].reactions.length;j++){
                                                                                                    if(element == commentData.commentList[i].replies[index].reactions[j].reaction_type){
                                                                                                      counter++;
                                                                                                      reactionsRepliesCounters['$element']=counter;

                                                                                                    }
                                                                                                  }

                                                                                                });
                                                                                                return Tab(
                                                                                                  child: Container(
                                                                                                    height: 40,
                                                                                                    // width: index==0 ? null : media.width*0.12,
                                                                                                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                                                                    decoration: BoxDecoration(
                                                                                                        color: Colors.transparent,
                                                                                                        border: Border.all(color: const Color(0xFFE2E2E2)),
                                                                                                        borderRadius: BorderRadius.circular(20)
                                                                                                    ),
                                                                                                    child: Center(child: idx==0 ? Text('All ${commentData.commentList[i].replies[index].reactions.length}')
                                                                                                        :
                                                                                                    Row(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        SvgPicture.asset('images/${reactionIcons.toList()[idx-1]}-active.svg',height: 18,width: 18,),
                                                                                                        const SizedBox(width: 5,),
                                                                                                        Text(commentData.commentList[i].replies[index].reactions != null ? commentData.commentList[i].replies[index].reactions.isNotEmpty ? "${reactionsRepliesCounters['${reactionIcons.toList()[idx-1]}']}": "" : "" ),
                                                                                                      ],
                                                                                                    )
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              })),
                                                                                        ),
                                                                                        const Divider(color: Color(0xFFEEEEEE),),
                                                                                        Expanded(
                                                                                          child:Container(
                                                                                            height: media.height*0.4,
                                                                                            child: TabBarView(
                                                                                              children: List.generate(reactionIcons.length+1, (idxx) {
                                                                                                List<String> reactionsForRepliesFilteredByType=['all'];
                                                                                                reactionIcons.forEach((element) { reactionsForRepliesFilteredByType.add(element);});

                                                                                                return MediaQuery.removePadding(
                                                                                                  context: context,
                                                                                                  removeTop: true,
                                                                                                  child: ListView(
                                                                                                    children: idxx == 0 ? List.generate(commentData.commentList[i].replies[index].reactions.length, (indx) => InkWell(
                                                                                                      onTap: ()async{

                                                                                                        if (userData.userData.id != commentData.commentList[i].replies[index].reactions[indx].user['api_service_id']) {
                                                                                                          // User user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: commentData.commentList[i].replies[index].reactions[indx].user['api_service_id']);
                                                                                                          Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": commentData.commentList[i].replies[index].reactions[indx].user['api_service_id']});
                                                                                                        }
                                                                                                      },
                                                                                                      child: Container(
                                                                                                        width: media.width,
                                                                                                        padding: EdgeInsets.symmetric(horizontal: media.width*0.1),
                                                                                                        child: Column(
                                                                                                          children: [
                                                                                                            Row(
                                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                              children: [
                                                                                                                Row(
                                                                                                                  children: [
                                                                                                                    Container(
                                                                                                                      width: 30,
                                                                                                                      height: 30,
                                                                                                                      decoration: BoxDecoration(
                                                                                                                          shape:BoxShape.circle,
                                                                                                                          image: DecorationImage(
                                                                                                                              image: NetworkImage('${commentData.commentList[i].replies[index].reactions[indx].user['profile_image']}'),
                                                                                                                              fit: BoxFit.cover
                                                                                                                          )
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    const SizedBox(width: 8,),
                                                                                                                    Text(userData.userData.id.toString() == commentData.commentList[i].replies[index].reactions[indx].user['api_service_id'].toString() ? "You" : '${commentData.commentList[i].replies[index].reactions[indx].user['name']}' ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                                SvgPicture.asset("images/${commentData.commentList[i].replies[index].reactions[indx].reaction_type}-active.svg",width: 18,height: 18,)

                                                                                                              ],
                                                                                                            ),
                                                                                                            indx == commentData.commentList[i].replies[index].reactions.length-1 ? const SizedBox() : const Divider(
                                                                                                              color: Color(0xFFEEEEEE),
                                                                                                            )
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                    )
                                                                                                    )
                                                                                                        :
                                                                                                    List.generate(commentData.commentList[i].replies[index].reactions.length, (indx) {
                                                                                                      return commentData.commentList[i].replies[index].reactions[indx].reaction_type == reactionsForRepliesFilteredByType[idxx] ? InkWell(
                                                                                                        onTap: ()async{

                                                                                                          if (userData.userData.id != commentData.commentList[i].replies[index].reactions[indx].user['api_service_id']) {
                                                                                                            // User user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: commentData.commentList[i].replies[index].reactions[indx].user['api_service_id']);
                                                                                                            Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": commentData.commentList[i].replies[index].reactions[indx].user['api_service_id']});
                                                                                                          }
                                                                                                        },
                                                                                                        child: Container(
                                                                                                          width: media.width,
                                                                                                          padding: EdgeInsets.symmetric(horizontal: media.width*0.1),
                                                                                                          child: Column(
                                                                                                            children: [
                                                                                                              Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                children: [
                                                                                                                  Row(
                                                                                                                    children: [
                                                                                                                      Container(
                                                                                                                        width: 30,
                                                                                                                        height: 30,
                                                                                                                        decoration: BoxDecoration(
                                                                                                                            shape:BoxShape.circle,
                                                                                                                            image: DecorationImage(
                                                                                                                                image: NetworkImage('${commentData.commentList[i].replies[index].reactions[indx].user['profile_image']}'),
                                                                                                                                fit: BoxFit.cover
                                                                                                                            )
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      const SizedBox(width: 8,),
                                                                                                                      Text(userData.userData.id.toString() == commentData.commentList[i].replies[index].reactions[indx].user['api_service_id'].toString() ? "You" : '${commentData.commentList[i].replies[index].reactions[indx].user['name']}' ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  SvgPicture.asset("images/${commentData.commentList[i].replies[index].reactions[indx].reaction_type}-active.svg",width: 18,height: 18,)

                                                                                                                ],
                                                                                                              ),
                                                                                                              indx == commentData.commentList[i].replies[index].reactions.length-1 ? const SizedBox() : const Divider(
                                                                                                                color: Color(0xFFEEEEEE),
                                                                                                              )
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ) : const SizedBox();
                                                                                                    }

                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              }),
                                                                                            ),
                                                                                          )
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                            );
                                                                          },
                                                                          child: RowSuper(
                                                                            children: List.generate(reactionIcons.length, (index) {

                                                                              return Material(
                                                                                borderRadius: BorderRadius.circular(100),
                                                                                child: Container(
                                                                                  width: 22,
                                                                                  height: 22,
                                                                                  padding: const EdgeInsets.only(left: 4,right: 4,bottom: 5,top: 3),
                                                                                  child: SvgPicture.asset(
                                                                                    'images/${reactionIcons.toList()[index]}-active.svg',
                                                                                    // color: Colors.grey[900],
                                                                                    width: 20,
                                                                                    height: 20,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                      shape: BoxShape.circle,
                                                                                      color: Colors.white,
                                                                                      border: Border.all(color: Colors.grey[300])
                                                                                  ),
                                                                                ),
                                                                                elevation: 2,
                                                                              );
                                                                            }),
                                                                            outerDistance: 2.0,
                                                                            innerDistance: -8.0,
                                                                            invert: true,
                                                                            alignment: Alignment.center,
                                                                            separator: Container(),
                                                                            separatorOnTop: true,
                                                                            fitHorizontally: true,
                                                                            shrinkLimit: 1.0,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                          ),
                                                                        )
                                                                            :
                                                                        const SizedBox()
                                                                            :
                                                                        const SizedBox(),
                                                                        isSubmittingCommentAlteration: _isSavingEditComment,
                                                                        isMe: commentData.commentList[i].replies[index].user['api_service_id'] == userData.userData.id,
                                                                        commentBody: commentData.commentList[i].replies[index].body,
                                                                        isEditing: commentData.commentList[i].replies[index].editing,
                                                                        onProfilePicClicked: commentData.commentList[i].replies[index].user['api_service_id'] == userData.userData.id
                                                                            ? null : () async {
                                                                          // User user = await commentData.fetchUserById(userId: commentData.commentList[i].user['api_service_id']);
                                                                          Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {
                                                                            "user_id": commentData.commentList[i].user['api_service_id'],
                                                                          });
                                                                        },
                                                                        onSaveEditingComment: editedComment ==
                                                                            null
                                                                            ? () {}
                                                                            : () async {
                                                                          setState(() {
                                                                            _isSavingEditComment = true;
                                                                          });
                                                                          Provider.of<NewsProvider>(context, listen: false).editComment(context: context, postId: passedData["id"], commentId: commentData
                                                                              .commentList[i]
                                                                              .replies[index].id, commentBody: editedComment,isReply: true).then((value) {
                                                                            Provider.of<NewsProvider>(context, listen: false).fetchCommentsForNewsObject(context, passedData["id"], pageOffset: 0).then((_) {
                                                                              setState(() {
                                                                                editedComment = null;
                                                                                _isSavingEditComment = false;
                                                                              });
                                                                            });
                                                                          });
                                                                        },
                                                                        onCancelEditingComment:
                                                                            () {
                                                                              commentData.commentList.forEach((element) {
                                                                                element.canReply = true;
                                                                              });
                                                                          setState(
                                                                                () {
                                                                                  editedComment = null;
                                                                                  commentData.commentList[i].replies[index].editing = false;
                                                                              });
                                                                        },
                                                                        commentEditor:
                                                                        TextFormField(
                                                                          autofocus: true,
                                                                          initialValue: commentData.commentList[i].replies[index].body,
                                                                          textCapitalization: TextCapitalization.sentences,
                                                                          onChanged: (value) {
                                                                            setState(() {
                                                                                  editedComment = value;
                                                                                });
                                                                          },
                                                                          decoration:
                                                                          const InputDecoration(
                                                                            border: InputBorder.none,
                                                                            focusedBorder: InputBorder.none,
                                                                            enabledBorder: InputBorder.none,
                                                                            errorBorder: InputBorder.none,
                                                                            disabledBorder: InputBorder.none,
                                                                          ),
                                                                          cursorColor:
                                                                          Theme.of(context).primaryColor,
                                                                          style: TextStyle(color: Colors.grey[900]),
                                                                        ),
                                                                        commentDate: commentData.commentList[i].replies[index].updatedAt,
                                                                        userProfilePic: commentData.commentList[i].replies[index].user['api_service_id'] == userData.userData.id
                                                                            ?
                                                                        "${userData.userData.profilePic}"
                                                                            :
                                                                        commentData.commentList[i].replies[index].user['api_service_id'] != userData.userData.id && commentData.commentList[i].user['profile_image'] == null
                                                                            ?
                                                                        'https://www.nicepng.com/png/full/556-5566636_helen-romero-person-headshot-silhouette.png'
                                                                            :
                                                                        commentData.commentList[i].replies[index].user['profile_image'],
                                                                        userName: commentData.commentList[i].replies[index].user['api_service_id'] == userData.userData.id
                                                                            ?
                                                                        "${userData.userData.name}"
                                                                            :
                                                                        commentData.commentList[i].replies[index].user['api_service_id'] != userData.userData.id && commentData.commentList[i].user['name'] == null
                                                                            ?
                                                                        'User'
                                                                            :
                                                                        "${commentData.commentList[i].replies[index].user['name']}",
                                                                      ),
                                                                    );
                                                                  }),
                                                                ),
                                                                indicatorBuilder:
                                                                    (context,
                                                                        showRepliesFunction,
                                                                        isOpened) {
                                                                  return isOpened
                                                                      ? Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top: 5,
                                                                              right: isOpened ? 12 : 2),
                                                                          child: Align(
                                                                              alignment: Alignment.centerRight,
                                                                              child: InkWell(
                                                                                  onTap: showRepliesFunction,
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text('hide ${commentData.commentList[i].replies.length > 1 ? "replies" : "reply"}',
                                                                                        style: TextStyle(
                                                                                          color: Theme.of(context).primaryColor,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 3,),
                                                                                      Icon(
                                                                                        Icons.keyboard_arrow_up,
                                                                                        color: Theme.of(context).primaryColor,
                                                                                        size: 16,
                                                                                      )
                                                                                    ],
                                                                                  ))),
                                                                        )
                                                                      : Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              top: 5,
                                                                              right: 2),
                                                                          child: Align(
                                                                              alignment: Alignment.centerRight,
                                                                              child: InkWell(
                                                                                  onTap: showRepliesFunction,
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text('${commentData.commentList[i].replies.length} ${commentData.commentList[i].replies.length > 1 ? "replies" : "reply"}',
                                                                                        style: TextStyle(
                                                                                          color: Theme.of(context).primaryColor,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 3,),
                                                                                      Icon(
                                                                                        Icons.keyboard_arrow_down,
                                                                                        color: Theme.of(context).primaryColor,
                                                                                        size: 16,
                                                                                      )
                                                                                    ],
                                                                                  ))),
                                                                        );
                                                                },
                                                              ),

                                                    ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
              commentToBeReplied == null
                  ? Container()
                  : Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 65.0,
                      child: Stack(
                        children: [
                          Container(
                            height: 80.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: const Offset(0, -4,), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: media.width,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.black12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: media.width - 120,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(commentToBeReplied.user['id'].toString() == userData.userData.id.toString()
                                                  ?
                                            "You"
                                                  :
                                            commentToBeReplied.user['name'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            const SizedBox(
                                              height: 4.0,
                                            ),
                                            Text(
                                              '${commentToBeReplied.body}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 15,
                            right: 15,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    commentToBeReplied = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.cancel,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              editedComment == null ? Positioned(
                right: 0,
                left: 0,
                bottom: 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isPostingComment ? Container(
                        height:5,
                        margin: const EdgeInsets.all(0),
                        child: LinearProgressIndicator(
                          backgroundColor: const Color(0xFFebf5fe),
                          color: Theme.of(context).primaryColor,
                          minHeight: 2,
                        ),
                      ) : const SizedBox(),
                      Container(
                        width: media.width,
                        height: 65.0,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    const Offset(0, 3), // changes position of shadow
                              ),
                            ], color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 5),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(80.0),
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(80.0),
                                    ),
                                    child: userData.userData == null
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2.0),
                                            child: Image.asset(
                                              "images/person.png",
                                              fit: BoxFit.contain,
                                              color: Colors.grey[400],
                                            ),
                                          )
                                        : Image.network(
                                            userData.userData.profilePic,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  height: 55,
                                  alignment: Alignment.topCenter,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: TextFormField(
                                      controller: commentEditingController,
                                      focusNode: commentFieldNode,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      maxLines: null,
                                      minLines: null,
                                      style: TextStyle(
                                          fontSize: media.width * 0.045),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          setState(() {
                                            _isCommentTextFieldEmpty = true;
                                          });
                                        } else {
                                          setState(() {
                                            _isCommentTextFieldEmpty = false;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Say something about this',
                                          contentPadding: const EdgeInsets.only(bottom: 15),
                                          hintStyle: TextStyle(
                                              fontSize: media.width * 0.035,
                                              fontFamily: 'Net',
                                              height: 3.5)),
                                    ),
                                  ),
                                ),
                              ),
                              // Button send message
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () async {
                                    if (commentToBeReplied == null) {
                                      if (commentEditingController
                                              .text.isNotEmpty &&
                                          _isCommentTextFieldEmpty == false) {
                                        setState(() {
                                          isPostingComment=true;
                                        });
                                         Provider.of<NewsProvider>(context, listen: false).postComment(
                                            context,
                                            passedData["id"],
                                            commentEditingController.text,
                                            membershipsIds: userData.userData.memberships,
                                                hospitalsIds:
                                                    userData.userData.hospitals,
                                                trustId: userData
                                                    .userData.trust['id']);
                                        _onRefresh();
                                        setState(() {
                                          commentEditingController.text = "";
                                          _isCommentTextFieldEmpty = true;

                                        });
                                        debugPrint('isPostingComment $isPostingComment');

                                      }
                                    } else {
                                      if (commentEditingController
                                              .text.isNotEmpty &&
                                          _isCommentTextFieldEmpty == false) {
                                        setState(() {
                                          isPostingComment=true;
                                        });
                                         Provider.of<NewsProvider>(context,
                                                listen: false)
                                            .postComment(
                                                context,
                                                passedData["id"],
                                                commentEditingController.text,
                                                membershipsIds: userData
                                                    .userData.memberships,
                                                hospitalsIds:
                                                    userData.userData.hospitals,
                                                trustId: userData
                                                    .userData.trust['id'],
                                                isReply: true,
                                                parent_id:
                                                    commentToBeReplied.id)
                                            .then((_) {
                                          setState(() {
                                            commentToBeReplied = null;
                                          });
                                        });
                                        _onRefresh();
                                        setState(() {
                                          commentEditingController.text = "";
                                          _isCommentTextFieldEmpty = true;
                                        });
                                      }
                                    }
                                  },
                                  color: _isCommentTextFieldEmpty
                                      ? Colors.grey
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ) : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

}
