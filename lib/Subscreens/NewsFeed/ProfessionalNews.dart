// ignore_for_file: file_names, prefer_typing_uninitialized_variables

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


class ProfessionalNews extends StatefulWidget{
  const ProfessionalNews({Key key}) : super(key: key);


  @override
  _ProfessionalNewsState createState() => _ProfessionalNewsState();
}

class _ProfessionalNewsState extends State<ProfessionalNews> {

  int pageOffset=0;
  var userTrustId;
  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = Container();
  bool _isLoadingFocusedNews = true;
  List<News> proNewsData=[];
  @override
  void initState() {
    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    if (Provider.of<NewsProvider>(context, listen: false).proNews.isEmpty) {
      Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: pageOffset, trustId: userTrustId).then((_) {
        if (mounted) {
          proNewsData = Provider.of<NewsProvider>(context, listen: false).proNews;
        }
        setState(() {
          _isLoadingFocusedNews = false;
        });
      });
    }
    else{
      _isLoadingFocusedNews = false;
      proNewsData = Provider.of<NewsProvider>(context, listen: false).proNews;
    }
    AnalyticsManager.track('screen_news_professional');

    super.initState();
  }

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async{
    // Provider.of<NewsProvider>(context, listen: false).clearUnreadNewsNotificationCount();
    // Provider.of<NewsProvider>(context, listen: false).clearUnreadMyOrganisationNewsNotificationCount();
    Provider.of<NewsProvider>(context, listen: false).clearUnreadFocusedNewsNotificationCount();
    pageOffset = 0;
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<NewsProvider>(context,listen: false).clearProNews();
    await Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: pageOffset, trustId: userTrustId).then((_){
      setState(() {
        _isLoadingFocusedNews = false;
      });
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
   setState(() {
     lastItemBottomPadding = 8.0;
     bottomGapToShowLoadingMoreStatus = const SizedBox(height: 60.0,);
   });
    await Future.delayed(const Duration(milliseconds: 1000));
    pageOffset +=10;
    await Provider.of<NewsProvider>(context,listen: false).fetchProfessionalNews(context,pageOffset: pageOffset, trustId: userTrustId);
    if(mounted){
      setState(() {
        lastItemBottomPadding = 55.0;
        bottomGapToShowLoadingMoreStatus = const SizedBox();
      });
      _refreshController.loadComplete();
    }
  }



  @override
  Widget build(BuildContext context) {

  final media = MediaQuery.of(context).size;
  final userData = Provider.of<UserProvider>(context);

  return
    Column(
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
                  body = const CupertinoActivityIndicator();
                }
                else if(mode == LoadStatus.failed){
                  body = Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Center(
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            _isLoadingFocusedNews = true;
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
                  );
                }
                else if(mode == LoadStatus.canLoading){
                }
                else{
                  body = const Padding(
                    padding: EdgeInsets.only(bottom: 60.0),
                    child: Text("No more to load!"),
                  );
                }
                return Center(child: body);
                //return Container();
              },
            ),
            child:
            _isLoadingFocusedNews
                ?
            Center(
              child: SpinKitCircle(
                color: Theme.of(context).primaryColor,
                size: 45.0,
              ),
            )
                :
            proNewsData.isEmpty && Provider.of<NewsProvider>(context).proNewsStage == NewsStage.DONE
                ?
            emptyNewsFeed(context, media,isVerified: userData.userData.verified)
                :
            userData.userData.verified == false
                ?
            emptyNewsFeed(context, media,isVerified: userData.userData.verified)
                :
            Provider.of<NewsProvider>(context).proNewsStage == NewsStage.ERROR
                ?
            Center(
              child: InkWell(
                onTap: (){
                  setState(() {
                    _isLoadingFocusedNews = true;
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
              shrinkWrap: true,
              itemCount: proNewsData.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, i) =>
              i == 0 ? leadingNews(context,
                isNewArticle: proNewsData[i].isNewArticle,
                isSharable: proNewsData[i].restricted_sharing == null ? true : proNewsData[i].restricted_sharing == true ? false : true,
                reactionsCount: proNewsData[i].reactions.isEmpty ? "" :proNewsData[i].reactions.length ,
                  title: proNewsData[i].title, id: proNewsData[i].id,
                  commentsCount: proNewsData[i].commentCount, published: proNewsData[i].published,
                  description: proNewsData[i].description, largeThumbnail: proNewsData[i].largeThumbnail,
                  favourite: proNewsData[i].favorite, url: proNewsData[i].url, thumbnail: proNewsData[i].thumbnail,
                  onFavouriteClicked: ()async{
                    if(proNewsData[i].favorite == false){
                      setState(() {
                        proNewsData[i].favorite = true;
                      });
                      await Provider.of<NewsProvider>(context,listen: false).addToFavourites(context, proNewsData[i].id.toString());
                    }else{
                      setState(() {
                        proNewsData[i].favorite = false;
                      });
                      await Provider.of<NewsProvider>(context,listen: false).removeFromFavourites(context, proNewsData[i].id.toString());
                    }
                  },
              ) : Padding(
                padding: i == proNewsData.length - 1 ? EdgeInsets.only(bottom:lastItemBottomPadding): const EdgeInsets.only(bottom:0.0),
                child: newsCard(
                  context,
                  isNewArticle: proNewsData[i].isNewArticle,
                  reactionsCount: proNewsData[i].reactions.length,
                  screenMedia: media,
                  title: proNewsData[i].title,
                  description: proNewsData[i].description,
                  id: proNewsData[i].id,
                    commentsCount: proNewsData[i].commentCount,
                  published: proNewsData[i].published,
                    largeThumbnail: proNewsData[i].largeThumbnail,
                  isSharable: proNewsData[i].restricted_sharing == null ? true : proNewsData[i].restricted_sharing == true ? false : true,
                  favourite: proNewsData[i].favorite, url: proNewsData[i].url, thumbnail: proNewsData[i].thumbnail,
                    onFavouriteClicked: ()async{
                      if(proNewsData[i].favorite == false){
                        setState(() {
                          proNewsData[i].favorite = true;
                        });
                        await Provider.of<NewsProvider>(context,listen: false).addToFavourites(context, proNewsData[i].id.toString());
                      }else{
                        setState(() {
                          proNewsData[i].favorite = false;
                        });
                        await Provider.of<NewsProvider>(context,listen: false).removeFromFavourites(context, proNewsData[i].id.toString());
                      }
                    },
                    /*onClicked: ()=> Navigator.pushNamed(context, NewsDetails.routeName)*/ ),
              ),
            ),
          ),
        ),
       bottomGapToShowLoadingMoreStatus
      ],
    );
  }
}