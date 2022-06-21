// ignore_for_file: file_names, unnecessary_this, constant_identifier_names, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Models/CommentModel.dart';
import 'package:rightnurse/Models/NewsModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Widgets/commonWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import '../main.dart';

enum NewsStage { ERROR, LOADING, DONE }

class NewsProvider extends ChangeNotifier {
  NewsStage newsPostStage;
  NewsStage proNewsStage;
  NewsStage favNewsStage;
  NewsStage searchNewsStage;
  NewsStage commentsStage;
  NewsStage getUserStage;
  NewsStage newsDetailsStage;
  Map<String,dynamic> lastPublishedTimeForNews={};


  Map<String,int> newsCounters={
    'orgNewsCounter' : 0,
    'focusedNewsCounter' : 0,
  };

  final String errorMessage = "Network Error !";

  News _newsPost;
  News get newsPost=>this._newsPost;
  List<News> _orgNews = [];
  List<News> _proNews = [];
  List<News> _favouriteNews = [];
  List<News> _searchMews = [];
  List<Comment> _commentsList = [];

  List<News> get orgNews => this._orgNews;
  List<News> get proNews => this._proNews;
  List<News> get favouriteNews => this._favouriteNews;
  List<News> get searchNews => this._searchMews;
  List<Comment> get commentList => this._commentsList;


// handle All News counter
  int _newsNotificationCount = 0;
  int get newsNotificationCount => this._newsNotificationCount;


  String _whenOrgNewsTabLastChecked;
  String _whenFocusedNewsTabLastChecked;


  clearUnreadNewsNotificationCount() async{
    _whenFocusedNewsTabLastChecked = DateTime.now().toString();
    _whenOrgNewsTabLastChecked = DateTime.now().toString();
    newsCounters['orgNewsCounter'] = 0;
    newsCounters['focusedNewsCounter'] = 0;
    _newsNotificationCount = 0;
    notifyListeners();
  }


  clearUnreadMyOrganisationNewsNotificationCount() async{
    _whenOrgNewsTabLastChecked = DateTime.now().toString();
    _newsNotificationCount = _newsNotificationCount - newsCounters['orgNewsCounter'];
    newsCounters['orgNewsCounter'] = 0;
    notifyListeners();
  }


  clearUnreadFocusedNewsNotificationCount() async{
    _whenFocusedNewsTabLastChecked = DateTime.now().toString();
    _newsNotificationCount = _newsNotificationCount - newsCounters['focusedNewsCounter'];
    newsCounters['focusedNewsCounter'] = 0;
    notifyListeners();
  }


  // set
  setComments(List<Comment> comments){
    _commentsList = comments;
  }

  setNewsPost(News post){
    _newsPost = post;
  }

  clearOrgNews(){
    _orgNews.clear();
    newsCounters['orgNewsCounter'] = 0;
    notifyListeners();
  }

  clearProNews(){
    _proNews.clear();
    newsCounters['focusedNewsCounter'] = 0;
    notifyListeners();
  }

  clearFavouriteNews(){
    _favouriteNews.clear();
    notifyListeners();
  }

  clearSearchNews(){
    _searchMews.clear();
    notifyListeners();
  }



