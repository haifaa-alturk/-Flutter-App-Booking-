// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// class FavoritesService {
//   static String get baseUrl {
//     if (kIsWeb) return "http://127.0.0.1:8000/api";
//     if (Platform.isAndroid) return "http://192.168.90.4:8000/api";
//     return "http://127.0.0.1:8000/api";
//   }

//   /// جلب المفضلة
//   Future<List<dynamic>> getFavorites(String token) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/favorites"),
//       headers: {
//         "Accept": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("فشل جلب المفضلة");
//     }
//   }

//   /// إضافة للمفضلة
//   Future<void> addToFavorites(String token, int apartmentId) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/favorites"),
//       headers: {
//         "Accept": "application/json",
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode({"apartment_id": apartmentId}),
//     );

//     if (response.statusCode != 200) {
//       throw Exception("فشل الإضافة للمفضلة");
//     }
//   }

//   /// إزالة من المفضلة
//   Future<void> removeFromFavorites(String token, int apartmentId) async {
//     final response = await http.delete(
//       Uri.parse("$baseUrl/favorites/$apartmentId"),
//       headers: {
//         "Accept": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );

//     if (response.statusCode != 200) {
//       throw Exception("فشل الإزالة من المفضلة");
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FavoritesService {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api";
    if (Platform.isAndroid) return "http://192.168.90.4:8000/api";
    return "http://127.0.0.1:8000/api";
  }

  /// جلب المفضلة
  Future<List<dynamic>> getFavorites(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/favorites"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("فشل جلب المفضلة");
    }
  }

  /// إضافة للمفضلة
  Future<void> addToFavorites(String token, int apartmentId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/favorites"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"apartment_id": apartmentId}),
    );

    if (response.statusCode != 200) {
      throw Exception("فشل الإضافة للمفضلة");
    }
  }

  /// إزالة من المفضلة
  Future<void> removeFromFavorites(String token, int apartmentId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/favorites/$apartmentId"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("فشل الإزالة من المفضلة");
    }
  }
}