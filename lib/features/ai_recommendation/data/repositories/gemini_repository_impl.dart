

import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';

class GeminiRepositoryImpl implements GeminiRepository {
  final ApiConsumer apiConsumer;

  GeminiRepositoryImpl({required this.apiConsumer});

  @override
  Future<Either<Failure, TripPlanResponse>> getTripPlan({
    required String region,
    required int numberOfDays,
    required String budget, 
    required List<String> interestTypes,
    required String travelMonth,
  }) async {
    try {
      final response = await apiConsumer.post(
        EndPoints.askGemini,
        data: {
          "Region": region,
          "NumberOfDays": numberOfDays,
          "Budget": budget, 
          "InterestTypes": interestTypes,
          "TravelMonth": travelMonth,
        },
      );

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        return Left(ServerFailure(message: "Unexpected response format"));
      }

      final tripResponse = TripPlanResponse.fromJson(jsonResponse);
      return Right(tripResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    } on FormatException catch (e) {
      return Left(ServerFailure(
          message: "Error parsing server response: ${e.message}"));
    } on TypeError catch (e) {
      return Left(ServerFailure(message: "Error interpreting server data: $e"));
    } catch (e) {
      return Left(
          ServerFailure(message: "An unknown error occurred: ${e.toString()}"));
    }
  }
}
