import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  //final _getStorage = GetStorage();
  final _storageKey = 'isDarkMode';
  late bool isDarkMode;
  Future<ThemeMode> getThemeMode() async {
    isDarkMode = await isSavedDarkMode();
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<bool> isSavedDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storageKey) ?? false;
  }

  void saveThemeMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, isDarkMode);
  }

  void changeThemeMode() async {
    Get.changeThemeMode(
        await isSavedDarkMode() ? ThemeMode.light : ThemeMode.dark);
    saveThemeMode(!await isSavedDarkMode());
  }
}
