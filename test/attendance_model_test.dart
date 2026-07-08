import 'package:flutter_test/flutter_test.dart';
import 'package:gym_mobile_flutter/app/data/models/attendance_model.dart';

void main() {
  test('AttendanceModel maps verification_status to label', () {
    final model = AttendanceModel.fromJson({
      'id': '1',
      'check_in_time': '2026-07-09T07:30:00Z',
      'verification_status': 'verified',
      'location': 'Kiosk',
    });

    expect(model.status, 'Hadir');
    expect(model.location, 'Kiosk');
  });
}
