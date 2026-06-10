import 'parse_utils.dart';

/// A trainer from `GET /trainers` (list) and `GET /trainers/{id}` (detail).
class TrainerModel {
  final String id;
  final String name;
  final String specialization;
  final int experienceYears;
  final double averageRating;
  final double hourlyRate;
  final String status;
  final String? bio;
  final String? certification;
  final List<TrainerSchedule> schedules;

  const TrainerModel({
    required this.id,
    required this.name,
    required this.specialization,
    this.experienceYears = 0,
    this.averageRating = 0,
    this.hourlyRate = 0,
    this.status = 'active',
    this.bio,
    this.certification,
    this.schedules = const [],
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    final rawSchedules = json['schedules'];
    return TrainerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '-',
      experienceYears: asInt(json['experience_years']) ?? 0,
      averageRating: asDouble(json['average_rating']) ?? 0,
      hourlyRate: asDouble(json['hourly_rate']) ?? 0,
      status: json['status']?.toString() ?? 'active',
      bio: json['bio']?.toString(),
      certification: json['certification']?.toString(),
      schedules: rawSchedules is List
          ? rawSchedules
              .whereType<Map<String, dynamic>>()
              .map(TrainerSchedule.fromJson)
              .toList()
          : const [],
    );
  }
}

class TrainerSchedule {
  final String id;
  final int dayOfWeek; // 0 = Sunday ... 6 = Saturday
  final String startTime; // "08:00:00"
  final String endTime;
  final int capacity;
  final String status;

  const TrainerSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.capacity = 0,
    this.status = 'active',
  });

  static const _dayNames = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  String get dayName =>
      (dayOfWeek >= 0 && dayOfWeek < 7) ? _dayNames[dayOfWeek] : '-';

  String get timeRange => '${_hm(startTime)} - ${_hm(endTime)}';

  String get label => '$dayName ${_hm(startTime)}';

  static String _hm(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }

  factory TrainerSchedule.fromJson(Map<String, dynamic> json) {
    return TrainerSchedule(
      id: json['id']?.toString() ?? '',
      dayOfWeek: asInt(json['day_of_week']) ?? 0,
      startTime: json['start_time']?.toString() ?? '00:00:00',
      endTime: json['end_time']?.toString() ?? '00:00:00',
      capacity: asInt(json['capacity']) ?? 0,
      status: json['status']?.toString() ?? 'active',
    );
  }
}
