import '../../../data/models/parse_utils.dart';

class ConversationModel {
  final String id;
  final String? subject;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? otherPartyName;
  final String? status;

  ConversationModel({
    required this.id,
    required this.title,
    this.subject,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.otherPartyName,
    this.status,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final admin = json['admin'];
    final adminName = admin is Map ? asString(admin['name']) : null;

    return ConversationModel(
      id: json['id'].toString(),
      title: asString(json['subject']) ?? asString(json['title']) ?? 'Chat',
      subject: asString(json['subject']),
      lastMessage: asString(json['last_message']),
      lastMessageAt: asDate(json['last_message_at'] ?? json['updated_at']),
      unreadCount: asInt(json['unread_count']) ?? 0,
      otherPartyName:
          asString(json['other_party_name']) ?? adminName ?? 'Admin Support',
      status: asString(json['status']),
    );
  }

  bool get isActive => status == null || status == 'open' || status == 'in_progress';
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    required this.isMe,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final senderId = asString(json['user_id'] ?? json['sender_id']) ?? '';
    return MessageModel(
      id: asString(json['id']) ?? '',
      conversationId:
          asString(json['chat_conversation_id'] ?? json['conversation_id']) ??
          '',
      senderId: senderId,
      message: json['message']?.toString() ?? '',
      createdAt: asDate(json['created_at']) ?? DateTime.now(),
      isMe: senderId == currentUserId,
    );
  }
}
