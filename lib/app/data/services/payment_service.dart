import 'api_client.dart';

class SnapPaymentResult {
  SnapPaymentResult({
    required this.renewalId,
    required this.orderId,
    required this.snapToken,
    required this.redirectUrl,
    required this.clientKey,
  });

  final String renewalId;
  final String orderId;
  final String snapToken;
  final String redirectUrl;
  final String clientKey;

  factory SnapPaymentResult.fromJson(Map<String, dynamic> json) {
    return SnapPaymentResult(
      renewalId: json['renewal_id'] as String,
      orderId: json['order_id'] as String,
      snapToken: json['snap_token'] as String,
      redirectUrl: json['redirect_url'] as String,
      clientKey: json['client_key'] as String? ?? '',
    );
  }
}

class PaymentStatusResult {
  PaymentStatusResult({
    required this.orderId,
    required this.renewalStatus,
    required this.transactionStatus,
    required this.isPaid,
  });

  final String orderId;
  final String renewalStatus;
  final String? transactionStatus;
  final bool isPaid;

  factory PaymentStatusResult.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResult(
      orderId: json['order_id'] as String,
      renewalStatus: json['renewal_status'] as String,
      transactionStatus: json['transaction_status'] as String?,
      isPaid: json['is_paid'] as bool? ?? false,
    );
  }
}

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  final ApiClient _api = ApiClient.instance;

  Future<SnapPaymentResult> createSnapPayment(String packageId) async {
    final body = await _api.post(
      '/memberships/payments/snap',
      data: {'package_id': packageId},
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return SnapPaymentResult.fromJson(data);
  }

  Future<PaymentStatusResult> getPaymentStatus(String orderId) async {
    final body = await _api.get('/memberships/payments/$orderId/status');
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return PaymentStatusResult.fromJson(data);
  }
}
