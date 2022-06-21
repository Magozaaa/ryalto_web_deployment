import 'package:flutter/material.dart';



class ChangeIndex with ChangeNotifier {

  int index = 2;
  int current;
  bool isMain = false;

  get currentIndex => this.current;

  void changeIndexFunction(int index) {
    this.index = index;
    this.current = index;
    this.isMain = true;
    notifyListeners();
  }

}