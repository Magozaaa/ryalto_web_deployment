// ignore_for_file: file_names

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

import 'NewsDetails.dart';

class FavouriteNews extends StatefulWidget{
  const FavouriteNews({Key key}) : super(key: key);


  @override
  _FavouriteNewsState createState() => _FavouriteNewsState();
}

class _FavouriteNewsState extends State<FavouriteNews> {
  int pageOffset=0;
  var lastItemBottomPadding = 55.0;
  Widget bottomGapToShowLoadingMoreStatus = const SizedBox();
  bool _isLoadingFavouriteNews = true;
  List<News> favouriteNewsData=[];

  @override
  void initState() {
    Provider.of<NewsProvider>(context, listen: false).fetchFavouriteNews(context, pageOffset: 0, isFromFavouriteScreen: true).then((_) {
      if (mounted) {
        favouriteNewsData = Provider.of<NewsProvider>(context, listen: false).favouriteNews;
      }
      setState(() {
        _isLoadingFavouriteNews = false;
      });
    });
    AnalyticsManager.track('screen_news_favourites');

    super.initState();
  }



  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async{
    pageOffset = 0;
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<NewsProvider>(context,listen: false).clearFavouriteNews();
    await Provider.of<NewsProvider>(context,listen: false).fetchFavouriteNews(context,pageOffset: pageOffset).then((_){
      setState(() {
        _isLoadingFavouriteNews = false;
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
    await Provider.of<NewsProvider>(context,listen: false).fetchFavouriteNews(context,pageOffset: pageOffset);
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
    // final favouriteNewsData = Provider.of<NewsProvider>(context);
    final userData = Provider.of<UserProvider>(context);

    return _isLoadingFavouriteNews
      // favouriteNewsData.favNewsStage == NewsStage.LOADING
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
    emptyFavourites(context, media,isVerified: false)
        :
    favouriteNewsData.isEmpty && Provider.of<NewsProvider>(context).favNewsStage == NewsStage.DONE
        ?
    emptyFavourites(context, media,isVerified: true)
        :
    Provider.of<NewsProvider>(context).favNewsStage == NewsStage.ERROR
        ?
    Center(
      child: InkWell(
        onTap: (){
          setState(() {
            _isLoadingFavouriteNews = true;
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
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: favouriteNewsData.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, i) =>
              i == 0 ? leadingNews(context,
                isNewArticle: favouriteNewsData[i].isNewArticle,
                isSharable: favouriteNewsData[i].restricted_sharing == null ? true : favouriteNewsData[i].restricted_sharing == true ? false : true,
                  reactionsCount: favouriteNewsData[i].reactions.isEmpty ? "" : favouriteNewsData[i].reactions.length,
                  title: favouriteNewsData[i].title, id: favouriteNewsData[i].id,
                  commentsCount: favouriteNewsData[i].commentCount,
                published: favouriteNewsData[i].published,
                  description: favouriteNewsData[i].description, largeThumbnail: favouriteNewsData[i].largeThumbnail,
                  onFavouriteClicked: ()async{
                    setState(() {
                      favouriteNewsData[i].favorite = false;
                    });
                    await Provider.of<NewsProvider>(context,listen: false).removeFromFavourites(context,
                        favouriteNewsData[i].id.toString(), isFromFavTab: true);
                  },
                  favourite: favouriteNewsData[i].favorite, url: favouriteNewsData[i].url, thumbnail: favouriteNewsData[i].thumbnail,
              ) : Padding(
                padding: i == favouriteNewsData.length - 1 ? EdgeInsets.only(bottom:lastItemBottomPadding): const EdgeInsets.only(bottom:0.0),
                child: newsCard(
                  context,
                  isNewArticle: favouriteNewsData[i].isNewArticle,
                  isSharable: favouriteNewsData[i].restricted_sharing==null ? true : favouriteNewsData[i].restricted_sharing == true ? false : true ,
                  reactionsCount: favouriteNewsData[i].reactions.length,
                  screenMedia: media,
                  title: favouriteNewsData[i].title,
                  description: favouriteNewsData[i].description,
                  id: favouriteNewsData[i].id,
                    commentsCount: favouriteNewsData[i].commentCount,
                  published: favouriteNewsData[i].published,
                    largeThumbnail: favouriteNewsData[i].largeThumbnail,
                    onFavouriteClicked: ()async{
                      setState(() {
                        favouriteNewsData[i].favorite = false;
                      });
                      await Provider.of<NewsProvider>(context,listen: false).removeFromFavourites(context,
                          favouriteNewsData[i].id.toString(), isFromFavTab: true);
                    },
                    favourite: favouriteNewsData[i].favorite, url: favouriteNewsData[i].url, thumbnail: favouriteNewsData[i].thumbnail,
                    /*onClicked: ()=> Navigator.pushNamed(context, NewsDetails.routeName) */
                ),
              ),
            ),
          ),
        ),
        bottomGapToShowLoadingMoreStatus
      ],
    );
  }
}