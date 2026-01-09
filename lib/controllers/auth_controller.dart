import 'dart:io';

import 'package:cozy_app/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

enum UserType { tenant, owner }

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // LOGIN
  TextEditingController loginPhoneController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  // REGISTER
  TextEditingController regPhoneController = TextEditingController();
  TextEditingController regPasswordController = TextEditingController();
  TextEditingController regFirstNameController = TextEditingController();
  TextEditingController regLastNameController = TextEditingController();
  TextEditingController regBirthdayController = TextEditingController();

  Rx<File?> profileImage = Rx<File?>(null);
  Rx<File?> idImage = Rx<File?>(null);
  Rx<Uint8List?> profileImageBytes = Rx<Uint8List?>(null);
  Rx<Uint8List?> idImageBytes = Rx<Uint8List?>(null);

  UserType userType = UserType.tenant;

  RxBool isLoading = false.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxString token = "".obs;
  RxBool regPasswordVisible = true.obs;

  UserModel? get tempUser => currentUser.value;

  void setUser(UserType type) {
    userType = type;
    update();
  }

  // LOGIN
  Future<void> login() async {
    try {
      isLoading.value = true;

      final res = await _authService.login(
        phone: loginPhoneController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      currentUser.value = res.user;
      token.value = res.token;

      // التوجيه حسب نوع المستخدم
      _navigateBasedOnRole();
    } catch (_) {
      Get.snackbar("خطأ", "بيانات الدخول غير صحيحة",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // التوجيه حسب دور المستخدم
  void _navigateBasedOnRole() {
    final role = currentUser.value?.role;

    if (role == 'admin') {
      // توجيه Admin إلى لوحة التحكم
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      // توجيه المستأجر أو المالك إلى الصفحة الرئيسية
      Get.offAllNamed(AppRoutes.mainPage);
    }
  }

  // REGISTER
  Future<void> register() async {
    final hasProfileImage = kIsWeb
        ? profileImageBytes.value != null
        : profileImage.value != null;
    final hasIdImage = kIsWeb ? idImageBytes.value != null : idImage.value != null;

    if (!hasProfileImage || !hasIdImage) {
      Get.snackbar("خطأ", "الصور مطلوبة",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final res = await _authService.register(
        phone: regPhoneController.text.trim(),
        password: regPasswordController.text.trim(),
        firstName: regFirstNameController.text.trim(),
        lastName: regLastNameController.text.trim(),
        birthDate: regBirthdayController.text.trim(),
        role: userType == UserType.owner ? "owner" : "renter",
        userImage: profileImage.value,
        idImage: idImage.value,
        userImageBytes: profileImageBytes.value,
        idImageBytes: idImageBytes.value,
      );

      currentUser.value = res.user;

      Get.snackbar("نجاح", res.message,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar("خطأ", message.isEmpty ? "فشل إنشاء الحساب" : message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // LOGOUT
  void logout() {
    // مسح بيانات المستخدم
    currentUser.value = null;
    token.value = "";

    // مسح حقول تسجيل الدخول
    loginPhoneController.clear();
    loginPasswordController.clear();

    // الانتقال لصفحة تسجيل الدخول
    Get.offAllNamed(AppRoutes.login);

    Get.snackbar("تم", "تم تسجيل الخروج بنجاح",
        backgroundColor: Colors.green, colorText: Colors.white);
  }
}