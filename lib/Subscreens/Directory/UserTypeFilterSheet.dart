import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';

class UserTypeFilterSheet extends StatefulWidget {
  final double width;
  final double height;
  final fetchParentRole;
  final popSheetFunction;
  final onDoneFunction;
  UserTypeFilterSheet(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.fetchParentRole,
      @required this.popSheetFunction,
      @required this.onDoneFunction})
      : super(key: key);

  @override
  _UserTypeFilterSheetState createState() => _UserTypeFilterSheetState();
}

class _UserTypeFilterSheetState extends State<UserTypeFilterSheet> {
  bool anySelected = false;
  bool doctorSelected = true;
  bool clinicalSelected = false;
  bool nonClinicalSelected = false;
  bool doneAllowed = false;
  int currentSelection = 2;

  @override
  initState() {
    super.initState();
    if(Provider.of<DiscoveryProvider>(context, listen:false).activeFilteringParameters.roleType != null){
      currentSelection = Provider.of<DiscoveryProvider>(context, listen:false).activeFilteringParameters.roleType;
      anySelected = currentSelection == 0;
      doctorSelected = currentSelection == 2;
      clinicalSelected = currentSelection == 1;
      nonClinicalSelected = currentSelection == 3;
      doneAllowed = false;
    }
  }

  void checkIfDoneAllowed() {
    final int parentRole = widget.fetchParentRole();
    if (currentSelection == parentRole) {
      doneAllowed = false;
    } else {
      doneAllowed = true;
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          const SizedBox(height: 12.0),
          ListTile(
            leading: IconButton(
              onPressed: () {
                setState(() {
                  currentSelection = widget.fetchParentRole();
                  anySelected = currentSelection == 0;
                  doctorSelected = currentSelection == 2;
                  clinicalSelected = currentSelection == 1;
                  nonClinicalSelected = currentSelection == 3;
                  doneAllowed = false;
                });
                widget.popSheetFunction();
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.blue,
              iconSize: 32,
            ),
            title: Center(
                child: Text(
              'User Type',
              style: Theme.of(context).textTheme.headline6,
            )),
            trailing: TextButton(
              onPressed: doneAllowed
                  ? () {
                      widget.onDoneFunction(currentSelection);
                      widget.popSheetFunction();
                      setState(() {
                        doneAllowed = false;
                      });
                    }
                  : null,
              child: Text('Done',
                  style:
                      Theme.of(context).textTheme.bodyText1.copyWith(color: doneAllowed ? Colors.blue : Colors.grey)),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    setState(() {
                      currentSelection = 0;
                      anySelected = !anySelected;
                      doctorSelected = false;
                      clinicalSelected = false;
                      nonClinicalSelected = false;
                      checkIfDoneAllowed();
                    });
                  },
                  leading: Text('Any', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(anySelected ? Icons.check : null, color: Theme.of(context).primaryColor),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      currentSelection = 2;
                      anySelected = false;
                      doctorSelected = !doctorSelected;
                      clinicalSelected = false;
                      nonClinicalSelected = false;
                      checkIfDoneAllowed();
                    });
                  },
                  leading: Text('Doctor', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(doctorSelected ? Icons.check : null, color: Theme.of(context).primaryColor),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      currentSelection = 1;
                      anySelected = false;
                      doctorSelected = false;
                      clinicalSelected = !clinicalSelected;
                      nonClinicalSelected = false;
                      checkIfDoneAllowed();
                    });
                  },
                  leading: Text('Clinical', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(clinicalSelected ? Icons.check : null, color: Theme.of(context).primaryColor),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      currentSelection = 3;
                      anySelected = false;
                      doctorSelected = false;
                      clinicalSelected = false;
                      checkIfDoneAllowed();
                      nonClinicalSelected = !nonClinicalSelected;
                    });
                  },
                  leading: Text('Non-clinical', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(nonClinicalSelected ? Icons.check : null, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
