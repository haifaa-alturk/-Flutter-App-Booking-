import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/user_model.dart';

class ChatService {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api";
    if (Platform.isAndroid) return "http://192.168.26.13:8000/api";
    return "http://127.0.0.1:8000/api";
  }

  Map<String, String> _headers(String token) => {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  /// Get all conversations (users you chatted with)
  // Future<List<UserModel>> fetchChats(String token) async {
  //   final res = await http.get(
  //     Uri.parse("$baseUrl/message"),
  //     headers: _headers(token),
  //   );

  //   if (res.statusCode == 200) {
  //     final List data = jsonDecode(res.body);
  //     return data.map((e) => UserModel.fromJson(e)).toList();
  //   }

  //   throw Exception("Failed to load chats");
  // }
   Future<List<UserModel>> fetchChats(String token) async {
    try {
      print('🔗 Fetching chats from: $baseUrl/message');
      print('📝 Token: ${token.substring(0, 20)}...');
      
      final res = await http.get(
        Uri.parse("$baseUrl/message"),
        headers: _headers(token),
      );

      print('📊 Response status: ${res.statusCode}');
      print('📦 Response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('✅ Parsed data: $data');
        
        if (data is List) {
          return data.map((e) => UserModel.fromJson(e)).toList();
        } else if (data is Map && data.containsKey('data')) {
          // إذا كان الرد يحتوي على data wrapper
          final List dataList = data['data'];
          return dataList.map((e) => UserModel.fromJson(e)).toList();
        } else {
          print('❌ Unexpected response format');
          return [];
        }
      } else if (res.statusCode == 401) {
        print('❌ Unauthorized - Token expired');
        throw Exception("Unauthorized - Please login again");
      } else if (res.statusCode == 404) {
        print('❌ Endpoint not found');
        return []; // لا توجد محادثات بعد
      } else {
        print('❌ Server error: ${res.body}');
        throw Exception("Server error: ${res.statusCode}");
      }
    } catch (e) {
      print('❌ Exception in fetchChats: $e');
      rethrow;
    }
  }

  /// Get messages between logged user & receiver
  Future<List<ChatMessage>> fetchMessages(
      String token, int receiverId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/message/$receiverId"),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    }

    throw Exception("Failed to load messages");
  }

  /// Send message
  Future<ChatMessage> sendMessage({
    required String token,
    required int receiverId,
    required String message,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/message"),
      headers: _headers(token),
      body: jsonEncode({
        "receiver_id": receiverId,
        "message": message,
      }),
    );

    if (res.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(res.body));
    }

    throw Exception("Failed to send message");
  }
}
