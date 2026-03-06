// lib/features/custom_trip/data/sources/trip_api_service.dart

import 'package:dio/dio.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import '../models/trip_data_model.dart';

class TripApiService {
  final Dio dio;

  TripApiService({required this.dio});

  Future<TripDataModel> generateTripPlan({
    required String region,
    required int numberOfDays,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.generateSpecificPlan,
        data: {
          'region': region,
          'numberOfDays': numberOfDays,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        // Handle the response structure
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true &&
              responseData['tripData'] != null) {
            return TripDataModel.fromJson(responseData['tripData']);
          } else {
            throw Exception(
                responseData['message'] ?? 'Failed to generate trip plan');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Please check your internet.');
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Response timeout. Please try again.');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${error.response?.statusCode}');
      case DioExceptionType.connectionError:
        return Exception('No internet connection');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error occurred');
    }
  }
}
