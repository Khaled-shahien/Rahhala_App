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

      final decoded =
          response.data is String ? jsonDecode(response.data) : response.data;
      final data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      if (data['success'] == true) {
        return Right(ImageSearchResponse.fromJson(data));
      }

      return Left(ServerFailure(
        message: data['message'] ?? 'Something went wrong',
      ));
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final message = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Image search is unavailable right now. Please try again later.';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Could not search with this image. Please try another photo.',
      ));
    }
  }
}
