import 'package:rahhala_app/features/nearby/data/models/nearby_response_model.dart';

abstract class NearbyRepository {
  Future<NearbyResponseModel> getNearbyPlaces({
    required double latitude,
    required double longitude,
  });
}
