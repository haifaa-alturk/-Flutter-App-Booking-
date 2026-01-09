import 'package:cozy_app/widget/safe-netowrk_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/admin_controller.dart';


class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    adminController.fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة المستخدمين"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        if (adminController.isLoadingAllUsers.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (adminController.allUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "لا يوجد مستخدمين",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.teal,
          onRefresh: () => adminController.fetchAllUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: adminController.allUsers.length,
            itemBuilder: (context, index) {
              final user = adminController.allUsers[index];
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
    final String status = user['status'] ?? '';
    final String? userImage = user['user_image_url'];

    Color statusColor;
    String statusText;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'مفعّل';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'معلق';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: SafeCircleAvatar(
          imageUrl: userImage,
          radius: 28,
          backgroundColor: Colors.grey.shade200,
        ),
        title: Text(
          "$firstName $lastName",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // نوع المستخدم
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: role == 'owner' ? Colors.blue.shade50 : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    role == 'owner' ? 'مالك' : 'مستأجر',
                    style: TextStyle(
                      fontSize: 11,
                      color: role == 'owner' ? Colors.blue : Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // حالة الحساب
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(user['id'], "$firstName $lastName"),
        ),
      ),
    );
  }

  void _confirmDelete(int userId, String userName) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل تريد حذف المستخدم \"$userName\"؟\nسيتم حذف جميع بياناته وشققه وحجوزاته.",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await adminController.deleteUser(userId);
          Get.snackbar("تم", "تم حذف المستخدم بنجاح",
              backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("خطأ", e.toString().replaceFirst('Exception: ', ''),
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }
}