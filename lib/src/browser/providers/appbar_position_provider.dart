import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';

enum AppBarPosition {
  top,
  bottom,
}

class AppBarPositionProvider extends ChangeNotifier {
  final List<AppBarPosition> positions = AppBarPosition.values;

  AppBarPosition _selectedPosition = AppBarPosition.top;

  AppBarPosition get selectedPosition => _selectedPosition;

  Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString('appbars_position');

    _selectedPosition = AppBarPosition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppBarPosition.top,
    );

    notifyListeners();
  }

  Future<void> changePosition(AppBarPosition position) async {
    _selectedPosition = position;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appbars_position', position.name);

    notifyListeners();
  }
}