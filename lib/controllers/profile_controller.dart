// import 'package:get/get.dart';
// import '../models/user_model.dart';

// class ProfileController extends GetxController {
//   Rx<UserModel> currentUser = UserModel().obs;

//   // تحديث بيانات المستخدم
//   void updateUser(UserModel user) {
//     currentUser.value = user;
//   }

//   // تعديل الاسم أو أي معلومة (مستقبلاً API)
//   void updateField(String key, dynamic value) {
//     switch (key) {
//       case "firstName":
//         currentUser.value.firstName = value;
//         break;
//       case "lastName":
//         currentUser.value.lastName = value;
//         break;
//       case "birthday":
//         currentUser.value.birthday = value;
//         break;
//       default:
//         break;
//     }
//     currentUser.refresh();
//   }
// }
