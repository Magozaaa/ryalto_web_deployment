import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/AreasOfWorkModel.dart';
import 'package:rightnurse/Models/AvailablePositionModel.dart';
import 'package:rightnurse/Models/BandModel.dart';
import 'package:rightnurse/Models/GradeModel.dart';
import 'package:rightnurse/Models/LanguageModel.dart';
import 'package:rightnurse/Models/MembershipModel.dart';
import 'package:rightnurse/Models/SkillModel.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:http/io_client.dart';
import '../main.dart';



enum FilterStage{ERROR, LOADING, DONE}

class FilterParameters {
  int roleType; // default to Doctor
  List<String> roleIds = [];
  List<String> areasOfWorkIds = [];
  List<String> membershipIds = [];
  List<String> gradeIds = [];
  List<String> bandIds = [];
  List<String> languageIds = [];
  List<String> skillsIds = [];

  setDefaultUserType(userType){
    roleType = userType;
  }
}

enum DiscoveryStage { ERROR, LOADING, DONE }

class DiscoveryProvider extends ChangeNotifier {
  DiscoveryStage stage;
  FilterStage filterStage;

  int discoveryProviderPageSize = 10;
  static String kDiscoveryHeaderPrefix = 'HSP:::';
  static String kDiscoveryFilterNumberPrefix = 'FILT:::';
  static String kDiscoveryFilterNumberSeparator = '@@';

  final String errorMessage = "Network Error! Please try again later.";

  List<User> _discoveredUsers = [];
  int _userCount = 0;
  List<User> _filteredUsers = [];
  int _activeFilterUserCount = 0;
  int _pageOffset = 0;

  FilterParameters _filterParameters = FilterParameters();
  FilterParameters _activeFilteringParameters = FilterParameters();

  int get pageOffset => this._pageOffset;
  List<User> get discoveredUsers => this._discoveredUsers;
  int get userCount => this._userCount;
  List<User> get filteredUsers => this._filteredUsers;
  int get activeFilterUserCount => this._activeFilterUserCount;

  // the following are needed for filtering
  List<Skill> _skills = [];
  Map<String, String> _orderedSkillsMap = {};
  List<Grade> _grades = [];
  Map<String, String> _orderedGradesMap = {};
  List<Level> _bands = [];
  Map<String, String> _orderedBandsMap = {};
  List<Language> _languages = [];
  Map<String, String> _orderedLanguagesMap = {};
  List<AvailablePosition> _availablePositions = [];
  Map<String, String> _orderedAvailablePositionsMap = {};
  List<AreaOfWork> _areasOfWork = [];
  Map<String, String> _orderedAreasOfWorkMap = {};
  List<Membership> _memberShips = [];
  Map<String, String> _orderedMembershipsMap = {};

  List<Skill> get skills => this._skills;
  Map<String, String> get orderedSkillsMap => _orderedSkillsMap;
  List<Level> get bands => this._bands;
  Map<String, String> get orderedBandsMap => _orderedBandsMap;
  List<Grade> get grades => this._grades;
  Map<String, String> get orderedGradesMap => _orderedGradesMap;
  List<Language> get languages => this._languages;
  Map<String, String> get orderedLanguagesMap => _orderedLanguagesMap;
  List<AvailablePosition> get availablePositions => this._availablePositions;
  Map<String, String> get orderedAvailablePositionsMap => this._orderedAvailablePositionsMap;
  List<AreaOfWork> get areasOfWork => this._areasOfWork;
  Map<String, String> get orderedAreasOfWorkMap => this._orderedAreasOfWorkMap;
  List<Membership> get memberShips => this._memberShips;
  Map<String, String> get orderedMembershipsMap => _orderedMembershipsMap;
  FilterParameters get filterParameters => this._filterParameters;
  FilterParameters get activeFilteringParameters => this._activeFilteringParameters;

  increaseNextOffset(){
    _pageOffset +=10;
    notifyListeners();
  }

  resettingOffset(){
    _pageOffset = 0;
    notifyListeners();
  }

