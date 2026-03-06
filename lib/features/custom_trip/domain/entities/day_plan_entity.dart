// lib/features/custom_trip/domain/entities/day_plan_entity.dart

import 'package:equatable/equatable.dart';
import 'activity_entity.dart';

class DayPlanEntity extends Equatable {
  final int day;
  final String title;
  final String estimatedDayCost;
  final List<ActivityEntity> activities;

  const DayPlanEntity({
    required this.day,
    required this.title,
    required this.estimatedDayCost,
    required this.activities,
  });

  @override
  List<Object?> get props => [
        day,
        title,
        estimatedDayCost,
        activities,
      ];
}
