import 'package:flutter/material.dart';

enum HomeView {
  home,
  tabs,
  changeNode,
  aichat,
}

class BottomNavigationProvider extends ChangeNotifier {

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;



    HomeView _currentView = HomeView.home;

  HomeView get currentView => _currentView;

  void changeView(HomeView view) {
    _currentView = view;
    notifyListeners();
  }

  bool get showBottomNav =>
      _currentView == HomeView.home;

  void changeIndex(int index) {
    if (_currentIndex == index) return;

    _currentIndex = index;
    notifyListeners();
  }

void gotoChangeNode(){
   if (_currentIndex == 1) return;

    _currentIndex = 1;
    notifyListeners();
}


  void goHome() {
    if (_currentIndex == 0) return;

    _currentIndex = 0;
    notifyListeners();
  }

  bool get isHome => _currentIndex == 0;



}