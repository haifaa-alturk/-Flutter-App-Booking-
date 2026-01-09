import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/booking_controller.dart';
import 'package:cozy_app/modules/booking/booking_page.dart';
import 'package:cozy_app/modules/home/apartment_model.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  final bookingController = Get.find<BookingController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    bookingController.fetchMyBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حجوزاتي"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "معلقة"),
            Tab(text: "مؤكدة"),
            Tab(text: "ملغية"),
            Tab(text: "مرفوضة"),
          ],
        ),
      ),
      body: Obx(() {
        if (bookingController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildBookingsList(bookingController.pendingBookings, "معلقة"),
            _buildBookingsList(bookingController.approvedBookings, "مؤكدة"),
            _buildBookingsList(bookingController.cancelledBookings, "ملغية"),
            _buildBookingsList(bookingController.rejectedBookings, "مرفوضة"),
          ],
        );
      }),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings, String status) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "لا توجد حجوزات $status",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: () => bookingController.fetchMyBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final apartment = booking['apartment'] ?? {};
    final String title = apartment['title'] ?? 'شقة';
    final String fromDate = booking['from'] ?? '';
    final String toDate = booking['to'] ?? '';
    final String status = booking['status'] ?? 'pending';
    final String? mainImage = apartment['main_image'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBookingDetails(booking),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // صورة الشقة
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: mainImage != null
                    ? Image.network(
                  mainImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.apartment, color: Colors.grey),
                  ),
                )
                    : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.apartment, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),

              // معلومات الحجز
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "$fromDate → $toDate",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(status),
                  ],
                ),
              ),

              // سهم للتفاصيل
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'في الانتظار';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        color = Colors.green;
        text = 'مؤكد';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.grey;
        text = 'ملغي';
        icon = Icons.cancel;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'مرفوض';
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'معلقة':
        return Icons.hourglass_empty;
      case 'مؤكدة':
        return Icons.check_circle_outline;
      case 'ملغية':
        return Icons.cancel_outlined;
      case 'مرفوضة':
        return Icons.block_outlined;
      default:
        return Icons.list;
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final apartment = booking['apartment'] ?? {};
    final String status = booking['status'] ?? 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                apartment['title'] ?? 'شقة',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // التواريخ
              _buildDetailRow(
                Icons.login,
                "تاريخ الوصول",
                booking['from'] ?? '',
              ),
              _buildDetailRow(
                Icons.logout,
                "تاريخ المغادرة",
                booking['to'] ?? '',
              ),
              _buildDetailRow(
                Icons.info_outline,
                "الحالة",
                _getStatusText(status),
              ),
              const SizedBox(height: 20),

              // الأزرار
              if (status == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          _editBooking(booking);
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("تعديل",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _cancelBooking(booking['id']);
                        },
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text("إلغاء",
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              // أزرار للحجوزات المقبولة (تعديل وإلغاء)
              if (status == 'approved') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          _editBooking(booking);
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("تعديل",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _cancelBooking(booking['id']);
                        },
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text("إلغاء",
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "* التعديل يحتاج موافقة المالك مرة أخرى",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'approved':
        return 'مؤكد';
      case 'cancelled':
        return 'ملغي';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  void _editBooking(Map<String, dynamic> booking) {
    final apartment = booking['apartment'];
    if (apartment == null) return;

    // تحويل بيانات الشقة لـ Apartment model
    final apt = Apartment.fromJson(apartment);

    Get.to(() => BookingPage(
      apartment: apt,
      existingBooking: booking,
    ));
  }

  void _cancelBooking(int bookingId) {
    Get.defaultDialog(
      title: "تأكيد الإلغاء",
      middleText: "هل تريد إلغاء هذا الحجز؟",
      textConfirm: "إلغاء الحجز",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await bookingController.cancelBooking(bookingId);
          Get.snackbar("تم", "تم إلغاء الحجز",
              backgroundColor: Colors.orange, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("خطأ", e.toString().replaceFirst('Exception: ', ''),
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }
}