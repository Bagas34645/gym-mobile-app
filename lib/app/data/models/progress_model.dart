import 'parse_utils.dart';

class ProgressWeight {
  final String id;
  final double weightKg;
  final DateTime? recordedAt;
  final String? notes;

  const ProgressWeight({
    required this.id,
    required this.weightKg,
    this.recordedAt,
    this.notes,
  });

  factory ProgressWeight.fromJson(Map<String, dynamic> json) {
    return ProgressWeight(
      id: json['id']?.toString() ?? '',
      weightKg: asDouble(json['weight_kg']) ?? 0,
      recordedAt: asDate(json['recorded_at']),
      notes: asString(json['notes']),
    );
  }
}

class ProgressSummary {
  final double? latestWeightKg;
  final int attendanceThisMonth;
  final int workoutsThisMonth;

  const ProgressSummary({
    this.latestWeightKg,
    this.attendanceThisMonth = 0,
    this.workoutsThisMonth = 0,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      latestWeightKg: asDouble(json['latest_weight_kg']),
      attendanceThisMonth: asInt(json['attendance_this_month']) ?? 0,
      workoutsThisMonth: asInt(json['workouts_this_month']) ?? 0,
    );
  }
}

class ProgressChartDataset {
  final String label;
  final List<double> values;

  const ProgressChartDataset({
    required this.label,
    required this.values,
  });

  factory ProgressChartDataset.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'];
    final values = rawValues is List
        ? rawValues.map((v) => asDouble(v) ?? 0).toList()
        : <double>[];
    return ProgressChartDataset(
      label: json['label']?.toString() ?? '',
      values: values,
    );
  }
}

class ProgressChartData {
  final List<String> labels;
  final List<ProgressChartDataset> datasets;

  const ProgressChartData({
    required this.labels,
    required this.datasets,
  });

  bool get isEmpty =>
      labels.isEmpty || datasets.isEmpty || datasets.first.values.isEmpty;

  factory ProgressChartData.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    final labels = rawLabels is List
        ? rawLabels.map((e) => e.toString()).toList()
        : <String>[];

    final rawDatasets = json['datasets'];
    final datasets = rawDatasets is List
        ? rawDatasets
            .whereType<Map<String, dynamic>>()
            .map(ProgressChartDataset.fromJson)
            .toList()
        : <ProgressChartDataset>[];

    return ProgressChartData(labels: labels, datasets: datasets);
  }
}
