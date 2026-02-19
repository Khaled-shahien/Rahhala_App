import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/ask_gemini_request.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';

class GeminiRepositoryImpl implements GeminiRepository {
  final ApiConsumer apiConsumer;

  GeminiRepositoryImpl({required this.apiConsumer});

  @override
  Future<Either<Failure, TripPlanResponse>> getTripPlan({
    required String country,
    required int numberOfDays,
    required String budget,
    required List<String> interestTypes,
    required String season,
  }) async {
    try {
      // Create the request model
      final request = AskGeminiRequest(
        country: country,
        numberOfDays: numberOfDays,
        budget: budget,
        interestTypes: interestTypes,
        season: season,
      );

      final response = await apiConsumer.post(
        EndPoints.askGemini,
        data: request.toJson(),
      );

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        try {
          // Attempt to parse the JSON response
          jsonResponse = jsonDecode(response);
        } on FormatException catch (e) {
          // Handle potentially malformed JSON by attempting to fix common issues
          String cleanResponse = response.trim();

          // Ensure JSON is properly closed
          if (!cleanResponse.endsWith('}') && !cleanResponse.endsWith(']')) {
            // Try to close any open objects or arrays
            int openBraces = 0;
            int openBrackets = 0;

            for (int i = 0; i < cleanResponse.length; i++) {
              if (cleanResponse[i] == '{') {
                openBraces++;
              } else if (cleanResponse[i] == '}')
                openBraces--;
              else if (cleanResponse[i] == '[')
                openBrackets++;
              else if (cleanResponse[i] == ']') openBrackets--;
            }

            // Close any unclosed structures
            while (openBraces > 0) {
              cleanResponse += '}';
              openBraces--;
            }
            while (openBrackets > 0) {
              cleanResponse += ']';
              openBrackets--;
            }

            try {
              jsonResponse = jsonDecode(cleanResponse);
            } catch (parseError) {
              print("Failed to parse JSON after cleanup: $parseError");
              print("Original response: $response");
              return Left(ServerFailure(
                  message:
                      "Failed to parse server response: ${parseError.toString()}"));
            }
          } else {
            return Left(ServerFailure(
                message: "Error parsing server response: ${e.message}"));
          }
        }
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveTripPlan({
    required TripPlanResponse tripPlan,
    required Map<String, dynamic> geminiRequest,
  }) async {
    try {
      // Send the entire trip plan response as the request body
      final response = await apiConsumer.post(
        EndPoints.saveTrip,
        data: {
          'success': tripPlan.success,
          'tripData': {
            'destination': tripPlan.response.destination,
            'days': tripPlan.response.days.map((day) {
              return {
                'day': day.day,
                'title': day.title,
                'estimatedDayCost': day.estimatedDayCost,
                'activities': day.activities.map((activity) {
                  return {
                    'time': activity.time,
                    'place': activity.place,
                    'description': activity.description,
                    'estimatedCost': activity.estimatedCost,
                    'transportation': activity.transportation.map((transport) {
                      return {
                        'from': transport.from,
                        'to': transport.to,
                        'method': transport.method,
                        'estimatedCost': transport.estimatedCost,
                      };
                    }).toList(),
                  };
                }).toList(),
              };
            }).toList(),
            'totalEstimatedCost': tripPlan.response.totalEstimatedCost,
            'budgetTips': tripPlan.response.budgetTips,
            'travelTips': tripPlan.response.travelTips,
            'tripId': '00000000-0000-0000-0000-000000000000', // Default tripId
          },
          'geminiRequest': geminiRequest,
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

      return Right(jsonResponse);
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
