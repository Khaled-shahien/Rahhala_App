import '../../data/models/home_model.dart';

abstract class HomeRepository {
  Future<List<PlaceModel>> getHomePlaces();
  Future<List<FavouriteModel>> getFavourites();
  Future<void> addFavourite(String placeId);
  Future<void> removeFavourite(String placeId);

  Future<PlaceDetailsModel> getPlaceDetails(String id);
  Future<void> addReview(String placeId, ReviewRequest reviewRequest);
  Future<void> updateReview(String reviewId, ReviewRequest reviewRequest);
  Future<void> deleteReview(String reviewId);
}
