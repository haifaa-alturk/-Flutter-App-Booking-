import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cozy_app/controllers/owner_apartments_controller.dart';
import 'package:cozy_app/modules/home/apartment_model.dart';

class EditApartmentPage extends StatefulWidget {
  final Apartment apartment;

  const EditApartmentPage({super.key, required this.apartment});

  @override
  State<EditApartmentPage> createState() => _EditApartmentPageState();
}

class _EditApartmentPageState extends State<EditApartmentPage> {
  final ownerController = Get.find<OwnerApartmentsController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController roomsController;
  late TextEditingController areaController;

  int? selectedGovernorateId;
  int? selectedCityId;

  List<Uint8List> newImages = [];
  List<String> existingImages = [];
  int mainImageIndex = 0;
  bool isLoading = false;

  final List<Map<String, dynamic>> governorates = [
    {'id': 1, 'name': 'Damascus'},
    {'id': 2, 'name': 'Rif Dimashq'},
    {'id': 3, 'name': 'Aleppo'},
    {'id': 4, 'name': 'Homs'},
    {'id': 5, 'name': 'Latakia'},
    {'id': 6, 'name': 'Tartus'},
  ];

  final Map<int, List<Map<String, dynamic>>> cities = {
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
    final a = widget.apartment;

    titleController = TextEditingController(text: a.name);
    descriptionController = TextEditingController(text: a.description ?? '');
    priceController = TextEditingController(text: a.price.toStringAsFixed(0));
    roomsController = TextEditingController(text: a.rooms.toString());
    areaController = TextEditingController(text: '100'); // Default if not available

    // تحديد المحافظة والمدينة من الاسم
    _setGovernorateAndCity(a.governorate, a.city);

    // الصور الموجودة
    if (a.gallery != null && a.gallery!.isNotEmpty) {
      existingImages = List.from(a.gallery!);
    } else if (a.image.isNotEmpty) {
      existingImages = [a.image];
    }
  }

  void _setGovernorateAndCity(String govName, String cityName) {
    for (var gov in governorates) {
      if (gov['name'] == govName) {
        selectedGovernorateId = gov['id'];
        break;
      }
    }

    if (selectedGovernorateId != null) {
      final cityList = cities[selectedGovernorateId] ?? [];
      for (var city in cityList) {
        if (city['name'] == cityName) {
          selectedCityId = city['id'];
          break;
        }
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
          newImages.add(bytes);
        });
      }
    }
  }

  void removeExistingImage(int index) {
    setState(() {
      existingImages.removeAt(index);
    });
  }

  void removeNewImage(int index) {
    setState(() {
      newImages.removeAt(index);
    });
  }

  Future<void> submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (existingImages.isEmpty && newImages.isEmpty) {
      Get.snackbar("خطأ", "يجب وجود صورة واحدة على الأقل",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedGovernorateId == null || selectedCityId == null) {
      Get.snackbar("خطأ", "يجب اختيار المحافظة والمدينة",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    try {
      await ownerController.updateApartment(
        apartmentId: widget.apartment.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        pricePerDay: double.parse(priceController.text.trim()),
        rooms: int.parse(roomsController.text.trim()),
        area: int.parse(areaController.text.trim()),
        governorateId: selectedGovernorateId!,
        cityId: selectedCityId!,
        newImages: newImages.isNotEmpty ? newImages : null,
        mainImageIndex: mainImageIndex,
      );

      Get.back();
      Get.snackbar("نجاح", "تم تحديث الشقة بنجاح",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل الشقة"),
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

              // الصور الحالية
              const Text("الصور الحالية",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              if (existingImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: existingImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                existingImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => removeExistingImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              if (existingImages.isEmpty)
                const Text("لا توجد صور حالية",
                    style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 16),

              // الصور الجديدة
              const Text("صور جديدة",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              if (newImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: newImages.length,
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
                                  color: mainImageIndex == index
                                      ? Colors.teal
                                      : Colors.grey,
                                  width: mainImageIndex == index ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  newImages[index],
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
                              onTap: () => removeNewImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          if (mainImageIndex == index)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("رئيسية",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10)),
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
                label: const Text("إضافة صور جديدة"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "إضافة صور جديدة ستستبدل الصور الحالية",
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
              const SizedBox(height: 24),

              // زر التحديث
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "تحديث الشقة",
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