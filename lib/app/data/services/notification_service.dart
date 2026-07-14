import '../../modules/notification/models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final ApiClient _api = ApiClient.instance;

  Future<bool> hasUnread() async {
    final body = await _api.get(
      '/notifications',
      query: {'per_page': 1, 'unread_only': true},
    );
    final list = (body['data'] as List?) ?? [];
    final meta = body['meta'] as Map<String, dynamic>?;
    final total = meta?['total'];
    if (total is num) return total > 0;
    return list.isNotEmpty;
  }

  Future<List<AppNotification>> list({
    int perPage = 50,
    bool unreadOnly = false,
  }) async {
    final body = await _api.get(
      '/notifications',
      query: {
        'per_page': perPage,
        if (unreadOnly) 'unread_only': true,
      },
    );
    final data = body['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AppNotification>> unreadList({int perPage = 20}) {
    return list(perPage: perPage, unreadOnly: true);
  }

  Future<void> markRead(String id) async {
    await _api.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.put('/notifications/read-all');
  }
}
