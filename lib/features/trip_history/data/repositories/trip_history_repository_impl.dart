import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';
import 'package:rahhala_app/features/trip_history/domain/trip_history_repository.dart';

class TripHistoryRepositoryImpl implements TripHistoryRepository {
  final Dio dio;

  TripHistoryRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, TripHistoryResponse>> getMyTrips() async {
    try {
      final response = await dio.get(
        EndPoints.myTrips,
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (data['success'] == true) {
        return Right(TripHistoryResponse.fromJson(data));
      }

      return Left(
          ServerFailure(message: data['message'] ?? 'Something went wrong'));
    } catch (e) {
      AppErrorReporter.record(
        'TripHistoryRepository.getMyTrips failed',
        error: e,
      );
      return Left(ServerFailure(message: 'Failed to load trips'));
    }
  }

  @override
  Future<Either<Failure, TripHistoryDetailResponse>> getTripById(
      String tripId) async {
    try {
      final response = await dio.get(
        EndPoints.myTripById(tripId),
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (data['success'] == true) {
        return Right(TripHistoryDetailResponse.fromJson(data));
      }

      return Left(
          ServerFailure(message: data['message'] ?? 'Something went wrong'));
    } catch (e) {
      AppLogger.instance
          .e('TripHistoryRepository.getTripById failed', error: e);
      return Left(ServerFailure(message: 'Failed to load trip details'));
    }
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
    try {
      // First, get the current trip data
      final getTripResult = await getTripById(tripId);

      return await getTripResult.fold(
        (failure) async => Left(failure),
        (currentTrip) async {
          try {
            // Prepare the request body with current trip data
            final requestBody = {
              'success': true,
              'tripData': {
                'destination': currentTrip.trip.destination,
                'days': currentTrip.trip.days
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
                'totalEstimatedCost': currentTrip.trip.totalEstimatedCost,
                'budgetTips': currentTrip.trip.budgetTips,
                'travelTips': currentTrip.trip.travelTips,
                'emergencycontact': currentTrip.trip.emergencyContact,
                'tripId': tripId,
              },
              'geminiRequest': {
                'country': destination,
                'numberOfDays': numberOfDays,
                'budget': budget,
                'interestTypes': interests,
                'season': season,
              }
            };

            final response = await dio.post(
              EndPoints.regenerateTrip,
              data: requestBody,
            );

            final data = response.data is String
                ? jsonDecode(response.data)
                : response.data;

            if (data['success'] == true) {
              return Right(TripHistoryDetailResponse.fromJson(data));
            }

            return Left(ServerFailure(
                message: data['message'] ?? 'Failed to regenerate trip'));
          } catch (e) {
            AppErrorReporter.record(
              'TripHistoryRepository.regenerateTripPlan inner failed',
              error: e,
            );
            return Left(ServerFailure(message: 'Failed to regenerate trip'));
          }
        },
      );
    } catch (e) {
      AppErrorReporter.record(
        'TripHistoryRepository.regenerateTripPlan failed',
        error: e,
      );
      return Left(ServerFailure(message: 'Failed to regenerate trip'));
    }
  }
}
