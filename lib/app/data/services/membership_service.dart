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

  /// Requests a cash renewal at the gym (pending admin verification).
  Future<Map<String, dynamic>> renew({
    required String packageId,
    required String paymentMethod,
  }) async {
    final body = await _api.post(
      '/memberships/renew',
      data: {
        'package_id': packageId,
        'payment_method': paymentMethod,
      },
    );
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }
}
