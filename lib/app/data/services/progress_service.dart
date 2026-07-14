import '../models/progress_model.dart';
import 'api_client.dart';

class ProgressService {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

  final ApiClient _api = ApiClient.instance;

  Future<ProgressSummary> getSummary() async {
    final body = await _api.get('/progress/summary');
    final data = (body['data'] as Map<String, dynamic>?) ?? {};
    return ProgressSummary.fromJson(data);
  }

  Future<List<ProgressWeight>> getWeightHistory() async {
    final body = await _api.get('/progress/weight');
    final data = body['data'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ProgressWeight.fromJson)
        .toList();
  }

  Future<ProgressWeight> storeWeight({
    required double weightKg,
    String? notes,
  }) async {
    final body = await _api.post(
      '/progress/weight',
      data: {
        'weight_kg': weightKg,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    final data = (body['data'] as Map<String, dynamic>?) ?? {};
    return ProgressWeight.fromJson(data);
  }

  Future<void> deleteWeight(String id) async {
    await _api.delete('/progress/weight/$id');
  }

  Future<ProgressChartData> getChart({
    required String type,
    required String period,
  }) async {
    final body = await _api.get(
      '/progress/chart',
      query: {'type': type, 'period': period},
    );
    final data = (body['data'] as Map<String, dynamic>?) ?? {};
    return ProgressChartData.fromJson(data);
  }
}
