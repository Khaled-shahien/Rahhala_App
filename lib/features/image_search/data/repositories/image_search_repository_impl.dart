import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/image_search/data/models/image_search_model.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';

class ImageSearchRepositoryImpl implements ImageSearchRepository {
  final Dio dio;

  ImageSearchRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, ImageSearchResponse>> searchByImage(
      String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imagePath, filename: 'photo.jpg'),
      });

      final response = await dio.post(
        EndPoints.imageSearch,
        data: formData,
      );

      AppLogger.instance.d(
        'ImageSearchRepository.searchByImage response type: '
        '${response.data.runtimeType}',
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (data['success'] == true) {
        return Right(ImageSearchResponse.fromJson(data));
      }

      return Left(ServerFailure(
        message: data['message'] ?? 'Something went wrong',
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search by image'));
    }
  }
}
