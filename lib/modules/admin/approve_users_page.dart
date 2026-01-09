import 'package:cozy_app/widget/safe-netowrk_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/admin_controller.dart';


class ApproveUsersPage extends StatefulWidget {
  const ApproveUsersPage({super.key});

  @override
  State<ApproveUsersPage> createState() => _ApproveUsersPageState();
}

class _ApproveUsersPageState extends State<ApproveUsersPage> {
  final adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    adminController.fetchPendingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات المستخدمين"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Obx(() {
        if (adminController.isLoadingUsers.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (adminController.pendingUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 80, color: Colors.green.shade300),
                const SizedBox(height: 16),
                const Text(
                  "لا توجد طلبات معلقة",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "جميع المستخدمين تمت مراجعتهم",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => adminController.fetchPendingUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: adminController.pendingUsers.length,
            itemBuilder: (context, index) {
              final user = adminController.pendingUsers[index];
              return _buildUserCard(user);
            },
          ),
        );
      }),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String firstName = user['first_name'] ?? '';
    final String lastName = user['last_name'] ?? '';
    final String phone = user['phone'] ?? '';
    final String role = user['role'] ?? '';
    final String? userImage = user['user_image_url'];
    final String? idImage = user['id_image_url'];
    final String birthDate = user['birth_date'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المستخدم الأساسية
            Row(
              children: [
                // صورة المستخدم
                SafeCircleAvatar(
                  imageUrl: userImage,
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$firstName $lastName",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(phone,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                // نوع المستخدم
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: role == 'owner'
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role == 'owner' ? 'مالك' : 'مستأجر',
                    style: TextStyle(
                      color: role == 'owner' ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // معلومات إضافية
            Row(
              children: [
                const Icon(Icons.cake, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text("تاريخ الميلاد: $birthDate",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),

            // صورة الهوية
            if (idImage != null) ...[
              const SizedBox(height: 12),
              const Text("صورة الهوية:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SafeNetworkImage(
                imageUrl: idImage,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                errorWidget: Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "فشل تحميل الصورة",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // أزرار القبول والرفض
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveUser(user['id']),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label:
                    const Text("قبول", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectUser(user['id']),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label:
                    const Text("رفض", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _approveUser(int userId) {
    Get.defaultDialog(
      title: "تأكيد القبول",
      middleText: "هل تريد قبول هذا المستخدم؟",
      textConfirm: "قبول",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () async {
        Get.back();
        try {
          await adminController.approveUser(userId);
          Get.snackbar("تم", "تم قبول المستخدم بنجاح",
              backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("خطأ", e.toString(),
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  void _rejectUser(int userId) {
    Get.defaultDialog(
      title: "تأكيد الرفض",
      middleText: "هل تريد رفض هذا المستخدم؟",
      textConfirm: "رفض",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await adminController.rejectUser(userId);
          Get.snackbar("تم", "تم رفض المستخدم",
              backgroundColor: Colors.orange, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("خطأ", e.toString(),
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }
}