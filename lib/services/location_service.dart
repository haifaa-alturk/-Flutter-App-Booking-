import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// خدمة لجلب المحافظات والمدن من API
class LocationService {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api";
    if (Platform.isAndroid) return "http://192.168.90.4:8000/api";
    return "http://127.0.0.1:8000/api";
  }

  /// جلب جميع المحافظات
  Future<List<Map<String, dynamic>>> getGovernorates() async {
    try {
      debugPrint("Fetching governorates from: $baseUrl/governorates");
      final response = await http.get(
        Uri.parse("$baseUrl/governorates"),
        headers: {
          "Accept": "application/json",
        },
      );

      debugPrint("Governorates response status: ${response.statusCode}");
      debugPrint("Governorates response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          final govs = List<Map<String, dynamic>>.from(data['data']);
          debugPrint("Loaded ${govs.length} governorates from API");
          return govs;
        }
        if (data is List) {
          final govs = List<Map<String, dynamic>>.from(data);
          debugPrint("Loaded ${govs.length} governorates from API (direct list)");
          return govs;
        }
        debugPrint("No governorates found in response");
        return [];
      } else {
        debugPrint("Failed to fetch governorates: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching governorates: $e");
      return [];
    }
  }

  /// جلب المدن حسب المحافظة
  Future<List<Map<String, dynamic>>> getCitiesByGovernorate(int governorateId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/governorates/$governorateId/cities"),
        headers: {
          "Accept": "application/json",
        },
      );

      debugPrint("Fetching cities for governorate $governorateId: Status ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          final cities = List<Map<String, dynamic>>.from(data['data']);
          debugPrint("Loaded ${cities.length} cities for governorate $governorateId");
          return cities;
        }
        if (data is List) {
          final cities = List<Map<String, dynamic>>.from(data);
          debugPrint("Loaded ${cities.length} cities for governorate $governorateId");
          return cities;
        }
        debugPrint("No cities found in response");
        return [];
      } else {
        debugPrint("Failed to fetch cities: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching cities: $e");
      return [];
    }
  }

  /// جلب جميع المدن
  Future<List<Map<String, dynamic>>> getAllCities() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/cities"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        debugPrint("Failed to fetch all cities: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching all cities: $e");
      return [];
    }
  }
}
