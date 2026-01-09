import 'package:get/get.dart';
import 'package:cozy_app/services/booking_service.dart';
import 'package:cozy_app/controllers/auth_controller.dart';

class BookingController extends GetxController {
  final BookingService _service = BookingService();

  var myBookings = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  /// جلب حجوزات المستخدم الحالي
  Future<void> fetchMyBookings() async {
    try {
      isLoading.value = true;
      final auth = Get.find<AuthController>();
      final userId = auth.currentUser.value?.id;

      if (userId == null) return;

      final data = await _service.getUserBookings(auth.token.value, userId);
      myBookings.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      print("Error fetching bookings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء حجز جديد
  Future<void> createBooking({
    required int apartmentId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final auth = Get.find<AuthController>();

    final result = await _service.createBooking(
      token: auth.token.value,
      apartmentId: apartmentId,
      fromDate: _formatDate(fromDate),
      toDate: _formatDate(toDate),
    );

    // إضافة الحجز الجديد للقائمة
    myBookings.add(Map<String, dynamic>.from(result));
  }

  /// إلغاء حجز
  Future<void> cancelBooking(int bookingId) async {
    final auth = Get.find<AuthController>();

    await _service.cancelBooking(auth.token.value, bookingId);

    // تحديث حالة الحجز في القائمة
    final index = myBookings.indexWhere((b) => b['id'] == bookingId);
    if (index != -1) {
      myBookings[index]['status'] = 'cancelled';
      myBookings.refresh();
    }
  }

  /// تعديل حجز
  Future<void> updateBooking({
    required int bookingId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final auth = Get.find<AuthController>();

    final result = await _service.updateBooking(
      token: auth.token.value,
      bookingId: bookingId,
      fromDate: _formatDate(fromDate),
      toDate: _formatDate(toDate),
    );

    // تحديث الحجز في القائمة
    final index = myBookings.indexWhere((b) => b['id'] == bookingId);
    if (index != -1) {
      myBookings[index] = Map<String, dynamic>.from(result);
      myBookings.refresh();
    }
  }

  /// تنسيق التاريخ للـ API
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// الحصول على حجوزات حسب الحالة
  List<Map<String, dynamic>> getBookingsByStatus(String status) {
    return myBookings.where((b) => b['status'] == status).toList();
  }

  /// الحجوزات المعلقة
  List<Map<String, dynamic>> get pendingBookings => getBookingsByStatus('pending');

  /// الحجوزات المقبولة
  List<Map<String, dynamic>> get approvedBookings => getBookingsByStatus('approved');

  /// الحجوزات الملغية
  List<Map<String, dynamic>> get cancelledBookings => getBookingsByStatus('cancelled');

  /// الحجوزات المرفوضة
  List<Map<String, dynamic>> get rejectedBookings => getBookingsByStatus('rejected');
}