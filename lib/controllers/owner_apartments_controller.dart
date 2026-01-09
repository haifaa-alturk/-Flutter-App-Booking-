import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:cozy_app/modules/home/apartment_model.dart';
import 'package:cozy_app/services/owner_service.dart';
import 'package:cozy_app/controllers/auth_controller.dart';

class OwnerApartmentsController extends GetxController {
  final OwnerService _service = OwnerService();

  var myApartments = <Apartment>[].obs;
  var allApartments = <Apartment>[].obs;
  var pendingBookings = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var isLoadingBookings = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyApartments();
  }

  /// جلب شقق المالك من API
  Future<void> fetchMyApartments() async {
    try {
      isLoading.value = true;
      final auth = Get.find<AuthController>();
      final data = await _service.getMyApartments(auth.token.value);
      myApartments.assignAll(
        data.map((item) => Apartment.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      print("Error fetching apartments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// إضافة شقة جديدة
  Future<void> addApartment({
    required String title,
    required String description,
    required double pricePerDay,
    required int rooms,
    required int area,
    required int governorateId,
    required int cityId,
    required List<Uint8List> images,
    required int mainImageIndex,
  }) async {
    final auth = Get.find<AuthController>();
    await _service.createApartment(
      token: auth.token.value,
      title: title,
      description: description,
      pricePerDay: pricePerDay,
      rooms: rooms,
      area: area,
      governorateId: governorateId,
      cityId: cityId,
      images: images,
      mainImageIndex: mainImageIndex,
    );
    await fetchMyApartments();
  }

  /// تحديث شقة
  Future<void> updateApartment({
    required int apartmentId,
    required String title,
    required String description,
    required double pricePerDay,
    required int rooms,
    required int area,
    required int governorateId,
    required int cityId,
    List<Uint8List>? newImages,
    int mainImageIndex = 0,
  }) async {
    final auth = Get.find<AuthController>();
    await _service.updateApartment(
      token: auth.token.value,
      apartmentId: apartmentId,
      title: title,
      description: description,
      pricePerDay: pricePerDay,
      rooms: rooms,
      area: area,
      governorateId: governorateId,
      cityId: cityId,
      images: newImages,
      mainImageIndex: mainImageIndex,
    );
    await fetchMyApartments();
  }

  /// حذف شقة
  Future<void> deleteApartment(int id) async {
    try {
      final auth = Get.find<AuthController>();
      await _service.deleteApartment(auth.token.value, id);
      myApartments.removeWhere((apt) => apt.id == id);
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    }
  }

  /// جلب طلبات الحجز المعلقة
  Future<void> fetchPendingBookings() async {
    try {
      isLoadingBookings.value = true;
      final auth = Get.find<AuthController>();
      final data = await _service.getPendingBookings(auth.token.value);
      pendingBookings.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      print("Error fetching bookings: $e");
    } finally {
      isLoadingBookings.value = false;
    }
  }

  /// قبول حجز
  Future<void> approveBooking(int bookingId) async {
    final auth = Get.find<AuthController>();
    await _service.approveBooking(auth.token.value, bookingId);
    await fetchPendingBookings();
  }

  /// رفض حجز
  Future<void> rejectBooking(int bookingId) async {
    final auth = Get.find<AuthController>();
    await _service.rejectBooking(auth.token.value, bookingId);
    await fetchPendingBookings();
  }
}