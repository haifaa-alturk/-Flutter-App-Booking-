import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AdminService {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api";
    if (Platform.isAndroid) return "http://192.168.90.4:8000/api";
    return "http://127.0.0.1:8000/api";
  }

  // ============== المستخدمين ==============

  /// جلب المستخدمين المعلقين
  Future<List<dynamic>> getPendingUsers(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/users/pending"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("فشل جلب المستخدمين المعلقين");
    }
  }

  /// جلب جميع المستخدمين
  Future<List<dynamic>> getAllUsers(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/users/all"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("فشل جلب المستخدمين");
    }
  }

  /// قبول مستخدم
  Future<void> approveUser(String token, int userId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/users/$userId/approve"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? "فشل قبول المستخدم");
    }
  }

  /// رفض مستخدم
  Future<void> rejectUser(String token, int userId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/users/$userId/reject"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? "فشل رفض المستخدم");
    }
  }

  /// حذف مستخدم
  Future<void> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/admin/users/$userId"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? "فشل حذف المستخدم");
    }
  }

  // ============== الشقق ==============

  /// جلب الشقق المعلقة
  Future<List<dynamic>> getPendingApartments(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/apartment/pending"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }
      return data is List ? data : [];
    } else {
      throw Exception("فشل جلب الشقق المعلقة");
    }
  }

  /// قبول شقة
  Future<void> approveApartment(String token, int apartmentId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/apartment/$apartmentId/approve"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? "فشل قبول الشقة");
    }
  }

  /// رفض شقة
  Future<void> rejectApartment(String token, int apartmentId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/apartment/$apartmentId/reject"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? "فشل رفض الشقة");
    }
  }

  // ============== الإحصائيات ==============

  /// جلب إحصائيات عامة (يمكن إضافة API لاحقاً)
  Future<Map<String, int>> getStatistics(String token) async {
    // حالياً نرجع الإحصائيات من خلال جلب البيانات
    final pendingUsers = await getPendingUsers(token);
    final pendingApartments = await getPendingApartments(token);

    return {
      'pendingUsers': pendingUsers.length,
      'pendingApartments': pendingApartments.length,
    };
  }
}