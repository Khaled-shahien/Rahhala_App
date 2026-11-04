import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import '../datasource/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HomeResponse> getHomePlaces({int page = 1, int pageSize = 8}) async {
    return await remoteDataSource.getHomePlaces(page: page, pageSize: pageSize);
  }

  @override
  Future<List<PlaceModel>> getHomePlacesList() async {
    final response = await remoteDataSource.getHomePlaces();
    return response.places;
  }

  @override
  Future<List<FavouriteModel>> getFavourites() async {
    return await remoteDataSource.getFavourites();
  }

  @override
  Future<void> addFavourite(String placeId) async {
    await remoteDataSource.addFavourite(placeId);
  }

  @override
  Future<void> removeFavourite(String placeId) async {
    await remoteDataSource.removeFavourite(placeId);
  }

  @override
  Future<PlaceDetailsModel> getPlaceDetails(String id) async {
    return await remoteDataSource.getPlaceDetails(id);
  }

  @override
  Future<void> addReview(String placeId, ReviewRequest reviewRequest) async {
    await remoteDataSource.addReview(placeId, reviewRequest);
  }

  @override
  Future<void> updateReview(
      String reviewId, ReviewRequest reviewRequest) async {
    await remoteDataSource.updateReview(reviewId, reviewRequest);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await remoteDataSource.deleteReview(reviewId);
  }
}
