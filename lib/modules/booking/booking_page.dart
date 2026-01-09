import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/booking_controller.dart';
import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:cozy_app/modules/home/apartment_model.dart';

class BookingPage extends StatefulWidget {
  final Apartment apartment;
  final Map<String, dynamic>? existingBooking;

  const BookingPage({
    super.key,
    required this.apartment,
    this.existingBooking,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final bookingController = Get.find<BookingController>();
  final authController = Get.find<AuthController>();

  DateTime? fromDate;
  DateTime? toDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfOwner();

    // إذا كان تعديل على حجز موجود
    if (widget.existingBooking != null) {
      fromDate = DateTime.parse(widget.existingBooking!['from']);
      toDate = DateTime.parse(widget.existingBooking!['to']);
    }
  }

  void _checkIfOwner() {
    final currentUserPhone = authController.currentUser.value?.phone;
    final apartmentOwnerPhone = widget.apartment.ownerPhone;

    if (currentUserPhone != null &&
        apartmentOwnerPhone != null &&
        currentUserPhone == apartmentOwnerPhone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          "غير مسموح",
          "لا يمكنك حجز شقتك الخاصة",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    }
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        // إعادة تعيين تاريخ المغادرة إذا كان قبل تاريخ الوصول الجديد
        if (toDate != null && toDate!.isBefore(picked)) {
          toDate = null;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final start = fromDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? start.add(const Duration(days: 1)),
      firstDate: start.add(const Duration(days: 1)),
      lastDate: DateTime(start.year + 2),
    );
    if (picked != null) setState(() => toDate = picked);
  }

  int _getNights() {
    if (fromDate == null || toDate == null) return 0;
    return toDate!.difference(fromDate!).inDays;
  }

  double _getTotal() {
    final nights = _getNights();
    return (nights > 0 ? nights : 1) * widget.apartment.price;
  }

  Future<void> _handleBooking() async {
    // التحقق من أن المستخدم ليس المالك
    final currentUserPhone = authController.currentUser.value?.phone;
    final apartmentOwnerPhone = widget.apartment.ownerPhone;

    if (currentUserPhone != null &&
        apartmentOwnerPhone != null &&
        currentUserPhone == apartmentOwnerPhone) {
      Get.snackbar("غير مسموح", "لا يمكنك حجز شقتك الخاصة",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // التحقق من التواريخ
    if (fromDate == null || toDate == null) {
      Get.snackbar("خطأ", "يرجى اختيار تاريخ الوصول والمغادرة",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.existingBooking != null) {
        // تعديل حجز موجود
        await bookingController.updateBooking(
          bookingId: widget.existingBooking!['id'],
          fromDate: fromDate!,
          toDate: toDate!,
        );
        Get.back();
        Get.snackbar("تم", "تم تعديل الحجز بنجاح",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // إنشاء حجز جديد
        await bookingController.createBooking(
          apartmentId: widget.apartment.id,
          fromDate: fromDate!,
          toDate: toDate!,
        );
        Get.back();
        Get.snackbar("تم", "تم إرسال طلب الحجز بنجاح\nفي انتظار موافقة المالك",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleCancel() async {
    if (widget.existingBooking == null) return;

    Get.defaultDialog(
      title: "تأكيد الإلغاء",
      middleText: "هل تريد إلغاء هذا الحجز؟",
      textConfirm: "إلغاء الحجز",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        setState(() => isLoading = true);
        try {
          await bookingController.cancelBooking(widget.existingBooking!['id']);
          Get.back();
          Get.snackbar("تم", "تم إلغاء الحجز",
              backgroundColor: Colors.orange, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("خطأ", e.toString().replaceFirst('Exception: ', ''),
              backgroundColor: Colors.red, colorText: Colors.white);
        } finally {
          setState(() => isLoading = false);
        }
      },
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Icon(Icons.apartment, size: 60, color: Colors.grey),
      );
    }

    if (path.startsWith("http")) {
      return Image.network(
        path,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      );
    }

    return Image.asset(
      path,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 200,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.apartment;
    final isEditing = widget.existingBooking != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "تعديل الحجز" : "حجز الشقة"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الشقة
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(apt.image),
            ),
            const SizedBox(height: 16),

            // معلومات الشقة
            Text(
              apt.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  apt.governorate.isNotEmpty
                      ? "${apt.governorate} - ${apt.city}"
                      : "غير محدد",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "\$${apt.price.toStringAsFixed(0)} / ليلة",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // اختيار التواريخ
            const Text(
              "تاريخ الوصول",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFromDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(
                      fromDate != null
                          ? "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}"
                          : "اختر تاريخ الوصول",
                      style: TextStyle(
                        color: fromDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "تاريخ المغادرة",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickToDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(
                      toDate != null
                          ? "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}"
                          : "اختر تاريخ المغادرة",
                      style: TextStyle(
                        color: toDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ملخص الحجز
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("عدد الليالي", "${_getNights()} ليلة"),
                  const Divider(),
                  _buildSummaryRow(
                      "سعر الليلة", "\$${apt.price.toStringAsFixed(0)}"),
                  const Divider(),
                  _buildSummaryRow(
                    "الإجمالي",
                    "\$${_getTotal().toStringAsFixed(0)}",
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // أزرار الحجز
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  isEditing ? "تحديث الحجز" : "إرسال طلب الحجز",
                  style:
                  const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            // زر الإلغاء (فقط في حالة التعديل)
            if (isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _handleCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "إلغاء الحجز",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: isBold ? Colors.teal : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}