  void copyActiveFilterParametersToFilterParameters() {
    _filterParameters.roleType = _activeFilteringParameters.roleType;
    _filterParameters.roleIds = _activeFilteringParameters.roleIds;
    _filterParameters.areasOfWorkIds = _activeFilteringParameters.areasOfWorkIds;
    _filterParameters.membershipIds = _activeFilteringParameters.membershipIds;
    _filterParameters.gradeIds = _activeFilteringParameters.gradeIds;
    _filterParameters.bandIds = _activeFilteringParameters.bandIds;
    _filterParameters.languageIds = _activeFilteringParameters.languageIds;
    _filterParameters.skillsIds = _activeFilteringParameters.skillsIds;
  }

  void copyFilterParametersToActiveFilterParameters() {
    _activeFilteringParameters.roleType = _filterParameters.roleType;
    _activeFilteringParameters.roleIds = _filterParameters.roleIds;
    _activeFilteringParameters.areasOfWorkIds = _filterParameters.areasOfWorkIds;
    _activeFilteringParameters.membershipIds = _filterParameters.membershipIds;
    _activeFilteringParameters.gradeIds = _filterParameters.gradeIds;
    _activeFilteringParameters.bandIds = _filterParameters.bandIds;
    _activeFilteringParameters.languageIds = _filterParameters.languageIds;
    _activeFilteringParameters.skillsIds = _filterParameters.skillsIds;

  }

  void resetActiveFilteringParameters(context) {
    _activeFilteringParameters.roleType = Provider.of<UserProvider>(context, listen: false).userData.roleType;
    _activeFilteringParameters.roleIds = [];
    _activeFilteringParameters.areasOfWorkIds = [];
    _activeFilteringParameters.membershipIds = [];
    _activeFilteringParameters.gradeIds = [];
    _activeFilteringParameters.bandIds = [];
    _activeFilteringParameters.languageIds = [];
    _activeFilteringParameters.skillsIds = [];
  }

  void resetFiltersWhenLogOut(){
    _activeFilteringParameters.roleType = null;
    _activeFilteringParameters.roleIds = [];
    _activeFilteringParameters.areasOfWorkIds = [];
    _activeFilteringParameters.membershipIds = [];
    _activeFilteringParameters.gradeIds = [];
    _activeFilteringParameters.bandIds = [];
    _activeFilteringParameters.languageIds = [];
    _activeFilteringParameters.skillsIds = [];

    _filterParameters.roleType = null;
    _filterParameters.roleIds = [];
    _filterParameters.areasOfWorkIds = [];
    _filterParameters.membershipIds = [];
    _filterParameters.gradeIds = [];
    _filterParameters.bandIds = [];
    _filterParameters.languageIds = [];
    _filterParameters.skillsIds = [];
    notifyListeners();
  }

  void resetFilters(context) {
    _filterParameters.roleType = Provider.of<UserProvider>(context, listen: false).userData.roleType;
    _filterParameters.roleIds = [];
    _filterParameters.areasOfWorkIds = [];
    _filterParameters.membershipIds = [];
    _filterParameters.gradeIds = [];
    _filterParameters.bandIds = [];
    _filterParameters.languageIds = [];
    _filterParameters.skillsIds = [];

    _activeFilteringParameters.roleType = Provider.of<UserProvider>(context, listen: false).userData.roleType;
    _activeFilteringParameters.roleIds = [];
    _activeFilteringParameters.areasOfWorkIds = [];
    _activeFilteringParameters.membershipIds = [];
    _activeFilteringParameters.gradeIds = [];
    _activeFilteringParameters.bandIds = [];
    _activeFilteringParameters.languageIds = [];
    _activeFilteringParameters.skillsIds = [];
  }

  void resetActiveFilters(context) {
    _activeFilteringParameters.roleType = Provider.of<UserProvider>(context, listen: false).userData.roleType;
    _activeFilteringParameters.roleIds = [];
    _activeFilteringParameters.areasOfWorkIds = [];
    _activeFilteringParameters.membershipIds = [];
    _activeFilteringParameters.gradeIds = [];
    _activeFilteringParameters.bandIds = [];
    _activeFilteringParameters.languageIds = [];
    _activeFilteringParameters.skillsIds = [];

  }

