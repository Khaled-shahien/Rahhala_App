import '../../domain/repositories/home_repository.dart';
import '../datasource/home_remote_data_source.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PlaceModel>> getHomePlaces() async {
    try {
      return await remoteDataSource.getHomePlaces();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PlaceDetailsModel> getPlaceDetails(String id) async {
    try {
      return await remoteDataSource.getPlaceDetails(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addReview(String placeId, ReviewRequest reviewRequest) async {
    return await remoteDataSource.addReview(placeId, reviewRequest);
  }

  @override
  Future<void> updateReview(
      String reviewId, ReviewRequest reviewRequest) async {
    return await remoteDataSource.updateReview(reviewId, reviewRequest);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    return await remoteDataSource.deleteReview(reviewId);
  }
}
