import 'dart:io';

import 'package:dio/dio.dart';

import '../models/membership_model.dart';
import 'api_client.dart';

class MembershipService {
  MembershipService._();

  static final MembershipService instance = MembershipService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<MembershipPackage>> packages() async {
    final body = await _api.get('/memberships/packages');
    final list = (body['data'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MembershipPackage.fromJson)
        .toList();
  }

  /// Returns the active membership, or `null` when the member has none.
  Future<ActiveMembership?> active() async {
    final body = await _api.get('/memberships/active');
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return ActiveMembership.fromJson(data);
    }
    return null;
  }

  Future<List<MembershipHistoryEntry>> history() async {
    final body = await _api.get('/memberships/history');
    final list = (body['data'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MembershipHistoryEntry.fromJson)
        .toList();
  }

  /// Requests a renewal. [paymentMethod] is one of `transfer|cash|qris`.
  /// A [paymentProof] image is required when paying via `transfer`.
  Future<Map<String, dynamic>> renew({
    required String packageId,
    required String paymentMethod,
    File? paymentProof,
  }) async {
    final form = <String, dynamic>{
      'package_id': packageId,
      'payment_method': paymentMethod,
    };
    if (paymentProof != null) {
      form['payment_proof'] = await MultipartFile.fromFile(
        paymentProof.path,
        filename: 'payment_proof.jpg',
      );
    }
    final body = await _api.postMultipart(
      '/memberships/renew',
      FormData.fromMap(form),
    );
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }
}
