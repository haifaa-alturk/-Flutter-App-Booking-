import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/admin_controller.dart';
import 'package:cozy_app/controllers/auth_controller.dart';
import 'approve_users_page.dart';
import 'approve_apartments_page.dart';
import 'manage_users_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final adminController = Get.put(AdminController());
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    adminController.fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.fetchAllData(),
            tooltip: "تحديث",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
            tooltip: "خروج",
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.teal,
        onRefresh: () => adminController.fetchAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ترحيب بسيط
              Text(
                "مرحباً، ${authController.currentUser.value?.firstName ?? 'Admin'}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "إدارة التطبيق",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // الإحصائيات
              Obx(() => Row(
                children: [
                  _buildStatCard(
                    title: "مستخدمين",
                    count: adminController.pendingUsersCount.value,
                    icon: Icons.person_outline,
                    onTap: () => Get.to(() => const ApproveUsersPage()),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: "شقق",
                    count: adminController.pendingApartmentsCount.value,
                    icon: Icons.apartment_outlined,
                    onTap: () => Get.to(() => const ApproveApartmentsPage()),
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // الإجراءات
              const Text(
                "الإدارة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _buildActionCard(
                title: "طلبات المستخدمين",
                subtitle: "قبول أو رفض المستخدمين الجدد",
                icon: Icons.people_outline,
                onTap: () => Get.to(() => const ApproveUsersPage()),
              ),
              const SizedBox(height: 10),

              _buildActionCard(
                title: "طلبات الشقق",
                subtitle: "قبول أو رفض الشقق المضافة",
                icon: Icons.home_work_outlined,
                onTap: () => Get.to(() => const ApproveApartmentsPage()),
              ),
              const SizedBox(height: 10),

              _buildActionCard(
                title: "إدارة المستخدمين",
                subtitle: "عرض وحذف المستخدمين",
                icon: Icons.manage_accounts_outlined,
                onTap: () => Get.to(() => const ManageUsersPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.teal),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.teal, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Get.defaultDialog(
      title: "تسجيل الخروج",
      middleText: "هل تريد تسجيل الخروج؟",
      textConfirm: "نعم",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        authController.logout();
        Get.back();
      },
    );
  }
}