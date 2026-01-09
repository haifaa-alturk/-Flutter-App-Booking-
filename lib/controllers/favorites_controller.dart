import 'package:get/get.dart';
import 'package:cozy_app/modules/home/apartment_model.dart';
import 'package:cozy_app/services/favorites_service.dart';
import 'package:cozy_app/controllers/auth_controller.dart';

class FavoritesController extends GetxController {
  final FavoritesService _service = FavoritesService();

  RxList<Apartment> favorites = <Apartment>[].obs;
  RxSet<int> favoriteIds = <int>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  /// جلب المفضلة من API
  Future<void> fetchFavorites() async {
    try {
      isLoading.value = true;
      final auth = Get.find<AuthController>();

      if (auth.token.value.isEmpty) return;

      final data = await _service.getFavorites(auth.token.value);
      favorites.assignAll(
        data.map((item) => Apartment.fromJson(item as Map<String, dynamic>)).toList(),
      );
      // تحديث قائمة الـ IDs
      favoriteIds.assignAll(favorites.map((apt) => apt.id).toSet());
    } catch (e) {
      print("Error fetching favorites: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// إضافة أو إزالة من المفضلة
  Future<void> toggleFavorite(Apartment apartment) async {
    try {
      final auth = Get.find<AuthController>();

      if (isFavorite(apartment)) {
        // إزالة من المفضلة
        await _service.removeFromFavorites(auth.token.value, apartment.id);
        favorites.removeWhere((apt) => apt.id == apartment.id);
        favoriteIds.remove(apartment.id);
      } else {
        // إضافة للمفضلة
        await _service.addToFavorites(auth.token.value, apartment.id);
        favorites.add(apartment);
        favoriteIds.add(apartment.id);
      }
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    }
  }

  /// تحقق إذا الشقة في المفضلة
  bool isFavorite(Apartment apartment) {
    return favoriteIds.contains(apartment.id);
  }
}