  void copyFilteredResultsToResults() {
    _discoveredUsers = [];
    // only add the first page to the screen
    for (int i = 0; i < _filteredUsers.length && i < discoveryProviderPageSize; i++) {
      _discoveredUsers.add(_filteredUsers[i]);
    }
    _userCount = _activeFilterUserCount;
    _activeFilterUserCount = 0;
    _filteredUsers = [];

    notifyListeners();
  }


  Future fetchUsers(BuildContext context,
      {int pageOffset,
        String trustId,
        String countryCode,
        String hospitalsIds,
        String membershipsIds,
        bool initialLoad,
        int defaultUserType,
        bool useActiveFilters = false,
        String groupId = "",
        String searchText = ''}) async {
    this.stage = DiscoveryStage.LOADING;

    if(_activeFilteringParameters.roleType == null && _filterParameters.roleType == null){
      _activeFilteringParameters.setDefaultUserType(Provider.of<UserProvider>(context, listen: false).userData.roleType);
      _filterParameters.setDefaultUserType(Provider.of<UserProvider>(context, listen: false).userData.roleType);
      // notifyListeners();
    }


    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final String token = jsonDecode(storedUser)['token'];
    final String searchTerm = searchText;

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;

    try {
      // http.Response response;
      String url;

      // Add all necessary params
      String roleTypeParam = '';
      int roleTypeId = useActiveFilters ? _activeFilteringParameters.roleType : //defaultUserType ;
       _filterParameters.roleType;
      if (roleTypeId != 0) {
        roleTypeParam = '&role_type=$roleTypeId';
        debugPrint('$roleTypeParam');
      }
      String rolesParams = '';
      List<String> roleIds = useActiveFilters ? _activeFilteringParameters.roleIds : _filterParameters.roleIds;
      if (roleIds.isNotEmpty) {
        roleIds.forEach((element) {
          rolesParams += '&roles[]=$element';
        });
        debugPrint('$rolesParams');
      }
      String areasOfWordParams = '';
      List<String> wardIds =
      useActiveFilters ? _activeFilteringParameters.areasOfWorkIds : _filterParameters.areasOfWorkIds;
      if (wardIds.isNotEmpty) {
        wardIds.forEach((element) {
          areasOfWordParams += '&wards[]=$element';
        });
        debugPrint('$areasOfWordParams');
      }
      String membershipsParams = '';
      List<String> membershipIds =
      useActiveFilters ? _activeFilteringParameters.membershipIds : _filterParameters.membershipIds;
      if (membershipIds.isNotEmpty) {
        membershipIds.forEach((element) {
          membershipsParams += '&memberships[]=$element';
        });
        debugPrint('$membershipsParams');
      }
      String gradesParams = '';
      List<String> gradeIds = useActiveFilters ? _activeFilteringParameters.gradeIds : _filterParameters.gradeIds;
      if (gradeIds.isNotEmpty) {
        gradeIds.forEach((element) {
          gradesParams += '&grades[]=$element';
        });
        debugPrint('$gradesParams');
      }
      String bandsParams = '';
      List<String> bandIds = useActiveFilters ? _activeFilteringParameters.bandIds : _filterParameters.bandIds;
      if (bandIds.isNotEmpty) {
        bandIds.forEach((element) {
          bandsParams += '&bands[]=$element';
        });
        debugPrint('$bandsParams');
      }
      String languageParams = '';
      List<String> languageIds =
      useActiveFilters ? _activeFilteringParameters.languageIds : _filterParameters.languageIds;
      if (languageIds.isNotEmpty) {
        languageIds.forEach((element) {
          languageParams += '&languages[]=$element';
        });
        debugPrint('$languageParams');
      }
      String skillsParams = '';
      List<String> skillIds = useActiveFilters ? _activeFilteringParameters.skillsIds : _filterParameters.skillsIds;
      if (skillIds.isNotEmpty) {
        skillIds.forEach((element) {
          skillsParams += '&skills[]=$element';
        });
        debugPrint('$skillsParams');
      }

      if (searchTerm.isEmpty) {
        url = '$appDomain/discovery?limit=$discoveryProviderPageSize&offset=$pageOffset&country_code=$countryCode&exclude_channel_id=$groupId';
      } else {
        url =
        '$appDomain/discovery?limit=$discoveryProviderPageSize&offset=$pageOffset&country_code=$countryCode&exclude_channel_id=$groupId&search=$searchTerm&search_fields%5B%5D=name&search_fields%5B%5D=roles&search_fields%5B%5D=trust&search_fields%5B%5D=memberships';
      }
      print('urlurl $url');

      url = url + '&trusts[]=$trustId';

      // add any extra params
      url = url + roleTypeParam;
      url = url + rolesParams;
      url = url + areasOfWordParams;
      url = url + membershipsParams;
      url = url + gradesParams;
      url = url + bandsParams;
      url = url + languageParams;
      url = url + skillsParams;

    //   final ioc = new HttpClient();
    //   ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //   final httpp = new IOClient(ioc);
    //
    // response = await httpp.get(Uri.parse(url), headers: headers);

      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();
    debugPrint("this is the url for discovery  $url");
      // responseString = response.body;

      if (response.statusCode == 200) {
        final Map<String, dynamic> usersResponse = json.decode(responseString);
        List<dynamic> users = usersResponse['users'];
        if (useActiveFilters) {
          _activeFilterUserCount = usersResponse['total_count'];
        } else {
          _userCount = usersResponse['total_count'];
        }

        if (!useActiveFilters && pageOffset == 0) {
          _discoveredUsers = [];
        }
        _filteredUsers = [];

        users.forEach((userJson) {
          final User user = User.fromJson(userJson);
          // save users to the correct list (actively filtering or not)
          useActiveFilters ? _filteredUsers.add(user) : _discoveredUsers.add(user);
          // adding this line to register users for Twilio in order not to have Ryalto user as name when they call
          if (!kIsWeb) {
            TwilioVoice.instance.registerClient(user.id, user.name);
          }
        });
      } else {
        debugPrint('api failed with code ${response.reasonPhrase}');
        _discoveredUsers = [];
        _filteredUsers = [];
        _userCount = 0;
        _activeFilterUserCount = 0;
      }
      this.stage = DiscoveryStage.DONE;
    } catch (e) {
      this.stage = DiscoveryStage.ERROR;
      print(e);
      _discoveredUsers = [];
      _filteredUsers = [];
      _userCount = 0;
      _activeFilterUserCount = 0;
    }

    notifyListeners();
  }