  Future fetchOrganisationNews(BuildContext context,{pageOffset, trustId, hospitalsIds, membershipsIds}) async{
    this.newsPostStage = NewsStage.LOADING;

    var featuredResponseString;
    var responseString;

    if(pageOffset == null){
      pageOffset = 0;
    }

    try{
      final prefs = await SharedPreferences.getInstance();
      final storedUser = prefs.getString("user");
      /// when user logs out the following line cases a problem ******
      String token = jsonDecode(storedUser)['token'];
      final url = '$appNewsUrl/api/posts?limit=10&offset=${pageOffset??0}&'
          'trust_only=true&trust_id=$trustId&without_trust=false&$hospitalsIds&filter=trust_id%3A$trustId$membershipsIds';
      print("tokentoken ${MyApp.platformIndex}");

      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=2',
        'Content-Type': 'application/json',
        'Authorization': 'Token token=$token'
      };

      //https://news-feed-staging.right-nurse.com/api/posts?limit=10&offset=0&trust_only=true&
      //trust_id=3351f9eb-d7b4-4327-9473-84157e4f58c7&
      //hospitals%5B%5D=d7b7ef1b-fbcf-43e7-ae20-2bd6a92e5098&hospitals%5B%5D=07f592dd-5c09-496e-8be4-8f104e30364e&hospitals%5B%5D=df8dec18-588d-4b92-b3da-469804d877ff&hospitals%5B%5D=9350751c-45e1-4827-b3c9-d4a3f146804d&
      // without_trust=false&
      // filter=trust_id%3A3351f9eb-d7b4-4327-9473-84157e4f58c7%7Cmembership_id%3A4ff689d3-b1e5-4857-b674-942b77ccdc1b%7Cmembership_id%3A853428c1-8091-4013-8155-17891b1e0de3%7Cmembership_id%3A6786713c-e216-485e-b1ec-46a30fff64f0

      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);


      http.Response featuredResponse;



      String responseString;



      List<dynamic> featuredNewsResponse;

      if(pageOffset == 0){
        var request = http.MultipartRequest('GET', Uri.parse('$appNewsUrl/api/posts?featured_posts=true&'
            'trust_only=true&trust_id=$trustId&without_trust=false&$hospitalsIds&filter=trust_id%3A$trustId$membershipsIds'));
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        featuredResponseString = await response.stream.bytesToString();

        // featuredResponse = await httpp.get('$appNewsUrl/api/posts?featured_posts=true&'
        //     'trust_only=true&trust_id=$trustId&without_trust=false&$hospitalsIds&filter=trust_id%3A$trustId$membershipsIds', headers: headers);

        // featuredResponseString = featuredResponse.body;
        print("newsResponsezzzzz ${featuredNewsResponse}");
        if (featuredNewsResponse!=null) {
          featuredNewsResponse = json.decode(featuredResponseString);
        }

      }

      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      // http.Response response = await httpp.get('$appNewsUrl/api/posts?limit=10&offset=${pageOffset??0}&'
      //     'trust_only=true&trust_id=$trustId&without_trust=false&$hospitalsIds&filter=trust_id%3A$trustId$membershipsIds', headers: headers);

      // responseString = response.body;



      List<dynamic> newsResponse = json.decode(responseString);



      // debugPrint("hello !!!!!!! response of fetured news with length ${featuredNewsResponse.length} $featuredResponseString");
      // debugPrint("hello !!!!!!! response of normal news with length ${newsResponse.length} $responseString");

