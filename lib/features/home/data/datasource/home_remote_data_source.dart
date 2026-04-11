import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import '../../../../core/network/api_consumer.dart';

abstract class HomeRemoteDataSource {
  Future<List<PlaceModel>> getHomePlaces();
  Future<List<FavouriteModel>> getFavourites();
  Future<void> addFavourite(String placeId);
  Future<void> removeFavourite(String placeId);
  Future<PlaceDetailsModel> getPlaceDetails(String id);
  Future<void> addReview(String placeId, ReviewRequest reviewRequest);
  Future<void> updateReview(String reviewId, ReviewRequest reviewRequest);
  Future<void> deleteReview(String reviewId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiConsumer api;

  HomeRemoteDataSourceImpl({required this.api});

  @override
  Future<List<PlaceModel>> getHomePlaces() async {
    final response = await api.get('/api/Home/GetHome');
    return HomeResponse.fromJson(response).places;
  }

  @override
  Future<List<FavouriteModel>> getFavourites() async {
    final response = await api.get(EndPoints.favourites);
    return FavouritesResponse.fromJson(response).favourites;
  }

  @override
  Future<void> addFavourite(String placeId) async {
    await api.post(EndPoints.favouriteByPlaceId(placeId));
  }

  @override
  Future<void> removeFavourite(String placeId) async {
    await api.delete(EndPoints.favouriteByPlaceId(placeId));
  }

  @override
  Future<PlaceDetailsModel> getPlaceDetails(String id) async {
    final response = await api.get(EndPoints.placeDetails(id));
    return PlaceDetailsResponse.fromJson(response).place;
  }

  @override
  Future<void> addReview(String placeId, ReviewRequest reviewRequest) async {
    await api.post(EndPoints.reviewById(placeId), data: reviewRequest.toJson());
  }

  @override
  Future<void> updateReview(
      String reviewId, ReviewRequest reviewRequest) async {
    await api.put(EndPoints.reviewById(reviewId), data: reviewRequest.toJson());
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await api.delete(EndPoints.reviewById(reviewId));
  }
}
