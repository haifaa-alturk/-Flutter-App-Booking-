import 'dart:io';
import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final authController = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "الحقل مطلوب";
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "الحقل مطلوب";
    }
    if (value.length < 8) {
      return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
    }
    return null;
  }

  String? _birthDateValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "الحقل مطلوب";
    }
    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!datePattern.hasMatch(value)) {
      return "الصيغة المطلوبة: YYYY-MM-DD";
    }
    return null;
  }

  // Profile Image
  Future<void> pickProfileImage() async {
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // تقليل جودة الصورة لتقليل الحجم
      );
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          if (bytes.isNotEmpty) {
            authController.profileImageBytes.value = bytes;
          } else {
            Get.snackbar("خطأ", "فشل قراءة الصورة",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          final file = File(picked.path);
          if (await file.exists()) {
            authController.profileImage.value = file;
          } else {
            Get.snackbar("خطأ", "الملف غير موجود",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        }
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل اختيار الصورة: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ID Image
  Future<void> pickIdImage() async {
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // تقليل جودة الصورة لتقليل الحجم
      );
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          if (bytes.isNotEmpty) {
            authController.idImageBytes.value = bytes;
          } else {
            Get.snackbar("خطأ", "فشل قراءة الصورة",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          final file = File(picked.path);
          if (await file.exists()) {
            authController.idImage.value = file;
          } else {
            Get.snackbar("خطأ", "الملف غير موجود",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        }
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل اختيار الصورة: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 248, 247),
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 15),

              // Profile Image
              Obx(() {
                final bytes = authController.profileImageBytes.value;
                final ImageProvider<Object>? profileImageProvider = kIsWeb
                    ? (bytes != null ? MemoryImage(bytes) : null)
                    : (authController.profileImage.value != null
                    ? FileImage(authController.profileImage.value!)
                    : null);
                return GestureDetector(
                  onTap: pickProfileImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profileImageProvider,
                    child: (kIsWeb ? bytes == null : authController.profileImage.value == null)
                        ? const Icon(Icons.camera_alt,
                        size: 35, color: Colors.black54)
                        : null,
                  ),
                );
              }),
              const SizedBox(height: 5),
              const Text("صورة البروفايل (مطلوبة)", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 15),

              // PHONE
              TextFormField(
                controller: authController.regPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  filled: true,
                  fillColor: Color.fromARGB(118, 212, 214, 188),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "هذا الحقل مطلوب";
                  }
                  if (value.length != 10) {
                    return "الرقم يجب أن يكون 10 خانات";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // PASSWORD
              Obx(() => TextFormField(
                controller: authController.regPasswordController,
                obscureText: authController.regPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: "Password (8+ characters)",
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: const Color.fromARGB(118, 212, 214, 188),
                  suffixIcon: IconButton(
                    icon: Icon(authController.regPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => authController.regPasswordVisible.value =
                    !authController.regPasswordVisible.value,
                  ),
                ),
                validator: _passwordValidator,
              )),
              const SizedBox(height: 10),

              // FIRST NAME
              TextFormField(
                controller: authController.regFirstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Color.fromARGB(118, 212, 214, 188),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 10),

              // LAST NAME
              TextFormField(
                controller: authController.regLastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Color.fromARGB(118, 212, 214, 188),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: authController.regBirthdayController,
                decoration: const InputDecoration(
                  labelText: "Birthday (YYYY-MM-DD)",
                  prefixIcon: Icon(Icons.date_range),
                  filled: true,
                  fillColor: Color.fromARGB(118, 212, 214, 188),
                ),
                validator: _birthDateValidator,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.credit_card, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: pickIdImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (kIsWeb
                            ? authController.idImageBytes.value != null
                            : authController.idImage.value != null)
                            ? Colors.green.shade100
                            : null,
                      ),
                      child: Text(
                        kIsWeb
                            ? (authController.idImageBytes.value == null
                            ? "Upload ID Image (مطلوب)"
                            : "✓ ID Image Selected")
                            : authController.idImage.value == null
                            ? "Upload ID Image (مطلوب)"
                            : "✓ ID Image Selected",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 26, 107, 81)),
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              GetBuilder<AuthController>(
                builder: (controller) {
                  return Column(
                    children: [
                      ListTile(
                        title: const Text("Tenant (مستأجر)"),
                        leading: Radio<UserType>(
                          value: UserType.tenant,
                          groupValue: controller.userType,
                          onChanged: (value) {
                            if (value != null) controller.setUser(value);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text("Owner (مالك)"),
                        leading: Radio<UserType>(
                          value: UserType.owner,
                          groupValue: controller.userType,
                          onChanged: (value) {
                            if (value != null) controller.setUser(value);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      authController.register();
                    }
                  },
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                        color: Color.fromARGB(255, 26, 107, 81)),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}