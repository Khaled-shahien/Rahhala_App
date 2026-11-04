import 'package:rahhala_app/features/home/domain/entities/home_entities.dart';

abstract class HomeRepository {
  Future<HomeResponse> getHomePlaces({int page = 1, int pageSize = 8});
  Future<List<PlaceModel>> getHomePlacesList();
  Future<List<FavouriteModel>> getFavourites();
  Future<void> addFavourite(String placeId);
  Future<void> removeFavourite(String placeId);
  Future<PlaceDetailsModel> getPlaceDetails(String id);
  Future<void> addReview(String placeId, ReviewRequest reviewRequest);
  Future<void> updateReview(String reviewId, ReviewRequest reviewRequest);
  Future<void> deleteReview(String reviewId);
}
