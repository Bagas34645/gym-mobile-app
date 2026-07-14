import '../../../data/models/parse_utils.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  bool get isChat => type == 'chat';

  String? get conversationId {
    final raw = data['conversation_id'];
    return raw?.toString();
  }

  String get typeLabel {
    switch (type) {
      case 'chat':
        return 'Chat';
      case 'promo':
        return 'Promo';
      case 'membership_reminder':
        return 'Membership';
      case 'workout_reminder':
        return 'Latihan';
      case 'system':
        return 'Sistem';
      default:
        return type;
    }
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return AppNotification(
      id: asString(json['id']) ?? '',
      title: asString(json['title']) ?? 'Notifikasi',
      message: asString(json['message']) ?? '',
      type: asString(json['type']) ?? 'system',
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
      isRead: json['is_read'] == true,
      createdAt: asDate(json['created_at']) ?? DateTime.now(),
    );
  }
}
