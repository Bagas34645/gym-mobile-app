import 'api_client.dart';

class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  final ApiClient _api = ApiClient.instance;

  /// Submits member feedback. Returns the created payload from the API.
  Future<Map<String, dynamic>> submit({
    required int rating,
    required String category,
    String? message,
    bool isAnonymous = false,
  }) async {
    final body = await _api.post(
      '/feedback',
      data: {
        'rating': rating,
        'category': category,
        if (message != null && message.isNotEmpty) 'message': message,
        'is_anonymous': isAnonymous,
      },
    );
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }
}
