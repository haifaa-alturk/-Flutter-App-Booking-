import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/owner_apartments_controller.dart';
import 'package:cozy_app/modules/home/apartment_model.dart';
import 'add_apartment_page.dart';
import 'edit_apartment_page.dart';
import 'owner_booking_requests_page.dart';

class MyApartmentsPage extends StatefulWidget {
  const MyApartmentsPage({super.key});

  @override
  State<MyApartmentsPage> createState() => _MyApartmentsPageState();
}

class _MyApartmentsPageState extends State<MyApartmentsPage> {
  final ownerController = Get.find<OwnerApartmentsController>();

  @override
  void initState() {
    super.initState();
    // جلب الشقق عند فتح الصفحة
    ownerController.fetchMyApartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("شُقَقي"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // زر طلبات الحجز
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: "طلبات الحجز",
            onPressed: () {
              Get.to(() => const OwnerBookingRequestsPage());
            },
          ),
        ],
      ),

      // زر إضافة شقة
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          await Get.to(() => const AddApartmentPage());
          // إعادة جلب الشقق بعد العودة من صفحة الإضافة
          ownerController.fetchMyApartments();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Obx(() {
        if (ownerController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (ownerController.myApartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  "لم تقم بإضافة أي شقة بعد",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "اضغط + لإضافة شقة جديدة",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ownerController.fetchMyApartments(),
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: ownerController.myApartments.length,
            itemBuilder: (context, index) {
              Apartment a = ownerController.myApartments[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة الشقة
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: _buildImage(a.image),
                    ),

                    const SizedBox(width: 10),

                    // تفاصيل الشقة
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.name,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text("${a.price.toStringAsFixed(0)} \$ لليوم",
                                style: const TextStyle(fontSize: 15, color: Colors.teal)),
                            const SizedBox(height: 4),
                            Text("${a.rooms} غرف",
                                style: const TextStyle(fontSize: 15, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text("${a.governorate} - ${a.city}",
                                style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 4),
                            // حالة الشقة
                            _buildStatusBadge(a.status),
                          ],
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Get.to(() => EditApartmentPage(apartment: a));
                            ownerController.fetchMyApartments();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmation(a);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey.shade300,
        child: const Icon(Icons.apartment, size: 40, color: Colors.grey),
      );
    }

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 120,
          height: 120,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, size: 40),
        ),
      );
    }

    return Container(
      width: 120,
      height: 120,
      color: Colors.grey.shade300,
      child: const Icon(Icons.apartment, size: 40, color: Colors.grey),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'مُعتمدة';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'قيد المراجعة';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'مرفوضة';
        break;
      default:
        color = Colors.grey;
        text = 'غير معروف';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDeleteConfirmation(Apartment a) {
    Get.defaultDialog(
      title: "حذف الشقة",
      middleText: "هل أنت متأكد من حذف '${a.name}'؟",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        ownerController.deleteApartment(a.id);
        Get.snackbar("تم الحذف", "تم حذف الشقة بنجاح",
            backgroundColor: Colors.green, colorText: Colors.white);
      },
    );
  }
}