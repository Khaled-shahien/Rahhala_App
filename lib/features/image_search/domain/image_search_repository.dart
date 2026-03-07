import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/image_search/data/models/image_search_model.dart';

abstract class ImageSearchRepository {
  Future<Either<Failure, ImageSearchResponse>> searchByImage(String imagePath);
}
