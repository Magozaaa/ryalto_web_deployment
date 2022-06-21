import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Models/UserModel.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Subscreens/AreaOfWork.dart';
import 'package:rightnurse/Subscreens/LanguagesScreen.dart';
import 'package:rightnurse/Subscreens/LevelsScreen.dart';
import 'package:rightnurse/Subscreens/Profile/RolesScreen.dart';
import 'package:rightnurse/Subscreens/SkillsScreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CompleteProfileInfo extends StatefulWidget {
  static const String routeName = "/CompleteProfileInfo_Screen";

  @override
  _CompleteProfileInfoState createState() => _CompleteProfileInfoState();
}

class _CompleteProfileInfoState extends State<CompleteProfileInfo> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;


  List<Widget> pagesToCompleteProfileIfo =[];

  Widget skipText ;
  bool _isUpdatingProfile = false;

  @override
  void initState() {

    if(Provider.of<UserProvider>(context, listen: false).userData == null) {
      Provider.of<UserProvider>(context, listen: false).getUser(context);
    }

    if (Provider.of<UserProvider>(context, listen: false).userData.roles == null ||
        Provider.of<UserProvider>(context, listen: false).userData.roles.isEmpty) {
        pagesToCompleteProfileIfo.add(RolesScreen());
    }

    if ((Provider.of<UserProvider>(context, listen: false).userData.roleType == 2) &&
        Provider.of<UserProvider>(context, listen: false).userData.grade == null) {
        pagesToCompleteProfileIfo.add(LevelsScreen(screen_title: 'Grade', section: 'Complete',));
    }

    if ((Provider.of<UserProvider>(context, listen: false).userData.roleType != 2) &&
        Provider.of<UserProvider>(context, listen: false).userData.band == null) {
        pagesToCompleteProfileIfo.add(LevelsScreen(screen_title: 'Level', section: 'Complete',));
      }

      if (Provider.of<UserProvider>(context, listen: false).userData.roleType == 2 &&
          Provider.of<UserProvider>(context, listen: false).userData.minAcceptedGrade == null) {
           pagesToCompleteProfileIfo.add(LevelsScreen(section: 'Complete', screen_title: 'Minimum Accepted Grade',));
      }

      if ((Provider.of<UserProvider>(context, listen: false).userData.roleType != 2) &&
          Provider.of<UserProvider>(context, listen: false).userData.minAcceptedBand == null) {
          pagesToCompleteProfileIfo.add(LevelsScreen(screen_title: 'Minimum Accepted Level', section: 'Complete',));
      }

    if (Provider.of<UserProvider>(context, listen: false).userData.wards == null ||
        Provider.of<UserProvider>(context, listen: false).userData.wards.isEmpty) {
        pagesToCompleteProfileIfo.add(AreaOfWork());
    }

    if (Provider.of<UserProvider>(context, listen: false).userData.languages == null ||
        Provider.of<UserProvider>(context, listen: false).userData.languages.isEmpty) {
        pagesToCompleteProfileIfo.add(LanguagesScreen());
    }

    super.initState();

  }


  final PageController _pageController = PageController(initialPage: 0,
    keepPage: true,);
  int currentIndex=0;

  void onSkipPage(int index) {
    if (index+1<pagesToCompleteProfileIfo.length) {
      _pageController.animateToPage(index+1,
          duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  void onPreviousPage(int index) {
    if (index>0 && index<pagesToCompleteProfileIfo.length) {
      _pageController.animateToPage(index-1,
          duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context).userData;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: pagesToCompleteProfileIfo,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (int pageIndex){
              setState(() {
                currentIndex = pageIndex;
              });
            },

          ),
          Positioned(
            bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey[200],
            width: media.width,
            height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      // width:80,
                      child:
                      // currentIndex == 0
                      //     ?
                      const SizedBox()
                      //     :
                      // InkWell(
                      //   child: Text('previous',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 16),),
                      //   onTap: (){
                      //     onPreviousPage(currentIndex);
                      //   },
                      // ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: pagesToCompleteProfileIfo.length,
                        effect: WormEffect(
                          activeDotColor: Theme.of(context).primaryColor,
                          dotColor: Colors.grey[400],
                          radius: 8,
                          spacing: 10,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      ),
                    ),

                    Container(
                      // width:80,
                      child: _isUpdatingProfile ? SpinKitCircle(color: Theme.of(context).primaryColor,size: 30,):
                      InkWell(child: (userProvider.rolesIdsForCompletingProfile == null || userProvider.rolesIdsForCompletingProfile.isEmpty) &&
                          (userProvider.levelForCompletingProfile == null) &&
                          (userProvider.minAcceptedLevelForCompletingProfile == null) &&
                          (userProvider.areaOfWorkIdsForCompletingProfile == null || userProvider.areaOfWorkIdsForCompletingProfile.isEmpty) &&
                          (userProvider.languagesIdsForCompletingProfile == null || userProvider.languagesIdsForCompletingProfile.isEmpty)
                              ?
                        const SizedBox()
                            :
                          /// this code is to hide finish button in case there is anything missing at any page !!
                          (((userProvider.rolesIdsForCompletingProfile == null || userProvider.rolesIdsForCompletingProfile.isEmpty) && (userProvider.userData.roles == null || userProvider.userData.roles.isEmpty)) ||
                          (userProvider.levelForCompletingProfile == null && userProvider.userData.band == null && userProvider.userData.grade == null) ||
                          (userProvider.minAcceptedLevelForCompletingProfile == null && userProvider.userData.minAcceptedBand == null && userProvider.userData.minAcceptedGrade == null) ||
                          ((userProvider.areaOfWorkIdsForCompletingProfile == null || userProvider.areaOfWorkIdsForCompletingProfile.isEmpty) && (userProvider.userData.wards == null || userProvider.userData.wards.isEmpty)) ||
                          (userProvider.languagesIdsForCompletingProfile == null || userProvider.languagesIdsForCompletingProfile.isEmpty) && (userProvider.userData.languages == null || userProvider.userData.languages.isEmpty))
                          && currentIndex == pagesToCompleteProfileIfo.length -1
                          ?
                      const SizedBox():
                        Text(currentIndex == pagesToCompleteProfileIfo.length -1
                            ?
                          'finish' : 'Next',
                          style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 16),
                        ),
                        // the second part of this condition is to update the Level so the min_accepted_level list gets the correct values
                        onTap: currentIndex == pagesToCompleteProfileIfo.length -1 || pagesToCompleteProfileIfo[currentIndex].toString() == "LevelsScreen" ?
                            () async {
                          setState(() {
                            _isUpdatingProfile = true;
                          });

                           Provider.of<UserProvider>(context, listen: false).updateProfile(context,

                              email: userData.email,
                              firstName: userData.firstName,
                              lastName: userData.lastName,
                              trustId: userData.trust['id'],
                              phoneNumber: userData.phone,
                              employeeNumber: userData.employee_number,
                              userType: userData.roleType,

                              languages: (userProvider.languagesIdsForCompletingProfile != null && userProvider.languagesIdsForCompletingProfile.isNotEmpty) ? userProvider.languagesIdsForCompletingProfile : null,

                              wards: (userProvider.areaOfWorkIdsForCompletingProfile != null && userProvider.areaOfWorkIdsForCompletingProfile.isNotEmpty) ? userProvider.areaOfWorkIdsForCompletingProfile : null,

                              roles: (userProvider.rolesIdsForCompletingProfile != null && userProvider.rolesIdsForCompletingProfile.isNotEmpty) ? userProvider.rolesIdsForCompletingProfile : null,

                              levelId: userData.roleType == 2 ? userData.grade != null ? userData.grade['id'] : userProvider.levelForCompletingProfile == null ? null : userProvider.levelForCompletingProfile.id :
                              userData.band != null ? userData.band['id'] : userProvider.levelForCompletingProfile == null ? null : userProvider.levelForCompletingProfile.id,

                              minimumLevelId: userData.roleType == 2 ? userData.minAcceptedGrade != null ? userData.minAcceptedGrade['id'] : userProvider.minAcceptedLevelForCompletingProfile == null ? null : userProvider.minAcceptedLevelForCompletingProfile.id
                                   : userData.minAcceptedBand != null ? userData.minAcceptedBand['id'] :  userProvider.minAcceptedLevelForCompletingProfile == null ? null : userProvider.minAcceptedLevelForCompletingProfile.id,

                             isFromCompleteProfile: true,

                          ).then((_) {
                            setState(() {
                              _isUpdatingProfile = false;
                            });
                            if (pagesToCompleteProfileIfo[currentIndex].toString() == "LevelsScreen" && currentIndex != pagesToCompleteProfileIfo.length -1) {
                              onSkipPage(currentIndex);
                            }
                          });
                        }
                        : (){
                          onSkipPage(currentIndex);
                        },
                      ),
                    )
                  ],
                ),
          )
          )
        ],
      ),
    );
  }
}
