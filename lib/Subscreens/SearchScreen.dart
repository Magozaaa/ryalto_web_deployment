// ignore_for_file: file_names, prefer_final_fields

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'NewsFeed/NewsDetails.dart';


TextEditingController _searchController = TextEditingController();

class SearchScreen extends StatefulWidget {
  static const String routeName = "/Search_Screen";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Map passedData = {};
  var _isInit = true;
  int pageOffset = 0;
  var userTrustId;
  // bool _isLoadingSearchResult= false;
  FocusNode _focus = new FocusNode();
  int searchCharactersLength = 0;


  @override
  void initState() {
    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
    // _focus.addListener(_onFocusChange);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      _search();
    });

    super.initState();
  }


  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    pageOffset = 0;
    await Future.delayed(const Duration(milliseconds: 1000));
    Provider.of<NewsProvider>(context, listen: false).clearSearchNews();
    await Provider.of<NewsProvider>(context, listen: false).fetchNewsForSearch(
        context,
        pageOffset: 0,
        trustId: userTrustId,
        title: _searchController.text);
    _refreshController.refreshCompleted();
  }



  _search()async{
    if(_focus.hasFocus && searchCharactersLength != _searchController.text.length){
      if (_searchController.text.length >= 3) {

        await Provider.of<
            NewsProvider>(
            context,
            listen: false)
            .clearSearchNews();
        Provider.of<
            NewsProvider>(
            context,
            listen: false)
            .fetchNewsForSearch(
            context,
            pageOffset: 0,
            trustId:
            userTrustId,
            title: _searchController.text).then((_) {
          searchCharactersLength = _searchController.text.length;
        });
      }
    }

  }

  @override
  void dispose() {
    _searchController.dispose();
    _focus.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final newsData = Provider.of<NewsProvider>(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        onHorizontalDragEnd: (DragEndDetails details){
          if (!kIsWeb) {
            if (Platform.isIOS) {
              if (details.primaryVelocity.compareTo(0) == 1) {
                Navigator.pop(context);
              }
            }
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context)),
              title: Text(
                      "search",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold),
                    ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: textFieldBorderRadius
                    ),
                    child: TextFormField(
                      controller: _searchController,
                      focusNode: _focus,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context)
                                .primaryColor,
                          ),
                          contentPadding: EdgeInsets.only(bottom: 0.0, left: 15.0, right: 15.0,top: 6),
                          border: InputBorder.none,
                          hintText: "Search",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'DIN')),
                    ),
                  ),
                ),
              ),
            ),
            body:/* _isLoadingSearchResult*/
            newsData.searchNewsStage == NewsStage.LOADING ?
            Container(
              height: media.height,
              child: Center(
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 40.0,
                ),
              ),
            )
                :
            newsData.searchNewsStage == NewsStage.ERROR
                ?
            Container(
              height: media.height,
              child: Center(
                child: InkWell(
                  onTap: (){
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
                :
            newsData.searchNews.isEmpty && newsData.searchNewsStage == null
                ?
            const SizedBox()
                :

            newsData.searchNewsStage == NewsStage.DONE && newsData.searchNews.isEmpty
                ?
            Container(
                height: media.height*0.7,
                child:Center(child: Text('No articles to show !'))
            )
                :

            newsData.searchNewsStage == NewsStage.DONE && newsData.searchNews.isNotEmpty
                ?
            SearchResultList()
                :
            const SizedBox()),
      ),
    );
  }
}


class SearchResultList extends StatefulWidget {
  @override
  _SearchResultListState createState() => _SearchResultListState();
}