      if (response.statusCode == 200) {
        if(pageOffset == 0){
          _orgNews.clear();
          _newsNotificationCount = _newsNotificationCount - newsCounters['orgNewsCounter'];
          newsCounters['orgNewsCounter'] = 0;
        }
        if ( pageOffset!=null && pageOffset>0 && newsResponse.isNotEmpty){
          AnalyticsManager.track('news_list_scroll');
        }

        if (featuredNewsResponse != null && featuredResponse.statusCode == 200) {
          featuredNewsResponse.forEach((element) {
            final News newsObject = News.fromJson(element);
            newsObject.url = "${newsObject.url}?user_id=${Provider.of<UserProvider>(context, listen: false).userData.id}";
            _orgNews.add(newsObject);

            if(DateTime.parse(newsObject.published).millisecondsSinceEpoch > DateTime.parse(_whenOrgNewsTabLastChecked??prefs.getString("whenAppWentToBackground")??DateTime.now().toString()).millisecondsSinceEpoch){
              newsCounters['orgNewsCounter']++;
              _newsNotificationCount++;
            }
          });
        }

        newsResponse.forEach((element) {
          final News newsObject = News.fromJson(element);
          newsObject.url = "${newsObject.url}?user_id=${Provider.of<UserProvider>(context, listen: false).userData.id}";
          _orgNews.add(newsObject);

          if(DateTime.parse(newsObject.published).millisecondsSinceEpoch > DateTime.parse(_whenOrgNewsTabLastChecked??prefs.getString("whenAppWentToBackground")??DateTime.now().toString()).millisecondsSinceEpoch){
            newsCounters['orgNewsCounter']++;
            _newsNotificationCount++;
          }
        });

      } else {
        debugPrint(response.reasonPhrase);
      }
      this.newsPostStage = NewsStage.DONE;
      print("this.newsPostStage ${this.newsPostStage}");

    }catch(e){
      this.newsPostStage = NewsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  // Future fetchFeaturedOrganisationNews(BuildContext context,{trustId, hospitalsIds, membershipsIds}) async{
  //   this.newsPostStage = NewsStage.LOADING;
  //
  //   var responseString;
  //
  //   try{
  //     final prefs = await SharedPreferences.getInstance();
  //     final storedUser = prefs.getString("user");
  //     /// when user logs out the following line cases a problem ******
  //     String token = jsonDecode(storedUser)['token'];
  //
  //     var headers = {
  //       'Platform': MyApp.platformIndex,
  //       'Right-Nurse-Version': Domain.appVersion,
  //       'Accept': 'application/vnd.right_nurse; version=2',
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Token token=$token'
  //     };
  //
  //     //https://news-feed-staging.right-nurse.com/api/posts?limit=10&offset=0&trust_only=true&
  //     //trust_id=3351f9eb-d7b4-4327-9473-84157e4f58c7&
  //     //hospitals%5B%5D=d7b7ef1b-fbcf-43e7-ae20-2bd6a92e5098&hospitals%5B%5D=07f592dd-5c09-496e-8be4-8f104e30364e&hospitals%5B%5D=df8dec18-588d-4b92-b3da-469804d877ff&hospitals%5B%5D=9350751c-45e1-4827-b3c9-d4a3f146804d&
  //     // without_trust=false&
  //     // filter=trust_id%3A3351f9eb-d7b4-4327-9473-84157e4f58c7%7Cmembership_id%3A4ff689d3-b1e5-4857-b674-942b77ccdc1b%7Cmembership_id%3A853428c1-8091-4013-8155-17891b1e0de3%7Cmembership_id%3A6786713c-e216-485e-b1ec-46a30fff64f0
  //
  //     final ioc = new HttpClient();
  //     ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  //     final httpp = new IOClient(ioc);
  //
  //     http.Response response = await httpp.get('$appNewsUrl/api/posts?featured_posts=true&'
  //         'trust_only=true&trust_id=$trustId&without_trust=false&$hospitalsIds&filter=trust_id%3A$trustId$membershipsIds', headers: headers);
  //
  //     responseString = response.body;
  //     List<dynamic> newsResponse = json.decode(responseString);
  //     if (response.statusCode == 200) {
  //       newsResponse.forEach((element) {
  //         final News newsObject = News.fromJson(element);
  //         _orgNews.add(newsObject);
  //       });
  //     } else {
  //       debugPrint(response.reasonPhrase);
  //     }
  //     this.newsPostStage = NewsStage.DONE;
  //   }catch(e){
  //     this.newsPostStage = NewsStage.ERROR;
  //     debugPrint(e.toString());
  //   }
  //   notifyListeners();
  // }

  Future getNewsPostById(BuildContext context,{postId}) async{
    // this.newsPostStage = NewsStage.LOADING;

    var responseString;

    try{
      final prefs = await SharedPreferences.getInstance();
      final storedUser = prefs.getString("user");
      /// when user logs out the following line cases a problem ******
      String token = jsonDecode(storedUser)['token'];

      var headers = {
        'Platform': MyApp.platformIndex,
        'Right-Nurse-Version': Domain.appVersion,
        'Accept': 'application/vnd.right_nurse; version=2',
        'Content-Type': 'application/json',
        'Authorization': 'Token token=$token'
      };

      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);
      http.Response response = await httpp.get(Uri.parse('$appNewsUrl/api/posts/$postId'), headers: headers);
      responseString = response.body;
      dynamic newsResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final News newsObject = News.fromJson(newsResponse);
        newsObject.url = "${newsObject.url}?user_id=${Provider.of<UserProvider>(context, listen: false).userData.id}";

        setNewsPost(newsObject);
      } else {
        debugPrint(response.reasonPhrase);
        setNewsPost(null);

      }
      this.newsDetailsStage = NewsStage.DONE;
    }catch(e){
      this.newsDetailsStage = NewsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future fetchNewsForSearch(BuildContext context,{title, trustId,pageOffset}) async{
    this.searchNewsStage = NewsStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    String url = '$appNewsUrl/api/posts/search?%5Btitle%2C%20body%2C%20description%5D=$title&trust_id=$trustId&limit=10&offset=$pageOffset';
    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;

    try{
      // var headers = {
      //   'Platform': '0',
      //   'Right-Nurse-Version': '11.2.2',
      //   'UserAgent': 'RightNurse/1.2.3 (iPhone; iOS 10.3.1; Scale/3.00)',
      //   'Accept': 'application/vnd.right_nurse; version=1',
      //   'Content-Type': 'application/json',
      //   'Authorization': 'Token token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiODc1MTA5YjUtYmFiZC00MTI1LWI3MzYtYzE4YjEyYmYxNDg5IiwibmJmIjoxNjQ3MDA4OTk2fQ.l6ygA8kjFvTHXFuf2XOvxqEyxg0kSI7RXFheAqxzFSk'
      // };
      var request = http.Request('GET', Uri.parse(url));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      dynamic offerObject = json.decode(responseString);

      if (response.statusCode == 200) {
        if(pageOffset==0){
          _searchMews.clear();
        }
        if ( pageOffset!=null && pageOffset>0 && offerObject.isNotEmpty){
          AnalyticsManager.track('news_list_scroll');
        }
        offerObject.forEach((element) {
          final News newsObject = News.fromJson(element);
          newsObject.url = "${newsObject.url}?user_id=${Provider.of<UserProvider>(context, listen: false).userData.id}";
          _searchMews.add(newsObject);
        });
      }
      else {
        print(response.reasonPhrase);
      }
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      // http.Response response = await httpp.get(Uri.parse(url), headers: headers);
      //
      // responseString =  response.body;
      // List<dynamic> newsResponse = json.decode(responseString);
      //
      // if (response.statusCode == 200) {
      //   print(url);
      //
      //   if(pageOffset==0){
      //     _searchMews.clear();
      //   }
      //   newsResponse.forEach((element) {
      //     final News newsObject = News.fromJson(element);
      //     _searchMews.add(newsObject);
      //   });
      //
      // } else {
      //   debugPrint(response.reasonPhrase);
      // }
      this.searchNewsStage = NewsStage.DONE;
    }catch(e){
      this.searchNewsStage = NewsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future fetchProfessionalNews(BuildContext context,{pageOffset,trustId,}) async{
    this.proNewsStage = NewsStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    final url = '$appNewsUrl/api/posts?category=Professional&limit=10&offset=$pageOffset&trust_only=true&trust_id=$trustId';

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;

    try{
//       final ioc = new HttpClient();
//       ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//       final httpp = new IOClient(ioc);
//       //https://news-feed-staging.right-nurse.com/api/posts?limit=10&offset=0&
//       // trust_only=false&country_id=5db11d21-125e-470d-a771-e3a4c312bef2&without_trust=true
//       http.Response response = await httpp.get(Uri.parse('$appNewsUrl/api/posts?category=Professional&limit=10&offset=$pageOffset&trust_only=true&trust_id=$trustId'), headers: headers);
// //                   https://news-feed-staging.right-nurse.com/api/posts?category=Professional&limit=20&offset=0&trust_id=df8ec8e0-eb9a-4589-b749-9c0aed991949&trust_only=1
//
//       responseString = response.body;

      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      List<dynamic> newsResponse = json.decode(responseString);

      print("newsResponsepppppp $newsResponse");

      if (response.statusCode == 200) {
        if(pageOffset==0){
          _proNews.clear();
          _newsNotificationCount = _newsNotificationCount - newsCounters['focusedNewsCounter'];
          newsCounters['focusedNewsCounter'] = 0;
        }
        newsResponse.forEach((element) {
          final News newsObject = News.fromJson(element);
          newsObject.url = "${newsObject.url}?user_id=${Provider.of<UserProvider>(context, listen: false).userData.id}";
          _proNews.add(newsObject);
          if(DateTime.parse(newsObject.published).millisecondsSinceEpoch > DateTime.parse(_whenFocusedNewsTabLastChecked??prefs.getString("whenAppWentToBackground")??DateTime.now().toString()).millisecondsSinceEpoch){
            newsCounters['focusedNewsCounter']++;
            _newsNotificationCount++;
          }
        });

      } else {
        debugPrint(response.reasonPhrase);
      }
      this.proNewsStage = NewsStage.DONE;
    }catch(e){
      this.proNewsStage = NewsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future fetchFavouriteNews(BuildContext context,{pageOffset, isFromFavouriteScreen = false}) async{
    this.favNewsStage = NewsStage.LOADING;

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;
    // List<News> favNews = [];
    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);

      http.Response response = await httpp.get(Uri.parse('$appNewsUrl/api/favorite_posts?limit=10&offset=${pageOffset??0}'), headers: headers);

      responseString = await response.body;
      List<dynamic> newsResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        if(isFromFavouriteScreen && _favouriteNews.isNotEmpty)
          _favouriteNews.clear();
        newsResponse.forEach((element) {
          final News newsObject = News.fromJson(element);
          newsObject.url = "${newsObject.url}?user_id=${Provider.of<UserProvider>(context, listen: false).userData.id}";
          _favouriteNews.add(newsObject);
        });

        //setFavouriteNews(favNews);

      } else {
        debugPrint(response.reasonPhrase);
      }
      this.favNewsStage = NewsStage.DONE;
    }catch(e){
      this.favNewsStage = NewsStage.ERROR;
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future addToFavourites(BuildContext context,id, {isFromNewsDetails = false}) async{

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);
      var body = json.encode({"id": id});
      http.Response response = await httpp.post(Uri.parse('$appNewsUrl/api/favorite_posts'), headers: headers, body: body);


      if(isFromNewsDetails){
        clearProNews();
        clearOrgNews();
        fetchProfessionalNews(context,pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);
        fetchOrganisationNews(context,pageOffset: 0, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds,
            hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);
      }
      // if (response.statusCode == 200) {
      //
      //   debugPrint(await response.stream.bytesToString());
      // }
      else {
        debugPrint(response.reasonPhrase);
      }
    }catch(e){
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future removeFromFavourites(BuildContext context,id,{isFromFavTab = false}) async{

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);

      if(_favouriteNews.length >1)
        _favouriteNews.removeWhere((element) => element.id == id);
      //_favouriteNews.firstWhere((element) => element.id == id).favorite = false;
      http.Response response = await httpp.delete(Uri.parse('$appNewsUrl/api/favorite_posts/$id'), headers: headers, );
      // request.body = '''{"id":$id}''';

      if (response.statusCode == 200) {
        if(isFromFavTab){
          if(_favouriteNews.length == 1)
            _favouriteNews.removeWhere((element) => element.id == id);
          clearProNews();
          clearOrgNews();
          fetchProfessionalNews(context,pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);

          fetchOrganisationNews(context,pageOffset: 0, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds,
              hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);
        }
        debugPrint(response.body);
      }
      else {
        debugPrint(response.reasonPhrase);
      }
    }catch(e){
      debugPrint(e.toString());
    }
    notifyListeners();
  }


  List<Comment> _replies = [];
  List<Comment> get replies =>this._replies;
  setReplies(List<Comment> replies){
    _replies = replies;
  }
  List<Comment> commentReplies = [];
  List<Comment> postComments = [];

  Future fetchCommentsForNewsObject(BuildContext context, id,{pageOffset,}) async{
    this.commentsStage = NewsStage.LOADING;
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;

    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);

      http.Response response = await httpp.get(Uri.parse('$appNewsUrl/api/posts/$id/comments?limit=25&offset=$pageOffset'), headers: headers);

      responseString = response.body;
      // debugPrint(responseString);

      List<dynamic> newsResponse = json.decode(responseString);
      if (response.statusCode == 200) {
        if (pageOffset==0 || pageOffset == null) {
          postComments.clear();
        }
        newsResponse.forEach((element) {
          final Comment comment = Comment.fromJson(element);
          debugPrint("${element['reactions']}");

          postComments.add(comment);

        });

        setComments(postComments);
        // AnalyticsManager.track(
        //     'comments_list',
        //     parameters: {
        //       "":""
        //     }
        // );
      }
      else {
        debugPrint(response.reasonPhrase);
      }

      this.commentsStage = NewsStage.DONE;
    }catch(e){
      debugPrint(e.toString());
      this.commentsStage = NewsStage.ERROR;
    }
    notifyListeners();
  }

  Future postComment(context,id, commentBody,
      {trustId, hospitalsIds, membershipsIds,isReply = false,parent_id}) async{
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);

      var body = isReply ? json.encode({"body": "$commentBody","parent_id": "$parent_id"}) : json.encode({"body": "$commentBody"});

      http.Response response = await httpp.post(Uri.parse('$appNewsUrl/api/posts/$id/comments'), headers: headers, body: body);

      // debugPrint('comment parent_id $parent_id');
      // debugPrint('Comment body ${response.body}');

      debugPrint("Status code !!!! !!! ${response.statusCode}");

      if (response.statusCode == 200 || response.reasonPhrase == "Created") {
        // fetchCommentsForNewsObject(context,id,pageOffset: 0);
        debugPrint("Success !!! ${response.reasonPhrase}");

        fetchOrganisationNews(context,pageOffset: 0, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds,
            hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);


        fetchProfessionalNews(context,pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);

        if (_favouriteNews.isNotEmpty) {
          clearFavouriteNews();
          fetchFavouriteNews(context,pageOffset: 0);
        }
      }
      else {
        debugPrint("Failure !!! ${response.reasonPhrase}");
      }
    }catch(e){
      debugPrint(e.toString());
    }

  }


  Future deleteComment({context,postId,commentId})async{

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);
      http.Response response = await httpp.delete(Uri.parse('$appNewsUrl/api/posts/$postId/comments/$commentId'),headers: headers);


      if (response.statusCode == 200) {
        fetchCommentsForNewsObject(context,postId,pageOffset: 0).then((_) {
          return showToast("Comment deleted successfully");
        });

        fetchOrganisationNews(context,pageOffset: 0, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds,
            hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);


        fetchProfessionalNews(context,pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);

        if (_favouriteNews.isNotEmpty) {
          clearFavouriteNews();
          fetchFavouriteNews(context,pageOffset: 0);
        }

      }
      else {
        debugPrint(response.reasonPhrase);
        showAlertDialog(context, content: "Something went wrong");
      }

    } on Exception catch (e) {
      showAlertDialog(context, content: "Something went wrong");
      debugPrint(e.toString());
    }


  }

  Future editComment({context,postId,commentId,commentBody,isReply = false})async{

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var body = !isReply
        ?
    json.encode({
      "body" : "$commentBody",
    })
        :
    json.encode({
      "body" : "$commentBody",
      "parent_id" : "$commentId",
    });

    try {
      // var request = http.Request('PUT', Uri.parse('$appNewsUrl/api/posts/$postId/comments/$commentId'));
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);
      http.Response response = await httpp.put(Uri.parse('$appNewsUrl/api/posts/$postId/comments/$commentId'),headers: headers,body: body);

      if (response.statusCode == 200) {
        fetchCommentsForNewsObject(context,postId,pageOffset: 0);
      }
      else {
        debugPrint("22222 $response");
      }

    } on Exception catch (e) {
      debugPrint(e.toString());
    }


  }


  Future fetchUserById({String userId}) async{

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];
    final url = '$appDomain/user/$userId';


    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
    var responseString;
    try{
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      // http.Response response = await httpp.get(Uri.parse(url), headers: headers);

      // responseString = response.body;


      String responseString;
      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
      Map responseMap = json.decode(responseString);
      User user = User.fromJson(responseMap);

      if (response.statusCode == 200) {
        return user;
      }
      else {
        debugPrint(response.reasonPhrase);
        return null;
      }

    }catch(e){
      debugPrint(e.toString());
    }

  }


  Future reactComment(context,{postId,commentId,reactionType}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);

      var body =json.encode({ "reaction": { "reaction_type": "$reactionType" } });

      http.Response response = await httpp.post( Uri.parse('$appNewsUrl/api/posts/$postId/comments/$commentId/reactions'), headers: headers, body: body);

      if (response.statusCode == 200) {
        // fetchCommentsForNewsObject(context,postId,pageOffset: 0);
        debugPrint(response.reasonPhrase);
      }
      else {
        debugPrint(response.reasonPhrase);
      }
    }catch(e){
      debugPrint(e.toString());
    }


  }

  Future deleteReactionForComment(context,{postId,commentId,reactionId}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);

      http.Response response = await httpp.delete(Uri.parse('$appNewsUrl/api/posts/$postId/comments/$commentId/reactions/$reactionId'), headers: headers);

      if (response.statusCode == 200) {
        debugPrint(response.reasonPhrase);
      }
      else {
        debugPrint(response.reasonPhrase);
      }
    }catch(e){
      debugPrint(e.toString());
    }


  }


  Future reactPost(context,{postId,reactionType}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);
      var body = json.encode({"reaction": { "reaction_type": "$reactionType" }});

      http.Response response = await httpp.post(Uri.parse('$appNewsUrl/api/posts/$postId/reactions'), headers: headers, body: body);
      if (response.reasonPhrase == "OK" || response.reasonPhrase == "Created") {
        // fetchCommentsForNewsObject(context,postId,pageOffset: 0);
        debugPrint(response.reasonPhrase);

        fetchOrganisationNews(context,pageOffset: 0, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds,
            hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);


        fetchProfessionalNews(context,pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);

        if (_favouriteNews.isNotEmpty) {
          clearFavouriteNews();
          fetchFavouriteNews(context,pageOffset: 0);
        }
      }
      else {
        debugPrint("Error for reactions !! --> ${response.reasonPhrase}");
      }
    }catch(e){
      debugPrint(e.toString());
    }


  }


  Future deleteReactionForPost(context,{postId,reactionId}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=2',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };
    try{
      final ioc = new HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final httpp = new IOClient(ioc);

      http.Response response = await httpp.delete(Uri.parse('$appNewsUrl/api/posts/$postId/reactions/$reactionId'), headers: headers);

      if (response.statusCode == 200) {
        debugPrint(response.reasonPhrase);

        fetchOrganisationNews(context,pageOffset: 0, membershipsIds: Provider.of<UserProvider>(context, listen: false).membershipIds,
            hospitalsIds: Provider.of<UserProvider>(context, listen: false).hospitalIds, trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);


        fetchProfessionalNews(context,pageOffset: 0,trustId: Provider.of<UserProvider>(context, listen: false).userData.trust["id"]);

        if (_favouriteNews.isNotEmpty) {
          clearFavouriteNews();
          fetchFavouriteNews(context,pageOffset: 0);
        }

      }
      else {
        debugPrint("Error for reaction deleting !! --> ${response.reasonPhrase}");
      }
    }catch(e){
      debugPrint(e.toString());
    }


  }




}
