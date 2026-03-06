// lib/features/custom_trip/data/repositories/trip_repository.dart

import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/constants/app_constants.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/day_plan_entity.dart';
import '../../domain/entities/trip_data_entity.dart';
import '../../domain/entities/transportation_entity.dart';
import '../../domain/repositories/trip_repository_interface.dart';
import '../models/transportation_model.dart';
import '../models/activity_model.dart';
import '../models/day_plan_model.dart';
import '../models/trip_data_model.dart';
import '../sources/trip_api_service.dart';

class TripRepository implements TripRepositoryInterface {
  final TripApiService apiService;

  TripRepository({required this.apiService});

  @override
  Future<Either<String, TripDataEntity>> generateTripPlan({
    required String region,
    required int numberOfDays,
  }) async {
    try {
      // Retry logic with exponential backoff for HTTP 503 errors
      TripDataModel? tripData;
      int retryCount = 0;
      const maxRetries = AppConstants.maxRetryAttempts;

      while (retryCount < maxRetries) {
        try {
          tripData = await apiService.generateTripPlan(
            region: region,
            numberOfDays: numberOfDays,
          );
          break; // Success, exit retry loop
        } catch (e) {
          retryCount++;

          // Check if it's a 503 error and we have retries left
          if (e.toString().contains('503') && retryCount < maxRetries) {
            // Exponential backoff: 1s, 2s, 4s
            final delay = Duration(seconds: 1 * (1 << (retryCount - 1)));
            await Future.delayed(delay);
            continue;
          }

          // If no more retries or not a 503 error, throw the exception
          rethrow;
        }
      }

      if (tripData == null) {
        return const Left(
            'Failed to generate trip plan after multiple attempts');
      }

      // Convert model to entity
      final tripEntity = _mapToEntity(tripData);
      return Right(tripEntity);
    } catch (e) {
      return Left(_mapErrorToMessage(e));
    }
  }

  TripDataEntity _mapToEntity(TripDataModel model) {
    return TripDataEntity(
      destination: model.destination,
      days: model.days.map((day) => _mapDayToEntity(day)).toList(),
      totalEstimatedCost: model.totalEstimatedCost,
      travelTips: model.travelTips,
      tripId: model.tripId,
    );
  }

  DayPlanEntity _mapDayToEntity(DayPlanModel model) {
    return DayPlanEntity(
      day: model.day,
      title: model.title,
      estimatedDayCost: model.estimatedDayCost,
      activities: model.activities
          .map((activity) => _mapActivityToEntity(activity))
          .toList(),
    );
  }

  ActivityEntity _mapActivityToEntity(ActivityModel model) {
    return ActivityEntity(
      time: model.time,
      place: model.place,
      description: model.description,
      estimatedCost: model.estimatedCost,
      transportation: model.transportation
          .map((t) => TransportationEntity(
                from: t.from,
                to: t.to,
                method: t.method,
                estimatedCost: t.estimatedCost,
              ))
          .toList(),
    );
  }

  String _mapErrorToMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
