// lib/features/custom_trip/domain/usecases/generate_trip_plan_usecase.dart

import 'package:dartz/dartz.dart';
import '../entities/trip_data_entity.dart';
import '../repositories/trip_repository_interface.dart';

class GenerateTripPlanUsecase {
  final TripRepositoryInterface repository;

  GenerateTripPlanUsecase(this.repository);

  Future<Either<String, TripDataEntity>> call({
    required String region,
    required int numberOfDays,
  }) async {
    return await repository.generateTripPlan(
      region: region,
      numberOfDays: numberOfDays,
    );
  }
}
