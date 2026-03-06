// lib/features/custom_trip/data/models/activity_model.dart

import 'package:equatable/equatable.dart';
import 'transportation_model.dart';

class ActivityModel extends Equatable {
  final String time;
  final String place;
  final String description;
  final String estimatedCost;
  final List<TransportationModel> transportation;

  const ActivityModel({
    required this.time,
    required this.place,
    required this.description,
    required this.estimatedCost,
    required this.transportation,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    var transportationList = json['transportation'] as List? ?? [];
    List<TransportationModel> transportation =
        transportationList.map((t) => TransportationModel.fromJson(t)).toList();

    return ActivityModel(
      time: json['time'] ?? '',
      place: json['place'] ?? '',
      description: json['description'] ?? '',
      estimatedCost: json['estimatedCost'] ?? '0',
      transportation: transportation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'place': place,
      'description': description,
      'estimatedCost': estimatedCost,
      'transportation': transportation.map((t) => t.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        time,
        place,
        description,
        estimatedCost,
        transportation,
      ];
}
