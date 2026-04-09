import '../../data/models/home_model.dart';

abstract class HomeRepository {
  Future<List<PlaceModel>> getHomePlaces();

  Future<PlaceDetailsModel> getPlaceDetails(String id);
  Future<void> addReview(String placeId, ReviewRequest reviewRequest);
}
