class Apartment {
  final int id;
  final String name;
  final double price;
  final String image;
  final int rooms;
  final String governorate;
  final String city;

  String? description;
  String? location;
  List<String>? gallery;
  String? ownerPhone;
  String? status;

  Apartment({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rooms,
    required this.governorate,
    required this.city,
    this.description,
    this.location,
    this.gallery,
    this.ownerPhone,
    this.status,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    // تحويل الـ id من String أو num إلى int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // تحويل السعر من String أو num إلى double
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // تحويل الغرف من String أو num إلى int
    int parseRooms(dynamic value) {
      if (value == null) return 1;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 1;
      if (value is double) return value.toInt();
      return 1;
    }

    // استخراج اسم المحافظة
    String parseGovernorate(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value['name']?.toString() ?? '';
      return '';
    }

    // استخراج اسم المدينة
    String parseCity(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value['name']?.toString() ?? '';
      return '';
    }

    // استخراج الصور
    List<String>? parseGallery(dynamic images) {
      if (images == null) return null;
      if (images is! List) return null;

      try {
        return images.map<String>((img) {
          if (img is String) return img;
          if (img is Map) {
            return img['url']?.toString() ??
                img['image_path']?.toString() ??
                img['path']?.toString() ?? '';
          }
          return '';
        }).where((url) => url.isNotEmpty).toList();
      } catch (e) {
        return null;
      }
    }

    // استخراج رقم المالك
    String? parseOwnerPhone(dynamic owner, dynamic ownerPhone) {
      if (ownerPhone != null && ownerPhone is String) return ownerPhone;
      if (owner == null) return null;
      if (owner is Map) return owner['phone']?.toString();
      return null;
    }

    return Apartment(
      id: parseId(json['id']),
      name: json['title']?.toString() ?? json['name']?.toString() ?? '',
      price: parsePrice(json['price_per_day'] ?? json['price']),
      image: json['main_image']?.toString() ?? json['image']?.toString() ?? '',
      rooms: parseRooms(json['rooms']),
      governorate: parseGovernorate(json['governorate']),
      city: parseCity(json['city']),
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      ownerPhone: parseOwnerPhone(json['owner'], json['owner_phone']),
      status: json['status']?.toString(),
      gallery: parseGallery(json['images']),
    );
  }
}