// lib/features/custom_trip/data/models/trip_data_model.dart

import 'package:equatable/equatable.dart';
import 'day_plan_model.dart';

class TripDataModel extends Equatable {
  final String destination;
  final List<DayPlanModel> days;
  final String totalEstimatedCost;
  final String travelTips;
  final String tripId;

  const TripDataModel({
    required this.destination,
    required this.days,
    required this.totalEstimatedCost,
    required this.travelTips,
    required this.tripId,
  });

  factory TripDataModel.fromJson(Map<String, dynamic> json) {
    var daysList = json['days'] as List? ?? [];
    List<DayPlanModel> days =
        daysList.map((d) => DayPlanModel.fromJson(d)).toList();

    return TripDataModel(
      destination: json['destination'] ?? '',
      days: days,
      totalEstimatedCost: json['totalEstimatedCost'] ?? '0',
      travelTips: json['travelTips'] ?? '',
      tripId: json['tripId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'days': days.map((d) => d.toJson()).toList(),
      'totalEstimatedCost': totalEstimatedCost,
      'travelTips': travelTips,
      'tripId': tripId,
    };
  }

  @override
  List<Object?> get props => [
        destination,
        days,
        totalEstimatedCost,
        travelTips,
        tripId,
      ];
}
