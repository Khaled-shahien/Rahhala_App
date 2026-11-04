import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/errors/error_model.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';
import 'package:rahhala_app/features/trip_history/domain/trip_history_repository.dart';

class TripHistoryRepositoryImpl implements TripHistoryRepository {
  TripHistoryRepositoryImpl({required ApiConsumer api}) : _api = api;

  final ApiConsumer _api;

  @override
  Future<Either<Failure, TripHistoryResponse>> getMyTrips() {
    return _request(
      call: () => _api.get(EndPoints.myTrips),
      parse: TripHistoryResponse.fromJson,
      fallbackMessage: AppMessages.current.errorTripsLoadFailed,
      operation: 'getMyTrips',
    );
  }

  @override
  Future<Either<Failure, TripHistoryDetailResponse>> getTripById(
    String tripId,
  ) {
    return _request(
      call: () => _api.get(EndPoints.myTripById(tripId)),
      parse: TripHistoryDetailResponse.fromJson,
      fallbackMessage: AppMessages.current.errorTripDetailsLoadFailed,
      operation: 'getTripById',
    );
  }

  @override
  Future<Either<Failure, TripHistoryDetailResponse>> regenerateTripPlan(
    String tripId,
    String destination,
    int numberOfDays,
    String budget,
    List<String> interests,
    String season,
  ) async {
    final currentTripResult = await getTripById(tripId);
    return currentTripResult.fold(
      (failure) async => Left(failure),
      (currentTrip) {
        final trip = currentTrip.trip;
        final requestBody = {
          'success': true,
          'tripData': {
            'destination': trip.destination,
            'days': trip.days
                .map((day) => {
                      'day': day.day,
                      'title': day.title,
                      'estimatedDayCost': day.estimatedDayCost,
                      'activities': day.activities
                          .map((activity) => {
                                'time': activity.time,
                                'place': activity.place,
                                'coordinates': activity.coordinates,
                                'description': activity.description,
                                'estimatedCost': activity.estimatedCost,
                                'image': activity.image,
                                'transportation': activity.transportation
                                    .map((transport) => transport.toJson())
                                    .toList(),
                              })
                          .toList(),
                    })
                .toList(),
            'totalEstimatedCost': trip.totalEstimatedCost,
            'budgetTips': trip.budgetTips,
            'travelTips': trip.travelTips,
            'emergencycontact': trip.emergencyContact,
            'tripId': tripId,
          },
          'geminiRequest': {
            'country': destination,
            'numberOfDays': numberOfDays,
            'budget': budget,
            'interestTypes': interests,
            'season': season,
          },
        };

        return _request(
          call: () => _api.post(EndPoints.regenerateTrip, data: requestBody),
          parse: TripHistoryDetailResponse.fromJson,
          fallbackMessage: AppMessages.current.errorTripRegenerateFailed,
          operation: 'regenerateTripPlan',
        );
      },
    );
  }

  /// Runs [call], checks the backend's `success` flag and parses the body.
  /// Every error becomes a typed [Failure] with a user-safe message.
  Future<Either<Failure, T>> _request<T>({
    required Future<dynamic> Function() call,
    required T Function(Map<String, dynamic>) parse,
    required String fallbackMessage,
    required String operation,
  }) async {
    try {
      final response = await call();
      final decoded = response is String ? jsonDecode(response) : response;
      if (decoded is! Map) {
        return Left(ServerFailure(
          message: fallbackMessage,
          type: FailureType.parsing,
        ));
      }
      final data = Map<String, dynamic>.from(decoded);

      if (data['success'] == true) {
        return Right(parse(data));
      }
      return Left(ServerFailure(
        message: ErrorModel.extractServerMessage(data) ?? fallbackMessage,
      ));
    } catch (e, stackTrace) {
      final failure = failureFromError(e);
      if (failure.type == FailureType.parsing ||
          failure.type == FailureType.unknown) {
        AppErrorReporter.record(
          'TripHistoryRepository.$operation failed',
          error: e,
          stackTrace: stackTrace,
        );
        return Left(
            ServerFailure(message: fallbackMessage, type: failure.type));
      }
      return Left(failure);
    }
  }
}
