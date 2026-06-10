import 'parse_utils.dart';

/// A workout plan from `GET /workout-plans` (raw Eloquent with exercises pivot).
class WorkoutPlanModel {
  final String id;
  final String name;
  final String? description;
  final String? goal;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<WorkoutExercise> exercises;

  const WorkoutPlanModel({
    required this.id,
    required this.name,
    this.description,
    this.goal,
    this.status = 'active',
    this.startDate,
    this.endDate,
    this.exercises = const [],
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'];
    return WorkoutPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Program Latihan',
      description: json['description']?.toString(),
      goal: json['goal']?.toString(),
      status: json['status']?.toString() ?? 'active',
      startDate: asDate(json['start_date']),
      endDate: asDate(json['end_date']),
      exercises: rawExercises is List
          ? rawExercises
              .whereType<Map<String, dynamic>>()
              .map(WorkoutExercise.fromJson)
              .toList()
          : const [],
    );
  }
}

class WorkoutExercise {
  final String id;
  final String name;
  final String? muscleGroup;
  final String? difficultyLevel;
  final String? videoUrl;
  final int sets;
  final int reps;
  final double? weightKg;
  final int? restSeconds;
  final String? notes;

  const WorkoutExercise({
    required this.id,
    required this.name,
    this.muscleGroup,
    this.difficultyLevel,
    this.videoUrl,
    this.sets = 0,
    this.reps = 0,
    this.weightKg,
    this.restSeconds,
    this.notes,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] is Map<String, dynamic>
        ? json['pivot'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return WorkoutExercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '-',
      muscleGroup: json['muscle_group']?.toString(),
      difficultyLevel: json['difficulty_level']?.toString(),
      videoUrl: json['video_url']?.toString(),
      sets: asInt(pivot['sets']) ?? 0,
      reps: asInt(pivot['reps']) ?? 0,
      weightKg: asDouble(pivot['weight_kg']),
      restSeconds: asInt(pivot['rest_seconds']),
      notes: pivot['notes']?.toString(),
    );
  }
}
