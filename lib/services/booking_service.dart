import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class BookingService {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api";
    if (Platform.isAndroid) return "http://192.168.26.13:8000/api";
    return "http://127.0.0.1:8000/api";
  }

  /// إنشاء حجز جديد
  Future<Map<String, dynamic>> createBooking({
    required String token,
    required int apartmentId,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "apartment_id": apartmentId,
        "from": fromDate,
        "to": toDate,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? "فشل إنشاء الحجز");
    }
  }

  /// جلب حجوزات المستخدم
  Future<List<dynamic>> getUserBookings(String token, int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId/bookings"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("فشل جلب الحجوزات");
    }
  }

  /// إلغاء حجز
  Future<Map<String, dynamic>> cancelBooking(String token, int bookingId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/bookings/$bookingId/cancel"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? "فشل إلغاء الحجز");
    }
  }

  /// تعديل حجز
  Future<Map<String, dynamic>> updateBooking({
    required String token,
    required int bookingId,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/bookings/$bookingId/update"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "from": fromDate,
        "to": toDate,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? "فشل تعديل الحجز");
    }
  }
}