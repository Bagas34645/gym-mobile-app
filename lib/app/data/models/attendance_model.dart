class AttendanceModel {
  final String id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String? method; // 'face_recognition' | 'manual'
  final String? location;
  final String? notes;

  AttendanceModel({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.method,
    this.location,
    this.notes,
  });

  /// Maps the backend `verification_status` to a user-facing label.
  static String _mapStatus(dynamic raw) {
    switch (raw?.toString()) {
      case 'verified':
      case 'manual_verified':
        return 'Hadir';
      case 'failed':
        return 'Gagal';
      default:
        return raw?.toString() ?? 'Hadir';
    }
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final verificationStatus = json['verification_status'];
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      checkInTime: DateTime.parse(json['check_in_time'] ?? json['checkInTime'] ?? DateTime.now().toIso8601String()),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.tryParse(json['check_out_time'])
          : null,
      status: verificationStatus != null
          ? _mapStatus(verificationStatus)
          : (json['status'] ?? 'Hadir'),
      method: json['method'] ?? (verificationStatus != null ? 'face_recognition' : null),
      location: json['location']?.toString(),
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
      'location': location,
      'notes': notes,
    };
  }
}
