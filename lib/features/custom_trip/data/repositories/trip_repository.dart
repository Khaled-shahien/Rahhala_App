import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/day_plan_entity.dart';
import '../../domain/entities/trip_data_entity.dart';
import '../../domain/entities/transportation_entity.dart';
import '../../domain/repositories/trip_repository_interface.dart';
import '../models/activity_model.dart';
import '../models/day_plan_model.dart';
import '../models/trip_data_model.dart';
import '../sources/trip_api_service.dart';

class TripRepository implements TripRepositoryInterface {
  final TripApiService apiService;

  TripRepository({required this.apiService});

  /// Generates a custom plan.
  ///
  /// Not retried automatically: the endpoint isn't idempotent, so a retry
  /// could produce duplicate plans. The UI offers "try again" instead
  /// (DECISIONS D-12).
  @override
  Future<Either<String, TripDataEntity>> generateTripPlan({
    required String region,
    required int numberOfDays,
  }) async {
    try {
      final tripData = await apiService.generateTripPlan(
        region: region,
        numberOfDays: numberOfDays,
      );
      return Right(_mapToEntity(tripData));
    } catch (e, stackTrace) {
      final failure = failureFromError(e);
      if (failure.type == FailureType.parsing ||
          failure.type == FailureType.unknown) {
        AppErrorReporter.record(
          'TripRepository.generateTripPlan failed',
          error: e,
          stackTrace: stackTrace,
        );
      }
      return Left(failure.message);
    }
  }

  TripDataEntity _mapToEntity(TripDataModel model) {
    return TripDataEntity(
      destination: model.destination,
      days: model.days.map(_mapDayToEntity).toList(),
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
      activities: model.activities.map(_mapActivityToEntity).toList(),
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
}