   clearUsers() {
    _discoveredUsers = [];
    _filteredUsers = [];
    _userCount = 0;
    _activeFilterUserCount = 0;
  }

  clearFilterForCurrentUser(){
    _skills.clear();
    _orderedSkillsMap.clear();
    _grades.clear();
    _orderedGradesMap.clear();
    _bands.clear();
    _orderedBandsMap.clear();
    _languages.clear();
    _orderedLanguagesMap.clear();
    _availablePositions.clear();
    _orderedAvailablePositionsMap.clear();
    _areasOfWork.clear();
    _orderedAreasOfWorkMap.clear();
    _memberShips.clear();
    _orderedMembershipsMap.clear();
    notifyListeners();
  }

  Future fetchAvailablePositions(BuildContext context,
      {String trustId, String countryCode, int roleType = 0, bool notify = true,profileUpdate = true,}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final String token = jsonDecode(storedUser)['token'];
    final int role = roleType;

    this.filterStage = FilterStage.LOADING;

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;


    try {
      // http.Response response;
      String url;
      if (role == 0) {
        url = '$appDomain/available_positions?limit=1000&offset=0&country_code=$countryCode&trusts[]=$trustId&profile_update=$profileUpdate';
      } else {
        url =
        '$appDomain/available_positions?limit=1000&offset=0&country_code=$countryCode&trusts[]=$trustId&role_type=$role&profile_update=$profileUpdate';
      }
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // response = await httpp.get(Uri.parse(url), headers: headers);

      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();



      if (response.statusCode == 200) {
        // responseString = response.body;
        final decodedResp = json.decode(responseString);

        final AvailablePositions positions = AvailablePositions.fromJson(decodedResp);
        _availablePositions = positions.positions;
        _orderedAvailablePositionsMap.clear();

        // need to order by hosital name
        _availablePositions.sort((a, b) {
          return (a.hospital.name.toLowerCase().compareTo(b.hospital.name.toLowerCase()));
        });
        // here see if hospital changes, add the hospital name as a separate entry for the header
        String hospitalName = '';
        _availablePositions.forEach((element) {
          if (hospitalName != element.hospital.name) {
            hospitalName = element.hospital.name;
            _orderedAvailablePositionsMap[element.hospital.id] = kDiscoveryHeaderPrefix + element.hospital.name;
          }
          _orderedAvailablePositionsMap[element.id] = element.name;
        });
      } else {
        _availablePositions = [];
      }
      this.filterStage = FilterStage.DONE;
    } catch (e) {
      debugPrint(e.toString());
      _availablePositions = [];
      this.filterStage = FilterStage.ERROR;

    }
    if (notify) {
      notifyListeners();
    }
  }

