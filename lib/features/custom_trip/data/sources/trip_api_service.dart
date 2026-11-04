import 'package:dio/dio.dart';
import 'package:rahhala_app/core/errors/error_model.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import '../models/trip_data_model.dart';

class TripApiService {
  final Dio dio;

  TripApiService({required this.dio});

  /// Generates a plan for [region]. Throws [ServerException] with a typed,
  /// localized message on any failure.
  Future<TripDataModel> generateTripPlan({
    required String region,
    required int numberOfDays,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        EndPoints.generateSpecificPlan,
        data: {
          'region': region,
          'numberOfDays': numberOfDays,
        },
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw ServerException(
          errorModel: ErrorModel(
            message: AppMessages.current.errorParsing,
            type: FailureType.parsing,
          ),
        );
      }

      final tripData = responseData['tripData'];
      if (responseData['success'] == true && tripData is Map<String, dynamic>) {
        return TripDataModel.fromJson(tripData);
      }

      throw ServerException(
        errorModel: ErrorModel(
          message: ErrorModel.extractServerMessage(responseData) ??
              AppMessages.current.errorServer,
        ),
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
