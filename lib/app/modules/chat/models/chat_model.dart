import '../../../data/models/parse_utils.dart';

class ConversationModel {
  final String id;
  final String? subject;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? otherPartyName;
  final String? otherPartyPhoto;

  ConversationModel({
    required this.id,
    required this.title,
    this.subject,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.otherPartyName,
    this.otherPartyPhoto,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Chat',
      subject: json['subject'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      unreadCount: asInt(json['unread_count']) ?? 0,
      otherPartyName: json['other_party_name'],
      otherPartyPhoto: json['other_party_photo'],
    );
  }
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
      message: json['message'] ?? '',
      createdAt: asDate(json['created_at']) ?? DateTime.now(),

      isMe: senderId.toString() == currentUserId,
    );
  }
}
