import 'dart:convert';
import 'dart:io';
import 'package:cozy_app/models/auth_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import '../models/register_response_model.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    }

    if (Platform.isAndroid) {
      return "http://192.168.90.4:8000/api";
    }

    return "http://127.0.0.1:8000/api";
  }

  Map<String, dynamic> _tryDecodeJson(String body, String? contentType) {
    final isJson = contentType != null && contentType.contains("application/json");
    if (!isJson || body.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String? _extractErrorMessage(Map<String, dynamic> bodyJson) {
    final directMessage = bodyJson['cause'] ?? bodyJson['message'] ?? bodyJson['error'];
    if (directMessage is String && directMessage.isNotEmpty) {
      return directMessage;
    }
    final errors = bodyJson['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      if (firstError is String && firstError.isNotEmpty) {
        return firstError;
      }
    }
    return null;
  }

  //  LOGIN
  Future<LoginResponseModel> login({
    required String phone,
    required String password,
  }) async {
    debugPrint("=== Login Debug ===");
    debugPrint("Phone: $phone");
    debugPrint("URL: $baseUrl/login");

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "phone": phone,
        "password": password,
      }),
    );

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      final bodyJson = _tryDecodeJson(response.body, response.headers["content-type"]);
      final errorMsg = _extractErrorMessage(bodyJson) ?? "بيانات الدخول غير صحيحة";
      throw Exception(errorMsg);
    }
  }

  // ADMIN LOGIN
  Future<LoginResponseModel> adminLogin({
    required String phone,
    required String password,
  }) async {
    debugPrint("=== Admin Login Debug ===");
    debugPrint("Phone: $phone");
    debugPrint("URL: $baseUrl/admin/login");

    final response = await http.post(
      Uri.parse("$baseUrl/admin/login"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "phone": phone,
        "password": password,
      }),
    );

    debugPrint("Admin Login Response status: ${response.statusCode}");
    debugPrint("Admin Login Response body: ${response.body}");

    // قبول status codes متعددة (200, 201)
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final body = jsonDecode(response.body);
        debugPrint("Admin Login Response parsed successfully");
        debugPrint("Response structure: ${body.keys}");
        
        // معالجة أشكال مختلفة من الـ response
        Map<String, dynamic> loginData;
        
        // إذا كان الـ response يحتوي على 'data'
        if (body.containsKey('data')) {
          loginData = body['data'] as Map<String, dynamic>;
        } 
        // إذا كان الـ response مباشر
        else if (body.containsKey('user') && body.containsKey('token')) {
          loginData = body;
        }
        // إذا كان الـ response يحتوي على 'user' فقط
        else if (body.containsKey('user')) {
          loginData = {
            'user': body['user'],
            'token': body['token'] ?? body['access_token'] ?? '',
          };
        }
        else {
          loginData = body;
        }
        
        return LoginResponseModel.fromJson(loginData);
      } catch (e) {
        debugPrint("Error parsing admin login response: $e");
        debugPrint("Response body: ${response.body}");
        throw Exception("خطأ في معالجة استجابة الخادم: ${e.toString()}");
      }
    } else {
      final bodyJson = _tryDecodeJson(response.body, response.headers["content-type"]);
      final errorMsg = _extractErrorMessage(bodyJson) ?? "بيانات الدخول غير صحيحة";
      debugPrint("Admin login failed: $errorMsg");
      debugPrint("Status code: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      throw Exception(errorMsg);
    }
  }

  // LOGOUT
  Future<void> logout({required String token}) async {
    await http.delete(
      Uri.parse("$baseUrl/logout"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //  REGISTER
  Future<RegisterResponseModel> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String role,
    File? userImage,
    File? idImage,
    Uint8List? userImageBytes,
    Uint8List? idImageBytes,
  }) async {
    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/register"));
    request.headers["Accept"] = "application/json";

    request.fields.addAll({
      "phone": phone,
      "password": password,
      "first_name": firstName,
      "last_name": lastName,
      "birth_date": birthDate,
      "role": role,
    });

    debugPrint("=== Register Debug ===");
    debugPrint("kIsWeb: $kIsWeb");
    debugPrint("userImageBytes: ${userImageBytes != null}");
    debugPrint("idImageBytes: ${idImageBytes != null}");
    debugPrint("userImage: ${userImage != null}");
    debugPrint("idImage: ${idImage != null}");

    if (kIsWeb) {
      if (userImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          "user_image",
          userImageBytes,
          filename: "user_image.jpg",
          contentType: MediaType('image', 'jpeg'),
        ));
        debugPrint("Added user_image from bytes");
      } else {
        debugPrint("WARNING: userImageBytes is null on web!");
      }
      if (idImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          "id_image",
          idImageBytes,
          filename: "id_image.jpg",
          contentType: MediaType('image', 'jpeg'),
        ));
        debugPrint("Added id_image from bytes");
      } else {
        debugPrint("WARNING: idImageBytes is null on web!");
      }
    } else {
      if (userImage != null) {
        final multipartFile = await http.MultipartFile.fromPath("user_image", userImage.path);
        request.files.add(multipartFile);
        debugPrint("Added user_image from path: ${userImage.path}");
      } else {
        debugPrint("WARNING: userImage is null on mobile!");
      }
      if (idImage != null) {
        final multipartFile = await http.MultipartFile.fromPath("id_image", idImage.path);
        request.files.add(multipartFile);
        debugPrint("Added id_image from path: ${idImage.path}");
      } else {
        debugPrint("WARNING: idImage is null on mobile!");
      }
    }
    
    debugPrint("Total files in request: ${request.files.length}");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: $responseBody");

    final bodyJson = _tryDecodeJson(responseBody, response.headers["content-type"]);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (bodyJson['user'] != null) {
        return RegisterResponseModel.fromJson(bodyJson);
      }
      final cause = _extractErrorMessage(bodyJson);
      throw Exception(cause ?? "Register failed");
    }

    // تحسين معالجة الأخطاء
    final cause = _extractErrorMessage(bodyJson);
    if (cause != null) {
      // التحقق من أخطاء الصور بشكل خاص
      if (bodyJson['errors'] != null) {
        final errors = bodyJson['errors'];
        if (errors is Map) {
          if (errors.containsKey('user_image')) {
            final imgError = errors['user_image'];
            if (imgError is List && imgError.isNotEmpty) {
              throw Exception("خطأ في صورة البروفايل: ${imgError.first}");
            }
          }
          if (errors.containsKey('id_image')) {
            final idError = errors['id_image'];
            if (idError is List && idError.isNotEmpty) {
              throw Exception("خطأ في صورة الهوية: ${idError.first}");
            }
          }
        }
      }
      throw Exception(cause);
    }
    throw Exception("Register failed");
  }
}