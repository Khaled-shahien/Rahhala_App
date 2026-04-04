import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';

abstract class TripHistoryRepository {
  Future<Either<Failure, TripHistoryResponse>> getMyTrips();
  Future<Either<Failure, TripHistoryDetailResponse>> getTripById(String tripId);
  Future<Either<Failure, TripHistoryDetailResponse>> regenerateTripPlan(
    String tripId,
    String destination,
    int numberOfDays,
    String budget,
    List<String> interests,
    String season,
  );
}
