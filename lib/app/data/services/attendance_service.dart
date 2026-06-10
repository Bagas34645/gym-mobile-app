import 'dart:io';

import 'package:dio/dio.dart';

import '../models/attendance_model.dart';
import 'api_client.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();

  final ApiClient _api = ApiClient.instance;

  /// Returns the member's face enrollment status:
  /// `none` | `pending` | `verified` | `rejected`.
  Future<Map<String, dynamic>> faceStatus() async {
    final body = await _api.get('/attendance/face/status');
    return (body['data'] as Map<String, dynamic>?) ?? {'status': 'none'};
  }

  /// Uploads a single frontal face photo for enrollment (pending admin review).
  Future<Map<String, dynamic>> registerFace(File image) async {
    final formData = FormData.fromMap({
      'face_image': await MultipartFile.fromFile(
        image.path,
        filename: 'face.jpg',
      ),
    });
    final body = await _api.postMultipart('/attendance/face/register', formData);
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<List<AttendanceModel>> history({int page = 1, int perPage = 20}) async {
    final body = await _api.get(
      '/attendance/history',
      query: {'page': page, 'per_page': perPage},
    );
    final list = (body['data'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AttendanceModel.fromJson)
        .toList();
  }
}