class _SearchResultListState extends State<SearchResultList> {
  List isSelected = [];
  Map passedData = {};
  var _isInit = true;
  int pageOffset = 0;
  var userTrustId;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  void _onRefresh() async {
    pageOffset = 0;
    await Future.delayed(Duration(milliseconds: 1000));
    Provider.of<NewsProvider>(context, listen: false).clearSearchNews();
    await Provider.of<NewsProvider>(context, listen: false).fetchNewsForSearch(
        context,
        pageOffset: 0,
        trustId: userTrustId,
        title: _searchController.text);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    pageOffset += 10;
    await Future.delayed(Duration(milliseconds: 1000));
    await Provider.of<NewsProvider>(context, listen: false).fetchNewsForSearch(
        context,
        pageOffset: pageOffset,
        trustId: userTrustId,
        title: _searchController.text);
    if (mounted) {
      setState(() {});
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userTrustId = Provider.of<UserProvider>(context, listen: false).userData.trust["id"];
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final newsData = Provider.of<NewsProvider>(context);
    return Container(
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
              body =
                  CupertinoActivityIndicator();
            } else if (mode ==
                LoadStatus.failed) {
              body = Text(
                  "Load Failed!Click retry!");
            } else if (mode ==
                LoadStatus.canLoading) {
            } else {
              body = Text("No more to load!");
            }
            return Center(child: body);
            //return Container();
          },
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: List.generate(newsData.searchNews.length, (i) => i == 0
              ? leadingNews(context,
            isNewArticle: newsData.searchNews[i].isNewArticle,
            isSharable: newsData.searchNews[i].restricted_sharing == null ? true : newsData.searchNews[i].restricted_sharing ? false : true,
            reactionsCount: newsData.searchNews[i].reactions.isEmpty ? "":newsData.searchNews[i].reactions.length,
            title: newsData
                .searchNews[i].title,
            id: newsData
                .searchNews[i].id,
            commentsCount: newsData
                .searchNews[i]
                .commentCount,
            published: newsData
                .searchNews[i]
                .published,
            description: newsData
                .searchNews[i]
                .description,
            largeThumbnail: newsData
                .searchNews[i]
                .largeThumbnail,
            favourite: newsData
                .searchNews[i].favorite,
            url: newsData
                .searchNews[i].url,
            thumbnail: newsData
                .searchNews[i]
                .thumbnail,
            onFavouriteClicked:
                () async {
              if (newsData.searchNews[i]
                  .favorite ==
                  false) {
                setState(() {
                  newsData.searchNews[i]
                      .favorite = true;
                });
                await Provider.of<
                    NewsProvider>(
                    context,
                    listen: false)
                    .addToFavourites(
                    context,
                    newsData
                        .searchNews[
                    i]
                        .id
                        .toString(),
                    isFromNewsDetails:
                    true);
              } else {
                setState(() {
                  newsData.searchNews[i]
                      .favorite = false;
                });
                await Provider.of<
                    NewsProvider>(
                    context,
                    listen: false)
                    .removeFromFavourites(
                    context,
                    newsData
                        .searchNews[
                    i]
                        .id
                        .toString(),
                    isFromFavTab:
                    true);
              }
            },)
              : Padding(
            padding: i ==
                newsData.searchNews
                    .length -
                    1
                ? EdgeInsets.only(
                bottom: 30.0)
                : const EdgeInsets.only(
                bottom: 0.0),
            child: newsCard(
              context,
              isNewArticle: newsData.searchNews[i].isNewArticle,
              reactionsCount: newsData.searchNews[i].reactions.length,
              screenMedia: media,
              description: newsData
                  .searchNews[i].description,
              title: newsData
                  .searchNews[i].title,
              id: newsData
                  .searchNews[i].id,
              commentsCount: newsData
                  .searchNews[i]
                  .commentCount,
              published: newsData
                  .searchNews[i]
                  .published,
              largeThumbnail: newsData
                  .searchNews[i]
                  .largeThumbnail,
              favourite: newsData
                  .searchNews[i]
                  .favorite,
              url: newsData
                  .searchNews[i].url,
              thumbnail: newsData
                  .searchNews[i]
                  .thumbnail,
              isSharable: newsData.searchNews[i].restricted_sharing == null ? true : newsData.searchNews[i].restricted_sharing ? false : true,
              onFavouriteClicked:
                  () async {
                if (newsData
                    .searchNews[i]
                    .favorite ==
                    false) {
                  setState(() {
                    newsData
                        .searchNews[i]
                        .favorite = true;
                  });
                  await Provider.of<
                      NewsProvider>(
                      context,
                      listen: false)
                      .addToFavourites(
                      context,
                      newsData
                          .searchNews[
                      i]
                          .id
                          .toString(),
                      isFromNewsDetails:
                      true);
                } else {
                  setState(() {
                    newsData
                        .searchNews[i]
                        .favorite = false;
                  });
                  await Provider.of<
                      NewsProvider>(
                      context,
                      listen: false)
                      .removeFromFavourites(
                      context,
                      newsData
                          .searchNews[
                      i]
                          .id
                          .toString(),
                      isFromFavTab:
                      true);
                }
              },
              /*onClicked: ()=> Navigator.pushNamed(context, NewsDetails.routeName)*/
            ),
          )),
          // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          // shrinkWrap: true,
          // itemCount:
          // newsData.searchNews.length,
          // itemBuilder: (context, i) => i == 0
          //     ? leadingNews(context,
          //   isSharable: newsData.searchNews[i].restricted_sharing == null ? true : newsData.searchNews[i].restricted_sharing ? false : true,
          //   reactionsCount: newsData.searchNews[i].reactions.isEmpty ? "":newsData.searchNews[i].reactions.length,
          //   title: newsData
          //       .searchNews[i].title,
          //   id: newsData
          //       .searchNews[i].id,
          //   commentsCount: newsData
          //       .searchNews[i]
          //       .commentCount,
          //   published: newsData
          //       .searchNews[i]
          //       .published,
          //   description: newsData
          //       .searchNews[i]
          //       .description,
          //   largeThumbnail: newsData
          //       .searchNews[i]
          //       .largeThumbnail,
          //   favourite: newsData
          //       .searchNews[i].favorite,
          //   url: newsData
          //       .searchNews[i].url,
          //   thumbnail: newsData
          //       .searchNews[i]
          //       .thumbnail,
          //   onFavouriteClicked:
          //       () async {
          //     if (newsData.searchNews[i]
          //         .favorite ==
          //         false) {
          //       setState(() {
          //         newsData.searchNews[i]
          //             .favorite = true;
          //       });
          //       await Provider.of<
          //           NewsProvider>(
          //           context,
          //           listen: false)
          //           .addToFavourites(
          //           context,
          //           newsData
          //               .searchNews[
          //           i]
          //               .id
          //               .toString(),
          //           isFromNewsDetails:
          //           true);
          //     } else {
          //       setState(() {
          //         newsData.searchNews[i]
          //             .favorite = false;
          //       });
          //       await Provider.of<
          //           NewsProvider>(
          //           context,
          //           listen: false)
          //           .removeFromFavourites(
          //           context,
          //           newsData
          //               .searchNews[
          //           i]
          //               .id
          //               .toString(),
          //           isFromFavTab:
          //           true);
          //     }
          //   },)
          //     : Padding(
          //   padding: i ==
          //       newsData.searchNews
          //           .length -
          //           1
          //       ? EdgeInsets.only(
          //       bottom: 30.0)
          //       : const EdgeInsets.only(
          //       bottom: 0.0),
          //   child: newsCard(
          //     context,
          //     reactionsCount: newsData.searchNews[i].reactions.length,
          //     screenMedia: media,
          //     title: newsData
          //         .searchNews[i].title,
          //     id: newsData
          //         .searchNews[i].id,
          //     commentsCount: newsData
          //         .searchNews[i]
          //         .commentCount,
          //     published: newsData
          //         .searchNews[i]
          //         .published,
          //     largeThumbnail: newsData
          //         .searchNews[i]
          //         .largeThumbnail,
          //     favourite: newsData
          //         .searchNews[i]
          //         .favorite,
          //     url: newsData
          //         .searchNews[i].url,
          //     thumbnail: newsData
          //         .searchNews[i]
          //         .thumbnail,
          //     isSharable: newsData.searchNews[i].restricted_sharing == null ? true : newsData.searchNews[i].restricted_sharing ? false : true,
          //     onFavouriteClicked:
          //         () async {
          //       if (newsData
          //           .searchNews[i]
          //           .favorite ==
          //           false) {
          //         setState(() {
          //           newsData
          //               .searchNews[i]
          //               .favorite = true;
          //         });
          //         await Provider.of<
          //             NewsProvider>(
          //             context,
          //             listen: false)
          //             .addToFavourites(
          //             context,
          //             newsData
          //                 .searchNews[
          //             i]
          //                 .id
          //                 .toString(),
          //             isFromNewsDetails:
          //             true);
          //       } else {
          //         setState(() {
          //           newsData
          //               .searchNews[i]
          //               .favorite = false;
          //         });
          //         await Provider.of<
          //             NewsProvider>(
          //             context,
          //             listen: false)
          //             .removeFromFavourites(
          //             context,
          //             newsData
          //                 .searchNews[
          //             i]
          //                 .id
          //                 .toString(),
          //             isFromFavTab:
          //             true);
          //       }
          //     },
          //     /*onClicked: ()=> Navigator.pushNamed(context, NewsDetails.routeName)*/
          //   ),
          // ),
        ),
      ),
    );
  }
}

