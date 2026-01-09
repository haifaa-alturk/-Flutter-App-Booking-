import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cozy_app/controllers/owner_apartments_controller.dart';
import 'package:cozy_app/services/location_service.dart';

class AddApartmentPage extends StatefulWidget {
  const AddApartmentPage({super.key});

  @override
  State<AddApartmentPage> createState() => _AddApartmentPageState();
}

class _AddApartmentPageState extends State<AddApartmentPage> {
  final ownerController = Get.find<OwnerApartmentsController>();
  final locationService = LocationService();
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final roomsController = TextEditingController();
  final areaController = TextEditingController();

  int? selectedGovernorateId;
  int? selectedCityId;

  List<Uint8List> selectedImages = [];
  int mainImageIndex = 0;
  bool isLoading = false;
  bool isLoadingLocations = false;

  // قائمة المحافظات والمدن (سيتم جلبها من API أو استخدام القائمة الثابتة)
  List<Map<String, dynamic>> governorates = [];
  Map<int, List<Map<String, dynamic>>> cities = {};

  // قائمة المحافظات الثابتة (fallback إذا فشل API)
  final List<Map<String, dynamic>> defaultGovernorates = [
    {'id': 1, 'name': 'Damascus'},
    {'id': 2, 'name': 'Rif Dimashq'},
    {'id': 3, 'name': 'Aleppo'},
    {'id': 4, 'name': 'Homs'},
    {'id': 5, 'name': 'Latakia'},
    {'id': 6, 'name': 'Tartus'},
  ];

