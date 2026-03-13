// lib/features/custom_trip/utils/trip_mapper.dart

import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/custom_trip/domain/entities/trip_data_entity.dart';

class TripMapper {
  static TripPlanResponse mapToTripPlanResponse({
    required TripDataEntity tripData,
    required String region,
    required int numberOfDays,
  }) {
    // Convert DayPlanEntity to DailyPlan
    final List<DailyPlan> dailyPlans = tripData.days.map((day) {
      return DailyPlan(
        day: day.day,
        title: day.title,
        estimatedDayCost: day.estimatedDayCost,
        activities: day.activities.map((activity) {
          return Activity(
            time: activity.time,
            place: activity.place,
            description: activity.description,
            estimatedCost: activity.estimatedCost,
            transportation: activity.transportation.map((transport) {
              return Transportation(
                from: transport.from,
                to: transport.to,
                method: transport.method,
                estimatedCost: transport.estimatedCost,
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    // Create TripPlan
    final tripPlan = TripPlan(
      destination: tripData.destination,
      days: dailyPlans,
      totalEstimatedCost: tripData.totalEstimatedCost,
      budgetTips: '', // Not provided in the response
      travelTips: tripData.travelTips,
      emergencyContact: '', // Not provided in the response
    );

    // Create TripPlanResponse
    return TripPlanResponse(
      success: true,
      savedId: 0, // Will be set when saved
      response: tripPlan,
    );
  }
}
