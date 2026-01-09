import 'package:cozy_app/modules/apartment/apartment_details_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cozy_app/controllers/favorites_controller.dart';
import 'package:cozy_app/modules/home/apartment_card.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final favController = Get.find<FavoritesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المفضلة"),
        backgroundColor: Colors.teal,
      ),

      body: Obx(() {
        if (favController.favorites.isEmpty) {
          return const Center(
            child: Text(
              "لا يوجد شقق في المفضلة حالياً",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: favController.favorites.length,
          itemBuilder: (context, index) {
            final apt = favController.favorites[index];
            return ApartmentCard(
              apartment: apt,
              onTap: () {
              
                Get.to(() => ApartmentDetailsPage(apartment: apt));
              },
            );
          },
        );
      }),
    );
  }
}
