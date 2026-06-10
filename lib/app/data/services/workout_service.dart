import '../models/workout_model.dart';
import 'api_client.dart';

class WorkoutService {
  WorkoutService._();

  static final WorkoutService instance = WorkoutService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<WorkoutPlanModel>> plans() async {
    final body = await _api.get('/workout-plans');
    final list = (body['data'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(WorkoutPlanModel.fromJson)
        .toList();
  }

  /// Logs a completed workout.
  Future<Map<String, dynamic>> logWorkout({
    String? workoutPlanId,
    required List<Map<String, dynamic>> exercises,
    int? durationMinutes,
    String? notes,
  }) async {
    final body = await _api.post(
      '/workout-logs',
      data: {
        if (workoutPlanId != null) 'workout_plan_id': workoutPlanId,
        'exercises': exercises,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }
}
