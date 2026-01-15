import 'user_model.dart';

class ChatUser {
  final UserModel user;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatUser({
    required this.user,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}
