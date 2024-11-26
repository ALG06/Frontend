import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends ChangeNotifier {
  late final SharedPreferences prefs;
  late final String name;
  late final String id;

  UserService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? '';
    id = prefs.getString('id') ?? '';

    notifyListeners();
  }
}
