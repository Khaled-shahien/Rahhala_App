import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/errors/error_model.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/image_search/data/models/image_search_model.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';

class ImageSearchRepositoryImpl implements ImageSearchRepository {
  ImageSearchRepositoryImpl({required ApiConsumer api}) : _api = api;

  final ApiConsumer _api;

  @override
  Future<Either<Failure, ImageSearchResponse>> searchByImage(
    String imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imagePath, filename: 'photo.jpg'),
      });

      final response = await _api.post(EndPoints.imageSearch, data: formData);
      final data = _asMap(response);
      if (data == null) {
        return Left(ServerFailure(
          message: AppMessages.current.errorParsing,
          type: FailureType.parsing,
        ));
      }

      if (data['success'] == true) {
        return Right(ImageSearchResponse.fromJson(data));
      }

      return Left(ServerFailure(
        message: ErrorModel.extractServerMessage(data) ??
            AppMessages.current.errorImageSearchFailed,
      ));
    } catch (e, stackTrace) {
      final failure = failureFromError(e);
      if (failure.type == FailureType.parsing ||
          failure.type == FailureType.unknown) {
        AppErrorReporter.record(
          'ImageSearchRepository.searchByImage failed',
          error: e,
          stackTrace: stackTrace,
        );
        return Left(ServerFailure(
          message: AppMessages.current.errorImageSearchFailed,
          type: failure.type,
        ));
      }
      return Left(failure);
    }
  }

  Map<String, dynamic>? _asMap(Object? response) {
    final decoded = response is String ? jsonDecode(response) : response;
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }
}
