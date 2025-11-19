

import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';

abstract class GeminiRepository {
  Future<Either<Failure, TripPlanResponse>> getTripPlan({
    required String region,
    required int numberOfDays,
    required String budget, 
    required List<String> interestTypes,
    required String travelMonth,
  });
}
