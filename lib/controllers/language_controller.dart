import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  // اللغة الحالية - العربية افتراضياً
  var currentLanguage = 'ar'.obs;
  var isArabic = true.obs;

  // مفتاح التخزين
  static const String _languageKey = 'language';

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  // تحميل اللغة المحفوظة - إذا لم توجد تكون العربية
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // العربية هي الافتراضية إذا لم يتم حفظ لغة مسبقاً
      final savedLanguage = prefs.getString(_languageKey) ?? 'ar';
      currentLanguage.value = savedLanguage;
      isArabic.value = savedLanguage == 'ar';
      _applyLanguage();
    } catch (e) {
      // في حالة الخطأ، استخدم العربية
      currentLanguage.value = 'ar';
      isArabic.value = true;
      print('Error loading language: $e');
    }
  }
// تغيير اللغة مع إعادة بناء GetMaterialApp
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    isArabic.value = languageCode == 'ar';
    await _saveLanguage();
    _applyLanguage();
    
    // 🔥 هذا السطر مهم لإعادة بناء التطبيق بأكمله
    Get.forceAppUpdate();
  }
  // تبديل اللغة
  Future<void> toggleLanguage() async {
    if (isArabic.value) {
      await changeLanguage('en');
    } else {
      await changeLanguage('ar');
    }
  }

  // حفظ اللغة
  Future<void> _saveLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, currentLanguage.value);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  // تطبيق اللغة
  void _applyLanguage() {
    final locale = Locale(currentLanguage.value);
    Get.updateLocale(locale);
  }

  // الحصول على Locale الحالي
  Locale get locale => Locale(currentLanguage.value);

  // الحصول على اسم اللغة
  String get languageName => isArabic.value ? 'العربية' : 'English';
}