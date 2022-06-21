import 'package:flutter/material.dart';
import 'package:rightnurse/Providers/DiscoveryProvider.dart';

class ListFilterSheet extends StatefulWidget {
  final double width;
  final double height;
  final String sheetTitle;
  final Map<String, String> items;
  final List<String> currentItemFilters;
  final popSheetFunction;
  final onDoneFunction;

  ListFilterSheet(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.sheetTitle,
      @required this.items,
      @required this.currentItemFilters,
      @required this.popSheetFunction,
      @required this.onDoneFunction})
      : super(key: key);

  @override
  _ListFilterSheetState createState() => _ListFilterSheetState();
}

class _ListFilterSheetState extends State<ListFilterSheet> {
  bool doneAllowed = false;
  List<String> selectedIdsList = [];
  Map<String, bool> isItemSelected = {};
  ScrollController scScrollController;

  @override
  initState() {
    super.initState();
    scScrollController = ScrollController();
    setSelectedListToCurrentGlobalFilters();
  }

  @override
  void dispose() {
    scScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ListFilterSheet oldWidget) {
    setSelectedListToCurrentGlobalFilters();
    super.didUpdateWidget(oldWidget);
  }

  void checkIfDoneAllowed() {
    setState(() {
      // need to check if the same as passed in...
      doneAllowed = true;
    });
  }

  void createReturnIdsList() {
    doneAllowed = false;
    isItemSelected.forEach((key, value) {
      if (value) {
        selectedIdsList.add(key);
      }
    });
  }

  void setSelectedListToCurrentGlobalFilters() {
    isItemSelected = {};
    widget.items.forEach((key, value) {
      isItemSelected[key] = false;
      if (widget.currentItemFilters.contains(key)) {
        isItemSelected[key] = true;
      }
    });
  }

  void selectAllItems() {
    setState(() {
      isItemSelected = {};
      widget.items.forEach((key, value) {
        if (!value.contains(DiscoveryProvider.kDiscoveryHeaderPrefix)) {
          isItemSelected[key] = true;
        }
      });
    });
    checkIfDoneAllowed();
  }

  void clearAllItems() {
    setState(() {
      isItemSelected = {};
      widget.items.forEach((key, value) {
        isItemSelected[key] = false;
      });
    });
    checkIfDoneAllowed();
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
                  doneAllowed = false;
                });
                scScrollController.jumpTo(0.0);
                setSelectedListToCurrentGlobalFilters();
                widget.popSheetFunction();
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.blue,
              iconSize: 32,
            ),
            title: Center(child: Text(widget.sheetTitle, style: Theme.of(context).textTheme.headline6)),
            trailing: TextButton(
              onPressed: doneAllowed
                  ? () {
                      createReturnIdsList();
                      widget.onDoneFunction(selectedIdsList);
                      selectedIdsList = [];
                      scScrollController.jumpTo(0.0);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: () => selectAllItems(), child: Text('Select All')),
              TextButton(
                  onPressed: () => clearAllItems(),
                  child: Text('Clear All', style: TextStyle(color: Theme.of(context).errorColor))),
            ],
          ),
          const Divider(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                controller: scScrollController,
                child: Column(
                    children: widget.items.entries.map((entry) {
                  final bool isHeader = entry.value.contains(DiscoveryProvider.kDiscoveryHeaderPrefix);
                  String itemName = entry.value;
                  if (isHeader) {
                    itemName = itemName.substring(DiscoveryProvider.kDiscoveryHeaderPrefix.length);
                  }
                  final Color tileColor = isHeader ? Colors.blue : Colors.black;
                  return ListTile(
                    onTap: () {
                      if (!isHeader) {
                        setState(() {
                          isItemSelected[entry.key] = !isItemSelected[entry.key];
                          checkIfDoneAllowed();
                        });
                      }
                    },
                    leading: Text(itemName, style: Theme.of(context).textTheme.bodyText1.copyWith(color: tileColor)),
                    trailing: isHeader
                        ? const SizedBox(width: 1)
                        : Icon(isItemSelected[entry.key] ? Icons.check : null, color: Theme.of(context).primaryColor),
                  );
                }).toList()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
