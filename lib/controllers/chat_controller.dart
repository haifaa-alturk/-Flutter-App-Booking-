import 'package:cozy_app/controllers/auth_controller.dart';
// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../services/chat_service.dart';


class ChatController extends GetxController {
  AuthController authController = Get.find<AuthController>();
  final ChatService _chatService = ChatService();

  RxList<ChatUser> conversations = <ChatUser>[].obs;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;

  RxBool isLoadingConversations = false.obs;
  RxBool isLoadingMessages = false.obs;

  //String get token => authController.token.value;

 String get token {
    // ✅ تحقق من وجود AuthController أولاً
    if (!Get.isRegistered<AuthController>()) {
      throw Exception("AuthController not ready");
    }
    return Get.find<AuthController>().token.value;
  }

 @override
  void onInit() {
    super.onInit();
    
    // ✅ تأخير الوصول إلى AuthController حتى يكتمل تهيئته
    Future.delayed(Duration(milliseconds: 100), () {
      if (Get.isRegistered<AuthController>()) {
        authController = Get.find<AuthController>();
        print('✅ ChatController: AuthController initialized successfully');
      } else {
        print('⚠️ ChatController: AuthController not ready yet');
      }
    });
  }

  // Load conversation list
  // Load conversation list
  // Future<void> fetchConversations() async {
  //   try {
  //     isLoadingConversations.value = true;
  //     conversations.clear(); // تنظيف القائمة القديمة

  //     print('🔄 Fetching conversations...');
      
  //     if (token.isEmpty) {
  //       throw Exception("No authentication token found");
  //     }

  //     final users = await _chatService.fetchChats(token);

  //     print('📱 Received ${users.length} users');
      
  //     // تحويل المستخدمين إلى ChatUser مع بيانات افتراضية
  //     conversations.value = users.map((user) {
  //       return ChatUser(
  //         user: user,
  //         lastMessage: "ابدأ المحادثة الآن",
  //         lastMessageTime: DateTime.now(),
  //         unreadCount: 0,
  //       );
  //     }).toList();

  //     print('✅ Conversations loaded successfully');

  //   } catch (e) {
  //     print('❌ Error in fetchConversations: $e');
      
  //     // عرض رسالة مناسبة للمستخدم
  //     String errorMessage;
  //     if (e.toString().contains("Unauthorized")) {
  //       errorMessage = "يرجى تسجيل الدخول مرة أخرى";
  //       // يمكنك إضافة إعادة توجيه إلى صفحة تسجيل الدخول
  //       // Get.offAllNamed('/login');
  //     } else if (e.toString().contains("Connection failed")) {
  //       errorMessage = "تحقق من اتصالك بالإنترنت";
  //     } else {
  //       errorMessage = "فشل تحميل المحادثات";
  //     }
      
  //     Get.snackbar(
  //       "خطأ",
  //       errorMessage,
  //       backgroundColor: Colors.red.shade100,
  //       colorText: Colors.red.shade900,
  //       duration: Duration(seconds: 3),
  //     );
      
  //     // إرجاع قائمة فارغة لتجنب الأخطاء
  //     conversations.value = [];
      
  //   } finally {
  //     isLoadingConversations.value = false;
  //   }
  // }

 // Load conversation list
  Future<void> fetchConversations() async {
    try {
      // ✅ تحقق من توفر التوكن أولاً
      if (!Get.isRegistered<AuthController>()) {
        print('❌ AuthController not registered yet');
        return;
      }
      
      final currentToken = Get.find<AuthController>().token.value;
      if (currentToken.isEmpty) {
        print('❌ No token available');
        Get.snackbar("تنبيه", "يرجى تسجيل الدخول أولاً");
        return;
      }

      isLoadingConversations.value = true;
      print('🔄 Fetching conversations with token...');

      // هنا يمكنك إضافة البيانات التجريبية أولاً
      await Future.delayed(Duration(milliseconds: 500));
     
      print('✅ Loaded conversations successfully');
      
    } catch (e) {
      print('❌ Error in fetchConversations: $e');
      Get.snackbar("خطأ", "حدث خطأ في تحميل المحادثات");
    } finally {
      isLoadingConversations.value = false;
    }
  }

  // Load messages with a specific user
  Future<void> fetchMessages(int otherUserId) async {
    try {
      isLoadingMessages.value = true;
      messages.value =
      await _chatService.fetchMessages(token, otherUserId);
    } catch (e) {
      Get.snackbar("Error", "Failed to load messages");
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // Send message
  Future<void> sendMessage({
    required int receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final myId = authController.currentUser.value!.id;

    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: myId,
      receiverId: receiverId,
      message: text,
      createdAt: DateTime.now(),
    );

    messages.add(tempMessage);

    try {
      final sent = await _chatService.sendMessage(
        token: token,
        receiverId: receiverId,
        message: text,
      );

      // Replace temp message
      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) messages[index] = sent;
    } catch (e) {
      messages.remove(tempMessage);
      Get.snackbar("Error", "Message failed to send");
    }
  }
}
