import 'package:equatable/equatable.dart';

class TripOption extends Equatable {
  const TripOption({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;

  factory TripOption.fromJson(Map<String, dynamic> json) {
    return TripOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? json['label']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, label, value];
}

class TripOptionsConfig extends Equatable {
  const TripOptionsConfig({
    required this.minDays,
    required this.maxDays,
    required this.budgetRanges,
    required this.interests,
  });

  const TripOptionsConfig.empty()
      : minDays = 1,
        maxDays = 14,
        budgetRanges = const [],
        interests = const [];

  final int minDays;
  final int maxDays;
  final List<TripOption> budgetRanges;
  final List<TripOption> interests;

  factory TripOptionsConfig.fromJson(Map<String, dynamic> json) {
    return TripOptionsConfig(
      minDays: (json['minDays'] as num?)?.toInt() ?? 1,
      maxDays: (json['maxDays'] as num?)?.toInt() ?? 14,
      budgetRanges: _readOptions(json['budgetRanges']),
      interests: _readOptions(json['interests']),
    );
  }

  static List<TripOption> _readOptions(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(TripOption.fromJson)
        .where((option) => option.label.isNotEmpty)
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [minDays, maxDays, budgetRanges, interests];
}
