import 'package:cozy_app/controllers/language_controller.dart';
import 'package:cozy_app/widget/safe-netowrk_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';

// أضف هذا الاستيراد

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

//   final authController = Get.find<AuthController>();

//   final themeController = Get.find<ThemeController>();

// final languageController = Get.find<LanguageController>(); 
 // أضف هذا
  @override
  Widget build(BuildContext context) {

  final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>(); // ✅ مهم
    
    final user = authController.currentUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // صورة البروفايل
            SafeCircleAvatar(
              imageUrl: user?.userImageUrl,
              radius: 60,
              backgroundColor: Colors.teal.shade100,
              fallbackIcon: Icons.person,
              fallbackIconColor: Colors.teal,
            ),
            const SizedBox(height: 15),

            // اسم المستخدم
            Text(
              "${user?.firstName ?? ''} ${user?.lastName ?? ''}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.teal.shade200 : Colors.teal,
              ),
            ),
            const SizedBox(height: 5),

            // نوع الحساب
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user?.role),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getRoleText(user?.role),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),

            // بطاقة المعلومات
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.phone, "رقم الهاتف", user?.phone ?? ''),
                    const Divider(),
                    _buildInfoRow(Icons.cake, "تاريخ الميلاد", user?.birthDate ?? ''),
                    const Divider(),
                    _buildInfoRow(
                      Icons.verified,
                      "حالة الحساب",
                      _getStatusText(user?.status),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // بطاقة الإعدادات
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "الإعدادات",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),


  // خيار اللغة
                      // خيار اللغة - تم التصحيح
                    Obx(() => ListTile(
                      leading: Icon(
                        languageController.isArabic.value  // ✅ صحح الخطأ هنا
                            ? Icons.language
                            : Icons.language_outlined,
                        color: Colors.blue,
                      ),
                      title: const Text("اللغة"),  // يمكنك استخدام 'language'.tr إذا أضفت الترجمات
                      subtitle: Text(
                        languageController.languageName,
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      trailing: Switch(
                        value: languageController.isArabic.value,
                        onChanged: (value) {
                          languageController.toggleLanguage();
                        },
                        activeColor: Colors.blue,
                      ),
                      onTap: () {
                        languageController.toggleLanguage();
                      },
                    )),


                    // زر الوضع الليلي
                    Obx(() => ListTile(
                      leading: Icon(
                        themeController.isDarkMode.value
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Colors.teal,
                      ),
                      title: const Text("الوضع الليلي"),
                      subtitle: Text(
                        themeController.isDarkMode.value
                            ? "مفعّل"
                            : "معطّل",
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      trailing: Switch(
                        value: themeController.isDarkMode.value,
                        onChanged: (value) {
                          themeController.toggleTheme();
                        },
                        activeColor: Colors.teal,
                      ),
                      onTap: () {
                        themeController.toggleTheme();
                      },
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // زر تعديل الملف الشخصي
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // _showEditDialog();
                    _showEditDialog(authController); 
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "تعديل الملف الشخصي",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // _showLogoutConfirmation();
                    _showLogoutConfirmation(authController); 
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'owner':
        return Colors.orange;
      case 'renter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRoleText(String? role) {
    switch (role) {
      case 'admin':
        return 'مدير';
      case 'owner':
        return 'مالك';
      case 'renter':
        return 'مستأجر';
      default:
        return 'مستخدم';
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'approved':
        return 'مفعّل ✔';
      case 'pending':
        return 'قيد الانتظار';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }


void _showLogoutConfirmation(AuthController authController) {
    Get.defaultDialog(
  // void _showLogoutConfirmation() {
  //   Get.defaultDialog(
      title: "تسجيل الخروج",
      middleText: "هل أنت متأكد من تسجيل الخروج؟",
      textConfirm: "نعم",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        authController.logout();
      },
    );
  }

  // void _showEditDialog() {
  //   final phoneController = TextEditingController(
  //     text: authController.currentUser.value?.phone ?? '',
  //   );
  //   final passwordController = TextEditingController();
  //   final confirmPasswordController = TextEditingController();

void _showEditDialog(AuthController authController) {
    final phoneController = TextEditingController(
      text: authController.currentUser.value?.phone ?? '',
    );
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();



    Get.dialog(
      AlertDialog(
        title: const Text("تعديل الملف الشخصي"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "رقم الهاتف",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "كلمة السر الجديدة",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  hintText: "اتركها فارغة إذا لا تريد التغيير",
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "تأكيد كلمة السر",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                if (passwordController.text.length < 8) {
                  Get.snackbar("خطأ", "كلمة السر يجب أن تكون 8 أحرف على الأقل",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                if (passwordController.text != confirmPasswordController.text) {
                  Get.snackbar("خطأ", "كلمة السر غير متطابقة",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
              }

              Get.back();
              Get.snackbar("نجاح", "تم حفظ التغييرات",
                  backgroundColor: Colors.green, colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("حفظ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}