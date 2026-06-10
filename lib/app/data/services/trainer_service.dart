import '../models/trainer_model.dart';
import 'api_client.dart';

class TrainerService {
  TrainerService._();

  static final TrainerService instance = TrainerService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<TrainerModel>> list() async {
    final body = await _api.get('/trainers');
    final list = (body['data'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(TrainerModel.fromJson)
        .toList();
  }

  Future<TrainerModel> detail(String id) async {
    final body = await _api.get('/trainers/$id');
    final data = (body['data'] as Map<String, dynamic>?) ?? {};
    return TrainerModel.fromJson(data);
  }

  /// Books a trainer session. [sessionDate] must be `yyyy-MM-dd`.
  Future<Map<String, dynamic>> book({
    required String trainerId,
    required String scheduleId,
    required String sessionDate,
    String? notes,
  }) async {
    final body = await _api.post(
      '/trainers/$trainerId/booking',
      data: {
        'schedule_id': scheduleId,
        'session_date': sessionDate,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }
}
