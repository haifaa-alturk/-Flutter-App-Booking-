import 'package:get/get.dart';
import 'package:cozy_app/services/admin_service.dart';
import 'package:cozy_app/controllers/auth_controller.dart';

class AdminController extends GetxController {
  final AdminService _service = AdminService();

  var pendingUsers = <Map<String, dynamic>>[].obs;
  var allUsers = <Map<String, dynamic>>[].obs;
  var pendingApartments = <Map<String, dynamic>>[].obs;

  var isLoadingUsers = false.obs;
  var isLoadingAllUsers = false.obs;
  var isLoadingApartments = false.obs;

  var pendingUsersCount = 0.obs;
  var allUsersCount = 0.obs;
  var pendingApartmentsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  /// جلب جميع البيانات
  Future<void> fetchAllData() async {
    await fetchPendingUsers();
    await fetchPendingApartments();
  }

  // ============== المستخدمين ==============

  /// جلب المستخدمين المعلقين
  Future<void> fetchPendingUsers() async {
    try {
      isLoadingUsers.value = true;
      final auth = Get.find<AuthController>();
      final data = await _service.getPendingUsers(auth.token.value);
      pendingUsers.assignAll(List<Map<String, dynamic>>.from(data));
      pendingUsersCount.value = pendingUsers.length;
    } catch (e) {
      print("Error fetching pending users: $e");
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// قبول مستخدم
  Future<void> approveUser(int userId) async {
    try {
      final auth = Get.find<AuthController>();
      await _service.approveUser(auth.token.value, userId);
      pendingUsers.removeWhere((user) => user['id'] == userId);
      pendingUsersCount.value = pendingUsers.length;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// رفض مستخدم
  Future<void> rejectUser(int userId) async {
    try {
      final auth = Get.find<AuthController>();
      await _service.rejectUser(auth.token.value, userId);
      pendingUsers.removeWhere((user) => user['id'] == userId);
      pendingUsersCount.value = pendingUsers.length;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// جلب جميع المستخدمين
  Future<void> fetchAllUsers() async {
    try {
      isLoadingAllUsers.value = true;
      final auth = Get.find<AuthController>();
      final data = await _service.getAllUsers(auth.token.value);
      allUsers.assignAll(List<Map<String, dynamic>>.from(data));
      allUsersCount.value = allUsers.length;
    } catch (e) {
      print("Error fetching all users: $e");
    } finally {
      isLoadingAllUsers.value = false;
    }
  }

  /// حذف مستخدم
  Future<void> deleteUser(int userId) async {
    try {
      final auth = Get.find<AuthController>();
      await _service.deleteUser(auth.token.value, userId);
      allUsers.removeWhere((user) => user['id'] == userId);
      pendingUsers.removeWhere((user) => user['id'] == userId);
      allUsersCount.value = allUsers.length;
      pendingUsersCount.value = pendingUsers.length;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============== الشقق ==============

  /// جلب الشقق المعلقة
  Future<void> fetchPendingApartments() async {
    try {
      isLoadingApartments.value = true;
      final auth = Get.find<AuthController>();
      final data = await _service.getPendingApartments(auth.token.value);
      pendingApartments.assignAll(List<Map<String, dynamic>>.from(data));
      pendingApartmentsCount.value = pendingApartments.length;
    } catch (e) {
      print("Error fetching pending apartments: $e");
    } finally {
      isLoadingApartments.value = false;
    }
  }

  /// قبول شقة
  Future<void> approveApartment(int apartmentId) async {
    try {
      final auth = Get.find<AuthController>();
      await _service.approveApartment(auth.token.value, apartmentId);
      pendingApartments.removeWhere((apt) => apt['id'] == apartmentId);
      pendingApartmentsCount.value = pendingApartments.length;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// رفض شقة
  Future<void> rejectApartment(int apartmentId) async {
    try {
      final auth = Get.find<AuthController>();
      await _service.rejectApartment(auth.token.value, apartmentId);
      pendingApartments.removeWhere((apt) => apt['id'] == apartmentId);
      pendingApartmentsCount.value = pendingApartments.length;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}