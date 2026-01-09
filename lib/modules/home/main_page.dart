import 'package:cozy_app/modules/home/my_apartments_page.dart';
import 'package:cozy_app/modules/home/owner_booking_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:cozy_app/modules/home/home_page.dart';
import 'package:cozy_app/modules/booking/my_bookings_page.dart';
import 'package:cozy_app/modules/favorites/favorites_page.dart';
import 'package:cozy_app/modules/profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final authController = Get.find<AuthController>();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userRole = authController.currentUser.value?.role;
    final isOwner = userRole == 'owner';

    // الصفحات حسب نوع المستخدم
    final screens = isOwner
        ? [
      HomePage(),
      MyApartmentsPage(),              // شققي
      const OwnerBookingRequestsPage(),      // طلبات الحجز (جديد)
      FavoritesPage(),
      ProfilePage(),
    ]
        : [
      HomePage(),
      const MyBookingsPage(),                // حجوزاتي
      FavoritesPage(),
      ProfilePage(),
    ];

    // الأيقونات حسب نوع المستخدم
    final navItems = isOwner
        ? const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
      BottomNavigationBarItem(icon: Icon(Icons.home_work), label: "شُقَقي"),
      BottomNavigationBarItem(icon: Icon(Icons.bookmark_added), label: "الطلبات"),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "المفضلة"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
    ]
        : const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
      BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "حجوزاتي"),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "المفضلة"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: navItems,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}