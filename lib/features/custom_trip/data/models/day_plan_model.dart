// lib/features/custom_trip/data/models/day_plan_model.dart

import 'package:equatable/equatable.dart';
import 'activity_model.dart';

class DayPlanModel extends Equatable {
  final int day;
  final String title;
  final String estimatedDayCost;
  final List<ActivityModel> activities;

  const DayPlanModel({
    required this.day,
    required this.title,
    required this.estimatedDayCost,
    required this.activities,
  });

  factory DayPlanModel.fromJson(Map<String, dynamic> json) {
    var activitiesList = json['activities'] as List? ?? [];
    List<ActivityModel> activities =
        activitiesList.map((a) => ActivityModel.fromJson(a)).toList();

    return DayPlanModel(
      day: json['day'] ?? 0,
      title: json['title'] ?? '',
      estimatedDayCost: json['estimatedDayCost'] ?? '0',
      activities: activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'estimatedDayCost': estimatedDayCost,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        day,
        title,
        estimatedDayCost,
        activities,
      ];
}
