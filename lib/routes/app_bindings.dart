import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:cozy_app/controllers/booking_controller.dart';
import 'package:cozy_app/controllers/favorites_controller.dart';
import 'package:cozy_app/controllers/owner_apartments_controller.dart';
import 'package:cozy_app/controllers/admin_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(BookingController());
    Get.put(FavoritesController());
    Get.put(OwnerApartmentsController());
    Get.lazyPut(() => AdminController());
  }
}