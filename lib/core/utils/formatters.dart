import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

/// Formats a number into Indonesian Rupiah, e.g. 150000 -> "Rp 150.000".
String formatRupiah(num value) => _currency.format(value);

/// Formats a date as e.g. "31 Juli 2025". Returns [fallback] when null.
String formatDateLong(DateTime? date, {String fallback = '-'}) {
  if (date == null) return fallback;
  return DateFormat('d MMMM yyyy', 'id').format(date.toLocal());
}

/// Formats a date as e.g. "31 Jul 2025". Returns [fallback] when null.
String formatDateShort(DateTime? date, {String fallback = '-'}) {
  if (date == null) return fallback;
  return DateFormat('d MMM yyyy', 'id').format(date.toLocal());
}

String formatTime(DateTime? date, {String fallback = '-'}) {
  if (date == null) return fallback;
  return DateFormat('HH:mm', 'id').format(date.toLocal());
}
