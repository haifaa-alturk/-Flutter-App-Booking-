import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // حالة الثيم
  var isDarkMode = false.obs;

  // مفتاح التخزين
  static const String _themeKey = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // تحميل الثيم المحفوظ
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool(_themeKey) ?? false;
      _applyTheme();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  // تبديل الثيم
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _saveTheme();
    _applyTheme();
  }

  // تعيين الثيم
  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    await _saveTheme();
    _applyTheme();
  }

  // حفظ الثيم
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDarkMode.value);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  // تطبيق الثيم
  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // الحصول على ThemeMode الحالي
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}