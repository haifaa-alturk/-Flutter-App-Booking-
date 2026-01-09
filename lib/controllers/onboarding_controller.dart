import 'package:cozy_app/models/OnBoarding_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  // للتحكم في حركة الصفحات
  var boardController = PageController();
  
  // متغير لمراقبة الصفحة الحالية (Reactive)
  var isLast = false.obs;
  var currentIndex = 0.obs;

  List<OnBoardingModel> boarding = [
    OnBoardingModel(
      image: 'assets/images/cozy.png',
      title: 'مرحباً بك في Cozy App',
      subTitle: 'نحن هنا لمساعدتك في حجز شقة بسهولة',
    ),
    OnBoardingModel(
      image: 'assets/images/option.png',
      title: 'تواصل أسرع',
      subTitle: 'اعرض شقتك للحجز بضغطة زر واحدة',
    ),
    OnBoardingModel(
      image: 'assets/images/agrement.png',
      title: 'ابدأ الآن',
      subTitle: 'سجل دخولك واستمتع بكافة المميزات',
    ),
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
    if (index == boarding.length - 1) {
      isLast.value = true;
    } else {
      isLast.value = false;
    }
  }

  void skip() {
    // الانتقال المباشر لشاشة تسجيل الدخول
    Get.offAllNamed('/login'); 
  }

  void next() {
    if (isLast.value) {
      skip();
    } else {
      boardController.nextPage(
        duration: const Duration(milliseconds: 750),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    }
  }
}