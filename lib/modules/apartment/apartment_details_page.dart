import 'package:cozy_app/modules/booking/booking_page.dart';
import 'package:cozy_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/apartment_model.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final Apartment apartment;

  const ApartmentDetailsPage({super.key, required this.apartment});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String path, BoxFit fit) {
    if (path.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.grey)),
      );
    }

    // إذا كانت الصورة من الإنترنت
    if (path.startsWith("http")) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        },
      );
    }

    // إذا كانت الصورة من assets
    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.apartment;

    final gallery = (a.gallery ?? []).isNotEmpty ? a.gallery! : (a.image.isNotEmpty ? [a.image] : []);

    return Scaffold(
      appBar: AppBar(
        title: Text(a.name),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معرض الصور
            SizedBox(
              height: 260,
              width: double.infinity,
              child: gallery.isEmpty
                  ? Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.apartment, size: 80, color: Colors.grey)),
              )
                  : PageView.builder(
                controller: _pageController,
                itemCount: gallery.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  return _buildImage(gallery[index], BoxFit.cover);
                },
              ),
            ),

            // مؤشرات الصفحات
            if (gallery.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(gallery.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == i ? 12 : 8,
                        height: _currentIndex == i ? 12 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == i ? Colors.teal : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ),

            // الصور المصغرة
            if (gallery.length > 1)
              SizedBox(
                height: 90,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: gallery.length,
                  itemBuilder: (context, index) {
                    final img = gallery[index];
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(index,
                            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _currentIndex == index ? Colors.teal : Colors.transparent, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildImage(img, BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // اسم الشقة والسعر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      a.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "\$${a.price.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 20, color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // الموقع وعدد الغرف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      a.governorate.isNotEmpty ? "${a.governorate} - ${a.city}" : (a.location ?? "Unknown location"),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.meeting_room, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("${a.rooms} rooms", style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // الوصف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(a.description ?? "No description provided.",
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                  const SizedBox(height: 16),
                  if (a.ownerPhone != null && a.ownerPhone!.isNotEmpty)
                    Text("Owner: ${a.ownerPhone}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            

            // التقييمات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("⭐ 4.6 (34 reviews)"),
                  SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // زر الحجز - يظهر فقط إذا لم يكن المستخدم هو المالك
            Builder(
              builder: (context) {
                final authController = Get.find<AuthController>();
                final currentUserPhone = authController.currentUser.value?.phone;
                final isOwner = currentUserPhone != null &&
                    a.ownerPhone != null &&
                    currentUserPhone == a.ownerPhone;

                if (isOwner) {
                  return const SizedBox.shrink(); // لا يظهر شيء للمالك
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        Get.to(() => BookingPage(apartment: a));
                      },
                      child: const Text("Book Now",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}