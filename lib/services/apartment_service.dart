import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApartmentService {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api";
    if (Platform.isAndroid) return "http://192.168.26.13:8000/api";
    return "http://127.0.0.1:8000/api";
  }

  /// جلب كل الشقق المتاحة
  Future<List<dynamic>> getAllApartments() async {
    final response = await http.get(
      Uri.parse("$baseUrl/apartment"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API returns { "data": [...] }
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }
      return data is List ? data : [];
    } else {
      throw Exception("فشل جلب الشقق");
    }
  }

  /// جلب تفاصيل شقة محددة
  Future<Map<String, dynamic>> getApartment(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/apartment/$id"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }
      return data;
    } else {
      throw Exception("فشل جلب تفاصيل الشقة");
    }
  }
}