// ignore_for_file: must_be_immutable, file_names, prefer_typing_uninitialized_variables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/NewsModel.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:rightnurse/main.dart';



class MyOrgNewsFeed extends StatefulWidget{
  const MyOrgNewsFeed({Key key}) : super(key: key);



  @override
  _MyOrgNewsFeedState createState() => _MyOrgNewsFeedState();
}

class _MyOrgNewsFeedState extends State<MyOrgNewsFeed> {

  int pageOffset=0;
  var userTrustId;
  var userHospitalsIds;
  var userMembershipsIds;
  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = Container();
  bool _isLoadingMyOrganisationNews = true;

  List<News> orgNewsData=[];
  @override
  void initState() {
    // userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    userHospitalsIds = Provider.of<UserProvider>(context, listen: false).hospitalIds;
    userMembershipsIds = Provider.of<UserProvider>(context, listen: false).membershipIds;
    userTrustId = Provider.of<UserProvider>(context, listen: false).userTrustId;

    // if(Provider.of<NewsProvider>(context,listen: false).orgNews.isNotEmpty)
    // Provider.of<NewsProvider>(context,listen: false).clearOrgNews();
    // _isLoadingMyOrganisation = false;
    if (Provider.of<NewsProvider>(context, listen: false).orgNews.isEmpty) {
      Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(context, pageOffset: 0,trustId: userTrustId, hospitalsIds: userHospitalsIds, membershipsIds: userMembershipsIds).then((_) {
        if (mounted) {
          orgNewsData = Provider.of<NewsProvider>(context, listen: false).orgNews;
          setState(() {
            _isLoadingMyOrganisationNews = false;
          });
        }

      });
    }
    else{
      _isLoadingMyOrganisationNews = false;
      orgNewsData = Provider.of<NewsProvider>(context, listen: false).orgNews;
    }
    AnalyticsManager.track('screen_news_organisation');

    super.initState();
  }

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async{
    // Provider.of<NewsProvider>(context, listen: false).clearUnreadNewsNotificationCount();
    Provider.of<NewsProvider>(context, listen: false).clearUnreadMyOrganisationNewsNotificationCount();
    // Provider.of<NewsProvider>(context, listen: false).clearUnreadFocusedNewsNotificationCount();
    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    pageOffset = 0;
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<NewsProvider>(context,listen: false).clearOrgNews();
    await Provider.of<NewsProvider>(context,listen: false).fetchOrganisationNews(context,pageOffset: pageOffset,trustId: userTrustId, hospitalsIds: userHospitalsIds, membershipsIds: userMembershipsIds).then((_) {
      setState(() {
        _isLoadingMyOrganisationNews = false;
      });
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    setState(() {
      lastItemBottomPadding = 8.0;
      bottomGapToShowLoadingMoreStatus = const SizedBox(height: 60.0,);
    });
    pageOffset +=10;
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<NewsProvider>(context,listen: false).fetchOrganisationNews(context,pageOffset: pageOffset,trustId: userTrustId, hospitalsIds: userHospitalsIds, membershipsIds: userMembershipsIds);
    if(mounted){
        setState(() {
          lastItemBottomPadding = 25.0;
          bottomGapToShowLoadingMoreStatus = Container(height: 35.0,);
        });
        _refreshController.loadComplete();
      }
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    // final orgNewsData = Provider.of<NewsProvider>(context);
    final userData = Provider.of<UserProvider>(context);

   return
     MyApp.userLoggedIn ? userData.userData == null ? Container(color: Colors.white,) : Column(
     children: [
       Expanded(
         child: SmartRefresher(
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
           child: _isLoadingMyOrganisationNews
               ?
           Center(
             child: SpinKitCircle(
               color: Theme.of(context).primaryColor,
               size: 45.0,
             ),
           )
               :
           userData.userData.verified == false
               ?
           emptyNewsFeed(context, media,isVerified: userData.userData.verified)
               :
           orgNewsData.isEmpty && Provider.of<NewsProvider>(context).newsPostStage == NewsStage.DONE
               ?
           emptyNewsFeed(context, media,isVerified: userData.userData.verified)
               :
           Provider.of<NewsProvider>(context).newsPostStage == NewsStage.ERROR
               ?
           Center(
             child: InkWell(
               onTap: (){
                 setState(() {
                   _isLoadingMyOrganisationNews = true;
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
           )
               :
           ListView.builder(
             physics: const BouncingScrollPhysics(),
             shrinkWrap: true,
             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
             itemCount: orgNewsData.length,
             itemBuilder: (context, i) =>
             i == 0
                 ?
             leadingNews(
                 context,
                 title: orgNewsData[i].title,
                 documentUrl: orgNewsData[i].documentUrl,
                 isNewArticle: orgNewsData[i].isNewArticle,
                 id: orgNewsData[i].id,
                 reactionsCount: orgNewsData[i].reactions.isEmpty ? "" : orgNewsData[i].reactions.length,
                 commentsCount: orgNewsData[i].commentCount,
                 published: orgNewsData[i].published,
                 description: orgNewsData[i].description,
                 largeThumbnail: orgNewsData[i].largeThumbnail,
                 favourite: orgNewsData[i].favorite,
                 url: orgNewsData[i].url,
                 thumbnail: orgNewsData[i].thumbnail,
               isSharable: orgNewsData[i].restricted_sharing == null ? true : orgNewsData[i].restricted_sharing == true ? false : true,
                 onFavouriteClicked: ()async{
                   if(orgNewsData[i].favorite == false){
                     setState(() {
                       orgNewsData[i].favorite = true;
                     });
                     await Provider.of<NewsProvider>(context,listen: false).addToFavourites(context, orgNewsData[i].id.toString());
                   }else{
                     setState(() {
                       orgNewsData[i].favorite = false;
                     });
                     await Provider.of<NewsProvider>(context,listen: false).removeFromFavourites(context, orgNewsData[i].id.toString());
                   }
                 },
                 // onClicked: (){
                 //   Navigator.pushNamed(context, NewsDetails.routeName,arguments: {"url": orgNewsData[i].url, " isArticleFavourite": orgNewsData[i].favorite, "id": orgNewsData[i].id,'commentsCount':orgNewsData[i].commentCount});
                 // }
             ) : Padding(
               padding: i == orgNewsData.length - 1 ? EdgeInsets.only(bottom:lastItemBottomPadding): const EdgeInsets.only(bottom:0.0),
               child: newsCard(
                 context,
                 documentUrl: orgNewsData[i].documentUrl,
                 isNewArticle: orgNewsData[i].isNewArticle,
                 description: orgNewsData[i].description,
                 reactionsCount: orgNewsData[i].reactions.length,
                 screenMedia: media,
                 title: orgNewsData[i].title,
                 id: orgNewsData[i].id,
                   commentsCount: orgNewsData[i].commentCount,
                 published: orgNewsData[i].published,
                   largeThumbnail: orgNewsData[i].largeThumbnail,
                   favourite: orgNewsData[i].favorite,
                 url: orgNewsData[i].url,
                 thumbnail: orgNewsData[i].thumbnail,
                 isSharable: orgNewsData[i].restricted_sharing == null ? true : orgNewsData[i].restricted_sharing == true ? false : true,
                 onFavouriteClicked: ()async{
                     if(orgNewsData[i].favorite == false){
                       setState(() {
                         orgNewsData[i].favorite = true;
                       });
                       await Provider.of<NewsProvider>(context,listen: false).addToFavourites(context, orgNewsData[i].id.toString());
                     }else{
                       setState(() {
                         orgNewsData[i].favorite = false;
                       });
                       await Provider.of<NewsProvider>(context,listen: false).removeFromFavourites(context, orgNewsData[i].id.toString());
                     }
                   },
                   /*onClicked: ()=> Navigator.pushNamed(context, NewsDetails.routeName)*/ ),
             ),
           ),
         ),
       ),
       bottomGapToShowLoadingMoreStatus
     ],
   ) : const SizedBox();
  }
}