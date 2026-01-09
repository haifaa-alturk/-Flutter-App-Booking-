


import 'package:cozy_app/controllers/onboarding_controller.dart';
import 'package:cozy_app/models/OnBoarding_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
   
    final controller = Get.put(OnBoardingController());

    return Scaffold(   backgroundColor: const Color.fromARGB(235, 249, 253, 252),
      appBar: AppBar(
         backgroundColor: Colors.teal,
        actions: [
          TextButton(
            onPressed: controller.skip,
            child: const Text("skip", style: TextStyle(color: Color.fromARGB(255, 228, 238, 238))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.boardController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.boarding.length,
                itemBuilder: (context, index) => buildBoardingItem(controller.boarding[index]),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
               
                Center(
                  child: SmoothPageIndicator(
                    controller: controller.boardController,
                    count: controller.boarding.length,
                    effect: const ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Color.fromARGB(255, 32, 126, 140),
                      dotHeight: 10,
                      expansionFactor: 4,
                      dotWidth: 10,
                      spacing: 5,
                    ),
                  ),
                ),
                const Spacer(),
               
                Obx(() => FloatingActionButton(
                  onPressed: controller.next,
                  child: Icon(controller.isLast.value ? Icons.done : Icons.arrow_forward_ios),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget buildBoardingItem(OnBoardingModel model) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.blue.withOpacity(0.1),
              backgroundImage: AssetImage(model.image),
            ),
          ),
        ),
      
      
    
          Center(child: Text(model.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 5, 45, 68)))),
          const SizedBox(height: 15),
          Center(child: Text(model.subTitle, style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 5, 39, 59)))),
        ],
      );
}