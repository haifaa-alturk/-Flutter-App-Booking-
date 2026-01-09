// import 'package:get/get.dart';
////with getx
// class FilterController extends GetxController {
//   RxDouble maxPrice = 500.0.obs;
//   RxInt bedrooms = 1.obs;

//   RxString governorate = ''.obs;
//   RxString city = ''.obs;

//   void resetFilters() {
//     maxPrice.value = 500;
//     bedrooms.value = 1;
//     governorate.value = '';
//     city.value = '';
//   }
// }
//////////////////
library;

class FilterController {
  double? maxPrice;
  int? rooms;
  String? governorate;
  String? city;

  FilterController({
    this.maxPrice,
    this.rooms,
    this.governorate,
    this.city,
  });

  // ترجيع القيم كـ Map (مفيد عند الإرسال للباكند مثلاً)
  Map<String, dynamic> toMap() {
    return {
      "maxPrice": maxPrice,
      "rooms": rooms,
      "governorate": governorate,
      "city": city,
    };
  }

  // تحديث قيم الفلتر
  void updateFilters({
    double? maxPrice,
    int? rooms,
    String? governorate,
    String? city,
  }) {
    this.maxPrice = maxPrice ?? this.maxPrice;
    this.rooms = rooms ?? this.rooms;
    this.governorate = governorate ?? this.governorate;
    this.city = city ?? this.city;
  }

  // مسح الفلتر بالكامل
  void clear() {
    maxPrice = null;
    rooms = null;
    governorate = null;
    city = null;
  }

  @override
  String toString() {
    return """
FilterController(
  maxPrice: $maxPrice,
  rooms: $rooms,
  governorate: $governorate,
  city: $city
)""";
  }
}
