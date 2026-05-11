class AttendanceModel {
  final String id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String? method; // 'face_recognition' | 'manual'
  final String? notes;

  AttendanceModel({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.method,
    this.notes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      checkInTime: DateTime.parse(json['check_in_time'] ?? json['checkInTime'] ?? DateTime.now().toIso8601String()),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.tryParse(json['check_out_time'])
          : null,
      status: json['status'] ?? 'Hadir',
      method: json['method'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'status': status,
      'method': method,
      'notes': notes,
    };
  }
}
