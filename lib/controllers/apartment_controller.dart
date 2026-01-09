//لاافييييل مع الAddApartmentPage 
// import 'package:cozy_app/modules/home/apartment_model.dart';
// import 'package:get/get.dart';
// //import '../data/models/apartment.dart';
// import '../data/services/apartment_service.dart';
// //هذا الكلاس مسؤول عن جلب الشقق + إضافة شقة جديدة
// class ApartmentController extends GetxController {
//   List<Apartment> apartments = [];

//   // تحميل الشقق عند بداية التطبيق
//   @override
//   void onInit() {
//     fetchApartments();
//     super.onInit();
//   }
// 
//   // جلب الشقق من الباكند
//   Future<void> fetchApartments() async {
//     apartments = await ApartmentService.getApartments();
//     update(); // تحديث الواجهة
//   }

//   // إضافة شقة جديدة
//   Future<void> addNewApartment(Map<String, dynamic> data) async {
//     try {
//       Apartment newApartment = await ApartmentService.addApartment(data);

//       apartments.add(newApartment); // نضيف الشقة للقائمة
//       update(); // نحدث الواجهة

//       Get.back(); // رجوع للصفحة السابقة
//       Get.snackbar("Success", "Apartment added successfully!");

//     } catch (e) {
//       Get.snackbar("Error", "Failed to add apartment");
//     }
//   }
// }
/////////////////////////////
//) التعديل داخل ApartmentController
// الملف:
// lib/controllers/apartment_controller.dart

// أضف دالة addApartment():

// ///import 'dart:io';
// import 'package:get/get.dart';
// import '../data/models/apartment.dart';
// import '../data/dummy/dummy_apartments.dart';

// class ApartmentController extends GetxController {
//   RxList<Apartment> apartments = <Apartment>[].obs;

//   @override
//   void onInit() {
//     apartments.assignAll(dummyApartments);
//     super.onInit();
//   }

//   void addApartment({
//     required File? image,
//     required String area,
//     required String bedrooms,
//     required String location,
//     required String price,
//     required String ownerPhone,
//     required String extraInfo,
//     required String description,
//   }) {
//     final newApt = Apartment(
//       id: apartments.length + 1,
//       name: "New Apartment",
//       image: image?.path ?? "",
//       price: int.parse(price),
//       area: area,
//       bedrooms: bedrooms,
//       location: location,
//       ownerPhone: ownerPhone,
//       extraInfo: extraInfo,
//       description: description,
//     );

//     apartments.add(newApt);
//     update();

//     Get.back(); // رجوع للصفحة السابقة
//     Get.snackbar("Success", "Apartment added successfully",
//         snackPosition: SnackPosition.BOTTOM);
//   }
// }
