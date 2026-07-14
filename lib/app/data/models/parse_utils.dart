/// Defensive parsers — the backend sometimes serializes decimals as strings
/// (e.g. "150000.00") and ids as UUID strings, so coerce carefully.
double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? asDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw) ??
      DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

String? asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

String? asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

List<String> asStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}