  Future fetchAreasOfWork(BuildContext context,
      {String trustId, String hospitalsIds, String countryCode, bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final String token = jsonDecode(storedUser)['token'];

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;

    if (_areasOfWork.isNotEmpty) {
      return;
    }

    try {
      // http.Response response;
      String url = '$appDomain/wards?limit=1000&offset=0&trusts_id=$trustId$hospitalsIds';
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);

      // response = await httpp.get(Uri.parse(url), headers: headers);
      debugPrint('WARDS api call ${url}');
      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // responseString =response.body;
        // log('$responseString\n\n');
        final decodedResp = json.decode(responseString);
        final areas = AreasOfWork.fromJson(decodedResp);
        _areasOfWork = areas.areasOfWork;
        // need to order by hosital name, then ward name
        _areasOfWork.sort((a, b) {
          final comparisonHospName = a.hospital.name.compareTo(b.hospital.name);
          if (comparisonHospName != 0) {
            return comparisonHospName;
          }

          return a.name.compareTo(b.name);
        });
        // here see if hospital changes, add the hospital name as a separate entry for the header
        String hospitalName = '';
        _areasOfWork.forEach((element) {
          if (hospitalName != element.hospital.name) {
            hospitalName = element.hospital.name;
            _orderedAreasOfWorkMap[element.hospital.id] = kDiscoveryHeaderPrefix + element.hospital.name;
          }
          _orderedAreasOfWorkMap[element.id] = element.name;
        });
      } else {
        debugPrint('api failed with code ${response.reasonPhrase}');
        _areasOfWork = [];
      }
    } catch (e) {
      debugPrint(e.toString());
      _areasOfWork = [];
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future fetchMemberships(BuildContext context, {String countryCode, int roleType = 0, bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final String token = jsonDecode(storedUser)['token'];
    final int role = roleType;

    this.filterStage = FilterStage.LOADING;

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    // var responseString;

    try {
      // http.Response response;
      String url;
      if (role == 0) {
        url = '$appDomain/memberships?country_code=$countryCode';
      } else {
        url = '$appDomain/memberships?country_code=$countryCode&role_type=$role';
      }
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // response = await httpp.get(Uri.parse(url), headers:  headers);

      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String responseString = await response.stream.bytesToString();

      debugPrint('api call ${url}');


      if (response.statusCode == 200) {
        // responseString = response.body;
        // log('$responseString\n\n');
        final decodedResp = json.decode(responseString);
        final members = Memberships.fromJson(decodedResp);
        _memberShips = members.memberships;
        _orderedMembershipsMap = {};
        _memberShips.forEach((element) {
          _orderedMembershipsMap[element.id] = element.name;
        });
      } else {
        debugPrint('api failed with code ${response.reasonPhrase}');
        _memberShips = [];
        _orderedMembershipsMap = {};
      }
      this.filterStage = FilterStage.DONE;

    } catch (e) {
      debugPrint(e.toString());
      _memberShips = [];
      _orderedMembershipsMap = {};
      this.filterStage = FilterStage.ERROR;

    }
    if (notify) {
      notifyListeners();
    }
  }

  Future fetchGradesBandsLanguagesAndSkills(BuildContext context,
      {String trustId, String countryCode, int roleType = 0, bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final String token = jsonDecode(storedUser)['token'];
    final int role = roleType;

    this.filterStage = FilterStage.LOADING;

    var headers = {
      'Platform': MyApp.platformIndex,
      'Right-Nurse-Version': Domain.appVersion,
      'Accept': 'application/vnd.right_nurse; version=1',
      'Content-Type': 'application/json',
      'Authorization': 'Token token=$token'
    };

    var responseString;
    _orderedBandsMap = {};
    _orderedGradesMap = {};
    _orderedLanguagesMap = {};
    _orderedSkillsMap = {};

    try {
      // http.Response response;
      String url;
      if (role == 0) {
        url = '$appDomain/competencies?limit=10000&offset=0&trust_id=$trustId';
      } else {
        url = '$appDomain/competencies?limit=10000&offset=0&role_type=$role&trust_id=$trustId';
      }
      debugPrint('url = $url');
      // final ioc = new HttpClient();
      // ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      // final httpp = new IOClient(ioc);
      //
      // response = await httpp.get(Uri.parse(url), headers: headers);
      var request = http.MultipartRequest('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseString = await response.stream.bytesToString();

      debugPrint('api call ${url}');


      if (response.statusCode == 200) {
        // responseString = response.body;
        // log('$responseString\n\n');
        final decodedResp = json.decode(responseString);
        final bs = Levels.fromJson(decodedResp['bands']);
        _bands = bs.bands;
        _bands.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        _bands.forEach((element) {
          _orderedBandsMap[element.id] = element.name;
        });
        final gs = Grades.fromJson(decodedResp['grades']);
        _grades = gs.grades;
        _grades.forEach((element) {
          _orderedGradesMap[element.id] = element.name;
        });
        final ls = Languages.fromJson(decodedResp['languages']);
        _languages = ls.languages;
        // TODO: currently, the language list is returning the wrong order for Urdu (it is 0, same as English
        // so not sorting by order...)

        // _languages.sort((a, b) {
        //   return (a.order < b.order
        //       ? -1
        //       : a.order >= b.order
        //           ? 1
        //           : 0);
        // });
        _languages.forEach((element) {
          _orderedLanguagesMap[element.id] = element.name;
        });
        final ss = Skills.fromJson(decodedResp['skills']);
        _skills = ss.skills;
        _skills.sort((a, b) {
          final comparisonHospName = a.hospital.name.compareTo(b.hospital.name);
          if (comparisonHospName != 0) {
            return comparisonHospName;
          }

          return a.name.compareTo(b.name);
        });
        // need to order by hosital name
        _skills.sort((a, b) {
          return (a.hospital.name.toLowerCase().compareTo(b.hospital.name.toLowerCase()));
        });
        // here see if hospital changes, add the hospital name as a separate entry for the header
        String hospitalName = '';
        _skills.forEach((element) {
          if (hospitalName != element.hospital.name) {
            hospitalName = element.hospital.name;
            _orderedSkillsMap[element.hospital.id] = kDiscoveryHeaderPrefix + element.hospital.name;
          }
          _orderedSkillsMap[element.id] = element.name;
        });
      } else {
        debugPrint('api failed with code ${response.reasonPhrase}');
        _grades = [];
        _orderedGradesMap = {};
        _languages = [];
        _orderedLanguagesMap = {};
        _skills = [];
        _orderedSkillsMap = {};
      }
      this.filterStage = FilterStage.DONE;

    } catch (e) {
      debugPrint(e.toString());
      _grades = [];
      _orderedGradesMap = {};
      _languages = [];
      _orderedLanguagesMap = {};
      _skills = [];
      _orderedSkillsMap = {};
      this.filterStage = FilterStage.ERROR;

    }

    if (notify) {
      notifyListeners();
    }
  }

  String getFilterName({String roleId, Map<String, String> itemsMap}) {
    if (itemsMap.keys.contains(roleId)) {
      return itemsMap.entries.firstWhere((element) => element.key == roleId).value;
    }
    return '';
  }

  bool anyFiltersSet() {
    /// this comment below is to show the Doctor filter when its applied on its own
    return _filterParameters.roleType != 0 /*&& _filterParameters.roleType != 2*/ ||
        _filterParameters.roleIds.isNotEmpty ||
        _filterParameters.areasOfWorkIds.isNotEmpty ||
        _filterParameters.membershipIds.isNotEmpty ||
        _filterParameters.gradeIds.isNotEmpty ||
        _filterParameters.bandIds.isNotEmpty ||
        _filterParameters.languageIds.isNotEmpty ||
        _filterParameters.skillsIds.isNotEmpty;
  }

  List<String> getFilterNames() {
    List<String> ret = [];
    String filter = '';
    switch (_filterParameters.roleType) {
      case 1:
        filter = 'Clinical';
        break;
      case 2:
        filter = 'Doctor';
        break;
      case 3:
        filter = 'Non-clinical';
        break;
      default:
      // don't return 'Any'
    }

    if (filter.isNotEmpty) {
      ret.add(filter);
    }

    if (_filterParameters.roleIds.isNotEmpty) {
      if (_filterParameters.roleIds.length == 1) {
        ret.add(getFilterName(roleId: _filterParameters.roleIds[0], itemsMap: orderedAvailablePositionsMap));
      } else {
        ret.add(
            '$kDiscoveryFilterNumberPrefix${_filterParameters.roleIds.length}${kDiscoveryFilterNumberSeparator}Roles');
      }
    }
    if (_filterParameters.areasOfWorkIds.isNotEmpty) {
      if (_filterParameters.areasOfWorkIds.length == 1) {
        ret.add(getFilterName(roleId: _filterParameters.areasOfWorkIds[0], itemsMap: _orderedAreasOfWorkMap));
      } else {
        ret.add(
            '$kDiscoveryFilterNumberPrefix${_filterParameters.areasOfWorkIds.length}${kDiscoveryFilterNumberSeparator}Areas of work');
      }
    }
    if (_filterParameters.membershipIds.isNotEmpty) {
      if (_filterParameters.membershipIds.length == 1) {
        ret.add(getFilterName(roleId: _filterParameters.membershipIds[0], itemsMap: _orderedMembershipsMap));
      } else {
        ret.add(
            '$kDiscoveryFilterNumberPrefix${_filterParameters.membershipIds.length}${kDiscoveryFilterNumberSeparator}Memberships');
      }
    }
    if (_filterParameters.gradeIds.isNotEmpty) {
      if (_filterParameters.gradeIds.length == 1) {
        ret.add(getFilterName(roleId: _filterParameters.gradeIds[0], itemsMap: _orderedGradesMap));
      } else {
        ret.add(
            '$kDiscoveryFilterNumberPrefix${_filterParameters.gradeIds.length}${kDiscoveryFilterNumberSeparator}Grades');
      }
    }
    if (_filterParameters.bandIds.isNotEmpty) {
      if (_filterParameters.bandIds.length == 1) {
        ret.add(getFilterName(roleId: _filterParameters.bandIds[0], itemsMap: _orderedBandsMap));
      } else {
        ret.add(
            '$kDiscoveryFilterNumberPrefix${_filterParameters.bandIds.length}${kDiscoveryFilterNumberSeparator}Bands');
      }
    }
    if (_filterParameters.languageIds.isNotEmpty) {
      if (_filterParameters.languageIds.length == 1) {
        ret.add(getFilterName(roleId: _filterParameters.languageIds[0], itemsMap: _orderedLanguagesMap));
      } else {
        ret.add(
            '$kDiscoveryFilterNumberPrefix${_filterParameters.languageIds.length}${kDiscoveryFilterNumberSeparator}Languages');
      }
    }
    if (_filterParameters.skillsIds.isNotEmpty) {
      if (_filterParameters.skillsIds.length == 1) {
        ret.add(getFilterName(roleId: _filterParameters.skillsIds[0], itemsMap: _orderedSkillsMap));
      } else {
        ret.add(
            '$kDiscoveryFilterNumberPrefix${_filterParameters.skillsIds.length}${kDiscoveryFilterNumberSeparator}Skills');
      }
    }

    return ret;
  }
}