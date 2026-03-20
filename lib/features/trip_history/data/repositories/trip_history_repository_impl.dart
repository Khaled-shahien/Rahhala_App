import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';
import 'package:rahhala_app/features/trip_history/domain/trip_history_repository.dart';

class TripHistoryRepositoryImpl implements TripHistoryRepository {
  final Dio dio;

  TripHistoryRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, TripHistoryResponse>> getMyTrips() async {
    try {
      final response = await dio.get(
        '/api/gemini/My_Trips',
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (data['success'] == true) {
        return Right(TripHistoryResponse.fromJson(data));
      }

      return Left(
          ServerFailure(message: data['message'] ?? 'Something went wrong'));
    } catch (e) {
      print('TripHistory error: $e');
      return Left(ServerFailure(message: 'Failed to load trips'));
    }
  }

  @override
  Future<Either<Failure, TripHistoryDetailResponse>> getTripById(
      String tripId) async {
    try {
      final response = await dio.get(
        '/api/gemini/My_Trips/$tripId',
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (data['success'] == true) {
        return Right(TripHistoryDetailResponse.fromJson(data));
      }

      return Left(
          ServerFailure(message: data['message'] ?? 'Something went wrong'));
    } catch (e) {
      print('TripHistory detail error: $e');
      return Left(ServerFailure(message: 'Failed to load trip details'));
    }
  }
}
