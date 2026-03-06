// lib/features/custom_trip/domain/repositories/trip_repository_interface.dart

import 'package:dartz/dartz.dart';
import '../entities/trip_data_entity.dart';

abstract class TripRepositoryInterface {
  Future<Either<String, TripDataEntity>> generateTripPlan({
    required String region,
    required int numberOfDays,
  });
}
