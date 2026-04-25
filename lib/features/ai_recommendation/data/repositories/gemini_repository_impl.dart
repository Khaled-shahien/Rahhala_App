import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
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
              } else if (cleanResponse[i] == '}') {
                openBraces--;
              } else if (cleanResponse[i] == '[') {
                openBrackets++;
              } else if (cleanResponse[i] == ']') {
                openBrackets--;
              }
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
              AppLogger.instance.e(
                'GeminiRepository.getTripPlan failed to parse cleaned JSON',
                error: parseError,
              );
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
            'countryImage': tripPlan.response.countryImage,
            'days': tripPlan.response.days.map((day) {
              return {
                'day': day.day,
                'title': day.title,
                'estimatedDayCost': day.estimatedDayCost,
                'activities': day.activities.map((activity) {
                  return {
                    'time': activity.time,
                    'place': activity.place,
                    'coordinates': activity.coordinates,
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
                    'image': activity.image,
                  };
                }).toList(),
              };
            }).toList(),
            'totalEstimatedCost': tripPlan.response.totalEstimatedCost,
            'budgetTips': tripPlan.response.budgetTips,
            'travelTips': tripPlan.response.travelTips,
            'emergencycontact': tripPlan.response.emergencyContact,
            'tripId': tripPlan.tripId ?? '00000000-0000-0000-0000-000000000000',
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

      // Validate the response structure
      if (jsonResponse['success'] == true && jsonResponse['tripId'] != null) {
        return Right(jsonResponse);
      } else {
        return Left(ServerFailure(
          message: jsonResponse['message']?.toString() ?? 'Failed to save trip',
        ));
      }
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
  Future<Either<Failure, Map<String, dynamic>>> regenerateTripPlan(
    Map<String, dynamic> requestBody,
  ) async {
    try {
      const String regenerateEndpoint = '/api/gemini/Regenerate_Trip';

      final response = await apiConsumer.post(
        regenerateEndpoint,
        data: requestBody,
      );

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        return Left(ServerFailure(message: "Unexpected response format"));
      }

      // Validate the response structure
      if (jsonResponse['success'] == true && jsonResponse['tripData'] != null) {
        return Right(jsonResponse);
      } else {
        return Left(ServerFailure(
          message: jsonResponse['message']?.toString() ??
              'Failed to regenerate trip',
        ));
      }
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
