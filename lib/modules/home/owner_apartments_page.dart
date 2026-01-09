// // lib/modules/owner/owner_apartments_page.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/owner_apartments_controller.dart';
// import '../../modules/home/apartment_model.dart';
// import '../../modules/home/apartment_card.dart';
// import '../home/add_apartment_page.dart';

// class OwnerApartmentsPage extends StatelessWidget {
//   OwnerApartmentsPage({super.key});

//   final ownerController = Get.find<OwnerApartmentsController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("شققي"), backgroundColor: Colors.teal, actions: [
//         IconButton(
//           icon: const Icon(Icons.add),
//           onPressed: () {
//             // انتقل لصفحة إضافة شقة
//             Get.to(() => const AddApartmentPage())?.then((result) {
//               // إذا صفحة الإضافة أعادت شقة جديدة يمكنك إضافتها هنا
//               if (result is Apartment) {
//                 ownerController.addApartment(result);
//               }
//             });
//           },
//         ),
//       ]),
//       body: Obx(() {
//         final list = ownerController.ownerApartments;
//         if (list.isEmpty) {
//           return const Center(child: Text("لا توجد شقق مضافة بعد"));
//         }
//         return ListView.separated(
//           padding: const EdgeInsets.all(12),
//           itemCount: list.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 12),
//           itemBuilder: (context, index) {
//             final apt = list[index];
//             return Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.asset(apt.image, width: 100, height: 80, fit: BoxFit.cover),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(apt.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 6),
//                           Text("\$${apt.price} - ${apt.rooms} rooms",
//                               style: const TextStyle(color: Colors.black54)),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit, color: Colors.orange),
//                           onPressed: () {
//                             // انتقل لصفحة تعديل الشقة (اعطِ صفحة التعديل الـ apt)
//                             // بعد التعديل استدعي ownerController.updateApartment(...)
//                             Get.to(() => AddApartmentPage(editApartment: apt));
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () {
//                             Get.defaultDialog(
//                               title: 'حذف شقة',
//                               middleText: 'هل تريد حذف هذه الشقة؟',
//                               onConfirm: () {
//                                 ownerController.removeApartment(apt.id);
//                                 Get.back();
//                                 Get.snackbar("تم", "حذفت الشقة", backgroundColor: Colors.red, colorText: Colors.white);
//                               },
//                               onCancel: () => Get.back(),
//                             );
//                           },
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
