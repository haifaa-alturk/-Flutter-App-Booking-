import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:cozy_app/controllers/language_controller.dart';
import 'package:cozy_app/controllers/theme_controller.dart';
import 'package:cozy_app/config/app_themes.dart';
import 'package:cozy_app/OnboardingScreens/onboarding.dart';
import 'package:cozy_app/localization/app_translations.dart';
import 'package:cozy_app/modules/auth/login_page.dart';
import 'package:cozy_app/modules/auth/register_page.dart';
import 'package:cozy_app/modules/home/home_page.dart';
import 'package:cozy_app/modules/home/main_page.dart';
import 'package:cozy_app/modules/admin/admin_dashboard.dart';
import 'package:cozy_app/modules/admin/approve_users_page.dart';
import 'package:cozy_app/modules/admin/approve_apartments_page.dart';
import 'package:cozy_app/routes/app_bindings.dart';
import 'package:cozy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // المهم: يجب أن تسجل LanguageController أولاً
  Get.put(LanguageController(), permanent: true);
  

  AppBindings().dependencies();

  // تسجيل ThemeController
  Get.put(ThemeController());

 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

final languageController = Get.find<LanguageController>(); // إضافة هذا


    // تحديد الصفحة الأولى حسب حالة تسجيل الدخول ونوع المستخدم
    String initialRoute;
    if (authController.token.value.isNotEmpty) {
      if (authController.currentUser.value?.role == 'admin') {
        initialRoute = AppRoutes.adminDashboard;
      } else {
        initialRoute = AppRoutes.mainPage;
      }
    } else {
      initialRoute = AppRoutes.OnBoardingBody;
    }

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cozy App',

// ✅ إضافة الترجمات هنا
      translations: AppTranslations(), // تأكد أن AppTranslations موجود
      locale: languageController.locale, // استخدم locale من controller
      fallbackLocale: const Locale('ar'),



      // الثيمات
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,

      initialRoute: initialRoute,
      getPages: [
        // Auth Routes
        GetPage(name: AppRoutes.OnBoardingBody, page: () => OnBoardingScreen()),
        GetPage(name: AppRoutes.login, page: () => LoginPage()),
        GetPage(name: AppRoutes.registration, page: () => RegisterPage()),

        // Main Routes
        GetPage(name: AppRoutes.homePage, page: () => HomePage()),
        GetPage(name: AppRoutes.mainPage, page: () => const MainPage()),

        // Admin Routes
        GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboard()),
        GetPage(name: AppRoutes.approveUsers, page: () => const ApproveUsersPage()),
        GetPage(name: AppRoutes.approveApartments, page: () => const ApproveApartmentsPage()),
      ],
    ));
  }
}