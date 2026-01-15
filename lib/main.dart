import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:cozy_app/controllers/booking_controller.dart';

import 'package:cozy_app/controllers/chat_controller.dart';
import 'package:cozy_app/controllers/favorites_controller.dart';
import 'package:cozy_app/controllers/language_controller.dart';
import 'package:cozy_app/controllers/owner_apartments_controller.dart';
import 'package:cozy_app/controllers/theme_controller.dart';
import 'package:cozy_app/config/app_themes.dart';
import 'package:cozy_app/OnboardingScreens/onboarding.dart';
import 'package:cozy_app/localization/app_translations.dart';
import 'package:cozy_app/modules/auth/login_page.dart';
import 'package:cozy_app/modules/auth/register_page.dart';
import 'package:cozy_app/modules/chat/chat_list_page.dart';
import 'package:cozy_app/modules/home/home_page.dart';
import 'package:cozy_app/modules/home/main_page.dart';
import 'package:cozy_app/modules/admin/admin_dashboard.dart';
import 'package:cozy_app/modules/admin/approve_users_page.dart';
import 'package:cozy_app/modules/admin/approve_apartments_page.dart';
// import 'package:cozy_app/routes/app_bindings.dart';
import 'package:cozy_app/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
// ✅ إضافة هذا الكود قبل أي شيء
  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message?.contains("KeyUpEvent") ?? false) {
        return; // تجاهل أخطاء KeyUpEvent
      }
      debugPrintSynchronously(message, wrapWidth: wrapWidth);
    };
  }

  // // المهم: يجب أن تسجل LanguageController أولاً
  // Get.put(LanguageController(), permanent: true);
  

  // AppBindings().dependencies();

  // // تسجيل ThemeController
  // Get.put(ThemeController());

 
// ✅ الخطوة 1: سجل الـ Controllers الأساسية فقط
  Get.put(LanguageController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  
  // ✅ الخطوة 2: أضف تأخير قبل تسجيل باقي الـ Controllers
  await Future.delayed(Duration(milliseconds: 300));
  
  // ✅ الخطوة 3: سجل AppBindings بشكل منفصل
  Get.put(AuthController(), permanent: true); // ✅ AuthController أولاً
  
  await Future.delayed(Duration(milliseconds: 200));
  
  // ✅ الخطوة 4: سجل باقي الـ Controllers
  Get.put(BookingController());
  Get.put(FavoritesController());
  Get.put(OwnerApartmentsController());
  Get.put(ChatController()); // ✅ الآن AuthController موجود مسبقاً
  
  print('✅ All controllers initialized successfully');
  

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

// ✅ أضف صفحة المراسلات هنا
        GetPage(name: AppRoutes.chatList, page: () => ChatListPage()),

        // Admin Routes
        GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboard()),
        GetPage(name: AppRoutes.approveUsers, page: () => const ApproveUsersPage()),
        GetPage(name: AppRoutes.approveApartments, page: () => const ApproveApartmentsPage()),

       
      ],
        builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        );
      },
    ));
  }
}