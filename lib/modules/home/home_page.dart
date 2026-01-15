// ignore_for_file: unused_import

import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:cozy_app/modules/apartment/apartment_details_page.dart';
import 'package:cozy_app/modules/home/add_apartment_page.dart';
import 'package:cozy_app/modules/home/apartment_model.dart';
import 'package:cozy_app/services/apartment_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'apartment_card.dart';

import 'package:cozy_app/modules/chat/chat_list_page.dart'; // ✅ استيراد صفحة المراسلات

import 'package:cozy_app/controllers/chat_controller.dart'; // ✅ استيراد الـ controller


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authController = Get.find<AuthController>();
  final ApartmentService _apartmentService = ApartmentService();

  List<Apartment> allApartments = [];
  List<Apartment> filteredApartments = [];
  bool isLoading = true;

  String selectedSearchType = "الاسم";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchApartments();
  }

  Future<void> fetchApartments() async {
    try {
      setState(() => isLoading = true);
      final data = await _apartmentService.getAllApartments();
      setState(() {
        allApartments = data.map((item) => Apartment.fromJson(item)).toList();
        filteredApartments = allApartments;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching apartments: $e");
    }
  }

  void search(String query) {
    final q = query.toLowerCase();

    setState(() {
      switch (selectedSearchType) {
        case "الاسم":
          filteredApartments = allApartments
              .where((apt) => apt.name.toLowerCase().contains(q))
              .toList();
          break;

        case "المدينة":
          filteredApartments = allApartments
              .where((apt) => apt.city.toLowerCase().contains(q))
              .toList();
          break;

        case "المحافظة":
          filteredApartments = allApartments
              .where((apt) => apt.governorate.toLowerCase().contains(q))
              .toList();
          break;

        case "السعر":
          double? price = double.tryParse(query);
          filteredApartments = price == null
              ? []
              : allApartments.where((apt) => apt.price <= price).toList();
          break;

        case "عدد الغرف":
          int? rooms = int.tryParse(query);
          filteredApartments = rooms == null
              ? []
              : allApartments.where((apt) => apt.rooms >= rooms).toList();
          break;

        default:
          filteredApartments = allApartments;
      }
    });
  }

  void showSearchOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("اختر طريقة البحث:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              buildSearchTypeOption("الاسم"),
              buildSearchTypeOption("المدينة"),
              buildSearchTypeOption("المحافظة"),
              buildSearchTypeOption("السعر"),
              buildSearchTypeOption("عدد الغرف"),
            ],
          ),
        );
      },
    );
  }

  Widget buildSearchTypeOption(String type) {
    return ListTile(
      title: Text(type),
      leading: Icon(
        selectedSearchType == type
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: Colors.teal,
      ),
      onTap: () {
        setState(() => selectedSearchType = type);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = authController.currentUser.value?.role;
    final isOwner = userRole == 'owner';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Apartments"),
        backgroundColor: Colors.teal,
//       actions: [
//   IconButton(
//     icon: Stack(
//       children: [
//         Icon(Icons.message, color: Colors.white),
//         // مؤشر الرسائل غير المقروءة
//         Positioned(
//           right: 0,
//           top: 0,
//           child: Obx(() {
//             // ✅ استخدم GetInstance بدلاً من Get.find مباشرة
//             try {
//               final chatController = GetInstance().find<ChatController>();
//               final unreadCount = chatController.conversations
//                   .fold(0, (sum, chat) => sum + chat.unreadCount);
//               if (unreadCount > 0) {
//                 return Container(
//                   padding: EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   constraints: BoxConstraints(
//                     minWidth: 16,
//                     minHeight: 16,
//                   ),
//                   child: Text(
//                     unreadCount > 9 ? '9+' : unreadCount.toString(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 );
//               }
//             } catch (e) {
//               // إذا لم يكن Controller مسجلاً، تجاهل
//               print('ChatController not ready yet: $e');
//             }
//             return SizedBox.shrink();
//           }),
//         ),
//       ],
//     ),
//     onPressed: () {
//       // ✅ تحقق من تسجيل Controller قبل الانتقال
//       if (!Get.isRegistered<ChatController>()) {
//         Get.put(ChatController());
//       }
//       Get.to(() => ChatListPage());
//     },
//   ),
// ],
      ),
        
      body: Column(
        children: [
          // صندوق البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "البحث حسب: $selectedSearchType",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: showSearchOptions,
                      child: const Text("تغيير"),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "أدخل كلمة للبحث...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey.shade600),
                    ),
                    onChanged: search,
                  ),
                ),
              ],
            ),
          ),

          // قائمة الشقق
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : filteredApartments.isEmpty
                ? const Center(
              child: Text(
                "لا توجد شقق متاحة",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : RefreshIndicator(
              onRefresh: fetchApartments,
              child: ListView.builder(
                itemCount: filteredApartments.length,
                itemBuilder: (context, index) {
                  final apt = filteredApartments[index];
                  return ApartmentCard(
                    apartment: apt,
                    onTap: () => Get.to(() => ApartmentDetailsPage(apartment: apt)),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // زر إضافة شقة للمالك
      floatingActionButton: isOwner
          ? FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Get.to(() => const AddApartmentPage());
        },
      )
          : null,
    );
  }
}