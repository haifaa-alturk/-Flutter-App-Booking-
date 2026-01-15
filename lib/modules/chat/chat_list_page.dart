// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/chat_controller.dart';
// import 'chat_page.dart';

// class ChatListPage extends StatefulWidget {
//   const ChatListPage({super.key});

//   @override
//   State<ChatListPage> createState() => _ChatListPageState();
// }

// class _ChatListPageState extends State<ChatListPage> {
//   final ChatController controller = Get.find<ChatController>();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchConversations();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("المراسلات"),
//         backgroundColor: Colors.teal,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () {
//               controller.fetchConversations();
//             },
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoadingConversations.value) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(color: Colors.teal),
//                 SizedBox(height: 16),
//                 Text("جاري تحميل المحادثات..."),
//               ],
//             ),
//           );
//         }

//         if (controller.conversations.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.message_outlined, size: 80, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   "لا توجد محادثات بعد",
//                   style: TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "ابدأ محادثة جديدة مع مستخدم آخر",
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//                 SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () {
//                     controller.fetchConversations();
//                   },
//                   child: Text("إعادة تحميل"),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: () async {
//             await controller.fetchConversations();
//           },
//           child: ListView.builder(
//             itemCount: controller.conversations.length,
//             itemBuilder: (context, index) {
//               final chat = controller.conversations[index];

//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: chat.user.userImageUrl != null
//                       ? NetworkImage(chat.user.userImageUrl!)
//                       : null,
//                   backgroundColor: Colors.teal.shade200,
//                   child: chat.user.userImageUrl == null
//                       ? Text(chat.user.firstName[0])
//                       : null,
//                 ),
//                 title: Text("${chat.user.firstName} ${chat.user.lastName}"),
//                 subtitle: Text(
//                   chat.lastMessage,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 trailing: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}",
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     if (chat.unreadCount > 0)
//                       Container(
//                         margin: EdgeInsets.only(top: 4),
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.teal,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           chat.unreadCount.toString(),
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 onTap: () {
//                   Get.to(() => ChatPage(user: chat.user));
//                 },
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatController controller;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() async {
    try {
      // ✅ انتظر حتى يكون ChatController جاهزاً
      await Future.delayed(Duration(milliseconds: 500));
      
      if (Get.isRegistered<ChatController>()) {
        controller = Get.find<ChatController>();
        _isControllerReady = true;
        
        // ✅ تحميل المحادثات بعد التأكد من جاهزية الـ Controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchConversations();
        });
        
        setState(() {});
      } else {
        print('⚠️ ChatController not registered, trying again...');
        await Future.delayed(Duration(milliseconds: 300));
        _initializeController(); // إعادة المحاولة
      }
    } catch (e) {
      print('❌ Error initializing ChatController: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("المراسلات"),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.teal),
              SizedBox(height: 20),
              Text("جاري تهيئة المراسلات..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("المراسلات"),
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        if (controller.isLoadingConversations.value) {
          return Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text("لا توجد محادثات بعد"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.fetchConversations();
                  },
                  child: Text("إعادة تحميل"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.conversations.length,
          itemBuilder: (context, index) {
            final chat = controller.conversations[index];
            return ListTile(
              title: Text("${chat.user.firstName} ${chat.user.lastName}"),
              subtitle: Text(chat.lastMessage),
              onTap: () {
                Get.to(() => ChatPage(user: chat.user));
              },
            );
          },
        );
      }),
    );
  }
}