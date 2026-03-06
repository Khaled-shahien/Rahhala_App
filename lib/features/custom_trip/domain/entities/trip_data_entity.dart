// lib/features/custom_trip/domain/entities/trip_data_entity.dart

import 'package:equatable/equatable.dart';
import 'day_plan_entity.dart';

class TripDataEntity extends Equatable {
  final String destination;
  final List<DayPlanEntity> days;
  final String totalEstimatedCost;
  final String travelTips;
  final String tripId;

  const TripDataEntity({
    required this.destination,
    required this.days,
    required this.totalEstimatedCost,
    required this.travelTips,
    required this.tripId,
  });

  @override
  List<Object?> get props => [
        destination,
        days,
        totalEstimatedCost,
        travelTips,
        tripId,
      ];
}