  // قائمة المدن الثابتة (fallback إذا فشل API)
  final Map<int, List<Map<String, dynamic>>> defaultCities = {
    1: [
      {'id': 1, 'name': 'Damascus City'},
      {'id': 2, 'name': 'Mazah'},
      {'id': 3, 'name': 'Baramkeh'},
    ],
    2: [
      {'id': 4, 'name': 'Mleiha'},
      {'id': 5, 'name': 'Douma'},
      {'id': 6, 'name': 'Harasta'},
    ],
    3: [
      {'id': 7, 'name': 'Aleppo City'},
      {'id': 8, 'name': 'Azaz'},
      {'id': 9, 'name': 'Albab'},
    ],
    4: [
      {'id': 10, 'name': 'Homs City'},
      {'id': 11, 'name': 'Ratan'},
      {'id': 12, 'name': 'Telbisa'},
    ],
    5: [
      {'id': 13, 'name': 'Latakia City'},
      {'id': 14, 'name': 'Alhafa'},
      {'id': 15, 'name': 'Slinfa'},
    ],
    6: [
      {'id': 16, 'name': 'Tartus City'},
      {'id': 17, 'name': 'Banyas'},
      {'id': 18, 'name': 'Safita'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  /// جلب المحافظات والمدن من API
  Future<void> _loadLocations() async {
    setState(() => isLoadingLocations = true);
    try {
      final fetchedGovernorates = await locationService.getGovernorates();
      if (fetchedGovernorates.isNotEmpty) {
        setState(() {
          governorates = fetchedGovernorates;
        });
        debugPrint("Loaded ${governorates.length} governorates from API");
      } else {
        // استخدام القائمة الثابتة إذا فشل API
        setState(() {
          governorates = defaultGovernorates;
        });
        debugPrint("Using default governorates list");
      }
    } catch (e) {
      debugPrint("Error loading governorates: $e");
      // استخدام القائمة الثابتة في حالة الخطأ
      setState(() {
        governorates = defaultGovernorates;
      });
    } finally {
      setState(() => isLoadingLocations = false);
    }
  }

  /// جلب المدن عند اختيار محافظة
  Future<void> _loadCities(int governorateId) async {
    try {
      final fetchedCities = await locationService.getCitiesByGovernorate(governorateId);
      if (fetchedCities.isNotEmpty) {
        setState(() {
          cities[governorateId] = fetchedCities;
          selectedCityId = null; // إعادة تعيين المدينة
        });
        debugPrint("Loaded ${fetchedCities.length} cities for governorate $governorateId");
      } else {
        // استخدام القائمة الثابتة إذا فشل API
        if (defaultCities.containsKey(governorateId)) {
          setState(() {
            cities[governorateId] = defaultCities[governorateId]!;
            selectedCityId = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading cities: $e");
      // استخدام القائمة الثابتة في حالة الخطأ
      if (defaultCities.containsKey(governorateId)) {
        setState(() {
          cities[governorateId] = defaultCities[governorateId]!;
          selectedCityId = null;
        });
      }
    }
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        setState(() {
          selectedImages.add(bytes);
        });
      }
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      if (mainImageIndex >= selectedImages.length) {
        mainImageIndex = selectedImages.isEmpty ? 0 : selectedImages.length - 1;
      }
    });
  }

  Future<void> submitApartment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImages.isEmpty) {
      Get.snackbar("خطأ", "يجب إضافة صورة واحدة على الأقل",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedGovernorateId == null || selectedCityId == null) {
      Get.snackbar("خطأ", "يجب اختيار المحافظة والمدينة",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // تسجيل القيم المختارة للتشخيص
    debugPrint("=== Submitting Apartment ===");
    debugPrint("Selected Governorate ID: $selectedGovernorateId");
    debugPrint("Selected City ID: $selectedCityId");
    
    // البحث عن أسماء المحافظة والمدينة المختارة
    final selectedGov = governorates.firstWhere(
      (g) => g['id'] == selectedGovernorateId,
      orElse: () => {'id': selectedGovernorateId, 'name': 'Unknown'},
    );
    final selectedCity = cities[selectedGovernorateId]?.firstWhere(
      (c) => c['id'] == selectedCityId,
      orElse: () => {'id': selectedCityId, 'name': 'Unknown'},
    );
    debugPrint("Selected Governorate: ${selectedGov['name']} (ID: ${selectedGov['id']})");
    if (selectedCity != null) {
      debugPrint("Selected City: ${selectedCity['name']} (ID: ${selectedCity['id']})");
    }

    setState(() => isLoading = true);

    try {
      await ownerController.addApartment(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        pricePerDay: double.parse(priceController.text.trim()),
        rooms: int.parse(roomsController.text.trim()),
        area: int.parse(areaController.text.trim()),
        governorateId: selectedGovernorateId!,
        cityId: selectedCityId!,
        images: selectedImages,
        mainImageIndex: mainImageIndex,
      );

      Get.back();
      Get.snackbar("نجاح", "تم إضافة الشقة بنجاح، في انتظار موافقة الإدارة",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint("Error submitting apartment: $errorMessage");
      Get.snackbar(
        "خطأ",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5), // إطالة مدة الرسالة
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة شقة جديدة"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان الشقة
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "عنوان الشقة",
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "مطلوب" : null,
              ),
              const SizedBox(height: 16),

              // الوصف
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "الوصف",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "مطلوب" : null,
              ),
              const SizedBox(height: 16),

              // السعر وعدد الغرف
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "السعر / يوم (\$)",
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "مطلوب" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: roomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "عدد الغرف",
                        prefixIcon: Icon(Icons.bed),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "مطلوب" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // المساحة
              TextFormField(
                controller: areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "المساحة (م²)",
                  prefixIcon: Icon(Icons.square_foot),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "مطلوب" : null,
              ),
              const SizedBox(height: 16),

              // المحافظة
              DropdownButtonFormField<int>(
                value: selectedGovernorateId,
                decoration: const InputDecoration(
                  labelText: "المحافظة",
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                items: governorates.map((g) {
                  return DropdownMenuItem<int>(
                    value: g['id'],
                    child: Text(g['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGovernorateId = value;
                    selectedCityId = null;
                  });
                  // جلب المدن عند اختيار محافظة
                  if (value != null) {
                    _loadCities(value);
                  }
                },
                validator: (v) => v == null ? "مطلوب" : null,
              ),
              const SizedBox(height: 16),

              // المدينة
              DropdownButtonFormField<int>(
                value: selectedCityId,
                decoration: const InputDecoration(
                  labelText: "المدينة",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                items: selectedGovernorateId == null
                    ? []
                    : (cities[selectedGovernorateId] ?? []).map((c) {
                  return DropdownMenuItem<int>(
                    value: c['id'],
                    child: Text(c['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCityId = value;
                  });
                },
                validator: (v) => v == null ? "مطلوب" : null,
              ),
              const SizedBox(height: 20),

              // الصور
              const Text("صور الشقة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // عرض الصور المختارة
              if (selectedImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => mainImageIndex = index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: mainImageIndex == index ? Colors.teal : Colors.grey,
                                  width: mainImageIndex == index ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  selectedImages[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          if (mainImageIndex == index)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("رئيسية", style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),

              // زر إضافة صور
              OutlinedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text("إضافة صور"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "اضغط على الصورة لجعلها الصورة الرئيسية",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // زر الإضافة
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitApartment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "إضافة الشقة",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    roomsController.dispose();
    areaController.dispose();
    super.dispose();
  }
}