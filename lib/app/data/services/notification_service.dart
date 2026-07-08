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
}
