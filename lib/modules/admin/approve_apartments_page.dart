import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/admin_controller.dart';

class ApproveApartmentsPage extends StatefulWidget {
  const ApproveApartmentsPage({super.key});

  @override
  State<ApproveApartmentsPage> createState() => _ApproveApartmentsPageState();
}

class _ApproveApartmentsPageState extends State<ApproveApartmentsPage> {
  final adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    adminController.fetchPendingApartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات الشقق"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Obx(() {
        if (adminController.isLoadingApartments.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (adminController.pendingApartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 80, color: Colors.green.shade300),
                const SizedBox(height: 16),
                const Text(
                  "لا توجد شقق معلقة",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "جميع الشقق تمت مراجعتها",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => adminController.fetchPendingApartments(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: adminController.pendingApartments.length,
            itemBuilder: (context, index) {
              final apartment = adminController.pendingApartments[index];
              return _buildApartmentCard(apartment);
            },
          ),
        );
      }),
    );
  }

  Widget _buildApartmentCard(Map<String, dynamic> apartment) {
    final String title = apartment['title'] ?? 'بدون عنوان';
    final String description = apartment['description'] ?? '';
    final dynamic pricePerDay = apartment['price_per_day'] ?? 0;
    final int rooms = apartment['rooms'] ?? 0;
    final int area = apartment['area'] ?? 0;
    final String? mainImage = apartment['main_image'];
    final Map<String, dynamic>? owner = apartment['owner'];
    final Map<String, dynamic>? governorate = apartment['governorate'];
    final Map<String, dynamic>? city = apartment['city'];

    final String ownerName = owner != null
        ? "${owner['first_name'] ?? ''} ${owner['last_name'] ?? ''}"
        : 'غير معروف';
    final String ownerPhone = owner?['phone'] ?? '';
    final String location = governorate != null && city != null
        ? "${governorate['name']} - ${city['name']}"
        : 'غير محدد';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة الشقة
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: mainImage != null
                ? Image.network(
              mainImage,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.apartment,
                    size: 60, color: Colors.grey),
              ),
            )
                : Container(
              height: 180,
              color: Colors.grey.shade200,
              child: const Center(
                child:
                Icon(Icons.apartment, size: 60, color: Colors.grey),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان والسعر
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "\$$pricePerDay/يوم",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // الموقع
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 8),

                // المواصفات
                Row(
                  children: [
                    _buildSpec(Icons.bed, "$rooms غرف"),
                    const SizedBox(width: 16),
                    _buildSpec(Icons.square_foot, "$area م²"),
                  ],
                ),

                const SizedBox(height: 12),

                // الوصف
                if (description.isNotEmpty) ...[
                  const Text("الوصف:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                ],

                const Divider(),

                // معلومات المالك
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.person, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("المالك:",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(ownerName,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                          Text(ownerPhone,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // أزرار القبول والرفض
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveApartment(apartment['id']),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text("قبول",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rejectApartment(apartment['id']),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text("رفض",
                            style: TextStyle(color: Colors.white)),
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
        ],
      ),
    );
  }

  Widget _buildSpec(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  void _approveApartment(int apartmentId) {
    Get.defaultDialog(
      title: "تأكيد القبول",
      middleText: "هل تريد قبول هذه الشقة؟",
      textConfirm: "قبول",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () async {
        Get.back();
        try {
          await adminController.approveApartment(apartmentId);
          Get.snackbar("تم", "تم قبول الشقة بنجاح",
              backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("خطأ", e.toString(),
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  void _rejectApartment(int apartmentId) {
    Get.defaultDialog(
      title: "تأكيد الرفض",
      middleText: "هل تريد رفض هذه الشقة؟",
      textConfirm: "رفض",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await adminController.rejectApartment(apartmentId);
          Get.snackbar("تم", "تم رفض الشقة",
              backgroundColor: Colors.orange, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("خطأ", e.toString(),
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }
}