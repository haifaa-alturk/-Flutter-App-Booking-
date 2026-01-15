import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:cozy_app/controllers/booking_controller.dart';
import 'package:cozy_app/controllers/favorites_controller.dart';
import 'package:cozy_app/controllers/owner_apartments_controller.dart';
import 'package:cozy_app/controllers/admin_controller.dart';
import 'package:cozy_app/controllers/chat_controller.dart'; // ✅ تأكد من الاستيراد
import 'package:get/get.dart';

// class AppBindings extends Bindings {
//   @override
//   void dependencies() {
//     Get.put(AuthController());
//     Get.put(BookingController());
//     Get.put(FavoritesController());
//     Get.put(OwnerApartmentsController());
//     Get.lazyPut(() => AdminController());
//      Get.put(() => ChatController()); // ✅ تأكد من أنه هنا
//   }
// }

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ✅ الخطوة 1: تسجيل AuthController أولاً (الأهم)
    Get.lazyPut(() => AuthController(), fenix: true);
    
    // ✅ الخطوة 2: انتظر قليلاً ثم سجل باقي الـ Controllers
    Future.delayed(Duration.zero, () {
      // Controllers التي تعتمد على AuthController
      Get.lazyPut(() => BookingController(), fenix: true);
      Get.lazyPut(() => FavoritesController(), fenix: true);
      Get.lazyPut(() => OwnerApartmentsController(), fenix: true);
      Get.lazyPut(() => ChatController(), fenix: true); // ✅ بعد AuthController
      Get.lazyPut(() => AdminController(), fenix: true);
    });
  }
}