// ignore_for_file: file_names, avoid_function_literals_in_foreach_calls, unnecessary_string_interpolations, missing_required_param, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inAppWebView;
import 'CommentScreen.dart';

class NewsDetails extends StatefulWidget{

  static const routeName = "/News_Details";

  const NewsDetails({Key key}) : super(key: key);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {

  var _isInit = true;
  Map passedData = {};
  // WebViewController _controller;
  Widget loader;
  String reactType = '';
  String initialCommentReaction = '';
  int reactionId;
  bool _isGetPostByIdLoading = true;
  Set<String> commentsReactionIcons={};

  inAppWebView.InAppWebViewController webView;
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  bool _permissionReady = false;
  String _localPath;
  bool isDocumentDownloadLinkClickedFromIOS = false;
  int progress = 0;
  ReceivePort receiverPort = ReceivePort();

  @override
  void initState() {
    loader = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            child: const SpinKitWave(
              color: Colors.blue,
              size: 35.0,
            ),
          ),
        ],
      ),
    );
    if (!kIsWeb) {
      if (Platform.isAndroid){
        WebView.platform = SurfaceAndroidWebView();
          _checkPermission();
        }
    }

    IsolateNameServer.registerPortWithName(receiverPort.sendPort, 'DownloadingFile');

    receiverPort.listen((message) {
      if (mounted) {
        setState(() {
          progress = message;
        });
      }
    });
    FlutterDownloader.registerCallback(downloadCallBack);

    super.initState();

  }

  @override
  void didChangeDependencies() {
    if(_isInit){
      passedData = ModalRoute.of(context).settings.arguments;
      _isInit = false;
      Provider.of<NewsProvider>(context, listen: false).newsDetailsStage = NewsStage.LOADING;
      Provider.of<NewsProvider>(context, listen: false).getNewsPostById(
          context,
          postId: passedData['id']).then((_){
        _isGetPostByIdLoading= false;
        if (Provider.of<NewsProvider>(context,listen: false).newsPost != null) {
          Provider.of<NewsProvider>(context,listen: false).newsPost.reactions.forEach((element) {
            commentsReactionIcons.add(element.reaction_type);

            if(element.user['api_service_id'] == Provider.of<UserProvider>(context,listen: false).userData.id){
              initialCommentReaction = element.reaction_type;
              reactionId = element.id;
            }
          });
        }
        setStartReadingTime(DateTime.now());
        AnalyticsManager.track(
            'news_article_view',
            parameters: {
              "article_id": "${Provider.of<NewsProvider>(context,listen: false).newsPost.id}",
              "article_name": "${Provider.of<NewsProvider>(context,listen: false).newsPost.title}"
            });

      });


    }
    super.didChangeDependencies();
  }


  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }


  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }


  static downloadCallBack(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName("DownloadingFile");
    sendPort.send(progress);
  }

  Future<bool> _checkPermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid && androidInfo.version.sdkInt <= 28) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          _permissionReady = true;
          return true;
        }
      } else {
        _permissionReady = true;
        return true;
      }
    } else {
      _permissionReady = true;
      return true;
    }
    return false;
  }

  void _downloadFile(url, {String fileName}) async {
    showSnack(
        millSeconds: 1200,
        context: context,
        bottomMargin: 15,
        // backgroundColor: Colors.white,
        content: SizedBox(
          height: 55.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  const <Widget>[
              SpinKitCircle(
                color: Colors.white,
                size: 20.0,
              ),

              const SizedBox(width: 8.0,),

              Flexible(child: Text("Downloading to your device’s Files app", maxLines: 2,)),
            ],
          ),
        ),
        fullHeight: 55.0,
        isFloating: true,
        scaffKey: _scaffoldKey
    );

    if(Platform.isIOS){
      final status = await Permission.storage.request();
      if(status.isGranted){
        setState(() {
          _permissionReady = true;
        });
      }
    }
    if (_permissionReady) {
      _prepareSaveDir().then((_){
        debugPrint("hey this is the Dir to save the file $_localPath");
        FlutterDownloader.enqueue(
            url: '$url',
            savedDir: _localPath,
            showNotification: true,
            openFileFromNotification: true,
            saveInPublicStorage: true,//baseStorage.path,
            // saveInPublicStorage: false,
            requiresStorageNotLow: true,
            fileName: "${fileName}"
        ).then((value){
          debugPrint('value for download is !  ${value}');
        });
      });
    } else {
      debugPrint('no permission');
    }
  }

  DateTime _startReadingTime;

  // int

  setStartReadingTime(time){
    _startReadingTime = time;
  }

  void measuringArticleReadingTime(){
    if(_startReadingTime!=null){
      // print(DateTime.now().difference(_startReadingTime).inSeconds);
      AnalyticsManager.track(
          'news_article_read',
          parameters: {
            "article_id": "${Provider.of<NewsProvider>(context,listen: false).newsPost.id}",
            "article_name": "${Provider.of<NewsProvider>(context,listen: false).newsPost.title}",
            "reading_time": DateTime.now().difference(_startReadingTime).inSeconds
          });
    }
  }

  @override
  Widget build(BuildContext context) {


    final media = MediaQuery.of(context).size;
    final newsData = Provider.of<NewsProvider>(context);


    return WillPopScope(
      onWillPop: () {
        measuringArticleReadingTime();
        Navigator.pop(context);
        newsData.setNewsPost(null);
        return Future.value(false);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: screenAppBar(context, media, showLeadingPop: true, hideProfilePic: true,
            isFavoured: /*passedData["isArticleFavourite"]*/ newsData.newsPost != null ? newsData.newsPost.favorite : false,
            appbarTitle: Image.asset("images/img_logo.webp", height: 30.0,),
            centerTitle: true,
            downloadDocAction: newsData.newsPost != null && newsData.newsPost.documentUrl != null ? (){
              _downloadFile(newsData.newsPost.documentUrl, fileName: "${newsData.newsPost.title}_document.pdf");
            }:null,
            onBackPressed: (){
              measuringArticleReadingTime();
              newsData.setNewsPost(null);
              Navigator.pop(context);
              // Navigator.of(context).popUntil(ModalRoute.withName(NavigationHome.routName));
            }
        ),

        body: newsData.newsDetailsStage == NewsStage.LOADING
            ?
        SizedBox(height: media.height*0.9,child: Center(child: SpinKitWave(color: Theme.of(context).primaryColor,size: 35,),),)
            :
        newsData.newsDetailsStage == NewsStage.DONE && newsData.newsPost != null
            ?
        Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 60,),
              child:
              inAppWebView.InAppWebView(
                initialUrl: newsData.newsPost.url,
                initialOptions: inAppWebView.InAppWebViewGroupOptions(
                  crossPlatform: inAppWebView.InAppWebViewOptions(
                      useOnDownloadStart: true
                  ),
                ),
                onWebViewCreated: (inAppWebView.InAppWebViewController controller) {
                  webView = controller;
                },
                onLoadStart: (inAppWebView.InAppWebViewController controller, String url) {
                      controller.evaluateJavascript(source: "window.document.getElementsByTagName('header')[0].style.display='none';");
                      controller.evaluateJavascript(source: "window.document.getElementsByTagName('footer')[0].style.display='none';");
                      controller.evaluateJavascript(source: "window.document.getElementsByTagName('hr')[0].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[0].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[1].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[2].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[3].style.display='none';");
                },
                onLoadStop: (inAppWebView.InAppWebViewController controller, String url) {
                      controller.evaluateJavascript(source: "window.document.getElementsByTagName('header')[0].style.display='none';");
                      controller.evaluateJavascript(source: "window.document.getElementsByTagName('footer')[0].style.display='none';");
                      controller.evaluateJavascript(source: "window.document.getElementsByTagName('hr')[0].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[0].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[1].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[2].style.display='none';");
                      controller.evaluateJavascript(source: " document.getElementsByClassName('social-icon-element')[3].style.display='none';");
                },
                onProgressChanged: (inAppWebView.InAppWebViewController controller, int progress) {
                    if(progress < 100){
                      setState(() {
                        loader = Center(
                          child: Container(
                            color: Colors.white,
                            height: media.height,
                            child: SpinKitWave(
                              color: Theme.of(context).primaryColor,
                              size: 35.0,
                            ),
                          ),
                        );
                      });
                    }else{
                      setState(() {
                        loader = const SizedBox();
                      });
                    }
                  },

                // onDownloadStart: (controller, url) async {
                //   // this condition is to make sure i will pass the right document url to the download method
                //   // as an article can include multiple links for other stuff !!
                //   if(url == newsData.newsPost.documentUrl){
                //     // if(Platform.isAndroid){
                //       _downloadFile(url, fileName: "${newsData.newsPost.title}_document.pdf");
                //     // }else if(Platform.isIOS){
                //     //   if (await canLaunch(url)) {
                //     //     await launch(url,
                //     //       forceSafariVC: true,
                //     //       forceWebView: true,
                //     //       enableJavaScript: true,
                //     //     );
                //     //   }
                //     // }
                //   }
                // },
              )
              // WebView(
              //
              //   initialUrl: newsData.newsPost.url,
              //   javascriptMode: JavascriptMode.unrestricted,
              //   onWebViewCreated: (controller) {
              //     _controller = controller;
              //   },
              //   onPageStarted: (_){
              //     _controller.evaluateJavascript("window.document.getElementsByTagName('header')[0].style.display='none';");
              //     _controller.evaluateJavascript("window.document.getElementsByTagName('footer')[0].style.display='none';");
              //     _controller.evaluateJavascript("window.document.getElementsByTagName('hr')[0].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[0].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[1].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[2].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[3].style.display='none';");
              //     //social-icon-element
              //   },
              //   gestureNavigationEnabled: true,
              //   onPageFinished: (_) {
              //     _controller.evaluateJavascript("window.document.getElementsByTagName('header')[0].style.display='none';");
              //     _controller.evaluateJavascript("window.document.getElementsByTagName('footer')[0].style.display='none';");
              //     _controller.evaluateJavascript("window.document.getElementsByTagName('hr')[0].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[0].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[1].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[2].style.display='none';");
              //     _controller.evaluateJavascript(" document.getElementsByClassName('social-icon-element')[3].style.display='none';");
              //     },
              //   onProgress: (int progress) {
              //     if(progress < 100){
              //       setState(() {
              //         loader = Center(
              //           child: Container(
              //             color: Colors.white,
              //             height: media.height,
              //             child: SpinKitWave(
              //               color: Theme.of(context).primaryColor,
              //               size: 35.0,
              //             ),
              //           ),
              //         );
              //       });
              //     }else{
              //       setState(() {
              //         loader = const SizedBox();
              //       });
              //     }
              //   },
              // ),
            ),

            loader,

            _isGetPostByIdLoading
                ?
            const SizedBox()
                :
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  // height: 80.0,
                  padding: const EdgeInsets.only(bottom: 30, left: 20.0, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,top: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(padding: const EdgeInsets.only(top: 5),
                                  child: Text(newsData.newsPost.reactions.isEmpty ? "":'${newsData.newsPost.reactions.length}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600],fontSize: 14),),
                                ),
                                const SizedBox(width: 3,),
                                newsData.newsPost.reactions != null
                                    ?
                                newsData.newsPost.reactions.isNotEmpty
                                    ?
                                InkWell(
                                  onTap: (){
                                    showReactionsBottomSheet(
                                        context: context,
                                        tabBarItems: commentsReactionIcons.length+1,
                                        content: SizedBox(
                                          height: media.height*0.5,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 30),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: media.width,
                                                  alignment: Alignment.center,
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
                                                          border: Border.all(color: const Color(0xFFEEF6FE)),
                                                          borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      tabs: List.generate(commentsReactionIcons.length+1, (index) {

                                                        Map<String,int> reactionsCounters={};
                                                        commentsReactionIcons.forEach((element) {
                                                          int counter =0;
                                                          for(int j =0; j<newsData.newsPost.reactions.length;j++){
                                                            if(element == newsData.newsPost.reactions[j].reaction_type){
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
                                                            child: Center(child: index==0 ? Text('All ${newsData.newsPost.reactions.length}')
                                                                :
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                SvgPicture.asset('images/${commentsReactionIcons.toList()[index-1]}-active.svg',height: 18,width: 18,),
                                                                const SizedBox(width: 5,),
                                                                Text(newsData.newsPost.reactions != null ? newsData.newsPost.reactions.isNotEmpty ? "${reactionsCounters['${commentsReactionIcons.toList()[index-1]}'] > 99 ? '+99' : reactionsCounters['${commentsReactionIcons.toList()[index-1]}']}": "" : "" ),
                                                              ],
                                                            )
                                                            ),
                                                          ),
                                                        );
                                                      })),
                                                ),
                                                const Divider(color: Color(0xFFEEEEEE),),
                                                Expanded(
                                                    child:SizedBox(
                                                        height: media.height*0.4,
                                                        child: TabBarView(
                                                          children: List.generate(commentsReactionIcons.length+1, (idxx) {
                                                            List<String> reactionsForCommentsFilteredByType=['all'];
                                                            commentsReactionIcons.forEach((element) { reactionsForCommentsFilteredByType.add(element);});
                                                            return MediaQuery.removePadding(
                                                                context: context,
                                                                removeTop: true,
                                                                child: ListView(
                                                                  children: idxx == 0 ? List.generate(newsData.newsPost.reactions.length, (indx) {
                                                                    return InkWell(
                                                                      onTap: ()async{
                                                                        if (Provider.of<UserProvider>(context,listen: false).userData.id != newsData.newsPost.reactions[indx].user['api_service_id']) {
                                                                          // User user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: newsData.organisationNewsPost.reactions[indx].user['api_service_id']);
                                                                          Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": newsData.newsPost.reactions[indx].user['api_service_id']});
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
                                                                                              image: NetworkImage('${newsData.newsPost.reactions[indx].user['profile_image']}'),
                                                                                              fit: BoxFit.cover
                                                                                          )
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 8,),
                                                                                    Text(Provider.of<UserProvider>(context,listen: false).userData.id.toString() == newsData.newsPost.reactions[indx].user['api_service_id'].toString() ? "You" : '${newsData.newsPost.reactions[indx].user['name']}'),
                                                                                  ],
                                                                                ),
                                                                                SvgPicture.asset("images/${newsData.newsPost.reactions[indx].reaction_type}-active.svg",width: 18,height: 18,)

                                                                              ],
                                                                            ),
                                                                            indx == newsData.newsPost.reactions.length-1 ? const SizedBox() : const Divider(
                                                                              color: Color(0xFFEEEEEE),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  ) : List.generate(newsData.newsPost.reactions.length, (indx) {


                                                                    return newsData.newsPost.reactions[indx].reaction_type == reactionsForCommentsFilteredByType[idxx] ? InkWell(
                                                                      onTap: ()async{

                                                                        if (Provider.of<UserProvider>(context,listen: false).userData.id != newsData.newsPost.reactions[indx].user['api_service_id']) {
                                                                          // User user = await Provider.of<NewsProvider>(context, listen: false).fetchUserById(userId: newsData.organisationNewsPost.reactions[indx].user['api_service_id']);
                                                                          Navigator.pushNamed(context, OtherUserProfile.routName, arguments: {"user_id": newsData.newsPost.reactions[indx].user['api_service_id']});
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
                                                                                              image: NetworkImage('${newsData.newsPost.reactions[indx].user['profile_image']}'),
                                                                                              fit: BoxFit.cover
                                                                                          )
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 8,),
                                                                                    Text(Provider.of<UserProvider>(context,listen: false).userData.id.toString() == newsData.newsPost.reactions[indx].user['api_service_id'].toString() ? "You" : '${newsData.newsPost.reactions[indx].user['name']}'),
                                                                                  ],
                                                                                ),
                                                                                SvgPicture.asset("images/${newsData.newsPost.reactions[indx].reaction_type}-active.svg",width: 18,height: 18,)

                                                                              ],
                                                                            ),
                                                                            indx == newsData.newsPost.reactions.length-1 ? const SizedBox() : const Divider(
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
                                          width: 28,
                                          height: 28,
                                          padding: const EdgeInsets.only(left: 4,right: 4,bottom: 5,top: 3),
                                          child: SvgPicture.asset(
                                            'images/${commentsReactionIcons.toList()[index]}-active.svg',
                                            width: 25,
                                            height: 25,
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
                              ],
                            ),
                            newsData.newsPost.commentCount == null || newsData.newsPost.commentCount == 0
                                ?
                            Text('No comments yet',style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),)
                                :
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, CommentScreen.routeName, arguments: {
                                "id":newsData.newsPost.id
                              }),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Container(
                                      padding: const EdgeInsets.only(top:2.0),
                                      child: Stack(
                                        children: [
                                          SvgPicture.asset("images/comment.svg", height: 20.0, color: Colors.grey[600],),
                                          newsData.newsPost.commentCount == null || newsData.newsPost.commentCount == 0
                                              ?
                                          const SizedBox()
                                              :
                                          Positioned(top: 2,bottom: 4,right: 2,left: 2,child: Center(child: Text(newsData.newsPost.commentCount > 99 ? "99+":'${newsData.newsPost.commentCount}',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.grey[600]),))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text('Comments',style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFFA9A9A9),),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          Padding(
                            padding: newsData.newsPost.restricted_sharing == true ?
                            const EdgeInsets.only(bottom: 4.0, right: 25.0, left: 25.0):  const EdgeInsets.only(bottom: 4),
                            child: ReactionButtonToggle<String>(
                              onReactionChanged:
                                  (String reaction, bool isChecked) {
                                if(reaction == null){
                                  reactType = reactionId == null ? "like" : '';
                                }
                                if(reactionId!=null && reactType == ''){
                                  Provider.of<NewsProvider>(context,listen: false).deleteReactionForPost(context,postId:/*passedData["id"]*/newsData.newsPost.id,reactionId: reactionId ).then((_) {
                                    Provider.of<NewsProvider>(context,listen: false).getNewsPostById(context,postId: /*passedData["id"]*/newsData.newsPost.id).then((_) {
                                      commentsReactionIcons.remove(initialCommentReaction);
                                      initialCommentReaction = '';
                                      reactionId=null;
                                      Provider.of<NewsProvider>(context,listen: false).newsPost.reactions.forEach((element) {
                                        commentsReactionIcons.add(element.reaction_type);

                                      });
                                      // Provider.of<NewsProvider>(context,listen: false).clearOrgNews();
                                      // Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(context, pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userTrustId, hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);

                                    });
                                  });
                                }
                                else {

                                  if(reaction == "like"){
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
                                  commentsReactionIcons.remove(initialCommentReaction);
                                  Provider.of<NewsProvider>(context,listen: false).reactPost(context,postId:/*passedData["id"]*/newsData.newsPost.id,reactionType: reactType ).then((_) {
                                    Provider.of<NewsProvider>(context,listen: false).getNewsPostById(context,postId: /*passedData["id"]*/newsData.newsPost.id).then((_) {
                                      Provider.of<NewsProvider>(context,listen: false).newsPost.reactions.forEach((element) {
                                        // commentsReactionIcons.remove(initialCommentReaction);
                                        if(element.user['api_service_id'] == Provider.of<UserProvider>(context,listen: false).userData.id){
                                          initialCommentReaction = element.reaction_type;
                                          reactionId=element.id;

                                        }
                                        commentsReactionIcons.add(element.reaction_type);

                                      });
                                      // Provider.of<NewsProvider>(context,listen: false).clearOrgNews();
                                      // Provider.of<NewsProvider>(context, listen: false).fetchOrganisationNews(context, pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userTrustId, hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds);

                                    });
                                  });
                                }
                              },
                              // boxAlignment: Alignment.topCenter,
                              boxPosition: Position.TOP,
                              boxRadius: 25.0,
                                itemScale:0.5,
                              boxPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 25),
                              // boxItemsSpacing: 20.0,
                              reactions: <Reaction<String>>[
                                Reaction<String>(
                                  value: "like",
                                    previewIcon: Padding(
                                      padding: const EdgeInsets.only(bottom: 2,right: 8,),
                                      child: SvgPicture.asset(
                                        'images/like-active.svg',
                                        // color: Colors.grey[900],
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    icon: SvgPicture.asset(
                                      'images/like-active.svg',
                                      // color: Colors.grey[900],
                                      width: 28,
                                      height: 28,
                                    ),
                                    id: 1
                                ),
                                Reaction<String>(
                                  value: "support",
                                    previewIcon: Padding(
                                      padding: const EdgeInsets.only(right: 8,),
                                      child: SvgPicture.asset(
                                        'images/support-active.svg',
                                        // color: Colors.grey[900],
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    icon: SvgPicture.asset(
                                      'images/support-active.svg',
                                      // color: Colors.grey[900],
                                      width: 28,
                                      height: 28,
                                    ),
                                    id: 2
                                ),
                                Reaction<String>(
                                  value: "insightful",
                                    previewIcon: Padding(
                                      padding: const EdgeInsets.only(right: 8,),
                                      child: SvgPicture.asset(
                                        'images/insightful-active.svg',
                                        // color: Colors.grey[900],
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    icon: SvgPicture.asset(
                                      'images/insightful-active.svg',
                                      // color: Colors.grey[900],
                                      width: 28,
                                      height: 28,
                                    ),
                                    id: 3
                                ),
                                Reaction<String>(
                                  value: "celeberate",
                                    previewIcon: Padding(
                                      padding: const EdgeInsets.only(right: 3,),
                                      child: SvgPicture.asset(
                                        'images/celeberate-active.svg',
                                        // color: Colors.grey[900],
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    icon: SvgPicture.asset(
                                      'images/celeberate-active.svg',
                                      // color: Colors.grey[900],
                                      width: 28,
                                      height: 28,
                                    ),
                                    id: 4
                                ),
                              ],
                              initialReaction: initialCommentReaction == ''
                                  ?
                              Reaction<String>(
                                // value: "like",
                                  icon: SvgPicture.asset(
                                    'images/like.svg',
                                    // color: Colors.grey[900],
                                    width: 28,
                                    height: 28,
                                    color: Colors.grey[800],
                                  ),
                                  id: 0
                              )
                                  :
                              Reaction<String>(
                                value: initialCommentReaction,
                                  icon: SvgPicture.asset(
                                    'images/${initialCommentReaction}-active.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                  id: initialCommentReaction == "like" ? 1 : initialCommentReaction == "support" ? 2 : initialCommentReaction == 'insightful' ? 3 :initialCommentReaction == "celeberate" ? 4 : 0
                              ),
                              selectedReaction: reactType != '' ?  Reaction(
                                  icon: SvgPicture.asset(
                                    'images/like.svg',
                                    // color: Colors.grey[900],
                                    width: 28,
                                    height: 28,
                                    color: Colors.grey[800],
                                  ),
                                  id: 0
                              )
                                  :
                              initialCommentReaction != ''
                                  ?
                              Reaction(
                                  icon: SvgPicture.asset(
                                    'images/like.svg',
                                    // color: Colors.grey[900],
                                    width: 28,
                                    height: 28,
                                    color: Colors.grey[800],
                                  ),
                                  id: 0
                              )
                                  :
                              Reaction(
                                value: "like",
                                  icon: SvgPicture.asset(
                                    'images/like-active.svg',
                                    // color: Colors.grey[900],
                                    width: 28,
                                    height: 28,
                                    // color: Colors.grey[800],
                                  ),
                                  id: 0
                              ),
                            ),
                          ),
                          newsData.newsPost.restricted_sharing == true
                              ?
                              const Spacer(flex: 1,) : const SizedBox(),
                          Padding(
                            padding: newsData.newsPost.restricted_sharing == true ?
                            const EdgeInsets.symmetric(horizontal: 15.0):  const EdgeInsets.symmetric(horizontal: 0.0),
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(context, CommentScreen.routeName, arguments: {
                                "id":/*passedData["id"]*/newsData.newsPost.id
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Container(
                                  padding: const EdgeInsets.only(top:2.0),
                                  child: Stack(
                                    children: [
                                      SvgPicture.asset("images/comment.svg", height: 25.0, color: Colors.grey[900],),
                                      newsData.newsPost.commentCount == null || newsData.newsPost.commentCount == 0
                                          ?
                                      const SizedBox()
                                          :
                                      Positioned(top: 2,bottom: 4,right: 2,left: 2,child: Center(child: Text(newsData.newsPost.commentCount > 99 ? "99+":'${newsData.newsPost.commentCount}',style: const TextStyle(fontSize: 10,fontWeight: FontWeight.bold),))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          newsData.newsPost.restricted_sharing == true
                              ?
                          const Spacer(flex: 1,) : const SizedBox(),
                          Padding(
                            padding: newsData.newsPost.restricted_sharing == true ?
                            const EdgeInsets.symmetric(horizontal: 12.0):  const EdgeInsets.symmetric(horizontal: 0.0),
                            child: InkWell(
                              onTap: ()async{
                                if(newsData.newsPost.favorite == false){
                                  setState(() {
                                    newsData.newsPost.favorite = true;
                                  });
                                  await Provider.of<NewsProvider>(context,listen: false).addToFavourites(context, newsData.newsPost.id, isFromNewsDetails: true);
                                }else{
                                  setState(() {
                                    newsData.newsPost.favorite = false;
                                  });
                                  await Provider.of<NewsProvider>(context,listen: false).removeFromFavourites(context, newsData.newsPost.id, isFromFavTab: true);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(newsData.newsPost.favorite ? "images/starFill.png" : "images/star.png", height: 25.0, color: newsData.newsPost.favorite ? const Color(0xFFff9c01) :Colors.grey[900],),
                              ),
                            ),
                          ),
                          newsData.newsPost.restricted_sharing == true
                              ?
                          const SizedBox()
                              :
                          InkWell(
                            onTap: (){
                              showSelectSharePicker(
                                  context,
                                  url:newsData.newsPost.url,
                                  thumbnail: newsData.newsPost.largeThumbnail??newsData.newsPost.thumbnail,
                                  articleTitle: newsData.newsPost.title,
                                  isFavourite: newsData.newsPost.favorite,
                                  id: newsData.newsPost.id,
                                  commentsCount: newsData.newsPost.commentCount,
                                  title: newsData.newsPost.title
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: SvgPicture.asset("images/share.svg", height: 25.0, color: Colors.grey[900],),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
          ],
        )
            :
        SizedBox(
          height: media.height * 0.8,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/notFound.png",height: 200,width: 200,color: Colors.grey[500],),
                const SizedBox(height: 20,),
                const Text('Article not found!',style: TextStyle(fontSize: 16,),)
              ],
            ),
          ),
        ),

      ),
    );
  }
}