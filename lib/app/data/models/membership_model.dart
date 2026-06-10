import 'parse_utils.dart';

/// A purchasable plan from `GET /memberships/packages`.
class MembershipPackage {
  final String id;
  final String name;
  final String type; // daily | weekly | monthly | yearly
  final int durationDays;
  final double price;
  final String? description;
  final List<String> benefits;
  final String status;

  const MembershipPackage({
    required this.id,
    required this.name,
    required this.type,
    required this.durationDays,
    required this.price,
    this.description,
    this.benefits = const [],
    this.status = 'active',
  });

  factory MembershipPackage.fromJson(Map<String, dynamic> json) {
    return MembershipPackage(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'monthly',
      durationDays: asInt(json['duration_days']) ?? 0,
      price: asDouble(json['price']) ?? 0,
      description: json['description']?.toString(),
      benefits: asStringList(json['benefits']),
      status: json['status']?.toString() ?? 'active',
    );
  }
}

/// The member's current membership from `GET /memberships/active`.
class ActiveMembership {
  final String membershipId;
  final String packageName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int remainingDays;
  final double price;

  const ActiveMembership({
    required this.membershipId,
    required this.packageName,
    required this.status,
    this.startDate,
    this.endDate,
    this.remainingDays = 0,
    this.price = 0,
  });

  bool get isActive => status == 'active';

  factory ActiveMembership.fromJson(Map<String, dynamic> json) {
    return ActiveMembership(
      membershipId: json['membership_id']?.toString() ?? '',
      packageName: json['package_name']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'inactive',
      startDate: asDate(json['start_date']),
      endDate: asDate(json['end_date']),
      remainingDays: asInt(json['remaining_days']) ?? 0,
      price: asDouble(json['price']) ?? 0,
    );
  }
}

/// A renewal entry from `GET /memberships/history`.
class MembershipHistoryEntry {
  final String id;
  final String packageName;
  final String status; // pending_verification | approved | rejected
  final DateTime? previousEndDate;
  final DateTime? newEndDate;
  final double amountPaid;
  final DateTime? createdAt;

  const MembershipHistoryEntry({
    required this.id,
    required this.packageName,
    required this.status,
    this.previousEndDate,
    this.newEndDate,
    this.amountPaid = 0,
    this.createdAt,
  });

  factory MembershipHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MembershipHistoryEntry(
      id: json['id']?.toString() ?? '',
      packageName: json['package_name']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'pending_verification',
      previousEndDate: asDate(json['previous_end_date']),
      newEndDate: asDate(json['new_end_date']),
      amountPaid: asDouble(json['amount_paid']) ?? 0,
      createdAt: asDate(json['created_at']),
    );
  }
}
